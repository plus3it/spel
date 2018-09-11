"""Deploys SPEL terraform projects."""

import os

import python_terraform
import s3
import ssm
from invoke import task

ENVIRONMENTS = []

ZONES = [
    "commercial",
    "govcloud"
]

PROJECT_STAGES = [
    "ci",
    "rc",
    "official"
]

for stage in PROJECT_STAGES:
    for zone in ZONES:
        ENVIRONMENTS.append("{}_{}".format(zone, stage))


def env_check(build_env):
    """validate provided environment exists within the global
    ENVIRONMENTS variable."""
    if build_env not in ENVIRONMENTS:
        print("\nERROR: the supplied build environment"
              " \"{}\"".format(build_env) +
              " does not exist. Exiting..\n")
        exit()


def get_directory(env):
    """Get the tf project directory."""
    return (os.getcwd() + "/environments/" + env)


def get_tf_handler(build_env, sub_dir=None):
    """return tf handler."""
    directory = get_directory(build_env)
    if sub_dir:
        directory = "{}/{}".format(directory, sub_dir)
    return python_terraform.Terraform(directory)


def tf_init(tf, backend_config=None, verbose=False):
    """Initialize target terraform project."""
    if verbose and backend_config:
        print('\ntf_init: passing the following backend config:'
              ' {}\n'.format(backend_config))
        tf.init(capture_output='True', backend_config=backend_config)
    elif verbose and not backend_config:
        print("\nRunning `terraform init`\n")
        tf.init(capture_output='True')
    else:
        tf.init(backend_config=backend_config)


# ################################
#
# remote state backend specifics
#
##################################


def get_backend_config(build_env, terraform_output):
    """Returns ssm readble object provided terraform output object"""
    try:
        return {
            build_env: [
                {
                    "var_name": "dynamodb_table",
                    "value": terraform_output['dynamodb_table_name']['value'],
                    "var_type": "String",
                },
                {
                    "var_name": "bucket",
                    "value": terraform_output['s3_bucket_id']['value'],
                    "var_type": "String",
                },
            ]
        }
    except KeyError:
        print('\nERROR: Terraform output did not contain the expected '
              'key/value pair(s).. Exiting.. \n')
        exit()
    except TypeError:
        print('\nERROR: Terraform output did not contain the expected '
              'key/value pair(s).. Exiting.. \n')
        exit()


def backend_apply(tf, build_env, stage, verbose=False):
    """Run terraform apply on the S3 backend."""
    tf_vars = {
        "project_name": build_env,
        "stage": stage
    }
    if verbose:
        print('\nRunning `terraform apply` against the backed for '
              '{}\n'.format(build_env))
        tf.apply(skip_plan=True, capture_output='True',
                 var=tf_vars)
    else:
        tf.apply(skip_plan=True, var=tf_vars)


def get_backend_bucket(build_env):
    """Return the name of the backend bucket that is stored in SSM."""
    ssm_obj = ssm.get_targeted_variables(build_env)
    return ssm_obj['bucket']


def backend_destroy(tf, build_env, stage, verbose=False):
    """Run terraform destroy on the S3 backend."""
    tf_vars = {
        "project_name": build_env,
        "stage": stage
    }
    if verbose:
        print('\nEmptying the backend S3 bucket.\n')
        s3.delete_all_objects(get_backend_bucket(build_env),
                              verbose=verbose)
        print('\nRunning `terraform destroy` against the backed for '
              '{}\n'.format(build_env))
        tf.destroy(vars=tf_vars, capture_output='True', lock='false')
    else:
        s3.delete_all_objects(get_backend_bucket(build_env))
        tf.destroy(vars=tf_vars, lock='false')


def backend_plan(tf, build_env, stage, verbose=False):
    """Run terraform plan on the S3 backend."""
    tf_vars = {
        "project_name": build_env,
        "stage": stage
    }
    if verbose:
        print('\nRunning `terraform plan` against the backed for '
              '{}\n'.format(build_env))
        tf.plan(vars=tf_vars, capture_output='True', lock='false')
    else:
        tf.plan(vars=tf_vars, lock='false')


