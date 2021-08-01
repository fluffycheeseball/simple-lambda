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
#The role that circleCi will assume that allows it to deploy stuff
cloudformation_role="arn:aws:iam::311047760260:role/jude_circle_ci_cloudformation_role"

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
cat ${parameter_file_location}

echo "reg {$CIRCLECI_AWS_REGION}"
echo " build {$CIRCLE_BUILD_NUM}"
echo " sha ${CIRCLE_SHA1}"

internal_param_file_location=parameters.json

# If we are stamping with git build numbers, copy the param file to a local location and amend it to include expected parameters for tags. Otherwise just copy to the output parameter location

  cp ${parameter_file_location} parameters.json.tmp



 jq --arg gitsha ${CIRCLE_SHA1} --arg buildnumber ${CIRCLE_BUILD_NUM} '. + [ { "ParameterKey":"GitCommit", "ParameterValue":$gitsha }, { "ParameterKey":"CircleCIBuildNumber", "ParameterValue":$buildnumber } ]' < parameters.json.tmp > $internal_param_file_location

 cat $internal_param_file_location

# aws --profile=$DEPLOYMENT_PROFILE_TEST cloudformation describe-stacks --stack-name jude-temp-stack

if aws --profile=$DEPLOYMENT_PROFILE_TEST cloudformation describe-stacks --stack-name ${target_stack_name} 2>&1; then
  
  echo "Updating stack ${target_stack_name} ..."
  template_parameters=$(jp --unquoted --filename /tmp/parameters.json "join(' ', @[].join('=', [ParameterKey, ParameterValue])[])")
  echo "template_parameters" ${template_parameters}
  
  aws --profile=$DEPLOYMENT_PROFILE_TEST cloudformation deploy \
      --template-file ${template_location} \
      --stack-name ${target_stack_name}  \
      --parameter-overrides $template_parameters \
      --capabilities CAPABILITY_NAMED_IAM \
      --role-arn ${cloudformation_role} \
      --no-fail-on-empty-changeset 

else
  echo "creating stack ${target_stack_name}"
  aws --profile=$DEPLOYMENT_PROFILE_TEST cloudformation create-stack  \
  --stack-name "${target_stack_name}" \
  --template-body "file://$template_location"  \
  --parameters "file://$internal_param_file_location"  \
  --capabilities CAPABILITY_NAMED_IAM  \
  --role-arn "${cloudformation_role}"

  echo "Waiting on $target_stack_name to be created."
  aws --profile=$DEPLOYMENT_PROFILE_TEST cloudformation wait stack-create-complete --stack-name "$target_stack_name"
fi

echo "$target_stack_name stack deployment complete"

exit 0