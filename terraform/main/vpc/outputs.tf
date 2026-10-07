output "vpc_id" {
  value = module.vpc.vpc_id
}
output "private_subnets" {
  value = module.vpc.private_subnets
}
output "sg_id" {
  value = module.security_group.security_group_id
}
