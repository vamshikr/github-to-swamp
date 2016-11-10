#! /bin/bash

# Test run the AWS Lambda function

function main {
        local lambda_function_arn= # example 'arn:aws:lambda:us-west-2:453083456048:function:upload_to_swamp'
    aws lambda invoke \
        --function-name "$lambda_function_arn" \
        --invocation-type Event \
        --payload fileb://$PWD/sample_github_sns_event.json \
        ./test.out
}

main "$@"

