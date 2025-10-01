# Source from https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet

resource "oci_core_subnet" "vcn-public-subnet"{

  # Required
  compartment_id = var.tenancy_ocid
  vcn_id = var.vcn_id
  cidr_block = var.public_cidr_block

  # Optional
  route_table_id = var.vcn_ig_route_id
  security_list_ids = [oci_core_security_list.public-security-list.id]
  display_name = var.public_subnet_name
}