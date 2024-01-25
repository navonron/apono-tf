resource "aws_vpc" "vpc" {
  for_each             = { for idx, vpc in var.vpc : idx => vpc }
  cidr_block           = each.value.cidr
  tags                 = each.value.tags
  enable_dns_support   = each.value.enable_dns_support
  enable_dns_hostnames = each.value.enable_dns_hostnames
}

