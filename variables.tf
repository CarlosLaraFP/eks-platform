variable filename {
  default = "pets.txt"
  type = string
}

variable length {
  default = 1
  type = number
}

variable pet {
    type = tuple([string, string, number])
    default = ["Mr", ".", 2]
}

variable cat {
    type = map(number)
    default = {
      "id" = 1
      "hello" = 2
    }
}

variable struct {
    type = object({
      prefix = string,
      separator = string,
      length = number
    })

    default = {
      prefix = "Mr",
      separator = ".",
      length = 2
    }
}

variable "account_id" {
    description = "AWS account ID"
    type = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
}

variable "spot_instance_types" {
  description = "Instance types for the spot worker node"
  type        = list(string)
  default     = ["t3.nano", "t4g.nano", "t3a.nano", "t4g.micro", "t3a.micro", "t3.micro", "t4g.small", "t3a.small", "t3.small"]
}

variable "spot_price" {
  description = "Maximum price to pay for the spot instance"
  type        = string
  default     = "0.01"  # Adjust based on your budget and region
}