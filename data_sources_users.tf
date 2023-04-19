locals {
  # These users are only in specific environments and will cause the data source to fail if it doesnt exist.
  # The following conditions allow us to toggle the data source based on the enviroment Terraform is running against. 
  # 1 == TRUE; 0 == FALSE
  Natl-Test = (
    var.env == "dev" ? 0 : (
      var.env == "tst" ? 1 : (
        var.env == "qa" ? 1 : (
          var.env == "stg" ? 1 : (
            var.env == "prd" ? 0 : 0
          )
        )
      )
    )
  )
  Natl-Agent = (
    var.env == "dev" ? 0 : (
      var.env == "tst" ? 1 : (
        var.env == "qa" ? 1 : (
          var.env == "stg" ? 1 : (
            var.env == "prd" ? 0 : 0
          )
        )
      )
    )
  )
  Natl-User = (
    var.env == "dev" ? 0 : (
      var.env == "tst" ? 1 : (
        var.env == "qa" ? 1 : (
          var.env == "stg" ? 1 : (
            var.env == "prd" ? 0 : 0
          )
        )
      )
    )
  )
  NATLAgent = (
    var.env == "dev" ? 0 : (
      var.env == "tst" ? 0 : (
        var.env == "qa" ? 1 : (
          var.env == "stg" ? 0 : (
            var.env == "prd" ? 0 : 0
          )
        )
      )
    )
  )
}

# Data Sources for Okta users. 
# Use locals abouve to toggle if the data source should be used for a specific environment. 

data "okta_user" "Natl-Test" {
  count = local.Natl-Test
  search {
    name  = "profile.firstName"
    value = "Natl"
  }

  search {
    name  = "profile.lastName"
    value = "Test"
  }
}

data "okta_user" "Natl-Agent" {
  count = local.Natl-Agent
  search {
    name  = "profile.firstName"
    value = "Natl"
  }

  search {
    name  = "profile.lastName"
    value = "Agent"
  }
}

data "okta_user" "Natl-User" {
  count = local.Natl-User
  search {
    name  = "profile.firstName"
    value = "Natl"
  }

  search {
    name  = "profile.lastName"
    value = "User"
  }
}

data "okta_user" "NATLAgent" {
  count = local.NATLAgent
  search {
    name  = "profile.firstName"
    value = "NATLAgent"
  }

  search {
    name  = "profile.lastName"
    value = "NationalInterstateInsuranceAgent"
  }
}