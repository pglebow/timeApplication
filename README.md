# timeApplication
Simple app to test deployment via Terraform on AWS Fargate using Graviton.

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
