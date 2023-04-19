locals {
  # These users are only in specific environments and will cause the data source to fail if it doesnt exist.
  # The following conditions allow us to toggle the data source based on the enviroment Terraform is running against. 
  # 1 == TRUE; 0 == FALSE

  # Factor Enrollment - "Multifactor for External Accounts" - Voice factor is not available in our external lower environments so a seperate resource was created.
  # This should be set to "0" for ONLY Production.
  external-accounts-lower-env = (
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
  # Factor Enrollment - "Multifactor for External Accounts" - Voice is only avaialble in our external Production tenant. 
  # This should be set to "1" for ONLY Production.
  external-accounts-prod = (
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
  # Use this in tenants that include user exclusions in the factor rule
  factor-enrollment-user-exclude = (
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
  # Use this in tenants that do NOT include user exclusions in the factor rule. 
  factor-enrollment = (
    var.env == "dev" ? 1 : (
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

resource "okta_policy_mfa" "external-accounts-prod" {
  count       = local.external-accounts-prod
  description = "Used for external users accessing Okta Apps. SMS only due to licensing restrictions. See authentication sign on policies for more info."
  groups_included = [
    data.okta_group.Agents.id,
    data.okta_group.Cognos_Agents[0].id,
    data.okta_group.Cognos_Customers[0].id,
    data.okta_group.External_Users.id
  ]
  is_oie = "false"
  name   = "Multifactor for External Accounts"

  okta_call = {
    consent_type = "NONE"
    enroll       = "OPTIONAL"
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
    enroll       = "REQUIRED"
  }

  priority = "1"
  status   = "ACTIVE"
}

resource "okta_policy_mfa" "external-accounts-lower-env" {
  count       = local.external-accounts-lower-env
  description = "Used for external users accessing Okta Apps. SMS only due to licensing restrictions. See authentication sign on policies for more info."
  groups_included = (
    var.env == "dev" ? [
      data.okta_group.Agents.id,
      data.okta_group.Cognos_External[0].id,
      data.okta_group.External_Users.id
      ] : (
      var.env == "tst" ? [
        data.okta_group.Agents.id,
        data.okta_group.External_Users.id
        ] : (
        var.env == "qa" ? [
          data.okta_group.Agents.id,
          data.okta_group.Cognos_External[0].id,
          data.okta_group.External_Users.id
          ] : (
          var.env == "stg" ? [
            data.okta_group.Agents.id,
            data.okta_group.External_Users.id
          ] : [""]
        )
      )
    )
  )
  is_oie = "false"
  name   = "Multifactor for External Accounts"

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
    enroll       = "REQUIRED"
  }

  priority = "1"
  status   = "ACTIVE"
}

# MFA Rules
# MFA rule for external accounts - Exclude users 
resource "okta_policy_rule_mfa" "factor-enrollment-user-exclude" {
  count              = local.factor-enrollment-user-exclude
  enroll             = "CHALLENGE"
  name               = "Factor Enrollment Rule"
  network_connection = "ANYWHERE"
  policy_id          = okta_policy_mfa.external-accounts-lower-env[0].id
  priority           = "1"
  status             = "ACTIVE"
  users_excluded = (
    var.env == "tst" ? [
      data.okta_user.Natl-Test[0].id,
      data.okta_user.Natl-Agent[0].id,
      data.okta_user.Natl-User[0].id
      ] : (
      var.env == "qa" ? [
        data.okta_user.Natl-Test[0].id,
        data.okta_user.Natl-Agent[0].id,
        data.okta_user.Natl-User[0].id,
        data.okta_user.NATLAgent[0].id
        ] : (
        var.env == "stg" ? [
          data.okta_user.Natl-Test[0].id,
          data.okta_user.Natl-Agent[0].id,
          data.okta_user.Natl-User[0].id
        ] : [""]
      )
    )
  )
}

# MFA Rule for external accounts - No user exclusions
resource "okta_policy_rule_mfa" "factor-enrollment" {
  count              = local.factor-enrollment
  enroll             = "CHALLENGE"
  name               = "Factor Enrollment Rule"
  network_connection = "ANYWHERE"
  policy_id = (
    var.env == "prd" ? okta_policy_mfa.external-accounts-prod[0].id : okta_policy_mfa.external-accounts-lower-env[0].id
  )
  priority = "1"
  status   = "ACTIVE"
}