"""Test spel aws ami builds."""
# pylint: disable=missing-function-docstring
import logging

import pytest

log = logging.getLogger("spel_validation")
log.setLevel(logging.INFO)


def test_root_volume_is_resized(host):  # noqa: D103
    cmd = "test $(vgs --noheadings -o pv_free | sed 's/ //g') != 0"
    pv_free = host.run(cmd)
    assert pv_free.exit_status == 0


@pytest.mark.amiutils_enabled
@pytest.mark.parametrize("name", [])
def test_common_amiutils_pkgs(host, name):  # noqa: D103
    pkg = host.package(name)
    if pkg.is_installed:
        log.info(
            "%s", {"pkg": pkg.name, "version": pkg.version, "release": pkg.release}
        )
    assert pkg.is_installed


@pytest.mark.amiutils_enabled
@pytest.mark.el7
@pytest.mark.parametrize(
    "name",
    [
        ("aws-amitools-ec2"),
        ("aws-apitools-as"),
        ("aws-apitools-cfn"),
        ("aws-apitools-common"),
        ("aws-apitools-ec2"),
        ("aws-apitools-elb"),
        ("aws-apitools-iam"),
        ("aws-apitools-mon"),
        ("aws-apitools-rds"),
        ("aws-cfn-bootstrap"),
        ("aws-scripts-ses"),
    ],
)
def test_el7_amiutils_pkgs(host, name):  # noqa: D103
    pkg = host.package(name)
    if pkg.is_installed:
        log.info(
            "%s", {"pkg": pkg.name, "version": pkg.version, "release": pkg.release}
        )
    assert pkg.is_installed


def test_aws_cli_is_in_path(host):  # noqa: D103
    cmd = "aws --version"
    aws = host.run(cmd)
    log.info("\n%s", aws.stderr)
    assert host.exists("aws")


def test_repo_access(host):  # noqa: D103
    cmd = "yum -y repolist all | sed -n '/^repo id/,$p'"
    repos = host.run(cmd)
    log.info("stdout:\n%s", repos.stdout)
    log.info("stderr:\n%s", repos.stderr)
    assert repos.exit_status == 0
    assert "Errno" not in repos.stderr


@pytest.mark.el7
def test_boot_is_mounted(host):  # noqa: D103
    boot = host.mount_point("/boot")
    assert boot.exists


def test_tmp_mount_properties(host):  # noqa: D103
    tmp = host.mount_point("/tmp")
    assert tmp.exists
    assert tmp.device == "tmpfs"
    assert tmp.filesystem == "tmpfs"


def test_el7_selinux_enforcing(host):  # noqa: D103
    cmd = "test $(getenforce) = 'Enforcing'"
    selinux_permissive = host.run(cmd)
    assert selinux_permissive.exit_status == 0


@pytest.mark.fips_enabled
def test_fips_enabled(host):  # noqa: D103
    fips = host.file("/proc/sys/crypto/fips_enabled")
    assert fips.exists and fips.content.strip() == b"1"


@pytest.mark.fips_disabled
def test_fips_disabled(host):  # noqa: D103
    fips = host.file("/proc/sys/crypto/fips_enabled")
    assert not fips.exists or fips.content.strip() == b"0"


@pytest.mark.parametrize(
    "names",
    [
        (
            [
                "python3",
                "python36",
                "python38",
                "python39",
            ]
        )
    ],
)
def test_python3_installed(host, names):  # noqa: D103
    pkg = type("pkg", (object,), {"is_installed": False})
    for name in names:
        pkg = host.package(name)
        if pkg.is_installed:
            break

    assert pkg.is_installed
    log.info("%s", {"pkg": pkg.name, "version": pkg.version, "release": pkg.release})


@pytest.mark.parametrize(
    "realpaths,link",
    [
        (
            (
                "/usr/bin/python3.6",
                "/usr/libexec/platform-python3.6",
                "/usr/bin/python3.8",
                "/usr/bin/python3.9",
            ),
            "/usr/bin/python3",
        )
    ],
)
def test_python3_symlink(host, realpaths, link):  # noqa: D103
    python3_symlink = host.file(link).linked_to
    assert python3_symlink in realpaths


@pytest.mark.parametrize("versions", [(["3.6", "3.8", "3.9"])])
def test_python3_version(host, versions):  # noqa: D103
    cmd = "python3 --version"
    python3_version = host.run(cmd)
    log.info("`%s` stdout: %s", cmd, python3_version.stdout)
    log.info("`%s` stderr: %s", cmd, python3_version.stderr)

    assert python3_version.exit_status == 0

    # Example stdout content: 'Python 3.6.8'
    version = python3_version.stdout.strip().split()[1]

    major_minor = ".".join(version.split(".")[:2])
    assert major_minor in versions


def test_timedatectl_dbus_status(host):  # noqa: D103
    cmd = "timedatectl"
    timedatectl = host.run(cmd)
    log.info("stdout:\n%s", timedatectl.stdout)
    log.info("stderr:\n%s", timedatectl.stderr)
    assert timedatectl.exit_status == 0


def test_var_run_symlink(host):  # noqa: D103
    var_run_symlink = host.file("/var/run").linked_to
    assert var_run_symlink == "/run"


@pytest.mark.parametrize(
    "service",
    [
        ("amazon-ssm-agent.service"),
    ],
)
def test_systemd_services(host, service):  # noqa: D103
    chk_service = host.service(service)
    assert chk_service.is_enabled


@pytest.mark.parametrize(
    "name",
    [
        ("spel-release"),
        ("amazon-ssm-agent"),
        ("ec2-hibinit-agent"),
        ("ec2-net-utils"),
    ],
)
def test_spel_packages(host, name):  # noqa: D103
    pkg = host.package(name)
    if pkg.is_installed:
        log.info(
            "%s", {"pkg": pkg.name, "version": pkg.version, "release": pkg.release}
        )
    assert pkg.is_installed


def test_cfn_bootstrap(host):  # noqa: D103
    cmd = "python3 -m pip show aws-cfn-bootstrap"
    cfnbootstrap = host.run(cmd)
    log.info("stdout:\n%s", cfnbootstrap.stdout)
    log.info("stderr:\n%s", cfnbootstrap.stderr)
    assert cfnbootstrap.exit_status == 0
    assert "Version: 2.0" in cfnbootstrap.stdout
