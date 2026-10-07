variable "cluster_name" {
  type    = string
  default = "citadel-cluster"
}

variable "k8s_version" {
  type    = string
  default = "1.33"
}



variable "iam_role_name" {
  type    = string
  default = "citadel_iam_role"
}

variable "iam_policy_name" {
  type    = string
  default = "citadel_iam_policy"
}


variable "association_name" {
  type    = string
  default = "citadel_association"
}




variable "vpc_id" {
  type = string
}
variable "private_subnets" {
  type = list(string)
}

variable "sg_id" {
  type = string
}
