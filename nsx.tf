provider "nsxt" {
  host                  = var.nsx_manager
  username              = var.nsx_username
  password              = var.nsx_password
  allow_unverified_ssl  = true
  max_retries           = 10
  retry_min_delay       = 500
  retry_max_delay       = 5000
  retry_on_status_codes = [429]
}


data "nsxt_transport_zone" "overlay_transport_zone" {
  display_name = "TZ-Overlay"
}

data "nsxt_logical_tier0_router" "tier0_router" {
  display_name = "Pacific-T0-Gateway"
}

data "nsxt_edge_cluster" "edge_cluster" {
  display_name = "Edge-Cluster-01"
}


resource "nsxt_logical_router_link_port_on_tier0" "t0_port_to_t1" {
  description = "TIER0_PORT1 provisioned by Terraform"
  display_name = "t0_port_to_t1"
  logical_router_id = data.nsxt_logical_tier0_router.tier0_router.id
  tag {
    scope = "dev"
    tag   = "demo"
  }
}

resource "nsxt_logical_tier1_router" "tier1_router" {
  description = "RTR1 provisioned by Terraform"
  display_name = var.nsxt_t1_rt_name
  #failover_mode = "PREEMPTIVE"
  edge_cluster_id = data.nsxt_edge_cluster.edge_cluster.id
  enable_router_advertisement = true
  advertise_connected_routes = true
  advertise_static_routes = true
  advertise_nat_routes = true
  tag {
    scope = "dev"
    tag   = "demo"
  }
}

resource "nsxt_logical_router_link_port_on_tier1" "t1_port_to_t0" {
  description  = "TIER1_PORT1 provisioned by Terraform"
  display_name = "t1_port_to_t0"
  logical_router_id = nsxt_logical_tier1_router.tier1_router.id
  linked_logical_router_port_id = nsxt_logical_router_link_port_on_tier0.t0_port_to_t1.id
  tag {
    scope = "dev"
    tag   = "demo"
  }
}



resource "nsxt_logical_switch" "LS-01" {
  admin_state = "UP"
  description = "LogicalSwitch01 provisioned by Terraform"
  display_name = var.ls1_name
  transport_zone_id = data.nsxt_transport_zone.overlay_transport_zone.id
  replication_mode  = "MTEP"
  tag {
    scope = "dev"
    tag   = "demo"
  }
}

resource "nsxt_logical_switch" "LS-02" {
  admin_state = "UP"
  description = "LogicalSwitch02 provisioned by Terraform"
  display_name = var.ls2_name
  transport_zone_id = data.nsxt_transport_zone.overlay_transport_zone.id
  replication_mode  = "MTEP"
  tag {
    scope = "dev"
    tag   = "demo"
  }
}


resource "nsxt_logical_switch" "LS-03" {
  admin_state = "UP"
  description = "LogicalSwitch03 provisioned by Terraform"
  display_name = var.ls3_name
  transport_zone_id = data.nsxt_transport_zone.overlay_transport_zone.id
  replication_mode  = "MTEP"
  tag {
    scope = "dev"
    tag   = "demo"
  }
}



resource "nsxt_logical_port" "lp-01" {
  admin_state = "UP"
  description = "lp provisioned by Terraform"
  display_name = "lp-terraform-01"
  logical_switch_id = nsxt_logical_switch.LS-01.id

  tag {
    scope = "dev"
    tag   = "demo"
  }
}

resource "nsxt_logical_port" "lp-02" {
  admin_state = "UP"
  description = "lp provisioned by Terraform"
  display_name = "lp-terraform-02"
  logical_switch_id = nsxt_logical_switch.LS-02.id

  tag {
    scope = "dev"
    tag   = "demo"
  }
}

resource "nsxt_logical_port" "lp-03" {
  admin_state = "UP"
  description = "lp provisioned by Terraform"
  display_name = "lp-terraform-03"
  logical_switch_id = nsxt_logical_switch.LS-03.id

  tag {
    scope = "dev"
    tag   = "demo"
  }
}




resource "nsxt_logical_router_downlink_port" "lif-01" {
  description = "lif provisioned by Terraform"
  display_name = "lif-terraform-01"
  logical_router_id = nsxt_logical_tier1_router.tier1_router.id
  linked_logical_switch_port_id = nsxt_logical_port.lp-01.id
  ip_address = var.ls1_gw

  tag {
    scope = "dev"
    tag   = "demo"
  }
}

resource "nsxt_logical_router_downlink_port" "lif-02" {
  description = "lif provisioned by Terraform"
  display_name = "lif-terraform-02"
  logical_router_id = nsxt_logical_tier1_router.tier1_router.id
  linked_logical_switch_port_id = nsxt_logical_port.lp-02.id
  ip_address = var.ls2_gw

  tag {
    scope = "dev"
    tag   = "demo"
  }
}

resource "nsxt_logical_router_downlink_port" "lif-03" {
  description = "lif provisioned by Terraform"
  display_name = "lif-terraform-03"
  logical_router_id = nsxt_logical_tier1_router.tier1_router.id
  linked_logical_switch_port_id = nsxt_logical_port.lp-03.id
  ip_address = var.ls3_gw

  tag {
    scope = "dev"
    tag   = "demo"
  }
}



