# ---------------------------------------------------------------------------------------------------------------------
# Create WAF and DNS CNAME for user access
# For formatting information: https://docs.cloud.oracle.com/en-us/iaas/Content/WAF/Concepts/gettingstarted.htm#upload
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# Example of a custom protection rule
# For more information: https://docs.cloud.oracle.com/en-us/iaas/Content/WAF/Tasks/customprotectionrules.htm
# ---------------------------------------------------------------------------------------------------------------------
# resource "oci_waas_custom_protection_rule" "custom_protection_rule" {
#   compartment_id = var.compartment_ocid
#   display_name   = "my_custom_protection_rule"
#   template       = "SecRule REQUEST_URI / \"phase:2,   t:none,   capture,   msg:'Custom (XSS) Attack. Matched Data: %%{TX.0}   found within %%{MATCHED_VAR_NAME}: %%{MATCHED_VAR}',   id:{{id_1}},   ctl:ruleEngine={{mode}},   tag:'Custom',   severity:'2'\""
#   description    = "Custom protection rule"
# }

# ---------------------------------------------------------------------------------------------------------------------
# Allowing VCN CIDR block to bypass WAF rules
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_waas_address_list" "admin_cidr_block" {
  addresses      = [var.vcn_cidr_block]
  compartment_id = var.compartment_ocid
  display_name   = "admin-cidr-block"
  freeform_tags = {
    "Description" = "Admin CIDR block"
    "Function"    = "Used to bypass the WAF rules internally"
  }
}

resource "oci_waas_waas_policy" "waas_policy" {
  compartment_id = var.compartment_ocid
  domain         = var.domain_name
  display_name   = var.waas_policy_display_name
  freeform_tags = {
    "Description" = "WAF/WAAS rules"
    "Function"    = "Web filtering and rule engine"
  }

  origin_groups {
    label = "originGroup1"

    origin_group {
      origin = "frontend-lb"
      weight = "1"
    }
  }

  origins {
    label      = "frontend-lb"
    uri        = var.dmz_load_balancer_ip
    https_port = "443"

    #Optional
    # custom_headers {
      #Required
      # name  = "name1"
      # value = "value1"
    # }
  }

  policy_config {
    certificate_id                = var.frontend_ssl_certificate_id
    cipher_group                  = "DEFAULT"
    client_address_header         = "X_FORWARDED_FOR"
    is_behind_cdn                 = false
    is_cache_control_respected    = true
    is_https_enabled              = true
    is_https_forced               = true
    is_origin_compression_enabled = true
    is_response_buffering_enabled = true
    is_sni_enabled                = true
    websocket_path_prefixes       = ["/url1"]
    tls_protocols                 = ["TLS_V1_3"]
  }

  timeouts {
    create = "120m"
    delete = "120m"
    update = "120m"
  }

  waf_config {
    access_rules {
      #Required
      action = "BLOCK"

      criteria {
        #Required
        condition = "URL_IS"
        value     = "/private"
      }

      name = "example_access_rule"

      #Optional
      block_action                 = "SET_RESPONSE_CODE"
      block_error_page_code        = 403
      block_error_page_description = "blockErrorPageDescription"
      block_error_page_message     = "blockErrorPageMessage"
      block_response_code          = 403
      bypass_challenges            = ["JS_CHALLENGE"]
      redirect_response_code       = "FOUND"
      redirect_url                 = "http://192.168.0.3"
      captcha_footer               = "captchaFooter"
      captcha_header               = "captchaHeader"
      captcha_submit_label         = "captchaSubmitLabel"
      captcha_title                = "captchaTitle"

      response_header_manipulation {
        #Required
        action = "EXTEND_HTTP_RESPONSE_HEADER"
        header = "header"

        #Optional
        value = "value"
      }
    }

    address_rate_limiting {
      #Required
      is_enabled = true

      #Optional
      allowed_rate_per_address      = 200
      block_response_code           = 403
      max_delayed_count_per_address = 60
    }

    caching_rules {
      #Required
      action = "CACHE"

      criteria {
        #Required
        condition = "URL_IS"
        value     = "/public"
      }

      name = "name"

      #Optional
      caching_duration          = "PT1S"
      client_caching_duration   = "PT1S"
      is_client_caching_enabled = false
      key                       = "key"
    }

    captchas {
      #Required
      failure_message               = "message"
      session_expiration_in_seconds = 10
      submit_label                  = "label"
      title                         = "title"
      url                           = "url"

      #Optional
      footer_text = "footer_text"
      header_text = "header_text"
    }

    # Example of custom protection rules
    # custom_protection_rules {
    #   #Optional
    #   action = "DETECT"
    #   id     = oci_waas_custom_protection_rule.custom_protection_rule.id

    #   exclusions {
    #     exclusions = ["example.com"]
    #     target     = "REQUEST_COOKIES"
    #   }
    # }

    device_fingerprint_challenge {
      #Required
      is_enabled = true

      #Optional
      action                       = "DETECT"
      action_expiration_in_seconds = 10

      challenge_settings {
        #Optional
        block_action                 = "SET_RESPONSE_CODE"
        block_error_page_code        = 403
        block_error_page_description = "blockErrorPageDescription"
        block_error_page_message     = "blockErrorPageMessage"
        block_response_code          = 403
        captcha_footer               = "captchaFooter"
        captcha_header               = "captchaHeader"
        captcha_submit_label         = "captchaSubmitLabel"
        captcha_title                = "captchaTitle"
      }

      failure_threshold                       = 10
      failure_threshold_expiration_in_seconds = 10
      max_address_count                       = 10
      max_address_count_expiration_in_seconds = 10
    }

    human_interaction_challenge {
      #Required
      is_enabled = false

      #Optional
      action                       = "DETECT"
      action_expiration_in_seconds = 10

      challenge_settings {
        #Optional
        block_action                 = "SET_RESPONSE_CODE"
        block_error_page_code        = 403
        block_error_page_description = "blockErrorPageDescription"
        block_error_page_message     = "blockErrorPageMessage"
        block_response_code          = 403
        captcha_footer               = "captchaFooter"
        captcha_header               = "captchaHeader"
        captcha_submit_label         = "captchaSubmitLabel"
        captcha_title                = "captchaTitle"
      }

      failure_threshold                       = 10
      failure_threshold_expiration_in_seconds = 10
      interaction_threshold                   = 10
      recording_period_in_seconds             = 10

      set_http_header {
        #Required
        name  = "hc_name1"
        value = "hc_value1"
      }
    }

    js_challenge {
      #Required
      is_enabled = true

      #Optional
      action                       = "DETECT"
      action_expiration_in_seconds = 10
      are_redirects_challenged     = true
      is_nat_enabled               = true

      criteria {
        #Required
        condition = "URL_IS"
        value     = "/public"

        #Optional
        is_case_sensitive = true
      }

      challenge_settings {
        #Optional
        block_action                 = "SET_RESPONSE_CODE"
        block_error_page_code        = 403
        block_error_page_description = "blockErrorPageDescription"
        block_error_page_message     = "blockErrorPageMessage"
        block_response_code          = 403
        captcha_footer               = "captchaFooter"
        captcha_header               = "captchaHeader"
        captcha_submit_label         = "captchaSubmitLabel"
        captcha_title                = "captchaTitle"
      }

      failure_threshold = 10
    }

    origin        = "frontend-lb"
    origin_groups = ["originGroup1"]

    protection_settings {
      #Optional
      allowed_http_methods               = ["OPTIONS", "HEAD"]
      block_action                       = "SET_RESPONSE_CODE"
      block_error_page_code              = 403
      block_error_page_description       = "blockErrorPageDescription"
      block_error_page_message           = "blockErrorPageMessage"
      block_response_code                = 403
      is_response_inspected              = false
      max_argument_count                 = 10
      max_name_length_per_argument       = 10
      max_response_size_in_ki_b          = 10
      max_total_name_length_of_arguments = 10
      media_types                        = ["application/plain", "application/json"]
      recommendations_period_in_days     = 10
    }

    #Optional
    whitelists {
      name = "admin_allow_list"
      address_lists = [oci_waas_address_list.admin_cidr_block.id]
    }
  }
}

