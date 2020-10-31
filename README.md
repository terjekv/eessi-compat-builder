# Usage

## Setup

Create a command line user for your AWS account:
https://blog.gruntwork.io/a-comprehensive-guide-to-authenticating-to-aws-on-the-command-line-63656a686799

The user needs access to EC2, nothing else. Make a note of your access data and export it into the environment:

```shell
export AWS_ACCESS_KEY_ID=(your access key id)
export AWS_SECRET_ACCESS_KEY=(your secret access key)
```

Then check out the repo:

```shell
git clone git@github.com:terjekv/eessi-compat-builder.git
cd eessi-compat-builder
```

You will want to edit the ssh keyname in `terraform/variables.tf`, unless you create your own keys
called `id_rsa.terraform`. Note that for terraform, these have to be keyless.

## To use

```
./run.sh [test|prod|plan]
```

Without input, a test will be run.

Wait for a while, or if you're doing a production run, a long while.
When the script completes, you will have files like this in the current directory:

```
compat-prod-arm-2020-10-31_07_33_16_UTC.tar.gz
compat-prod-x86_64-2020-10-31_07_33_16_UTC.tar.gz
```


## How?

The infrastructure on AWS has been created, set up to pull the docker instance that builds the
compat layer, as the compat layer is done it is copied to your local machine, and then the 
infrastructure is wiped.

