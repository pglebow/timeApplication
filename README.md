# timeApplication
Simple app to test deployment via Terraform on AWS Fargate using Graviton.  This application simply returns the current
time in response to a GET on the /time endpoint.  The infrastructure is deployed using Terraform and includes creation
of an HTTPS-protected subdomain.  To test this, try

`curls -s https://<SUBDOMAIN>.<DOMAIN>/time`

## Development Process
I'm very comfortable developing with Spring and Java, but less so with Fargate and Terraform.
I heavily used ChatGPT to help me develop those aspects of the project.  CODEX was tried but seemed
less useful than working with ChatGPT more directly.

### Lessons Learned
1. Learning through Q&A and working examples was useful and got me this project in a few hours.
2. CODEX seemed to struggle and I preferred using ChatGPT.  Specifically, it sometimes generated incorrect code, e.g., excluding files in a .Dockerignore that were later used.
3. Generation of the permission set for the deployment user was through trial and error.  I would have liked something more comprehensive from the start.  I could have chosen to read through the docs, but wanted to see how far I could get with ChatGPT.
4. ChatGPT produced a deployment script that was useful and worked.  However, when I deployed the app using a subdomain.domain, it did not update the test code at the end and still used the load balancer endpoint.  

## Identity Center Login
`aws sso login --profile deployer`

## Terraform Variables
Create a file called `terraform.tfvars` in this directory.
This file should contain values for:

- `route53_zone_id = "<ZONE_ID>"`
- `subdomain        = "<SUBDOMAIN>"`
- `container_image = "<IMAGE>"`

## Permission Set
To deploy this application, you need to create a user in the IAM Identity Center.
This user requires these permissions:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ECSDeployAccess",
            "Effect": "Allow",
            "Action": [
                "ecs:*",
                "ecr:*",
                "ec2:*",
                "elasticloadbalancing:*",
                "logs:*",
                "ssm:GetParameter",
                "ssm:GetParameters"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowServiceLinkedRole",
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole"
            ],
            "Resource": "*"
        },
        {
            "Sid": "IAMForFargateExecution",
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:ListRolePolicies",
                "iam:ListAttachedRolePolicies",
                "iam:ListInstanceProfilesForRole",
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy",
                "iam:PassRole"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowACMCertificateManagement",
            "Effect": "Allow",
            "Action": [
                "acm:RequestCertificate",
                "acm:DescribeCertificate",
                "acm:ListCertificates",
                "acm:DeleteCertificate",
                "acm:GetCertificate",
                "acm:ListTagsForCertificate"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowRoute53AccessForACMValidation",
            "Effect": "Allow",
            "Action": [
                "route53:GetHostedZone",
                "route53:ListHostedZones",
                "route53:ChangeResourceRecordSets",
                "route53:ListResourceRecordSets",
                "route53:GetChange"
            ],
            "Resource": "*"
        }
    ]
}
```
