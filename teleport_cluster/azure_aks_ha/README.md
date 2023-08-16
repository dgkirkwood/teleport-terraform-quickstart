# Teleport Quick Start with Terraform
## Teleport Azure HA Deployment

This repository contains Terraform code which will stand up a Teleport control plane in AKS, backed by Azure PostgreSQL Flexible Server and Azure Blob Storage for High Availability. This resources in this deployment fall into two groups: Infrastructure (Resource group, networks, AKS cluster, PostgreSQL cluster, blob storage account, Service Principals etc.) and Applications (Cert Manager for managing certificate lifecycle in Kubernetes and Teleport for the actual cluster).This code is not designed for a production deployment, but rather for testing and lab scenarios.

## Pre-requisites
Please note the following pre-requisites for using this repository:
- An existing DNS Zone in Azure. As domain registration is outside the scope of this code, we assume you have a registered domain with the DNS handled in an existing Azure resource group. 
- The Terraform binary on your local machine, or on a machine where you can perform the automated builds. Tested using Terraform v1.4.6
- Azure Credentials. Any of the accepted credential types for automated provisioning on Azure. Examples can be found [here](https://registry.terraform.io/providers/hashicorp/azurerm/3.68.0/docs#authenticating-to-azure).

## How to use this repository

### Terraform Build
As long as you can satisfy the pre-requsites, Terraform will build everything you need for an Azure HA deployment in a contained Resource Group. You can take a look at the .tf files in this repository to understand what will be built. This is by no means a best-practice deployment, more one that will get you started quickly. 

1. Navigate to the `/teleport_cluster/azure_aks_ha` directory
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
