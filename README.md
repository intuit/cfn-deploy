# cfn-deploy
<img src="https://github.com/intuit/cfn-deploy/blob/master/.github/cfn-deploy-logo.png" align=right alt="cfn-deploy" width="250"> 
A simple github action to deploy cloudformation yaml files to AWS

## Usage

An example workflow for deploying a cloudformation template follows.

```
 - uses: intuit/cfn-deploy@master
      env:
        AWS_REGION: us-east-2
        STACK_NAME: cfn-deploy
        TEMPLATE_FILE: ec2.yml
        PARAMETERS_FILE: parameter.json
        CAPABLITIES: CAPABILITY_IAM
        AWS_ACCESS_KEY_ID: ${{secrets.AWS_ACCESS_KEY_ID}}
        AWS_SECRET_ACCESS_KEY: ${{secrets.AWS_SECRET_ACCESS_KEY}}
```

**Note**: The stack will created if it does not exist. If the initial stack creation fails for some reason then it will be deleted instead of rolled back.

## Secrets

 - `AWS_ACCESS_KEY_ID` – (Required) The AWS access key part of your credentials [more info](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets)
 
 - `AWS_SECRET_ACCESS_KEY` – (Required) The AWS secret access key part of your credentials [more info](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets)

## Environment variables

All environment variables listed in the official documentation are supported.

The custom env variables to be added are:

`AWS_REGION` - Region to which you need to deploy your app<br>
`STACK_NAME` - Cloudformation Stack Name <br>
`TEMPLATE_FILE` - Cloudformation template yaml file<br>
`PARAMETERS_FILE` - (If required) Input parameters to the cloudformation stack as json file<br>
`CAPABLITIES` - IAM capablities for the cloudformation stack<br>
#### Optional
`WAIT_TIMEOUT` - Timeout in seconds to exit from "wait" of create/update stack.  

## Nested Stacks

Nested stacks creation is supported. You create a nested stack within another stack by using the `AWS::CloudFormation::Stack` resource.

Your root stack template should contain resource definitions for your nested stacks with the **S3 URLs** of their templates.

An example of a root stack template:
```
{
    "AWSTemplateFormatVersion" : "2010-09-09",
    "Resources" : {
        "myStack" : {
	       "Type" : "AWS::CloudFormation::Stack",
	       "Properties" : {
	        "TemplateURL" : "https://s3.amazonaws.com/cloudformation-templates-us-east-1/S3_Bucket.template",
              "TimeoutInMinutes" : "60"
	       }
        }
    },
    "Outputs": {
       "StackRef": {"Value": { "Ref" : "myStack"}},
       "OutputFromNestedStack" : {
             "Value" : { "Fn::GetAtt" : [ "myStack", "Outputs.BucketName" ] }
       }
    }
}
```

Refer to AWS docs for additional help: [Working with nested stacks](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-nested-stacks.html)

More example template snippets: [AWS CloudFormation template snippets](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/quickref-cloudformation.html#w2ab1c27c21c19b5)

## Contributing

See [Contributing](https://github.com/intuit/cfn-deploy/blob/master/.github/CONTRIBUTING.md)
