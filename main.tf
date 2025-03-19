resource "local_file" "pet" { // provider: local, resource: file, and resource name can be anything
    filename = "pets.txt"
    content = "We love pets!"
    file_permission = "0700"
}

resource "random_pet" "my-pet" {
    prefix = "Mrs"
    separator = "."
    length = "1"
}

// terraform init
// terraform plan
// terraform apply
// terraform show
// terraform destroy