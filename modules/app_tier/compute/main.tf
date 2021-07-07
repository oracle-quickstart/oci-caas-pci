# ---------------------------------------------------------------------------------------------------------------------
# Instance Configuration used for autoscaling
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_core_instance_configuration" "app_instance_configuration" {
  compartment_id = var.compartment_ocid
  display_name   = "app-instance-configuration"
  freeform_tags = {
    "Description" = "App Tier Instance Configuration",
    "Function"    = "Defines launch details for application tier"
  }

  instance_details {
    instance_type = "compute"


    launch_details {
      freeform_tags = {
        "Description" = "App Tier Instance",
        "Function"    = "Autoscaled application instance"
      }

      compartment_id = var.compartment_ocid
      shape          = var.app_instance_shape
      display_name   = "AppInstanceConfiguration"
      is_pv_encryption_in_transit_enabled = true

      create_vnic_details {
        subnet_id        = var.app_subnet_id
        display_name     = "appinstance"
        assign_public_ip = false
        hostname_label   = "appinstance"
        freeform_tags = {
          "Description" = "App Tier VNIC",
          "Function"    = "VNIC for application instance"
        }
      }

      extended_metadata = {
        ssh_authorized_keys = file (var.ssh_public_key)
        user_data           = base64encode(data.template_file.bootstrap.rendered)
      }

      source_details {
        source_type = "image"
        image_id    = data.oci_core_images.autonomous_images.images.0.id
      }
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Additional application storage
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_core_volume" "app_block_volume_paravirtualized" {
  count               = var.num_instances * var.num_paravirtualized_volumes_per_instance
  availability_domain = data.template_file.ad_names.*.rendered[count.index]
  compartment_id      = var.compartment_ocid
  display_name        = "AppBlockParavirtualized${count.index}"
  size_in_gbs         = var.app_storage_gb
}

# ---------------------------------------------------------------------------------------------------------------------
# Autoscaling instance pool
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_core_instance_pool" "app_instance_pool" {
  compartment_id            = var.compartment_ocid
  instance_configuration_id = oci_core_instance_configuration.app_instance_configuration.id
  size                      = "1"
  state                     = "RUNNING"
  display_name              = "AppInstance"
  freeform_tags = {
    "Description" = "App Tier Instance Pool",
    "Function"    = "Autoscaling pool for Application Tier"
  }

  # To allow updates to instance_configuration without a conflict with the pool
  lifecycle {
    create_before_destroy = true
  }

  placement_configurations {
    availability_domain = lookup(data.oci_identity_availability_domains.ad.availability_domains[0],"name")
    primary_subnet_id   = var.app_subnet_id
  }

  placement_configurations {
    availability_domain = lookup(data.oci_identity_availability_domains.ad.availability_domains[1],"name")
    primary_subnet_id   = var.app_subnet_id
  }

  placement_configurations {
    availability_domain = lookup(data.oci_identity_availability_domains.ad.availability_domains[2],"name")
    primary_subnet_id   = var.app_subnet_id
  }

  load_balancers {
    backend_set_name = var.dmz_backendset_name
    load_balancer_id = var.dmz_load_balancer_id
    port             = var.tomcat_config["http_port"]
    vnic_selection   = "PrimaryVnic"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# Autoscaling configuration
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_autoscaling_auto_scaling_configuration" "app_autoscaling_configuration" {
  compartment_id       = var.compartment_ocid
  cool_down_in_seconds = 300
  display_name         = "app_server_autoscaling_config"
  is_enabled           = true
  freeform_tags = {
    "Description" = "App Tier Autoscaling Configuration",
    "Function"    = "Defines autoscaling policy for application tier"
  }

  policies {
    capacity {
      initial = var.app_autoscaling_initial
      max     = var.app_autoscaling_max
      min     = var.app_autoscaling_min
    }

    display_name = "AppServerScalingPolicy"
    policy_type  = "threshold"

    rules {
      action {
        type  = "CHANGE_COUNT_BY"
        value = 1
      }

      display_name = "AppServerScaleOutRule"

      metric {
        metric_type = "CPU_UTILIZATION"

        threshold {
          operator = "GT"
          value    = 80
        }
      }
    }

    rules {
      action {
        type  = "CHANGE_COUNT_BY"
        value = "-1"
      }

      display_name = "AppServerScaleInRule"

      metric {
        metric_type = "CPU_UTILIZATION"

        threshold {
          operator = "LT"
          value    = 10
        }
      }
    }
  }

  auto_scaling_resources {
    id   = oci_core_instance_pool.app_instance_pool.id
    type = "instancePool"
  }
}

# Get a list of availability domains
data "oci_identity_availability_domains" "ad" {
  compartment_id = var.tenancy_ocid
}

data "template_file" "ad_names" {
  count = length(data.oci_identity_availability_domains.ad.availability_domains)
  template = lookup(data.oci_identity_availability_domains.ad.availability_domains[count.index], "name")
}

resource "random_string" "wallet_password" {
  length  = 16
  special = true
}

data "template_file" bootstrap {
  template = file("${path.module}/userdata/bootstrap")

  vars = {
    bootstrap_bucket = var.oci_caas_bootstrap_bucket
    bootstrap_bundle = var.oci_caas_app_bootstrap_bundle
    cinc_version     = var.cinc_version
    vcn_cidr_block   = var.vcn_cidr_block
    app_war_file     = var.app_war_file
    tomcat_version   = var.tomcat_config["version"]
    shutdown_port    = var.tomcat_config["shutdown_port"]
    http_port        = var.tomcat_config["http_port"]
    https_port       = var.tomcat_config["https_port"]
    wazuh_server     = var.wazuh_server
    compartment_id   = var.compartment_ocid
    database_id      = var.database_id
    database_name    = var.database_name
    unique_prefix    = var.unique_prefix
    wallet_password  = random_string.wallet_password.result
  }
}