resource "openstack_compute_instance_v2" "dashboard" {
  name      = "cloud-info-api"
  image_id  = var.image_id
  flavor_id = var.flavor_id
  user_data = file("cloud-init.yaml")
  network {
    uuid = var.net_id
  }
  security_groups = [openstack_compute_secgroup_v2.secgroup.name, "default"]
}

resource "openstack_compute_secgroup_v2" "secgroup" {
  name        = "HTTP"
  description = "HTTP and HTTPS access"

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_networking_floatingip_v2" "fip" {
  pool = var.ip_pool
}

resource "openstack_compute_floatingip_associate_v2" "fip" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  instance_id = openstack_compute_instance_v2.dashboard.id
}

output "public_ip" {
  value = openstack_networking_floatingip_v2.fip.address
}
