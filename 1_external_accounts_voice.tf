locals {
  # These users are only in specific environments and will cause the data source to fail if it doesnt exist.
  # The following conditions allow us to toggle the data source based on the enviroment Terraform is running against. 
  # 1 == TRUE; 0 == FALSE

  external-accounts-prod-voice = (
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

resource "okta_policy_mfa" "external-accounts-prod-voice" {
  count           = local.external-accounts-prod-voice
  description     = "Used for external users accessing Okta Apps. Voice for users that don't have access to SMS."
  groups_included = [data.okta_group.External_Users_Voice[0].id]
  is_oie          = "false"
  name            = "Multifactor for External Accounts - Voice"

  okta_call = {
    consent_type = "NONE"
    enroll       = "REQUIRED"
  }

  okta_otp = {
    consent_type = "NONE"
    enroll       = "NOT_ALLOWED"
  }

  okta_password = {
    consent_type = "NONE"
    enroll       = "OPTIONAL"
  }

  okta_sms = {
    consent_type = "NONE"
    enroll       = "OPTIONAL"
  }

  priority = "1"
  status   = "ACTIVE"
}

resource "okta_policy_rule_mfa" "factor-enrollment-rule-voice" {
  count              = local.external-accounts-prod-voice
  enroll             = "CHALLENGE"
  name               = "Factor Enrollment Rule - Voice"
  network_connection = "ANYWHERE"
  policy_id          = okta_policy_mfa.external-accounts-prod-voice[0].id
  priority           = "1"
  status             = "ACTIVE"
}