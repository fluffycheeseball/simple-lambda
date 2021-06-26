#!/usr/bin/env bash
set -ex

function usage() {
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
environment="testing_env"

#read the input parametrs. OPTIND (option index) set to 1 so that all input parameters are read
OPTIND=1
while getopts "r:e:h" arg; do
    case $arg in
    r)
        aws_region=$OPTARG
        ;;
    e)
        environment=$OPTARG
        ;;
    *)
        usage
        ;;
    esac
done
shift "((OPTIND-1))

# Load global variables