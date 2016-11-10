#! /bin/bash

# This requires AWS CLI, create a python virtual environment and run 'pip install awscli'

function main {

    if [[ -z "$(which aws)" ]]; then
        echo "Install AWS CLI by running the command 'pip install awscli'" && echo "Create a profile by running 'aws configure --profile <profile-name>'" && exit 1;
    fi
        
    local aws_func_name="$1";
    local aws_profile="$2"
    local aws_region="${3:-us-west-2}"

    if [[ -z "$aws_func_name" || -z "$aws_profile" ]]; then
        echo "$Requires AWS Lambda function name and AWS CLI configuration profile" && \
            exit 1;
    fi
    
    aws lambda update-function-code \
        --region "$aws_region" \
        --function-name "$aws_func_name" \
        --zip-file fileb://$PWD/release/github-to-swamp.zip \
        --profile "$aws_profile"
}

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <aws-lambda-function-name> <aws-config-profile> [<aws-region> default us-west-2]" && \
        echo "Create a profile by running 'aws configure --profile <profile-name>'" && \
        exit 1;
fi
main "$@"
