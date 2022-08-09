# Teleport Quick Start with Terraform
## Kubernetes access for EKS

This repository contains Terraform code to stand up a EKS cluster, and install a Teleport agent so that the cluster can be accessed via your Teleport proxy.

## Pre-requisites
Please note the following pre-requisites for using this repository:
- A working, accessible Teleport cluster. You will need your proxy address as an input to this code. 
- Network connectivity between these EKS clusters and the mentioned Teleport proxy. The security groups in this repository are very permissive and allow all egress out of the created VPC. 
- A Teleport join token for Kubernetes. Please see instructions [here](https://goteleport.com/docs/kubernetes-access/getting-started/) or use `tctl tokens add --type=kube`
- The Terraform binary on your local machine, or on a machine where you can perform the automated builds. Tested with Terraform v1.2.4.
- AWS credentials. Any of the accepted credential types for automated provisioning on AWS. Examples can be found [here](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started).

## How to use this repository


### Terraform Build
Terraform is used to create one or more EKS clusters and all the supporting infrastructure for those clusters. Terraform will also use Helm to install the Teleport agent to facilitate Kubernetes access. Note this is not a production EKS deployment and many default options have been used. Thie repository makes use of the [AWS EKS module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest).

1. Navigate to the `/targets/kubernetes/eks` directory
2. Open the `variables.tf` file and inspect the required variables for this build.
3. Create a file named `terraform.tfvars` to satisfy the input variables. An example format for this file would be: 

```
   region = "ap-southeast-2"
   clustername = "my-eks-teleport"
   proxy_address = "myproxy.address.com:443"
   auth_token = "7ade998743ffe934573aacb"
   label_environment = "dev"
```

4. In the same directory, run `terraform init` to ensure Terraform has the right plugins loaded
5. Run `terraform plan` to see the resources created by this code and ensure there are no input or syntax errors
6. Run `terraform apply` to create the target clusters. 
7. Note that on completion of the Terraform run, you will not see any outputs by default. Your Kubernetes cluster should automatically join your Teleport cluster. The module creates a role binding between the ClusterRole of 'view' to a Kubernetes group named 'viewonly' which you can then map to your Teleport roles. If your cluster does not join, you can troubleshoot the cluster using `aws eks update-kubeconfig --region <region> --name <cluster name>` to authenticate, and then kubectl to investigate logs. 