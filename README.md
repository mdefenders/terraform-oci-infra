# Terraform OCI Infrastructure Module

## Overview
This Terraform module provisions foundational Oracle Cloud Infrastructure (OCI) networking and identity components for an OKE (Oracle Kubernetes Engine) or general compute environment. Specifically, it:

- Creates a dedicated compartment.
- Creates two security lists (public and private) with opinionated ingress/egress rules.
- Creates one public subnet and one private subnet inside an existing Virtual Cloud Network (VCN).
- Exposes useful outputs including resource OCIDs and availability domains.

The module assumes an existing VCN and associated route tables for an Internet Gateway (IG) and a NAT Gateway. You supply those as input variables (`vcn_id`, `vcn_ig_route_id`, `vcn_nat_route_id`).

## Architecture Components
| Component | Type | Purpose |
|----------|------|---------|
| `oci_identity_compartment.tf-compartment` | Compartment | Logical isolation boundary for subsequent OKE / infra resources. |
| `oci_core_security_list.public-security-list` | Security List | Rules for internet-facing workloads (SSH, HTTP, HTTPS, ICMP). |
| `oci_core_security_list.private-security-list` | Security List | Rules for internal/private workloads (restricted TCP ports + ICMP). |
| `oci_core_subnet.vcn-public-subnet` | Subnet (Public) | Publicly accessible subnet using the Internet Gateway route table. |
| `oci_core_subnet.vcn-private-subnet` | Subnet (Private) | Private subnet using the NAT Gateway route table. |

## Security List Rules Summary
### Public Security List
Ingress:
- TCP 22 from 0.0.0.0/0 (SSH)
- TCP 80 from 0.0.0.0/0 (HTTP)
- TCP 443 from 0.0.0.0/0 (HTTPS)
- ICMP types 3 (and code 4) for diagnostics from 0.0.0.0/0
- ICMP type 3 from 10.0.0.0/16 (internal diagnostics)

Egress:
- Allow all to 0.0.0.0/0
- Specific TCP egress to private subnet CIDR segment (10.0.1.0/24) on ports 30233, 30277, 31793 (likely OKE / control plane related)

### Private Security List
Ingress:
- ICMP type 3 from 10.0.0.0/16
- ICMP type 3 code 4 from 0.0.0.0/0
- TCP 22 from 10.0.0.0/16
- TCP 30233, 30277, 31793 from 10.0.0.0/24 (cluster internal / node ports)
- TCP 3306 from 10.0.1.0/24 (database / internal service example)
- All UDP (protocol 17) from 10.0.0.0/16

Egress:
- Allow all to 0.0.0.0/0

> IMPORTANT: These rules are intentionally permissive for internal ranges (`10.0.0.0/16`). Review and harden for production (principle of least privilege, narrow CIDR ranges, restrict management ports, evaluate network security groups (NSGs) as an alternative to broad security lists).

## Prerequisites
Before using this module you must already have:
1. An existing VCN (with its OCID).
2. An Internet Gateway route table (for public subnet) and its route table OCID.
3. A NAT Gateway route table (for private subnet) and its route table OCID.
4. Proper OCI credentials (user OCID, tenancy OCID, fingerprint, private key) available to Terraform.

## Inputs
| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| tenancy_ocid | string | Yes | n/a | OCID of the tenancy (also used as compartment parent). |
| user_ocid | string | Yes | n/a | OCID of the user for authentication. |
| fingerprint | string | Yes | n/a | API key fingerprint. |
| private_key_path | string | Yes | n/a | Path to the private API key file. |
| region | string | Yes | n/a | OCI region (e.g., `us-ashburn-1`). |
| vcn_display_name | string | Yes | n/a | (Currently unused in resources; reserved for future VCN-related logic.) |
| private_sec_list_name | string | No | security-list-for-private-subnet | Display name for private security list. |
| public_sec_list_name | string | No | security-list-for-public-subnet | Display name for public security list. |
| private_cidr_block | string | Yes | n/a | CIDR for private subnet (e.g., `10.0.1.0/24`). |
| private_subnet_name | string | No | private-subnet | Display name of private subnet. |
| public_cidr_block | string | Yes | n/a | CIDR for public subnet (e.g., `10.0.0.0/24`). |
| public_subnet_name | string | No | public-subnet | Display name of public subnet. |
| vcn_id | string | Yes | n/a | OCID of existing VCN where subnets & security lists are created. |
| vcn_ig_route_id | string | Yes | n/a | Route table OCID used by the public subnet (Internet Gateway). |
| vcn_nat_route_id | string | Yes | n/a | Route table OCID used by the private subnet (NAT Gateway). |

