# Source from https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_security_list

resource "oci_core_security_list" "private-security-list" {

  # Required
  compartment_id = var.tenancy_ocid
  vcn_id         = var.vcn_id

  # Optional
  display_name = var.private_sec_list_name

  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }


  ingress_security_rules {
    stateless   = false
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    # Get protocol numbers from https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml ICMP is 1
    protocol = "1"

    # For ICMP type and code see: https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
    icmp_options {
      type = 3
    }
  }

  ingress_security_rules {
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false

    icmp_options {
      code = 4
      type = 3
    }
  }
  ingress_security_rules {
    protocol    = "17"
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = false

  }
  ingress_security_rules {
    protocol    = "6"
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 22
      min = 22
    }
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "10.0.0.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 30233
      min = 30233
    }
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "10.0.0.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 30277
      min = 30277
    }
  }
  ingress_security_rules {
    protocol    = "6"
    source      = "10.0.0.0/24"
    source_type = "CIDR_BLOCK"
    stateless   = false

    tcp_options {
      max = 31793
      min = 31793
    }
  }

  ingress_security_rules {
    stateless   = false
    source      = "10.0.1.0/24"
    source_type = "CIDR_BLOCK"
    protocol    = "6" # TCP
    tcp_options {
      min = 3306
      max = 3306
    }
  }
}
