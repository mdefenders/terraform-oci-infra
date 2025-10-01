variable "tenancy_ocid" {
  description = "The OCID of the tenancy"
  type        = string
}
variable "user_ocid" {
  description = "The OCID of the user"
  type        = string
}
variable "fingerprint" {
  description = "The fingerprint of the user's API key"
  type        = string
}
variable "private_key_path" {
  description = "The path to the private key file"
  type        = string
}
variable "region" {
  description = "The region to deploy resources in"
  type        = string
}
variable "vcn_display_name" {
  description = "The display name for the VCN"
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