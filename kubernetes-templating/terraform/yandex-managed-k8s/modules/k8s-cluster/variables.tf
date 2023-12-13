variable "sa_name" {
  type = string
}

variable "k8s_version" {
  type = string
}

variable "folder_id" {
  type = string
}

variable "cloud_id" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "preemptible" {
  type = string
  default = "false"
}

variable "max_scale" {
  type = number
  default = 3
}



# variable "key_name" {
#   type = string
# }

# variable "domain-name" {
#   type = string
# }

# variable "email" {
#   type = string
# }





# variable "access_key" {}

# variable "secret_key" {}
