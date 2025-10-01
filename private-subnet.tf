# Source from https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet

resource "oci_core_subnet" "vcn-private-subnet"{

  # Required
  compartment_id = var.tenancy_ocid
  vcn_id = var.vcn_id
  cidr_block = var.private_cidr_block

  # Optional
  # Caution: For the route table id, use module.vcn.nat_route_id.
  # Do not use module.vcn.nat_gateway_id, because it is the OCID for the gateway and not the route table.
  route_table_id = var.vcn_nat_route_id
  security_list_ids = [oci_core_security_list.private-security-list.id]
  display_name = var.private_subnet_name
}