def backend_create(tf, build_env, stage, verbose=False):
    """Initilalize and apply the remote state backend.
       Also sets output of remote state as variables within SSM.
    """
    tf_init(tf, verbose=verbose)
    backend_apply(tf, build_env, stage, verbose)
    ssm.set_remote_variables_from_obj(
        get_backend_config(build_env, tf.output()), verbose=verbose
    )


@task(optional=['verbose'])
def init_backend(ctx, build_env, verbose=False):
    """Initialize the remote state backend."""
    env_check(build_env)
    tf = get_tf_handler(build_env, "backend_init")
    tf_init(tf, verbose=verbose)


@task(optional=['stage', 'verbose'])
def apply_backend(ctx, build_env, stage="test", verbose=False):
    """Apply the remote state backend."""
    env_check(build_env)
    tf = get_tf_handler(build_env, "backend_init")
    apply_backend(tf, build_env=build_env, stage=stage, verbose=verbose)


@task(optional=['stage', 'verbose'])
def plan_backend(ctx, build_env, stage="test", verbose=False):
    """Apply the remote state backend."""
    env_check(build_env)
    tf = get_tf_handler(build_env, "backend_init")
    plan_backend(tf, build_env=build_env, stage=stage, verbose=verbose)


@task(optional=['stage', 'verbose'])
def create_backend(ctx, build_env, stage="test", verbose=False):
    """Initialize and apply the backend."""
    env_check(build_env)
    tf = get_tf_handler(build_env, "backend_init")
    backend_create(tf, build_env=build_env, stage=stage, verbose=verbose)


@task(optional=['stage', 'verbose'])
def destroy_backend(ctx, build_env, stage="test", verbose=False):
    """Apply the remote state backend."""
    env_check(build_env)
    tf = get_tf_handler(build_env, "backend_init")
    backend_destroy(tf, build_env=build_env, stage=stage, verbose=verbose)


# ################################
#
# main module
#
##################################


def get_backend_config_from_ssm(build_env, verbose=False):
    """Return object with backend configuration values."""
    env_check(build_env)
    if verbose:
        print('\nRetrieving backend configuration variables from SSM\n')
    ssm_obj = ssm.get_targeted_variables(build_env)
    try:
        return {
            "bucket": ssm_obj['bucket'],
            "key": "terraform.tfstate",
            "dynamodb_table": ssm_obj['dynamodb_table']
        }
    except KeyError:
        print('\nERROR: key/value not found in SSM. Ensure backend has'
              ' been initilized with `invoke create-backend '
              '--build-env={}`\n'.format(build_env))
        exit()


def env_apply(tf, tf_vars, verbose=False):
    """Apply the target environment."""
    if verbose:
        print('\nRunning `terraform apply` aginst the target codebuild '
              'project\nenv_apply: passing the following vars:'
              ' {}\n'.format(tf_vars))
        tf.apply(skip_plan=True, capture_output='True', vars=tf_vars)
    else:
        tf.apply(skip_plan=True, vars=tf_vars)


def env_destroy(tf, tf_vars, verbose=False):
    """Destroy the target environment."""
    if verbose:
        print('\nRunning `terraform destroy` against the target codebuild '
              'project.\n\ntf_destroy_env: passing the following vars:'
              ' {}\n'.format(tf_vars))
        tf.destroy(capture_output='True', vars=tf_vars, lock=False)
    else:
        tf.destroy(vars=tf_vars, lock=False)


def env_and_backend_destroy(tf_env, tf_backend, build_env, tf_vars,
                            verbose=False):
    """Destroy the target environment and its backend."""
    env_destroy(tf_env, tf_vars, verbose)
    destroy_backend(tf_backend, build_env, stage, verbose)


