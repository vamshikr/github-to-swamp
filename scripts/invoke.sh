#! /bin/bash

# Test run the AWS Lambda function

function main {
    local lambda_function_arn="$1"

    aws lambda invoke \
        --function-name "$lambda_function_arn" \
        --invocation-type Event \
        --payload fileb://$PWD/resources/sample_github_sns_event.json \
        ./test.out
}

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 'arn:aws:lambda:us-west-2:358603856372:function:upload_to_swamp'" && \
    exit 1;
fi
    
main "$@"
