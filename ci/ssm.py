"""SSM handler."""
import boto3
import yaml

import tasks

SPEL_PATH = "/spel/"


def load_local_parameters():
    """Load parameters from source yaml file."""
    try:
        stream = open('variables.yaml', 'r')
        param_obj = yaml.load(stream)
        return param_obj
    except FileNotFoundError:
        print('variables.yaml file was not found. Make sure it exists and is'
              ' named correctly.')
        exit()


def validate_parameters(param_obj):
    """Validate the paramater object."""
    try:
        for key, var_list in param_obj.items():
            for var in var_list:
                try:
                    if not var['var_name']:
                        print('A variable block in the {} section was found'
                              ' with a blank a var_name'
                              ' declaration'.format(key))
                except KeyError:
                    print('A variable block in the {} section was found'
                          ' without a var_name declaration'.format(key))
                    exit()
                try:
                    if not var['value']:
                        print('A variable block in the {} section was found'
                              ' with a value of None'.format(key))
                except KeyError:
                    print('A variable block in the {} section was found'
                          ' without a value declaration'.format(key))
                    exit()
                try:
                    if var['var_type'] != "SecureString"  \
                            and var['var_type'] != "String":
                            print('A variable block in the {} section was'
                                  ' found with an invalid var_type value:'
                                  ' var_type must be \"String\" '
                                  ' or \"SecureString\" \n'.format(key))
                            print("Found value: {} \nExpected value:"
                                  " \"String\" or \"SecureString\""
                                  "\n".format(var['var_type']))
                            exit()
                except KeyError:
                    print('A variable block in the {} section was found'
                          ' without a var_type declaration'.format(key))
                    exit()
        print("No potential issues found.")
    except KeyError:
        print("variables.yaml is not formatted correctly.")
        raise


def put_parameter(name, value, var_type):
    """Set parameters in ssm."""
    # print("updating var: {}".format(name))
    ssm = boto3.client('ssm')
    ssm.put_parameter(
        Name=name,
        Description='',
        Value=value,
        Type=var_type,
        Overwrite=True
    )


def parse_local_parameters(param_obj, verbose=None):
    """Parse the source parameter object."""
    for key in param_obj:
        for var in param_obj[key]:
            name = "{0}{1}/{2}".format(SPEL_PATH, key, var['var_name'])
            value = var['value']
            var_type = var['var_type']
            if verbose:
                print("Adding parameter:"
                      "\n     Name: {}".format(name) +
                      "\n     Value: {}".format(value) +
                      "\n     Type: {}".format(var_type))
            put_parameter(name, value, var_type)


def get_parameters(client, path, **kwargs):
    """Get SSM parameters."""
    next_token = kwargs.get('next_token', None)
    verbose = kwargs.get('verbose', None)
    if next_token:
        response = client.get_parameters_by_path(
            Path=path,
            Recursive=True,
            WithDecryption=True,
            MaxResults=10,
            NextToken=next_token
        )
        if verbose:
            print("Recieved NextToken with response: {}".format(response))
    else:
        response = client.get_parameters_by_path(
            Path=path,
            Recursive=True,
            WithDecryption=True,
            MaxResults=10
        )
        if verbose:
            print("Recieved response: {}".format(response))
    return response


def get_env_paths():
    """Get environment variable (ssm) paths."""
    environment_paths = []
    for environment in tasks.ENVIRONMENTS:
        environment_paths.append("{0}{1}".format(SPEL_PATH, environment))
    return environment_paths


def get_ssm_path(env):
    """Return the ssm path for an environment."""
    return "{}{}/".format(SPEL_PATH, env)


def get_parameters_by_path(path):
    """Get all parameters."""
    parameters = []
    client = boto3.client('ssm')
    response = get_parameters(client, path)
    parameters += response['Parameters']
    try:
        while response['NextToken']:
            response = get_parameters(client, path,
                                      next_token=response['NextToken'])
            parameters += response['Parameters']
    except KeyError:
        return parameters


def get_all_remote_parameters():
    """Get all variable values."""
    parameters = []
    paths = get_env_paths()
    for path in paths:
        parameters += get_parameters_by_path(path)
    return parameters


def compare_ssm_to_local(verbose=None, target_env=None):
    """Compare variables.yaml file to SSM."""
    ssm_values = get_all_remote_parameters()
    local_values = load_local_parameters()
    # targeted environment search
    if target_env:
        local_values = local_values[target_env]
        ssm_path = "{}{}/".format(SPEL_PATH, target_env)
        for local_variable in local_values:
            for ssm_variable in ssm_values:
                ssm_var_name = ssm_variable['Name'].replace(ssm_path, '')
                if (
                    SPEL_PATH not in ssm_var_name and
                    local_variable['var_name'] == ssm_var_name
                ):
                    if ssm_variable['Value'] != local_variable['value']:
                        print("Local var {} in {}".format(
                              local_variable['var_name'], target_env) +
                              "does not match remote {} ".format(
                              ssm_variable['Name']) +
                              "\nremote value: {} ".format(
                              ssm_variable['Value']) +
                              "\nlocal value: {} \n".format(
                              local_variable['value']))
                    else:
                        if verbose:
                            print("Local var {} in {}".format(
                                  local_variable['var_name'], target_env) +
                                  " matches remote {}".format(
                                  ssm_variable['Name']))
    else:
        # search across all environments
        for env in local_values:
            ssm_path = "{}{}/".format(SPEL_PATH, env)
            for local_variable in local_values[env]:
                for ssm_variable in ssm_values:
                    ssm_var_name = ssm_variable['Name'].replace(ssm_path, '')
                    if (
                        SPEL_PATH not in ssm_var_name and
                        local_variable['var_name'] == ssm_var_name
                    ):
                        if ssm_variable['Value'] != local_variable['value']:
                                print("Local var {} in {}".format(
                                      local_variable['var_name'], env) +
                                      " does not match remote {}".format(
                                        ssm_variable['Name']) +
                                      "\nremote value: {} ".format(
                                        ssm_variable['Value']) +
                                      "\nlocal value: {} ".format(
                                        local_variable['value']) +
                                      "\n")
                        else:
                            if verbose:
                                print("Local var {} in {}".format(
                                      local_variable['var_name'], env) +
                                      " matches remote {}".format(
                                      ssm_variable['Name']))
                    else:
                        continue


def local_parameter_check():
    """Validate local variables.yaml file."""
    param_obj = load_local_parameters()
    validate_parameters(param_obj)


def set_remote_variables_from_file(verbose=None):
    """Set variable values from a local file."""
    param_obj = load_local_parameters()
    validate_parameters(param_obj)
    parse_local_parameters(param_obj, verbose=verbose)


def set_remote_variables_from_obj(input_obj, verbose=None):
    """Set variable values from an input object"""
    validate_parameters(input_obj)
    parse_local_parameters(input_obj, verbose=verbose)


def get_targeted_variables(env):
    """Get variables for targeted environment."""
    variables = {}
    ssm_path = get_ssm_path(env)
    parameters = get_parameters_by_path(ssm_path)
    for tf_var in parameters:
        if tf_var['Name']:
            variables[tf_var['Name'].replace(ssm_path, '')] = (
              tf_var['Value'])
    return variables
