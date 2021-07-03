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

cp ${parameter_file_location} parameters.json.tmp
echo "parameters.json.tmp"
cat ${parameters.json.tmp} 

# merge the commit sha and build number into parameters.json.tmp and push the result into parameters.json

jq --arg gitsha ${CIRCLE_SHA1} --arg buildnumber ${CIRCLE_BUILD_NUM} '. + [ { "ParameterKey":"GitCommit", "ParameterValue":$gitsha }, {"ParameterKey":"CircleCIBuildNumber", "ParameterValue":$buildnumber} ] ' < parameters.json.tmp > $internal_param_file_location