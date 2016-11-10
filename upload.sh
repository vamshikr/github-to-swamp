#! /bin/bash

# This requires AWS CLI, create a python virtual environment and run 'pip install awscli'

function main {
    local aws_region= # example us-west-2
    local aws_profile=<profile-name> # run aws configure --profile <profile-name>
    
    aws lambda update-function-code \
        --region "$aws_region" \
        --function-name upload_to_swamp \
        --zip-file fileb://$PWD/release/github-to-swamp.zip \
        --profile "$aws_profile"
}

main "$@"
