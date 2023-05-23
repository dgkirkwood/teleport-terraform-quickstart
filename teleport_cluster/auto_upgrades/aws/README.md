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

`bucket-name` is the created bucket to store the update settings.

`desired_version` is the target version of Teleport for your agents. This should match your auth and proxy versions.

`critical` is whether the update is critical or not. Must be yes or no. 

Your site will be `https://<endpoint_name>.<hosted_zone>/current` so that would be https://your-endpoint-name.example-route43-zone.com/current with
the above values.


To run:

```bash
terraform init
# Confirm the settings before applying
terraform plan
# apply
terraform apply
# After running you will get this type of output
# cloudfront_domain = "your-endpoint-name.example-route53-zone.com/current"
```

You will see an output which is what you will add to the updater endpoint configuration as per the [enroll instructions](https://goteleport.com/docs/management/operations/enroll-agent-into-automatic-updates/).

To test:

```bash
# Replace the endpoint with yours
AGENT_ENDPOINT=https://agentupdate.example.com/current
curl ${AGENT_ENDPOINT}/version
# version number
curl ${AGENT_ENDPOINT}/critical
# no or yes
```

Note that any other endpoint attempt will return a `AccessDenied` error by default.

Google examples and more to come.
