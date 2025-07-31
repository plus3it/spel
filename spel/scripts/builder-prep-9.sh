#!/bin/bash
# shellcheck disable=SC2034,SC2046
#
# Execute AMIGen9 scripts to prepare an EC2 instance for the AMI Create Image
# task.
#
##############################################################################
PROGNAME="$(basename "$0")"
AMIGENREPOS="${SPEL_AMIGENREPOS}"
AMIGENREPOSRC="${SPEL_AMIGENREPOSRC}"
AMIGENSOURCE="${SPEL_AMIGEN9SOURCE:-https://github.com/plus3it/AMIgen9.git}"
EXTRARPMS="${SPEL_EXTRARPMS}"
HTTP_PROXY="${SPEL_HTTP_PROXY}"
USEDEFAULTREPOS="${SPEL_USEDEFAULTREPOS:-true}"


read -r -a BUILDDEPS <<< "${SPEL_BUILDDEPS:-lvm2 yum-utils unzip git dosfstools python3-pip}"

ELBUILD="/tmp/el-build"

# Make interactive-execution more-verbose unless explicitly told not to
if [[ $( tty -s ) -eq 0 ]] && [[ -z ${DEBUG:-} ]]
then
    DEBUG="true"
fi


# Error handler function
function err_exit {
    local ERRSTR
    local ISNUM
    local SCRIPTEXIT

    ERRSTR="${1}"
    ISNUM='^[0-9]+$'
    SCRIPTEXIT="${2:-1}"

    if [[ ${DEBUG} == true ]]
    then
        # Our output channels
        logger -i -t "${PROGNAME}" -p kern.crit -s -- "${ERRSTR}"
    else
        logger -i -t "${PROGNAME}" -p kern.crit -- "${ERRSTR}"
    fi

    # Only exit if requested exit is numerical
    if [[ ${SCRIPTEXIT} =~ ${ISNUM} ]]
    then
        exit "${SCRIPTEXIT}"
    fi
}

# Setup per-builder values
case $( rpm -qf /etc/os-release --qf '%{name}' ) in
    centos-linux-release | centos-stream-release )
        BUILDER=centos-9stream

        DEFAULTREPOS=(
            baseos
            appstream
            extras-common
        )
        ;;
    redhat-release-server|redhat-release)
        BUILDER=rhel-9

        DEFAULTREPOS=(
            rhel-9-appstream-rhui-rpms
            rhel-9-baseos-rhui-rpms
            rhui-client-config-server-9
        )
        ;;
    oraclelinux-release)
        BUILDER=ol-9

        DEFAULTREPOS=(
            ol9_UEKR7
            ol9_appstream
            ol9_baseos_latest
        )
        ;;
    system-release) # Amazon should be shot for this
        BUILDER=amzn-2023

        BASEREPOS=(
            amazonlinux
            kernel-livepatch
        )
        ;;
    *)
        echo "Unknown OS. Aborting" >&2
        exit 1
        ;;
esac
DEFAULTREPOS+=()

# Default to enabling default repos
ENABLEDREPOS=$(IFS=,; echo "${DEFAULTREPOS[*]}")

if [[ "$USEDEFAULTREPOS" != "true" ]]
then
    # Enable AMIGENREPOS exclusively when instructed not to use default repos
    ENABLEDREPOS="${AMIGENREPOS}"
elif [[ -n "${AMIGENREPOS:-}" ]]
then
    # When using default repos, also enable AMIGENREPOS if present
    ENABLEDREPOS+=,"${AMIGENREPOS}"
fi


retry()
{
    # Make an arbitrary number of attempts to execute an arbitrary command,
    # passing it arbitrary parameters. Convenient for working around
    # intermittent errors (which occur often with poor repo mirrors).
    #
    # Returns the exit code of the command.
    local n=0
    local try=$1
    local cmd="${*: 2}"
    local result=1
    [[ $# -le 1 ]] && {
        echo "Usage $0 <number_of_retry_attempts> <Command>"
        exit $result
    }

    echo "Will try $try time(s) :: $cmd"

    if [[ "${SHELLOPTS}" == *":errexit:"* ]]
    then
        set +e
        local ERREXIT=1
    fi

    until [[ $n -ge $try ]]
    do
        sleep $n
        $cmd
        result=$?
        if [[ $result -eq 0 ]]
        then
            break
        else
            ((n++))
            echo "Attempt $n, command failed :: $cmd"
        fi
    done

    if [[ "${ERREXIT}" == "1" ]]
    then
        set -e
    fi

    return $result
}  # ----------  end of function retry  ----------


# Disable strict hostkey checking
function DisableStrictHostCheck {
    local HOSTVAL

    if [[ ${1:-} == '' ]]
    then
        err_exit "No connect-string passed to function [${0}]"
    else
        HOSTVAL="$( sed -e 's/^.*@//' -e 's/:.*$//' <<< "${1}" )"
    fi

    # Git host-target parameters
    err_exit "Disabling SSH's strict hostkey checking for ${HOSTVAL}" NONE
    (
        printf "Host %s\n" "${HOSTVAL}"
        printf "  Hostname %s\n" "${HOSTVAL}"
        printf "  StrictHostKeyChecking off\n"
    ) >> "${HOME}/.ssh/config" || \
    err_exit "Failed disabling SSH's strict hostkey checking"
}



##########################
## Main program section ##
##########################

set -x
set -e
set -o pipefail

# Install supplementary tooling
if [[ ${#BUILDDEPS[@]} -gt 0 ]]
then
    err_exit "Installing build-host dependencies" NONE
    yum -y install "${BUILDDEPS[@]}" || \
        err_exit "Failed installing build-host dependencies"

    err_exit "Verifying build-host dependencies" NONE
    rpm -q "${BUILDDEPS[@]}" || \
        err_exit "Verification failed"
fi

if [[ -n "${HTTP_PROXY:-}" ]]
then
    echo "Setting Git Config Proxy"
    git config --global http.proxy "${HTTP_PROXY}"
    echo "Set git config to use proxy"
fi

if [[ -n "${EPELREPO:-}" ]]
then
    yum-config-manager --enable "$EPELREPO" > /dev/null
fi

echo "Installing custom repo packages in the builder box"
IFS="," read -r -a BUILDER_AMIGENREPOSRC <<< "$AMIGENREPOSRC"
for RPM in "${BUILDER_AMIGENREPOSRC[@]}"
do
    {
        STDERR=$( yum -y install "$RPM" 2>&1 1>&$out );
    } {out}>&1 || echo "$STDERR" | grep "Error: Nothing to do"
done

# Enable any extra repos that have been specified
if [[ -n ${ENABLEDREPOS} ]]
then
    echo "Enabling repos in the builder box"
    yum-config-manager --disable "*" > /dev/null
    yum-config-manager --enable "$ENABLEDREPOS" > /dev/null

    echo "Installing specified extra packages in the builder box"
    IFS="," read -r -a BUILDER_EXTRARPMS <<< "$EXTRARPMS"
    for RPM in "${BUILDER_EXTRARPMS[@]}"
    do
        {
            STDERR=$( yum -y install "$RPM" 2>&1 1>&$out );
        } {out}>&1 || echo "$STDERR" | grep "Error: Nothing to do"
    done
fi

# Disable strict host-key checking when doing git-over-ssh
if [[ ${AMIGENSOURCE} =~ "@" ]]
then
    DisableStrictHostCheck "${AMIGENSOURCE}"
fi
