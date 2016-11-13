## AWS Lambda function to build and assess GitHub projects in SWAMP (unoffical)

This is an attempt to have a SWAMP integration for GitHub project (like Travis CI and all of these: https://github.com/integrations).  This is accomplished using [AWS Lambda](https://aws.amazon.com/lambda/)

> This is not an official SWAMP project

It is done this way:

1. For a github project, setup an [Amazon's Simple Notification Service (AWS SNS)](https://aws.amazon.com/sns/) service for events (like *push*). GitHub services are pre-built integrations that perform certain actions when events occur on GitHub. For details on services, go to your GitHub project home page (you must be an admin for the project) >> settings >> integrations & services https://github.com/vamshikr/java-api/settings/installations).

1. When an event like (git push) happens for the registered GitHub project, GitHub sends a **event notification** using AWS SNS to a registered end point, in this case it is the AWS Lambda function `github-to-swamp` (this project).

1. The `github-to-swamp` lambda function parses the event object, downloads the **latest** archive of the *master* branch of the *github project* which sent the notification.

1. The `github-to-swamp` lambda function uses the [swamp-api](https://github.com/vamshikr/swamp-python-api) to upload the archive with build information (provided in `package.conf` configuration file) to SWAMP. The `github-to-swamp` lambda function then triggers assessments with all the relevant static analysis tools in SWAMP. Users will get a notification from SWAMP once the assessments are complete.


### AWS Lambda and GitHub Webhooks setup

To use this lambda function, you first have to setup an AWS account:

1. Open an AWS account (if don't already have one) and an AWS IAM user (http://docs.aws.amazon.com/lambda/latest/dg/setting-up.html)
1. Create an AWS SNS topic (http://docs.aws.amazon.com/sns/latest/dg/GettingStarted.html)
1. Create an AWS Lambda function (https://aws.amazon.com/lambda/getting-started/) that uses python-2.7 runtime.


#### This blog has step-by-step tutorial to accomplish the above:
https://aws.amazon.com/blogs/compute/dynamic-github-actions-with-aws-lambda/

### Usage

First clone or download this project

#### Make

To make a `zip` file that contains the lambda function and its dependencies. First, fill in `resources/user-info.conf` with your SWAMP login credentials
and run `./scripts/make.sh`, if everything is fine, this will create `release/github-to-swamp.zip`.

This lambda function has two external dependencies that it carries along with it.

1. [Requests: HTTP for Humans](http://docs.python-requests.org/en/master/)
2. [SWAMP Python API (unofficial)](https://github.com/vamshikr/swamp-python-api)

#### Upload

Users can upload the `zip` file using AWS lambda web interface or running the command `scripts/upload.sh`.

The script uses AWS CLI. You can install AWS CLI by running `pip install awscli`.

The `scripts/upload.sh`needs the *AWS lambda function name* and *AWS configuration profile name* as argument. There is an optional third argument for *AWS region* which defaults to *us-west-2*.

#### Package.conf in GitHub Project

Add a file named `package.conf` in the top-level directory of your GitHub project. The contents of the `package.conf` file must look like this
```sh
package-short-name=my-java-pkg
package-version=<filed-in-by-lambda-function>
package-archive=<filed-in-by-lambda-function>
package-dir=<filed-in-by-lambda-function>
package-language=Java
# supported ant, ant+ivy, maven, gradle
build-sys=maven
build-file=pom.xml
build-target=clean install
build-opt=-DskipTests -Dmaven.test.skip
config-cmd=mvn
config-opt=clean
config-dir=.
```

#### Test
Users can test/trigger the AWS lambda function using AWS web interface or the command line using `./scripts/invoke.sh`.

The script used default GitHub event `resources/sample_github_sns_event.json` and requires *ARN for the AWS Lambda function* as the argument.

### Limitations

1. The AWS Lambda runtime environment does not have `git` installed. Because of this the actual commit reference that generated the event cannot be fetched. i.e. the lambda function always downloads the archive of the **latest of the master** branch.

2. Currently, only **Java** package upload and assessments are possible, and this is because of the limitations of [SWAMP Python API (unofficial)](https://github.com/vamshikr/swamp-python-api)

3. Requires build information be specified in a `package.conf` in the top-level directory of the GitHub project.
