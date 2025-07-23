# timeApplication
Simple app to test deployment via Terraform on AWS

## Terraform Variables
Create a file called `terraform.tfvars` in this directory.
This file should contain values for:

`route53_zone_id = "<ZONE_ID>"`
`subdomain        = "<SUBDOMAIN>"`
`container_image = "<IMAGE>`