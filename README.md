SlackNotifierSampler
=======

Deploy [AWS SAM](https://github.com/awslabs/serverless-application-model) with [Circle CI](https://circleci.com/?utm_source=Google&utm_medium=SEM&utm_campaign=Search%20Signup%20Branded&utm_content=Search%20Signup%20Branded-Eng-Branded-CircleCI%20(Branded)%20-%20ci&gclid=CjwKCAjw2_LcBRBYEiwA_XVBU8c3mBHwOGXR10vtzEvp0PIVvH7o0xVMppQ5roFa7EZvf8jEwE_YJhoCxG0QAvD_BwE)

# Session
<script async class="speakerdeck-embed" data-id="95839ac8ec494e43885f8f7434fcea7e" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>

# Requirements

- [AWS CLI](https://aws.amazon.com/cli/)
- [Docker for Mac](https://www.docker.com/docker-mac)
- [yarn](https://yarnpkg.com)

# Deploy

- Example AWS Profile 

| Environment | AWS Profile | Region |
| --- | --- | --- |
| development | sns-development | us-east-1 |
| integration | sns-integration | eu-west-1 |
| staging | sns-staging | us-west-2 |
| production | sns-production | ap-northeast-1 |

## 1. Configure AWS credentials

- `~/.aws/credentials`

```bash
[sns-development]
aws_access_key_id = <your_aws_access_key_id>
aws_secret_access_key = <your_aws_secret_access_key>

[sns-integration]
aws_access_key_id = <your_aws_access_key_id>
aws_secret_access_key = <your_aws_secret_access_key>

[sns-staging]
aws_access_key_id = <your_aws_access_key_id>
aws_secret_access_key = <your_aws_secret_access_key>

[sns-production]
aws_access_key_id = <your_aws_access_key_id>
aws_secret_access_key = <your_aws_secret_access_key>
```

- `~/.aws/config`

```bash
[profile sns-development]
region = us-east-1
output = json

[profile sns-integration]
region = eu-west-1
output = json

[profile sns-staging]
region = us-west-2
output = json

[profile sns-production]
region = ap-northeast-1
output = json
```

## 2. Setting AWS

- Setting [SSM](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-paramstore.html)

| Parameter | Value |
| --- | --- |
| CircleCIDeployRoleExternalId | <your_genarate_external_id> |
| MessageHooksSlackURL | <your_genarate_slack_hooks_url> |

## 3. Building Cloud Formation

```bash
$ cd cfn
```

### Deploy S3

```bash
$ ./run.sh -t s3.yml -e <Environment>
```

### Deploy IAM

```bash
$ ./run.sh -t iam.yml -e <Environment>
```

### Deploy Message Notifier

```bash
$ ./run.sh -t message-notifier.yml -e <Environment>
```

## 4. Setting Circle CI

### AWS Permissions

| Parameter | Value |
| --- | --- |
| Access Key ID | <your_aws_access_key_id> |
| Secret Access Key | <your_aws_secret_access_key> |

### Environment Variables

| Parameter | Value |
| --- | --- |
| AWS_ACCOUNT_ID_DEVELOPMENT | <your_aws_account_id> |
| AWS_ACCOUNT_ID_INTEGRATION | <your_aws_account_id> |
| AWS_ACCOUNT_ID_STAGING | <your_aws_account_id> |
| AWS_ACCOUNT_ID_PRODUCTION | <your_aws_account_id> |
| AWS_IAM_ROLE_EXTERNAL_ID_DEVELOPMENT | <your_genarate_external_id> |
| AWS_IAM_ROLE_EXTERNAL_ID_INTEGRATION | <your_genarate_external_id> |
| AWS_IAM_ROLE_EXTERNAL_ID_STAGING | <your_genarate_external_id> |
| AWS_IAM_ROLE_EXTERNAL_ID_PRODUCTION | <your_genarate_external_id> |
