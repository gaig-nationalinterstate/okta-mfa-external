locals {
  voice = (
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

resource "okta_factor" "voice" {
  count       = local.voice
  active      = "true"
  provider_id = "okta_call"
}

resource "okta_factor" "verify" {
  active      = "true"
  provider_id = "okta_otp"
}

resource "okta_factor" "sms" {
  active      = "true"
  provider_id = "okta_sms"
}