def env_destroy_all(build_env, include_backend=False, verbose=False):
    """Destroys the target codebuild project."""
    env_check(build_env)
    tf_env = get_tf_handler(build_env)
    tf_vars = ssm.get_targeted_variables(build_env)
    if include_backend:
        tf_backend = get_tf_handler(build_env, "backend_init")
        env_and_backend_destroy(tf_env, tf_backend, build_env, tf_vars,
                                verbose)
    else:
        env_destroy(tf=tf_env, tf_vars=tf_vars, verbose=verbose)


def env_create(build_env, stage, verbose=False):
    """Create the backend and environment."""
    env_check(build_env)
    # initialize terraform-python in the backend directory
    tf_state = get_tf_handler(build_env, "backend_init")
    # create the backend
    backend_create(tf=tf_state, build_env=build_env, stage=stage,
                   verbose=verbose)
    # initialize terraform-python in the main project directory
    tf_env = get_tf_handler(build_env)
    # get the backend configuration from SSM
    backend_config = get_backend_config_from_ssm(build_env, verbose=verbose)
    # initialze the main project's backend
    tf_init(tf=tf_env, backend_config=backend_config, verbose=verbose)
    # get the main project's input variables from ssm
    tf_vars = ssm.get_targeted_variables(build_env)
    # run terraform apply against the main project
    env_apply(tf=tf_env, tf_vars=tf_vars, verbose=verbose)


@task()
def init_env(ctx, build_env, verbose=False):
    """Intialize the target environment via pyinvoke."""
    env_check(build_env)
    tf = get_tf_handler(build_env)
    backend_config = get_backend_config_from_ssm(build_env)
    tf_init(tf, backend_config=backend_config, verbose=verbose)


@task()
def apply_env(ctx, build_env, verbose=False):
    """Apply the target environment via pyinvoke."""
    env_check(build_env)
    tf = get_tf_handler(build_env)
    tf_vars = ssm.get_targeted_variables(build_env)
    env_apply(tf, tf_vars=tf_vars, verbose=verbose)


@task()
def create_env(ctx, build_env, stage, verbose=False):
    """Create the backend and environment via pyinvoke."""
    if build_env == 'all':
        for env in ENVIRONMENTS:
            env_create(env, stage, verbose)
    else:
        env_create(build_env, stage, verbose)


@task()
def destroy_env(ctx, build_env, include_backend=False, verbose=False):
    """Destroys the target codebuild project via pyinvoke."""
    if build_env == 'all':
        for env in ENVIRONMENTS:
            env_destroy_all(env, include_backend, verbose)
    else:
        env_destroy_all(build_env, include_backend, verbose)


# ################################
#
# ssm variables
#
##################################

@task(optional=['validate', 'build_env', 'update', 'verbose'],
      help={"validate": "[Optional] Accepts values of 'local' or 'remote'." +
            " local = validate the file structure of varaiables.yaml " +
            " remote = compare variables.yaml to the vales stored in AWS SSM",
            "env": "[Optional] if provided will target a single environment." +
            " all environments are passed by default.",
            "update": "[Optional] Updates the AWS SSM variable values with " +
            " variables.yaml",
            "verbose": "[Optional] Use this flag to provide output"})
def variables(ctx, build_env=None, update=None, validate=None, verbose=None):
    """Update, view, or validate existing or new ssm variables."""
    if validate == 'local':
        if verbose:
            print("Validating variables.yaml..")
        ssm.local_parameter_check()
    elif validate == 'remote':
        if verbose:
            print("Comparing variables.yaml values to AWS SSM values..")
            if build_env:
                print("Targeting build-env: {}".format(build_env))
        print("\n")
        ssm.compare_ssm_to_local(verbose=verbose, target_env=build_env)
    if update:
        if verbose:
            print("Validating variables.yaml..")
        ssm.set_remote_variables_from_file(verbose=verbose)