## Outputs
| Output | Description |
|--------|-------------|
| all-availability-domains-in-your-tenancy | List of ADs in the tenancy (data source). |
| compartment-name | Name of created compartment. |
| compartment-OCID | OCID of created compartment. |
| private-security-list-name | Display name of private security list. |
| private-security-list-OCID | OCID of private security list. |
| public-security-list-name | Display name of public security list. |
| public-security-list-OCID | OCID of public security list. |
| private-subnet-name | Display name of private subnet. |
| private-subnet-OCID | OCID of private subnet. |
| public-subnet-name | Display name of public subnet. |
| public-subnet-OCID | OCID of public subnet. |

## Provider & Version
Configured provider:
```
provider "oci" {
  source  = "oracle/oci"
  version = "7.4.0"
}
```
Add a `required_version` constraint in `versions.tf` if you want to pin Terraform CLI (e.g., `required_version = ">= 1.5.0"`).

## Usage Example
```
module "base_infra" {
  source = "github.com/your-org/terraform-oci-infra"  # adjust to registry or VCS path

  tenancy_ocid       = var.tenancy_ocid
  user_ocid          = var.user_ocid
  fingerprint        = var.fingerprint
  private_key_path   = var.private_key_path
  region             = var.region

  vcn_id             = module.network.vcn_id
  vcn_ig_route_id    = module.network.igw_route_table_id
  vcn_nat_route_id   = module.network.nat_route_table_id

  private_cidr_block = "10.0.1.0/24"
  public_cidr_block  = "10.0.0.0/24"

  # Optional overrides
  public_subnet_name  = "public-app"
  private_subnet_name = "private-app"
}
```

Associated variables (example `terraform.tfvars`):
```
tenancy_ocid       = "ocid1.tenancy.oc1..."
user_ocid          = "ocid1.user.oc1..."
fingerprint        = "ab:cd:ef:01:23:45:67:89:ab:cd:ef:01:23:45:67:89"
private_key_path   = pathexpand("~/.oci/oci_api_key.pem")
region             = "us-ashburn-1"

# Provided by a separate VCN module
vcn_id             = "ocid1.vcn.oc1..xxxxx"
vcn_ig_route_id    = "ocid1.routetable.oc1..internetRT"
vcn_nat_route_id   = "ocid1.routetable.oc1..natRT"

private_cidr_block = "10.0.1.0/24"
public_cidr_block  = "10.0.0.0/24"
```

## Getting Started
```
terraform init
terraform plan -out plan.tfplan
terraform apply plan.tfplan
```
To destroy:
```
terraform destroy
```

## Authentication Notes
You can authenticate using user principal (keys) as shown. For instance:
```
export TF_VAR_tenancy_ocid=... \
       TF_VAR_user_ocid=... \
       TF_VAR_fingerprint=... \
       TF_VAR_private_key_path=~/.oci/oci_api_key.pem \
       TF_VAR_region=us-ashburn-1
```
Consider using the OCI config file (`~/.oci/config`) plus the Terraform provider's shared config support for better secret hygiene.

## Design Considerations
- Security Lists vs NSGs: For finer-grained isolation, consider migrating to Network Security Groups.
- Wide CIDR allowances (`10.0.0.0/16`) simplify early experimentation but should be narrowed.
- Hard-coded special TCP ports (30233, 30277, 31793, 3306) imply workload assumptions (OKE / DB access); parameterize them if they vary per environment.
- The `vcn_display_name` variable is currently unused—remove or implement usage in a future enhancement.

## Recommended Improvements (Roadmap)
1. Add `required_version` for Terraform in `versions.tf`.
2. Parameterize special TCP port lists.
3. Provide optional Network Security Group resources.
4. Add examples/ directory for multi-environment patterns (dev/stage/prod).
5. Introduce tags (defined_tags / freeform_tags) for governance.
6. Add optional flow logs (VCN / subnet) for auditing.
7. Support resource deletion protection via lifecycle policies if needed.

## Testing & Validation
Basic validation steps:
- `terraform validate` ensures syntax correctness.
- `terraform plan` should show creation of 1 compartment, 2 security lists, 2 subnets, and data population for availability domains.

## Troubleshooting
| Symptom | Possible Cause | Resolution |
|---------|----------------|-----------|
| 404 / NotAuthorizedOrNotFound | Wrong OCID or insufficient permissions | Verify IAM policy allows compartment and network creation. |
| Subnet creation fails | Route table OCID mismatch | Ensure you pass a route TABLE OCID, not a gateway OCID. |
| Provider auth errors | Key / fingerprint mismatch | Recreate API key pair and update fingerprint. |

## License
MIT (see [LICENSE.md](./LICENSE.md)).

## Contributing
1. Fork & branch (`feature/xyz`).
2. Run `terraform fmt -recursive` and `terraform validate`.
3. Open a pull request with a clear description.

## Disclaimer
This module is provided "as is" without warranties. Review and adapt security configurations before production use.

