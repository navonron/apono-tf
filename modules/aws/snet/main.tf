resource "aws_subnet" "snet" {
  for_each          = { for idx, snet in var.snet : idx => snet }
  vpc_id            = each.value.vpc_id
  cidr_block        = each.value.cidr
  tags              = each.value.tags
  availability_zone = each.value.az
}
