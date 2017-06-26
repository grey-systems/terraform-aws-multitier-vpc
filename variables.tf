/**
* List of AZ to spare the different subnets
*/
variable "availability_zones" {
  type = "list"
}

/**
* VPC Main CIDR block
*/
variable "cidr_block" {
  type = "string"
}

/**
* List of public Subnets CIDRs. The module will create a public subnet
* for every cidr_block
*/
variable "public_cidr_blocks" {
  type = "list"
}

/**
* List of private Subnets CIDRs. The module will create a private subnet
* for every cidr_block
*/
variable "private_cidr_blocks" {
  type = "list"
}

/**
* Environment name. Used to name the different resources for an easy
* identification in AWS console
*/
variable "environment" {
  type = "string"
}

/**
* Short environment name. Used to name the different resources for an easy
* identification in AWS console
*/
variable "short_identifier" {
  type = "string"
}

/**
* The IP of the counterpart of the VPN connection.
*/
variable "customer_gateway_ip" {
  type = "string"
}

/**
* Name for customer gateway
*/
variable "customer_gateway_name" {
  type = "string"
}

/**
* List of cidr blocks to be configured as static routes in the AWS VPN
*/
variable "subnets_vpn" {
  type    = "string"
  default = ""
}
