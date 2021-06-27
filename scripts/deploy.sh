#!/usr/bin/env bash
# -e = exit on first failed line
# -x = print line being executed to console
set -ex

function show_usage() {
    cat <<EOF 
    #### deploy.sh ####
    Deploy 
      -r AWS region name
      -e Deployment environment
      Example:
      deploy.sh -r eu-west-2 -e test
EOF

exit 2
}

# set defaults
aws_region="eu-west-2"
environment="test"

#read the input parametrs. OPTIND (option index) set to 1 so that all input parameters are read
echo "input params: ${fred}"
OPTIND=1
while getopts ":r:e:h:" arg; do #yes that last h is needed - otherwise it fails to read 2nd environment parameter
    case $arg in
    r)
        aws_region=$OPTARG
        echo "aws_region: ${aws_region}"
        ;;
    e)
        environment=$OPTARG
        echo "environment: ${environment}"
        ;;
    *)
        show_usage
        echo "showing usage"
        ;;
    esac #case end marker
done
shift "$((OPTIND-1))"

echo "aws region: ${aws_region}"
echo "target environment: ${environment} "

# Load global variables
. deploy/${environment}.config

# Add enviromment specific parameters
cp deploy/infrastructure/${environment}.parameters.json /tmp/parameters.json
cat /tmp/parameters.json

# deploy the infrastucture stack
. scripts/deploy_stack.sh
