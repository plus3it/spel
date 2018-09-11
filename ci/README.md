# SSM-Terraform

This project is designed to automate the deployment of all spel codebuild projects across both Commercial and GovCloud AWS environments.

## Overview

At it's core this project is simply a wrapper for terraform.

It leverages `python_terraform`, `boto3`, and `pyinvoke` in an attempt to enhance ease of use and reduce deployment friction.

Terraform variables can be defined per project ( under the `/environments/` directory of this project ) with a `terraform.tfvars` file, or they can be called at `terraform apply` from the SSM parameter store.

Parameter store variable values can be manipulated by using a `yaml` based template who's structure is outlined below.

Currently only remote state is supported.

## Prerequisites

- Python 3.6+
- A `*nix` machine
- configuring a virtual env:

```bash
python3 -m venv tf
source tf/bin/activate
pip3 install -r requirements.txt
```

### Usage

Note: the `invoke create-env` option configures the target codebuild project(s) with an S3 backed remote state.

To deploy both AWS Commercial and AWS GovCloud TF projects with variable values from SSM:

```bash
invoke create-env --build-env=all
```

To deploy a single codebuild project with variable values from SSM:

```bash
invoke create-env --build-env=<environment_name>
```

Note: If at any point you experience issues all commands have an included `--verbose` flag.

### destroy

To destroy a targeted CodeBuild environment and it's backend:

```bash
invoke destroy-env --build-env=commercial_ci --include-backend
```

To destroy all CodeBuild environments and their backends:

```bash
invoke destroy-env --build-env=all --include-backend
```

To destroy the CodeBuild environment and preserve the backend just remove the `--include-backend` flag

Note: Remote state buckets are deployed with versioning on by default and will need to be deleted manually along with the project's like-named DynamoDB table.

### Variables configuration

Variable values are pulled at `terraform apply` from the AWS SSM parameter store. However, these values are configurable/updatable via the cli and the use of a template yaml file.

#### Starting fresh

Create a `varialbles.yaml` file in the root of this directory in the following format:

```yaml
commercial_ci:
  -
      var_name: "VARIABLE_NAME"
      value: "VARIABLE_VALUE"
      var_type: String|SecureString
  -
      var_name: "VARIABLE_NAME"
      value: "VARIABLE_VALUE"
      var_type: String|SecureString

commercial_rc:
  -
      var_name: "VARIABLE_NAME"
      value: "VARIABLE_VALUE"
      var_type: String|SecureString
  -
      var_name: "VARIABLE_NAME"
      value: "VARIABLE_VALUE"
      var_type: String|SecureString

...etc...

```

Use the following command to confirm your `variables.yaml` is in the proper format:

```bash
invoke variables --validate=local
```

Use the following command to compare your local values to their accompanying SSM values:

```bash
invoke variables --validate=remote
```

When you are satisfied with the new values, run the following command to update the remote values with your local values:

```bash
invoke variables --update
```
