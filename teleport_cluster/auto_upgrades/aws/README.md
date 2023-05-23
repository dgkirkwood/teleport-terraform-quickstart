# Teleport Auto-Upgrade Endpoint

This code will create version server for Teleport auto-upgrades, as described [here](https://goteleport.com/docs/management/operations/self-hosted-automatic-agent-updates/?scope=enterprise).

The web server is hosted on S3, using CloudFront and ACM for TLS termination. Please note a pre-requisite for using this code is an existing hosted zone on Route53.

To test the AWS code, create a `terraform.tfvars` file in the `/aws/` folder with the following content
```
region = "us-west-2"
bucket-name = "your-unique-bucket-name"
hosted_zone = "example-route53-zone.com"
endpoint_name = "your-endpoint-name"
desired_version = "13.0.2"
critical = "no"
```
Where `hosted_zone` is an existing Route53 hosted zone.

`desired_version` is the target version of Teleport for your agents. This should match your auth and proxy versions.

`critical` is whether the update is critical or not. Must be yes or no. 

Then simply `terraform init` and `terraform apply`!

You will see an output which is what you will add to the updater endpoint configuration as per the [enroll instructions](dk-update3.teleportdemo.com/current).

Google examples and more to come.

