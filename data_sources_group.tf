locals {
  # These groups are only in specific environments and will cause the data source to fail if it doesnt exist.
  # The following conditions allow us to toggle the data source based on the enviroment Terraform is running against. 
  # 1 == TRUE; 0 == FALSE
  Cognos_External = (
    var.env == "dev" ? 1 : (
      var.env == "tst" ? 0 : (
        var.env == "qa" ? 1 : (
          var.env == "stg" ? 0 : (
            var.env == "prd" ? 0 : 0
          )
        )
      )
    )
  )
  Cognos_Agents = (
    var.env == "dev" ? 0 : (
      var.env == "tst" ? 0 : (
        var.env == "qa" ? 0 : (
          var.env == "stg" ? 0 : (
            var.env == "prd" ? 1 : 0
          )
        )
      )
    )
  )
  Cognos_Customers = (
    var.env == "dev" ? 0 : (
      var.env == "tst" ? 0 : (
        var.env == "qa" ? 0 : (
          var.env == "stg" ? 0 : (
            var.env == "prd" ? 1 : 0
          )
        )
      )
    )
  )
  External_Users_Voice = (
    var.env == "dev" ? 0 : (
      var.env == "tst" ? 0 : (
        var.env == "qa" ? 0 : (
          var.env == "stg" ? 0 : (
            var.env == "prd" ? 1 : 0
          )
        )
      )
    )
  )
}

# Each Group data source can be toggled per environment.
# Use the locals above to toggle per environment.

# "Everyone" group exists in all tenants by default
data "okta_group" "Everyone" {
  name = "Everyone"
}

data "okta_group" "Agents" {
  name = "Agents"
}

data "okta_group" "External_Users" {
  name = "External_Users"
}

data "okta_group" "Cognos_External" {
  count = local.Cognos_External
  name  = "Cognos_External"
}

data "okta_group" "Cognos_Agents" {
  count = local.Cognos_Agents
  name  = "Cognos_Agents"
}

data "okta_group" "Cognos_Customers" {
  count = local.Cognos_Customers
  name  = "Cognos_Customers"
}

data "okta_group" "External_Users_Voice" {
  count = local.External_Users_Voice
  name  = "External_Users_Voice"
}