resource "oci_core_instance_configuration" "web_instance_configuration" {
  compartment_id = var.compartment_ocid
  display_name   = "web-instance-configuration"

  instance_details {
    instance_type = "compute"

    launch_details {
      compartment_id = var.compartment_ocid
      shape          = var.web_instance_shape
      display_name   = "WebInstanceConfiguration"

      create_vnic_details {
        subnet_id        = var.web_subnet_id
        display_name     = "Primaryvnic"
        assign_public_ip = false
        hostname_label   = "webinstance"
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

resource "oci_core_volume" "web_block_volume_paravirtualized" {
  count               = var.num_instances * var.num_paravirtualized_volumes_per_instance
  availability_domain = data.template_file.ad_names.*.rendered[count.index]
  compartment_id      = var.compartment_ocid
  display_name        = "WebBlockParavirtualized${count.index}"
  size_in_gbs         = var.web_storage_gb
}

resource "oci_core_instance_pool" "web_instance_pool" {
  compartment_id            = var.compartment_ocid
  instance_configuration_id = oci_core_instance_configuration.web_instance_configuration.id
  size                      = "0"
  state                     = "RUNNING"
  display_name              = "WebInstancePool"

   placement_configurations {
     availability_domain = lookup(data.oci_identity_availability_domains.ad.availability_domains[0],"name")
     primary_subnet_id   = var.web_subnet_id
   }

   placement_configurations {
     availability_domain = lookup(data.oci_identity_availability_domains.ad.availability_domains[1],"name")
     primary_subnet_id   = var.web_subnet_id
   }

   placement_configurations {
     availability_domain = lookup(data.oci_identity_availability_domains.ad.availability_domains[2],"name")
     primary_subnet_id   = var.web_subnet_id
   }

  load_balancers {
    backend_set_name = var.dmz_backendset_name
    load_balancer_id = var.dmz_load_balancer_id
    port             = var.web_server_port
    vnic_selection   = "PrimaryVnic"
  }
}

// Create autoscaling configuration
resource "oci_autoscaling_auto_scaling_configuration" "web_autoscaling_configuration" {
  compartment_id       = var.compartment_ocid
  cool_down_in_seconds = 300
  display_name         = "web_server_autoscaling_config"
  is_enabled           = true

  policies {
    capacity {
      initial = 1
      max     = 3
      min     = 1
    }

    display_name = "WebServerScalingPolicy"
    policy_type  = "threshold"

    rules {
      action {
        type  = "CHANGE_COUNT_BY"
        value = 1
      }

      display_name = "WebServerScaleOutRule"

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

      display_name = "WebServerScaleInRule"

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
    id   = oci_core_instance_pool.web_instance_pool.id
    type = "instancePool"
  }
}
