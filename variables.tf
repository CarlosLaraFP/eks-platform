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

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
}

variable "spot_instance_type" {
  description = "Instance type for the spot worker node"
  type        = string
  default     = "t3.nano"
}

variable "spot_price" {
  description = "Maximum price to pay for the spot instance"
  type        = string
  default     = "0.01"  # Adjust based on your budget and region
}