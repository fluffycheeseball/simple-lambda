#!/usr/bin/env bash
# -e = exit on first failed line
# -x = print line being executed to console
set -ex

function usage() {
    cat <<EOF 
    #### deploy_stack.sh ####
    Deploy 
      --s Stack name to deploy
      --t location of cloudformation template for stack
      --p Parameters file for environment to teploy to
      --g Flag to indicate that git shas should be used with parameters
      Example:
      deploy_stack.sh -s "myStackName" -t "deploy/infrastucture/template.yml" -p "tmp/parameters.json"
EOF

exit 2
}

target_stack_name=""
template_location=""
parameter_file_location=""
use_git_commit='true'

#read the input parametrs. OPTIND (option index) set to 1 so that all input parameters are read
OPTIND=1
while getopts ":s:t:p:" arg; do
    case $arg in
    s)
        target_stack_name=$OPTARG
        ;;
    t)
        template_location=$OPTARG
        ;;
    p)
        parameter_file_location=$OPTARG
        ;;      
    *)
        usage
        ;;
    esac
done
shift "$((OPTIND-1))"

echo "Deploying stack: ${target_stack_name}"
echo "Using template: ${template_location}"
echo "Using parameters: ${parameter_file_location}"

internal_param_file_location=parameters.json

# If we are stamping with git build numbers, copy the param file to a local location and amend it to include expected parameters for tags. Otherwise just copy to the output parameter location
if ${use_git_commit}
then
  cp ${parameter_file_location} parameters.json.tmp
  jq --arg gitsha ${CIRCLE_SHA1} --arg buildnumber ${CIRCLE_BUILD_NUM} '. + [ { "ParameterKey":"GitCommit", "ParameterValue":$gitsha }, { "ParameterKey":"CircleCIBuildNumber", "ParameterValue":$buildnumber } ]' < parameters.json.tmp > $internal_param_file_location
else
  cp ${parameter_file_location} $internal_param_file_location
fi