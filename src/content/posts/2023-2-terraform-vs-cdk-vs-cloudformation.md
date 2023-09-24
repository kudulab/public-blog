+++
date = "2023-09-TODO"
title = "TODO"
description = "TODO"
images = []
math = "false"
series = []
author = "Ava"
+++

As [Wikipedia](https://en.wikipedia.org/wiki/Infrastructure_as_code) explains:
> Infrastructure as code (IaC) is the process of managing and provisioning computer data centers through machine-readable definition files, rather than physical hardware configuration or interactive configuration tools.

IaC is one of the DevSecOps practices. With IaC you can manage your infrastructure (bare metal, virtual machines, containers, databases, networking services and other resources) in a similar way as you would manage the code of any other project (e.g. a .NET or Java application). It literally means that you can define your infrastructure as a bunch of text files.


## Benefits of IaC
There are many benefits of infrastructure as code:
  * **Automation** - you no longer have to manually log into the AWS Management Console or Azure Portal or other GUI provided by your infrastructure provider. Instead, you can use CLI tools and run the same CLI command to deploy or delete your infrastructure. This means that you can now **manage your infrastructure using CICD pipelines** and have a well-defined software delivery cycle for your IaC, including tests, peer reviews, security scans, etc. IaC enables you to fail fast, thanks to IaC linters (e.g. tflint) and other static analysis tools. Automation means **reliable and repeatable processes**. In contrast, performing operations manually (creating, updating, destroying infrastructure resources) is prone to human errors, such as forgetting about a step or committing a typo (which then in turn may lead to a deployment targeting the wrong cloud region).
  * **Auditability and record keeping** - putting your infrastructure in a version control system (such as git) allows you to see a list of commits (and git tags) and helps you identify who did what change and when.
  * **Documentation** - all the infrastructure resources needed to set up an environment (to provision your infrastructure) could be stored in a git repository. Without that, you'd need to perform some kind of discovery to find out that information - e.g. look for an architecture diagram or documentations or talk to a person who managed an environment previously.
  * **Removed dependency on GUIs** - usually the cloud providers and other infrastructure providers offer some kind of a GUI (e.g. AWS Management Console or Azure Portal). The GUI may often change and you usually don't have the control over which GUI version you use.
  * **Scalability** - it's much easier to create 500 virtual machines using code than doing it manually.
  * **Environment Consistency and easy Reproduction of an environment** - as the [12 Factor App](https://12factor.net/dev-prod-parity) recommends, we should keep development, staging, and production environments as similar as possible. With IaC it is easier to parameterise your code, so that the differences between environments are minimal. Also, sometimes, you may want to create a representative copy of our environment for troubleshooting or experimenting purposes. It's a good way to avoid affecting the production environment. Using a IaC tool makes is easier to replicate an environment, or keep multiple environments in sync, and it is generally faster (than the manual way).
  * **Drift Detection** - you can use a IaC tool to see what changes were done to your infrastructure outside of the well-defined SDLC (either manually, or using a unapproved script).
  * **Security and Governance** - it’s easier to ensure security standards are met with IaC. You can use tools such as tfsec or AWS CloudFormation Guard and make them run even before the infrastructure is created.

## Tools comparison

Let's compare the most commonly used infrastructure as code tools:
* [Terraform](https://www.terraform.io/)
* [AWS CloudFormation](https://aws.amazon.com/cloudformation/faqs/) (AWS CFN)
* [AWS CDK](https://docs.aws.amazon.com/cdk/v2/guide/home.html)

While the above tools fullfil the same purpose (allow us to treat and manage infrastructure as code), they are vastly different in how they work, their workflows, integrations, code logic etc. It's important to note that while Terraform and AWS CloudFormation are two separate tools, **AWS CDK is built on top of AWS CloudFormation**. This means, that when you use AWS CDK, you also use AWS CloudFormation. AWS CDK just adds another layer to the tool. Read more here about how [AWS CDK is powered by AWS CloudFormation](https://aws.amazon.com/cdk/features/)

Below is a table detailing the main differences between the IaC tools.

### Main differences
| Feature | AWS CloudFormation | AWS CDK | Terraform |
|----------|-----------|----------| -- |
| Language | YAML or JSON or AWS CloudFormation Designer - a GUI | TypeScript, Python, Java, .NET, or Go (in Developer Preview). | Hashicorp (HCL) syntax |
| Supported infrastructure  | AWS only (plus 3rd party modules to support e.g. monitoring or incident management; [link](https://aws.amazon.com/cloudformation/features/?pg=ln&sec=hs#extensibility))  | Same as AWS CloudFormation | Various clouds and PaaS integrations (e.g. AWS, Azure, GCP, Kubernetes, Alibaba Cloud. Find out about other Terraform providers [here](https://registry.terraform.io/browse/providers)) |
| State management | Handled for you | Same as AWS CloudFormation | Needs to be configured by you (many options) |
| Version management | You cannot choose which version of AWS CFN you're using (the history of changes is available [here](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/ReleaseHistory.html)) | Same as AWS CloudFormation | You can choose which version of Terraform and each Terraform provider you use (the history of changes is available [here](https://github.com/hashicorp/terraform/blob/main/CHANGELOG.md)) |
| Pricing | [Not free](https://aws.amazon.com/cloudformation/pricing/), but also subjectively not expensive | Same as AWS CloudFormation | Fee |
| License | It's one of many AWS services | Open-source | Until 11.08.2023 Terraform used be open-source, today it's under the BSL license, which really only impacts the Terraform competitors. Read more [here](https://kudulab.io/posts/2023-1-terraform-license-change/) |

This leads to the following conclusions:
* if you want to deploy infrastructure that is not AWS, go with Terraform
* if you want to use only AWS-provided tools, go with AWS CloudFormation or AWS CDK

### Other differences
| Feature | AWS CloudFormation | AWS CDK | Terraform  |
| -- | -- | -- | -- |
| Troubleshooting | More complex than Terraform (see the Appendix) | It's possible to detect errors in code without creating any infrastructure, although CDK adds an additional layer of abstraction on top of CFN, so it's not unreasonable to expect problems at any of these layers and in result, one has to be familiar with both tools ([exampl1](https://awsmaniac.com/troubleshooting-aws-cdk-part-1-nested-stacks/), [example2](https://medium.com/@gwenleigh/week-8-troubleshooting-cdk-deploy-not-working-72ce59ab8293)) | It's possible to detect errors in code without creating any infrastructure |
| State locking (Prevent multiple processes/people/pipelines from applying changes to your infrastructure at the same time) | Native support (Updating an IN_PROGRESS stack not permitted) |  Same as AWS CloudFormation | Native support (Can be configured with DynamoDB) |
| Preview your changes before actually applying them | Native support, but not a part of the default workflow. You can use [Change sets](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks-changesets.html) in [this way](https://theithollow.com/2018/01/22/introduction-aws-cloudformation-change-sets/). AWS recommends to [Create change sets before updating your stacks](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/best-practices.html). | Native support, but not a part of the default workflow. See `cdk diff`. | Native support and a part of the default workflow. You first run `terraform plan` which shows the intended changes (the plan of the target infrastructure), and then `terraform apply` to actually deploy or delete the infrastructure. |
| Drift detection (detect changes done to your infrastructure outside of the IaC tool). | Supported but limited. Limited, because (1) if a resource was deleted outside of CFN, you have to recreate it manually, (2) not all the resources are supported (e.g. SSM Parameter is not) (See the Appendix) | Supported with `cdk diff`, same limitations as AWS CloudFormation (also see the Appendix) | Supported by `terraform plan`. Part of the default workflow. (See the Appendix) |
| Idempotency of the workflow (you can use the CLI commands and expect the same results) | Less idempotent than Terraform. (1) By default, when you create a new CFN stack and it fails, you have to delete the full stack - you cannot fix the error without deleting the stack. (2) There are multiple CLI commands available to create a CFN stack. The command `create-stack` can be used only once, while the command `deploy` can be used many times. These commands take different parameters (e.g. `--parameters` vs `--parameter-overrides`, `--on-failure`). There seems to be no `on-failure` option for `aws cloudformation deploy` command, so on the 1st time, if the stack fails, you have to delete it manually. | Easy idempotent command `cdk deploy`, however it does not offer the same confidence as Terraform commands do. (There is no possibility for this command to execute ChangeSets without creating them.  read more [here](https://github.com/aws/aws-cdk/issues/15495#issuecomment-881319185)). | Easy idempotent commands `terraform plan` and `terraform apply`. First, you create a plan for your infrastructure, then you apply the plan which creates the infrastructure. |
| Modularity/re-useability | You can use just one YAML or JSON file or you can separate common components of your infrastructure into [nested stacks](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-nested-stacks.html). You can also use modules. AWS recommends [using modules to reuse resource configurations](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/best-practices.html). You have to register the module in the account and region in which you want to use it. Otherwise, you end up with long CFN YAML or JSON files and repeated logic. | There are 3 levels of [constructs](https://docs.aws.amazon.com/cdk/v2/guide/constructs.html) and also stacks available. AWS recommends to [separate your application into multiple stacks](https://docs.aws.amazon.com/cdk/v2/guide/best-practices.html)  | Terraform natively supports multiple `.tf` files. You can use one or many `.tf` files. Additionally, you can use [Terraform modules](https://developer.hashicorp.com/terraform/language/modules). There are many open-source Terraform modules to choose from, e.g. [AWS Terraform Modules](https://registry.terraform.io/namespaces/terraform-aws-modules). |
| Limits and quotas | Hard limits set by AWS: [max 200 Parameters and 500 resources](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cloudformation-limits.html) per template. You can use nested templates as a workaround. |  (Same as AWS CloudFormation](https://docs.aws.amazon.com/cdk/v2/guide/stacks.html) | No such limits |

The list above does is not exhaustive. There are other differences between the IaC tools.

## Conclusions

You can manage your infrastructure, make it secure, and automate this process with any of the IaC tools. Each of the tools is going to have some **trade-offs**. For example, setting up the Terraform remote state, which takes some time and effort, is not needed by AWS CloudFormation. However, it seems that troubleshooting, and drift detection is much better supported by Terraform than by AWS CloudFormation. You can compare these features, by **applying the frequency perspective**. You'd usually set up the Terraform remote state once per project (so it's not going to happen often), but the troubleshooting and drift detection are the business-as-usual daily tasks that Infrastructure Engineers do. Please also note that since AWS CDK is a wrapper around AWS CloudFormation, not only you have the standard problems with troubleshooting AWS CloudFormation, but you also may have to deal with troubleshooting this additional layer.

A general recommendation is to **choose 1 IaC tool** per project/team/company and stick with it. Otherwise:
* you are asking the engineers to master multiple tools, and that time, that is going to be spent on learning a new tool, could be spent in a more efficient way.
* you need to take care of the multiple sets of best practices (for each IaC tool) and of multiple software delivery lifecycles.
* you need to come up with multiple sets of other tools that test your infrastructure code (e.g. linters or security scanners).


See also:
* https://techconnect.com.au/aws-cdk-the-good-the-bad-and-the-ugly/#:~:text=Anyone%20who%20has%20used%20AWS,describe%20as%20slow%20and%20chunky.
* https://blog.devspecops.com/stop-using-aws-cdk-b2052abb4cb5

----
# Appendix
## Troubleshooting
### Troubleshooting AWS CloudFormation
Let's cover a simple example and create an S3 bucket with CFN. First, we need to create a YAML or JSON file (a CFN template) containing an S3 bucket text resource. It could look like the following:
```
AWSTemplateFormatVersion: 2010-09-09
Description: A simple CloudFormation template
Resources:
    Bucket:
        Type: AWS::S3::Bucket
        Properties:
            BucketName: unsupportedName_-412*&herE_000AndAlsoHopefullyItIsTooLongLetsHopeThisIsEnoughCharactersToCauseAnError
```

This YAML files creates just one Amazon S3 bucket. The bucket's name is invalid on purpose, so that we can experience an error in AWS CFN.

Secondly, in order to create the S3 bucket, we run a CFN CLI command and we get the following output:
```
$ aws cloudformation deploy --template-file create_s3_bucket.yaml --stack-name s3-bucket


Waiting for changeset to be created..
Waiting for stack create/update to complete

Failed to create/update the stack. Run the following command
to fetch the list of events leading up to the failure
aws cloudformation describe-stack-events --stack-name s3-bucket
```

There is no information about what is the specific error. Following the suggestion from the output above, we then run another CLI command and we get the following information about CFN stack events:
```
$ aws cloudformation describe-stack-events --stack-name s3-bucket{
    "StackEvents": [
        {
            "StackId": "arn:aws:cloudformation:eu-west-1:<aws_account_id>:stack/s3-bucket/ab495190-5a70-11ee-af83-06680f3be939",
            "EventId": "b1ae2100-5a70-11ee-bd5a-0a4ffa38e2e5",
            "StackName": "s3-bucket",
            "LogicalResourceId": "s3-bucket",
            "PhysicalResourceId": "arn:aws:cloudformation:eu-west-1:<aws_account_id>:stack/s3-bucket/ab495190-5a70-11ee-af83-06680f3be939",
            "ResourceType": "AWS::CloudFormation::Stack",
            "Timestamp": "2023-09-24T00:24:15.880000+00:00",
            "ResourceStatus": "ROLLBACK_COMPLETE"
        },
        {
            "StackId": "arn:aws:cloudformation:eu-west-1:<aws_account_id>:stack/s3-bucket/ab495190-5a70-11ee-af83-06680f3be939",
            "EventId": "Bucket-DELETE_COMPLETE-2023-09-24T00:24:15.544Z",
            "StackName": "s3-bucket",
            "LogicalResourceId": "Bucket",
            "PhysicalResourceId": "",
            "ResourceType": "AWS::S3::Bucket",
            "Timestamp": "2023-09-24T00:24:15.544000+00:00",
            "ResourceStatus": "DELETE_COMPLETE",
            "ResourceProperties": "{\"BucketName\":\"unsupportedName_-412*&herE_000AndAlsoHopefullyItIsTooLongLetsHopeThisIsEnoughCharactersToCauseAnError\"}"
        },
        {
            "StackId": "arn:aws:cloudformation:eu-west-1:<aws_account_id>:stack/s3-bucket/ab495190-5a70-11ee-af83-06680f3be939",
            "EventId": "b07f3df0-5a70-11ee-87a3-066b3bd090bd",
            "StackName": "s3-bucket",
            "LogicalResourceId": "s3-bucket",
            "PhysicalResourceId": "arn:aws:cloudformation:eu-west-1:<aws_account_id>:stack/s3-bucket/ab495190-5a70-11ee-af83-06680f3be939",
            "ResourceType": "AWS::CloudFormation::Stack",
            "Timestamp": "2023-09-24T00:24:13.893000+00:00",
            "ResourceStatus": "ROLLBACK_IN_PROGRESS",
            "ResourceStatusReason": "The following resource(s) failed to create: [Bucket]. Rollback requested by user."
        },
        {
            "StackId": "arn:aws:cloudformation:eu-west-1:<aws_account_id>:stack/s3-bucket/ab495190-5a70-11ee-af83-06680f3be939",
            "EventId": "Bucket-CREATE_FAILED-2023-09-24T00:24:13.422Z",
            "StackName": "s3-bucket",
            "LogicalResourceId": "Bucket",
            "PhysicalResourceId": "",
            "ResourceType": "AWS::S3::Bucket",
            "Timestamp": "2023-09-24T00:24:13.422000+00:00",
            "ResourceStatus": "CREATE_FAILED",
            "ResourceStatusReason": "Bad Request (Service: Amazon S3; Status Code: 400; Error Code: 400 Bad Request; Request ID: V37ZBGVQW0MR2YWD; S3 Extended Request ID: 94pxNmG9bdl/5JehkJrs47ROdqqOoD3lAawN7fcxTFBa1vOKkviVgWuWnCNkG4aeUVJ6vIDXYVQ=; Proxy: null)",
            "ResourceProperties": "{\"BucketName\":\"unsupportedName_-412*&herE_000AndAlsoHopefullyItIsTooLongLetsHopeThisIsEnoughCharactersToCauseAnError\"}"
        },
        {
            "StackId": "arn:aws:cloudformation:eu-west-1:<aws_account_id>:stack/s3-bucket/ab495190-5a70-11ee-af83-06680f3be939",
            "EventId": "Bucket-CREATE_IN_PROGRESS-2023-09-24T00:24:13.154Z",
            "StackName": "s3-bucket",
            "LogicalResourceId": "Bucket",
            "PhysicalResourceId": "",
            "ResourceType": "AWS::S3::Bucket",
            "Timestamp": "2023-09-24T00:24:13.154000+00:00",
            "ResourceStatus": "CREATE_IN_PROGRESS",
            "ResourceProperties": "{\"BucketName\":\"unsupportedName_-412*&herE_000AndAlsoHopefullyItIsTooLongLetsHopeThisIsEnoughCharactersToCauseAnError\"}"
        },
        {
            "StackId": "arn:aws:cloudformation:eu-west-1:<aws_account_id>:stack/s3-bucket/ab495190-5a70-11ee-af83-06680f3be939",
            "EventId": "af2664b0-5a70-11ee-8a61-0e577bdce9eb",
            "StackName": "s3-bucket",
            "LogicalResourceId": "s3-bucket",
            "PhysicalResourceId": "arn:aws:cloudformation:eu-west-1:<aws_account_id>:stack/s3-bucket/ab495190-5a70-11ee-af83-06680f3be939",
            "ResourceType": "AWS::CloudFormation::Stack",
            "Timestamp": "2023-09-24T00:24:11.638000+00:00",
            "ResourceStatus": "CREATE_IN_PROGRESS",
            "ResourceStatusReason": "User Initiated"
        },
        {
            "StackId": "arn:aws:cloudformation:eu-west-1:<aws_account_id>:stack/s3-bucket/ab495190-5a70-11ee-af83-06680f3be939",
            "EventId": "ab490370-5a70-11ee-af83-06680f3be939",
            "StackName": "s3-bucket",
            "LogicalResourceId": "s3-bucket",
            "PhysicalResourceId": "arn:aws:cloudformation:eu-west-1:<aws_account_id>:stack/s3-bucket/ab495190-5a70-11ee-af83-06680f3be939",
            "ResourceType": "AWS::CloudFormation::Stack",
            "Timestamp": "2023-09-24T00:24:05.217000+00:00",
            "ResourceStatus": "REVIEW_IN_PROGRESS",
            "ResourceStatusReason": "User Initiated"
        }
    ]
}
```

The output above is long and it indicates that
* it was indeed the S3 Bucket that caused a failure
```
The following resource(s) failed to create: [Bucket]
```
* the error was
```
Bad Request (Service: Amazon S3; Status Code: 400; Error Code: 400 Bad Request;
```

The output above does not specify the exact error. You have to [google](https://docs.aws.amazon.com/AmazonS3/latest/API/ErrorResponses.html) what `Status Code: 400` might mean in this context.

The CFN stack status should be now `ROLLBACK_COMPLETE`, which means that the S3 bucket was not created. Therefore, to clean up - you have to just delete the CFN stack:
```
aws cloudformation delete-stack --stack-name s3-bucket
```

To troubleshoot AWS CloudFormation, one has to run additional CLI commands to get more information about the error. The output is long and may not print the specific error. Sometimes it helps to visit the AWS Management Console. Given that you'd usually like to automate your infrastructure operations and run them in a CICD pipeline, it's not great when the CICD pipeline output does not show what the actual error is.

### Troubleshooting with AWS CDK
Let's cover a simple example and create an S3 bucket with AWS CDK v2. First, we need to set up a cdk project. We can do it with `cdk init example --language=python`. Here we decided to use Python as our infrastructure language. Then, we can edit the file `cdk/cdk_stack.py` so that it contains an [S3 bucket text resource](https://docs.aws.amazon.com/cdk/api/v2/python/aws_cdk.aws_s3/Bucket.html). It could look like the following:
```
from constructs import Construct
from aws_cdk import (
    Duration,
    Stack,
    aws_s3 as s3,
    RemovalPolicy
)


class CdkStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        s3_bucket = s3.Bucket(self, "my_bucket",
            bucket_name = "unsupportedName_-412*&herE_000AndAlsoHopefullyItIsTooLongLetsHopeThisIsEnoughCharactersToCauseAnError",
            block_public_access=s3.BlockPublicAccess.BLOCK_ALL,
            encryption=s3.BucketEncryption.S3_MANAGED,
            versioned=True,
            removal_policy=RemovalPolicy.RETAIN
        )
```

This CDK project creates just one Amazon S3 bucket. The bucket's name is invalid on purpose, so that we can experience an error in AWS CDK.

Secondly, we need to make sure that we have both Python and NodeJS runtimes locally available. (You can start from an official NodeJS Docker image, and then install Python packages: `apt install python3 python3.11-venv`). Then, we set up a local environment and install python dependencies:
```
python3 -m venv .env
source .env/bin/activate
pip install -r requirements.txt
```

Then, we can run `cdk synth` which is going to generate an AWS CloudFormation YAML templates. Then, in order to create the S3 bucket, we run the CDK CLI commands:
```
$ cdk bootstrap
jsii.errors.JavaScriptError:
  Error: Invalid S3 bucket name (value: unsupportedName_-412*&herE_000AndAlsoHopefullyItIsTooLongLetsHopeThisIsEnoughCharactersToCauseAnError)
  Bucket name must be at least 3 and no more than 63 characters
  Bucket name must only contain lowercase characters and the symbols, period (.) and dash (-) (offset: 11)
      at Bucket.validateBucketName (/tmp/jsii-kernel-0ieIFn/node_modules/aws-cdk-lib/aws-s3/lib/bucket.js:1:17615)
      at new Bucket (/tmp/jsii-kernel-0ieIFn/node_modules/aws-cdk-lib/aws-s3/lib/bucket.js:1:18211)
      at Kernel._Kernel_create (/tmp/tmpqdrcdk0r/lib/program.js:10104:25)
      at Kernel.create (/tmp/tmpqdrcdk0r/lib/program.js:9775:93)
      at KernelHost.processRequest (/tmp/tmpqdrcdk0r/lib/program.js:11691:36)
      at KernelHost.run (/tmp/tmpqdrcdk0r/lib/program.js:11651:22)
      at Immediate._onImmediate (/tmp/tmpqdrcdk0r/lib/program.js:11652:46)
      at process.processImmediate (node:internal/timers:478:21)

The above exception was the direct cause of the following exception:

Traceback (most recent call last):
  File "/tmp/cdk/app.py", line 9, in <module>
    CdkStack(app, "CdkStack")
  File "/tmp/cdk/.env/lib/python3.11/site-packages/jsii/_runtime.py", line 118, in __call__
    inst = super(JSIIMeta, cast(JSIIMeta, cls)).__call__(*args, **kwargs)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/tmp/cdk/cdk/cdk_stack.py", line 15, in __init__
    s3_bucket = s3.Bucket(self, "my_bucket",
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/tmp/cdk/.env/lib/python3.11/site-packages/jsii/_runtime.py", line 118, in __call__
    inst = super(JSIIMeta, cast(JSIIMeta, cls)).__call__(*args, **kwargs)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/tmp/cdk/.env/lib/python3.11/site-packages/aws_cdk/aws_s3/__init__.py", line 16825, in __init__
    jsii.create(self.__class__, self, [scope, id, props])
  File "/tmp/cdk/.env/lib/python3.11/site-packages/jsii/_kernel/__init__.py", line 334, in create
    response = self.provider.create(
               ^^^^^^^^^^^^^^^^^^^^^
  File "/tmp/cdk/.env/lib/python3.11/site-packages/jsii/_kernel/providers/process.py", line 365, in create
    return self._process.send(request, CreateResponse)
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/tmp/cdk/.env/lib/python3.11/site-packages/jsii/_kernel/providers/process.py", line 342, in send
    raise RuntimeError(resp.error) from JavaScriptError(resp.stack)
RuntimeError: Invalid S3 bucket name (value: unsupportedName_-412*&herE_000AndAlsoHopefullyItIsTooLongLetsHopeThisIsEnoughCharactersToCauseAnError)
Bucket name must be at least 3 and no more than 63 characters
Bucket name must only contain lowercase characters and the symbols, period (.) and dash (-) (offset: 11)

Subprocess exited with error 1
```

The output is quite long but it clearly shows the specific error.

There is nothing to clean, because no infrastructure was created. However, if you ran `cdk bootstrap` successfully, and then `cdk deploy` failed, then you would need to run several commands to delete the resources created by `cdk bootstrap` as there is no `cdk bootstrap --delete` option available (see [this GH issue](https://github.com/aws/aws-cdk/issues/986)):
```
aws cloudformation delete-stack --stack-name CDKToolkit
aws s3 ls | grep cdk # copy the name
aws s3 rb --force s3://cdk-hnb659fds-assets-1234-us-east-1 # replace the name here
```

### Troubleshooting with Terraform
Let's cover a simple example and create an S3 bucket with Terraform. First, we need to create a `.tf` file (a Terraform file) containing an S3 bucket text resource. It could look like the following:
```
resource "aws_s3_bucket" "example" {
  bucket = "unsupportedName_-412*&herE_000AndAlsoHopefullyItIsTooLongLetsHopeThisIsEnoughCharactersToCauseAnError"
}
```
and we need another `.tf` file to configure Terraform backend and Terraform provider, e.g.:
```
terraform {
  required_version = "= 1.5.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}
```

Then we run:
```
$ terraform init
$ terraform plan
╷
│ Error: expected length of bucket to be in the range (0 - 63), got unsupportedName_-412*&herE_000AndAlsoHopefullyItIsTooLongLetsHopeThisIsEnoughCharactersToCauseAnError
│
│   with aws_s3_bucket.example,
│   on s3.tf line 2, in resource "aws_s3_bucket" "example":
│    2:   bucket = "unsupportedName_-412*&herE_000AndAlsoHopefullyItIsTooLongLetsHopeThisIsEnoughCharactersToCauseAnError"
│
╵
```

You can see that the output from the `terraform plan` command
* shows the exact specific error: `Error: expected length of bucket to be in the range (0 - 63)`
* does not require to run any other commands
* is not long

There is nothing to clean, because no infrastructure was created.

## Drift detection

## Drift detection with AWS CloudFormation
### 1. Let's create the 2 AWS resources
Let's create a CFN stack which deploys two resources: an S3 bucket and a SSM Parameter. First, we need to have a YAML (or JSON) file with contents like below:
```
AWSTemplateFormatVersion: 2010-09-09
Description: A simple CloudFormation template
Resources:
    SSMParameter:
        Type: AWS::SSM::Parameter
        Properties:
          Name: ABC
          Value: abcdef
          Type: String
    Bucket:
        Type: AWS::S3::Bucket
        Properties:
            BucketName: test-bucket-cfn-111-03062021-bla
```
Then, we deploy the CFN stack with the CLI command `aws cloudformation deploy`. The 2 AWS resources are now created.

Then, we can detect stack drift using either of the two options:
* option 1 - using CLI commands
* option 2 - using AWS Management Console

```
$ aws cloudformation detect-stack-drift --stack-name s3-bucket
{
    "StackDriftDetectionId": "1b9eae20-5a7d-11ee-9157-069156f6c145"
}
$ aws cloudformation describe-stack-resource-drifts --stack-name s3-bucket
{
    "StackResourceDrifts": [
        {
            "StackId": "arn:aws:cloudformation:eu-west-1:<aws_account_id>:stack/s3-bucket/a0201b40-5a7b-11ee-9656-0a3b194998f5",
            "LogicalResourceId": "Bucket",
            "PhysicalResourceId": "test-bucket-cfn-111-03062021-bla",
            "ResourceType": "AWS::S3::Bucket",
            "ExpectedProperties": "{\"BucketName\":\"test-bucket-cfn-111-03062021-bla\"}",
            "ActualProperties": "{\"BucketName\":\"test-bucket-cfn-111-03062021-bla\"}",
            "PropertyDifferences": [],
            "StackResourceDriftStatus": "IN_SYNC",
            "Timestamp": "2023-09-24T01:53:08.651000+00:00"
        }
    ]
}
```

The above shows that the CFN stack is in sync.

### 2. Let's manually modify one of the AWS resources
Then, let's remove the SSM Parameter, and then let's initiate the drift detection again. The status will be still `IN_SYNC`, the drift is not detected.

Even if we deploy the stack again, it will not recreate the SSM parameter:
```
$ aws cloudformation deploy --template-file create_s3_bucket.yaml --stack-name s3-bucket

Waiting for changeset to be created..

No changes to deploy. Stack s3-bucket is up to date
```
(No changes).

The drift was not detected (CloudFormation did not find out that the SSM Parameter was deleted). This may be the exception, as the drift detection may work for other AWS resources, however, it's good to be aware about exemptions like this, to avoid future surprises (and missing resources and invalid CloudFormation state)


## Drift detection with AWS CDK
### 1. Let's create the 2 AWS resources
Let's create a CFN stack which deploys two resources: an S3 bucket and a SSM Parameter. First, we need to have a YAML (or JSON) file with contents like below:


Let's cover a simple example and create an S3 bucket with AWS CDK v2. We follow the same steps as for the Troubleshooting scenario above. We set up a cdk project with `cdk init example --language=python`. Then, we edit the file `cdk/cdk_stack.py` so that it contains an [S3 bucket text resource](https://docs.aws.amazon.com/cdk/api/v2/python/aws_cdk.aws_s3/Bucket.html) and an [SSM Parameter text resource](https://docs.aws.amazon.com/cdk/api/v2/python/aws_cdk.aws_ssm/StringParameter.html). It could look like the following:
```
from constructs import Construct
from aws_cdk import (
    Duration,
    Stack,
    aws_s3 as s3,
    aws_ssm as ssm,
    RemovalPolicy
)


class CdkStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        s3_bucket = s3.Bucket(self, "my_bucket",
            bucket_name = "test124wrraojqwrvuiriorqorjqo",
            block_public_access=s3.BlockPublicAccess.BLOCK_ALL,
            encryption=s3.BucketEncryption.S3_MANAGED,
            versioned=True,
            removal_policy=RemovalPolicy.RETAIN
        )

        ssm_parameter = ssm.StringParameter(self, "ABC",
          parameter_name="ABC",
          string_value="1234"
        )
```

Now we could run `cdk diff` to find out the difference between our current infrastructure and our intention (plan) of the infrastructure coded in `cdk/cdk_stack.py`.
```
$ cdk diff
Stack CdkStack
Parameters
[+] Parameter BootstrapVersion BootstrapVersion: {"Type":"AWS::SSM::Parameter::Value<String>","Default":"/cdk-bootstrap/hnb659fds/version","Description":"Version of the CDK Bootstrap resources in this environment, automatically retrieved from SSM Parameter Store. [cdk:skip]"}

Conditions
[+] Condition CDKMetadata/Condition CDKMetadataAvailable: {"Fn::Or":[{"Fn::Or":[{"Fn::Equals":[{"Ref":"AWS::Region"},"af-south-1"]},{"Fn::Equals":[{"Ref":"AWS::Region"},"ap-east-1"]},{"Fn::Equals":[{"Ref":"AWS::Region"},"ap-northeast-1"]},{"Fn::Equals":[{"Ref":"AWS::Region"},"ap-northeast-2"]},{"Fn::Equals":[{"Ref":"AWS::Region"},"ap-south-1"]},{"Fn::Equals":[{"Ref":"AWS::Region"},"ap-southeast-1"]},{"Fn::Equals":[{"Ref":"AWS::Region"},"ap-southeast-2"]},{"Fn::Equals":[{"Ref":"AWS::Region"},"ca-central-1"]},{"Fn::Equals":[{"Ref":"AWS::Region"},"cn-north-1"]},{"Fn::Equals":[{"Ref":"AWS::Region"},"cn-northwest-1"]}]},{"Fn::Or":[{"Fn::Equals":[{"Ref":"AWS::Region"},"eu-central-1"]},{"Fn::Equals":[{"Ref":"AWS::Region"},"eu-north-1"]},{"Fn::Equals":[{"Ref":"AWS::Region"},"eu-south-1"]},{"Fn::Equals":[{"Ref":"AWS::Region"},"eu-west-1"]},{"Fn::Equals":[{"Ref":"AWS::Region"},"eu-west-2"]},{"Fn::Equals":[{"Ref":"AWS::Region"},"eu-west-3"]},{"Fn::Equals":[{"Ref":"AWS::Region"},"me-south-1"]},{"Fn::Equals":[{"Ref":"AWS::Region"},"sa-east-1"]},{"Fn::Equals":[{"Ref":"AWS::Region"},"us-east-1"]},{"Fn::Equals":[{"Ref":"AWS::Region"},"us-east-2"]}]},{"Fn::Or":[{"Fn::Equals":[{"Ref":"AWS::Region"},"us-west-1"]},{"Fn::Equals":[{"Ref":"AWS::Region"},"us-west-2"]}]}]}

Resources
[+] AWS::S3::Bucket my_bucket mybucketD601CBAA
[+] AWS::SSM::Parameter ABC ABC5C6A8F78

Other Changes
[+] Unknown Rules: {"CheckBootstrapVersion":{"Assertions":[{"Assert":{"Fn::Not":[{"Fn::Contains":[["1","2","3","4","5"],{"Ref":"BootstrapVersion"}]}]},"AssertDescription":"CDK bootstrap stack version 6 required. Please run 'cdk bootstrap' with a recent version of the CDK CLI."}]}}


✨  Number of stacks with differences: 1
```
The output is not very concise, but you can easily spot the two resources to be created:
```
[+] AWS::S3::Bucket my_bucket mybucketD601CBAA
[+] AWS::SSM::Parameter ABC ABC5C6A8F78
```

Let's deploy the infrastructure with `cdk deploy`. After the command succeeds, let's run `cdk diff` again:
```
cdk diff
Stack CdkStack
There were no differences

✨  Number of stacks with differences: 0
```

That is good, there are no differences, the current infrastructure matches the infrastructure plan.

### 2. Let's manually modify one of the AWS resources
Now, let's manually delete the SSM parameter and then, let's run `cdk diff` again. Ideally, we expect CDK to find out that the SSM parameter is missing. However, the output shows no changes again:
```
cdk diff
Stack CdkStack
There were no differences

✨  Number of stacks with differences: 0
```

## Drift detection with Terraform
### 1. Let's create the 2 AWS resources
Let's create infrastructure with Terraform which contains two resources: an S3 bucket and a SSM Parameter. First, we need to create a Terraform file, with  with contents like below:
```
resource "aws_s3_bucket" "example" {
  bucket = "test-bucket-cfn-111-03062021-bla"
}

resource "aws_ssm_parameter" "foo" {
  name  = "ABC"
  type  = "String"
  value = "abcdef"
}
```

Then we run:
```
$ terraform init
$ terraform plan -out my.tfplan
$ terraform apply "my.tfplan"
```
The 2 AWS resources are now created.

Then, we can detect drift in our configuration using the same CLI command:
```
$ terraform plan -out my.tfplan
aws_ssm_parameter.foo: Refreshing state... [id=ABC]
aws_s3_bucket.example: Refreshing state... [id=test-bucket-cfn-111-03062021-bla]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and
found no differences, so no changes are needed.
```

### 2. Let's manually modify one of the AWS resources
Then, let's remove the SSM Parameter, and then let's run the `terraform plan` command again.
```
$ terraform plan -out my.tfplan
aws_ssm_parameter.foo: Refreshing state... [id=ABC]
aws_s3_bucket.example: Refreshing state... [id=test-bucket-cfn-111-03062021-bla]

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_ssm_parameter.foo will be created
  + resource "aws_ssm_parameter" "foo" {
      + arn       = (known after apply)
      + data_type = (known after apply)
      + id        = (known after apply)
      + key_id    = (known after apply)
      + name      = "ABC"
      + tags_all  = (known after apply)
      + tier      = "Standard"
      + type      = "String"
      + value     = (sensitive value)
      + version   = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

──────────────────────────────────────────────────────────────────────────────

Saved the plan to: my.tfplan

To perform exactly these actions, run the following command to apply:
    terraform apply "my.tfplan"
```
The command not only correctly detected the drift (the deleted SSM Parameter), but also informs that in order to remediate (in order to re-create that SSM Parameter, we just need to run `terraform apply "my.tfplan"`.

Let's also note how great the default Terraform workflow is. There are two commands which you use on a daily basis `terraform plan` and `terraform apply`. The `terraform plan` not only records the plan of which resources are to be deployed so that the current infrastructure matches the target infrastructure. So it shows the preview of what is going to be deployed. But you can also use that command for drift detection.
