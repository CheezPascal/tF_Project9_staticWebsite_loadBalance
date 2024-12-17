# tF_Project9_staticWebsite_loadBalance
I made a terraform project with 4 VM's using AWS and set up to test load balancing as well as Splunk forwarder 

Terraform AWS Load Balancer Project
Overview
This project provisions 4 EC2 instances on AWS using Terraform:

* 2 Ubuntu instances:
  - One serves a "Main" static website.
  - The other serves a "Website Outage" page.
* 2 Windows instances:
  - Not part of the load balancer.
* An Application Load Balancer (ALB) to distribute traffic between the two Ubuntu instances.

Architecture
* Load Balancer:
Balances HTTP traffic between the Ubuntu instances.
* Security Groups:
Allow HTTP (port 80) and RDP (port 3389) access.

Prerequisites
* Terraform installed.
* AWS credentials configured (aws configure).
* An existing AWS key pair for SSH access.

Deployment
Clone this repository:
using git clone <repo url>

Initialize and deploy using Terraform:

terraform init
terraform plan
terraform apply

Retrieve the Load Balancer DNS from the Terraform output:

terraform output load_balancer_dns
Open the DNS in a browser to view the Main or Outage pages.

Outputs
* Load Balancer DNS: Access point for the load-balanced Ubuntu instances.

Cleanup
To destroy all resources:

terraform destroy


Notes:
Replace your-key-pair in the code with your actual AWS key pair name.
Ubuntu instances are configured with HTTPD to serve static web pages.
Windows instances are provisioned but excluded from the load balancer.