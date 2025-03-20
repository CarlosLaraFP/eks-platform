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