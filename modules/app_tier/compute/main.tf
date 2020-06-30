# ---------------------------------------------------------------------------------------------------------------------
# Instance Configuration used for autoscaling
# ---------------------------------------------------------------------------------------------------------------------
resource "oci_core_instance_configuration" "app_instance_configuration" {
  compartment_id = var.compartment_ocid
  display_name   = "app-instance-configuration"

  instance_details {
    instance_type = "compute"

    launch_details {
      compartment_id = var.compartment_ocid
      shape          = var.app_instance_shape
      display_name   = "AppInstanceConfiguration"

      create_vnic_details {
        subnet_id        = var.app_subnet_id
        display_name     = "appinstance"
        assign_public_ip = false
        hostname_label   = "appinstance"
      }

      extended_metadata = {
        ssh_authorized_keys = file (var.ssh_public_key)
        user_data           = base64encode(file("${path.module}/userdata/bootstrap"))
      }

      source_details {
        source_type = "image"
        image_id   = var.instance_image_ocid[var.region]
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
    backend_set_name = var.app_backendset_name
    load_balancer_id = var.app_load_balancer_id
    port             = var.app_server_port
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

  policies {
    capacity {
      initial = 1
      max     = 3
      min     = 1
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
  compartment_id = "${var.tenancy_ocid}"
}

data "template_file" "ad_names" {
  count = "${length(data.oci_identity_availability_domains.ad.availability_domains)}"
  template = "${lookup(data.oci_identity_availability_domains.ad.availability_domains[count.index], "name")}"
}
