# Kubernetes workload visibility with rancher (tutorial)
This repository contains terraform script and kubernetes yaml files for an article written for Ambassador Labs as a Guest writer. The article explains how rancher can user to visualise kubernetes workload and how cluster administrators can easily manager user authenticate and autorization via the simple-to-use Rancher server UI.
## Deploy Infrastructure
> Please be aware that deploying this infrastructure would cost you some $$ on AWS. 

Prerequisites

* Install terraform (>=v0.14.6)
* [Configure AWS Credentials](https://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/setup-credentials.html)

Clone this repository
```bash
git clone https://github.com/hydeenoble/kubernetes-workload-visibility-with-rancher-tutorial.git
```

Initialize Terraform modules
```bash
cd kubernetes-workload-visibility-with-rancher-tutorial
terraform init 
```

Provide Variables

create a file named `terraform.tfvars` in the root directory and correct vaules for the following variables: 

```
rancher_key_pair_key_pair="ssh-rsa ..."

iam_username="<username that owns the AWS credentials previously configured>"

aws_account_id="<AWS account ID>"
```

Deploy
```bash
terraform apply
```

## Clean Up

To delete all recently provisioned infrastructure, run the command below: 
```
terraform destroy
```
## License
[MIT](LICENSE)