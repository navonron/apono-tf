module "connector" {
    source = "github.com/apono-io/terraform-modules/azure/connector-with-permissions/stacks/apono-connector"
    aponoToken = var.apono_token
    resourceGroup = var.rg_name
    ipAddressType = "Private"
    subnetIds = [var.snet_id]
}

### https://github.com/apono-io/terraform-modules/blob/main/azure/connector-with-permissions/stacks/apono-connector/cdk.tf.json