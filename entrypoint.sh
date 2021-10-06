#!/usr/bin/env bash

# Exit on error. Append "|| true" if you expect an error.
set -o errexit  # same as -e
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch if the pipe fucntion fails
set -o pipefail
set -x

AWS_PROFILE="default"

#Check AWS credetials are defined in Gitlab Secrets
if [[ -z "$AWS_ACCESS_KEY_ID" ]];then
    echo "AWS_ACCESS_KEY_ID is not SET!"; exit 1
fi

if [[ -z "$AWS_SECRET_ACCESS_KEY" ]];then
    echo "AWS_SECRET_ACCESS_KEY is not SET!"; exit 2
fi

if [[ -z "$AWS_REGION" ]];then
echo "AWS_REGION is not SET!"; exit 3
fi


aws configure --profile ${AWS_PROFILE} set aws_access_key_id "${AWS_ACCESS_KEY_ID}"
aws configure --profile ${AWS_PROFILE} set aws_secret_access_key "${AWS_SECRET_ACCESS_KEY}"
aws configure --profile ${AWS_PROFILE} set region "${AWS_REGION}"

cfn-deploy(){
   #Paramters
   # region       - the AWS region
   # stack-name   - the stack name
   # template     - the template file
   # parameters   - the paramters file
   # capablities  - capablities for IAM

    template=$3
    parameters=$4
    capablities=$5

    ARG_CMD=" "
    if [[ -n $template ]];then
        ARG_CMD="${ARG_CMD}--template-body file://${template} "
    fi
    if [[ -n $parameters ]];then
        ARG_CMD="${ARG_CMD}--parameters file://${parameters} "
    fi
    if [[ -n $capablities ]];then
        ARG_CMD="${ARG_CMD}--capabilities ${capablities} "
    fi

    ARG_STRING=$ARG_CMD

    shopt -s failglob
    set -eu -o pipefail

    echo -e "\nVERIFYING IF CFN STACK EXISTS ...!"

    if ! aws cloudformation describe-stacks --region "$1" --stack-name "$2" ; then

    echo -e "\nSTACK DOES NOT EXISTS, RUNNING VALIDATE"
    aws cloudformation validate-template \
        --template-body file://${template}

    echo -e "\nSTACK DOES NOT EXISTS, RUNNING CREATE"
    # shellcheck disable=SC2086
    aws cloudformation create-stack \
        --region "$1" \
        --stack-name "$2" \
        $ARG_STRING

    echo "\nSLEEP STILL STACK CREATES zzz ..."
    aws cloudformation wait stack-create-complete \
        --region "$1" \
        --stack-name "$2" \

    else

    echo -e "\n STACK IS AVAILABLE, TRYING TO UPDATE !!"

    set +e
    # shellcheck disable=SC2086
    stack_output=$( aws cloudformation update-stack \
        --region "$1" \
        --stack-name "$2" \
        $ARG_STRING  2>&1)
    exit_status=$?
    set -e

    echo "$stack_output"

    if [ $exit_status -ne 0 ] ; then

        if [[ $stack_output == *"ValidationError"* && $stack_output == *"No updates"* ]] ; then
            echo -e "\nNO OPERATIONS PERFORMED" && exit 0
        else
            exit $exit_status
        fi

    fi

    echo "STACK UPDATE CHECK ..."

    aws cloudformation wait stack-update-complete \
        --region "$1" \
        --stack-name "$2" \

    fi

    echo -e "\nSUCCESSFULLY UPDATED - $2"
}


cfn-deploy "$AWS_REGION" "$STACK_NAME" "$TEMPLATE_FILE" "${PARAMETERS_FILE:-}" "$CAPABLITIES"

