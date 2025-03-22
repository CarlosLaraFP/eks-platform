resource "local_file" "pet" { // provider: local, resource: file, and resource name can be anything
    filename = var.filename
    content = "We love pets!"
    file_permission = "0700"
}

resource "random_pet" "my-pet" {
    prefix = var.pet[0]
    separator = var.pet[1]
    length = var.pet[2]
}

// terraform init
// terraform plan
// terraform apply -auto-approve
// terraform show
// terraform destroy

// aws eks update-kubeconfig --region us-west-2 --name my-eks-cluster
// ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'
// export TF_VAR_account_id=