# Output data that will be used by other submodules to build other parts of the
# stack to support defined architecture

data "google_compute_instance" "instances" {
  count = "${var.server_count + var.node_count}"
  self_link = local.instances[count.index]
  depends_on = [ google_compute_instance.server, google_compute_instance.node ]
}

locals {
  public_ip_list = [
    for instance in data.google_compute_instance.instances : try(instance.network_interface[0].access_config.0.nat_ip, "no-public")
  ]
  list_lacks_public = contains(local.public_ip_list, "no-public")
  instances = flatten([google_compute_instance.server[*].self_link, google_compute_instance.node[*].self_link])
}

output "public_ip_list" {
  value = local.public_ip_list
}

output "ip_path" {
  value = local.list_lacks_public ? "network_interface.0.network_ip" : "network_interface.0.access_config.0.nat_ip"
}
