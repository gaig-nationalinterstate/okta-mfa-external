locals {
  # These users are only in specific environments and will cause the data source to fail if it doesnt exist.
  # The following conditions allow us to toggle the data source based on the enviroment Terraform is running against. 
  # 1 == TRUE; 0 == FALSE

  default-policy-lower-env = (
    var.env == "dev" ? 1 : (
      var.env == "tst" ? 1 : (
        var.env == "qa" ? 1 : (
          var.env == "stg" ? 1 : (
            var.env == "prd" ? 0 : 0
          )
        )
      )
    )
  )
  default-policy-prod = (
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

# The default policy for lower environments. Voice is not available in lower envs so needed to create a separate resource and toggle per env. 
resource "okta_policy_mfa_default" "default-policy-lower-env" {
  count  = local.default-policy-lower-env
  is_oie = "false"

  okta_otp = {
    consent_type = "NONE"
    enroll       = "OPTIONAL"
  }

  okta_password = {
    consent_type = "NONE"
    enroll       = "OPTIONAL"
  }

  okta_sms = {
    consent_type = "NONE"
    enroll       = "OPTIONAL"
  }
}

# The default policy for prod. Voice is only avaialable in prod so needed to create separate resource and toggle only for prod. 
resource "okta_policy_mfa_default" "default-policy-prod" {
  count  = local.default-policy-prod
  is_oie = "false"

  okta_call = {
    consent_type = "NONE"
    enroll       = "OPTIONAL"
  }

  okta_otp = {
    consent_type = "NONE"
    enroll       = "OPTIONAL"
  }

  okta_password = {
    consent_type = "NONE"
    enroll       = "OPTIONAL"
  }

  okta_sms = {
    consent_type = "NONE"
    enroll       = "OPTIONAL"
  }
}

resource "okta_policy_rule_mfa" "default-rule" {
  enroll             = "CHALLENGE"
  name               = "Default Rule"
  network_connection = "ANYWHERE"
  policy_id = (
    var.env == "prd" ? okta_policy_mfa_default.default-policy-prod[0].id : okta_policy_mfa_default.default-policy-lower-env[0].id
  )
  priority = "1"
  status   = "ACTIVE"
}