# data "oci_waas_waas_policies" "test_waas_policies" {
#   #Required
#   compartment_id = var.compartment_ocid

#   #Optional
#   display_names                         = [var.waas_policy_display_name]
#   ids                                   = [oci_waas_waas_policy.waas_policy.id]
#   states                                = ["ACTIVE"]
#   time_created_greater_than_or_equal_to = "2018-01-01T00:00:00.000Z"
#   time_created_less_than                = "2038-01-01T00:00:00.000Z"
# }

# Example of a custom proteciton rule
# data "oci_waas_custom_protection_rules" "custom_protection_rules" {
#   #Required
#   compartment_id = var.compartment_ocid

#   #Optional
#   display_names                         = ["tf_example_protection_rule"]
#   ids                                   = [oci_waas_custom_protection_rule.custom_protection_rule.id]
#   states                                = ["ACTIVE"]
#   time_created_greater_than_or_equal_to = "2018-01-01T00:00:00.000Z"
#   time_created_less_than                = "2038-01-01T00:00:00.000Z"
# }

# resource "oci_waas_http_redirect" "test_http_redirect" {
#   #Required
#   compartment_id = var.compartment_ocid
#   domain         = "example3.com"

#   target {
#     #Required
#     host     = "example4.com"
#     path     = "/test{path}"
#     protocol = "HTTP"
#     query    = "{query}"

#     #Optional
#     port = "8080"
#   }

#   #Optional
#   display_name = "displayName"

#   freeform_tags = {
#     "Department" = "Finance"
#   }

#   response_code = 301
# }

# data "oci_waas_http_redirects" "test_http_redirects" {
#   #Required
#   compartment_id = var.compartment_ocid

#   #Optional
#   display_names                         = [oci_waas_http_redirect.test_http_redirect.display_name]
#   ids                                   = [oci_waas_http_redirect.test_http_redirect.id]
#   states                                = [oci_waas_http_redirect.test_http_redirect.state]
#   time_created_greater_than_or_equal_to = "2018-01-01T00:00:00.000Z"
#   time_created_less_than                = "2038-01-01T00:00:00.000Z"
# }

# ---------------------------------------------------------------------------------------------------------------------
# Register front-end ALIAS record to point to the WAF
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_dns_record" "waf_alias" {
  compartment_id  = var.compartment_ocid
  zone_name_or_id = var.domain_name
  domain = var.domain_name
  rtype = "ALIAS"
  rdata = oci_waas_waas_policy.waas_policy.cname
  ttl   = 30
}
