variable "tenancy_ocid" {
  description = "The OCID of the tenancy"
  type        = string
}

variable "private_sec_list_name" {
  description = "Private security List Name"
  type        = string
  default     = "security-list-for-private-subnet"
}

variable "public_sec_list_name" {
  description = "Public security List Name"
  type        = string
  default     = "security-list-for-public-subnet"
}

variable "private_cidr_block" {
  description = "Private Sunbet CIDR"
  type        = string
}

variable "private_subnet_name" {
  description = "Private Subnet Name"
  type        = string
  default     = "private-subnet"
}

variable "public_cidr_block" {
  description = "Public Sunbet CIDR"
  type        = string
}

variable "public_subnet_name" {
  description = "Public Subnet Name"
  type        = string
  default     = "public-subnet"
}

variable "vcn_id" {
  description = "The OCID of the VCN"
  type        = string
}

variable "vcn_ig_route_id" {
  description = "The OCID of the VCN Internet Gateway Route Table"
  type        = string
}
variable "vcn_nat_route_id" {
  description = "The OCID of the VCN NAT Gateway Route Table"
  type        = string
}