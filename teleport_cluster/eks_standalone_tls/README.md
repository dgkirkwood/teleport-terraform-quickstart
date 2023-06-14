# Teleport Quick Start with Terraform
## Teleport EKS Standalone deployment with Nginx Ingress

This repository Terraform code which will stand up a Teleport control plane in EKS, with Nginx as an ingress controller. Nginx terminates TLS for Teleport, with a certificate managed by cert-manager. This deployment demonstrates the TLS routing capability introduced with Teleport 13. See more on this feature [here](https://goteleport.com/docs/architecture/tls-routing/). This code is not designed for a production deployment, but rather for testing and lab scenarios. Terraform code for a Teleport HA deployment on AWS can be found [here](https://github.com/gravitational/teleport/tree/master/examples/aws/terraform/ha-autoscale-cluster).

## Pre-requisites
Please note the following pre-requisites for using this repository:
- A Route 53 hosted zone on AWS. This terraform code will create Route 53 'CNAME' records using this hosted zone. Please have a host name ready as an input for the Terraform code.
- Port 80 access to your EKS cluster to be able to complete the Let's Encrypt HTTP01 challenge. More information [here](https://letsencrypt.org/docs/challenge-types/#http-01-challenge).
- The Terraform binary on your local machine, or on a machine where you can perform the automated builds. Tested using Terraform v1.2.4
- AWS Credentials. Any of the accepted credential types for automated provisioning on AWS. Examples can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).

## How to use this repository

### Terraform Build
Terraform will create your EKS cluster, and all supporting AWS infrastructure for that cluster. Terraform will also deploy Nginx, cert-manager and Teleport into this cluster. You can take a look at the .tf files in this repository to understand what will be built. This is by no means a best-practice deployment, more one that will get you started quickly. 

1. Navigate to the `/teleport_cluster/eks_cluster` directory
2. Open the `variables.tf` file and inspect the required variables for this build.
3. Create a file named `terraform.tfvars` to satisfy the input variables. An example format for this file would be: 

```
region = "ap-southeast-2"
prefix = "short-unique-prefix"               # Any short character combination as a prefix for all created resources
cluster_fqdn = "your.cluster.domain.name"    # This will be the domain name for your Teleport cluster
hosted_zone = "domain.name"                  # This is your hosted zone (see pre-requisites). Must match domain from FQDN
teleport_version = "13.0.3"                  # Must be >13.0.0
ingress_name = "teleport"              
email_address = "your@email.com"             # Used for Let's Encrypt certificate
```

1. In the same directory, run `terraform init` to ensure Terraform has the right plugins loaded
2. Run `terraform plan` to see the resources created by this code and ensure there are no input or syntax errors
3. Run `terraform apply` to create the infrastructure and deployment. 
4. On the completion of the Terraform run, you will see the `cluster-url` output, which you can input to your browser to see the running Teleport service. 
5. If your service is up and running, you can configure your first role and user following the instructions [here](https://goteleport.com/docs/deploy-a-cluster/helm-deployments/kubernetes-cluster/#step-22-create-a-local-user). To authenticate to your Kubernetes cluster, complete one of the steps outlined [here](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html). The most common method is to use the AWS CLI - `aws eks update-kubeconfig --region=<your region> --name <your chosen prefix>`
