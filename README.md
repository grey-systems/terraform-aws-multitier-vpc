# terraform-multitier-vpc

This repo contains a [Terraform](https://terraform.io/) module for
provisioning an [AWS Multitier VPC](http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Scenario3.html), with the following topology:

* A virtual private cloud (VPC) with a size /16 IPv4 CIDR (example: 10.0.0.0/16). This provides 65,536 private IPv4 addresses.
* 1-n private subnets (spread between the different AZ).
* 1-n public subnets (spread between the different AZ).
* VPN Connection between your VPC and your network. The VPN connection consists of a virtual private gateway located on the Amazon side of the VPN connection and a customer gateway located on your side of the VPN connection.


Module usage:

      provider "aws" {
        access_key = "${var.access_key}"
        secret_key = "${var.secret_key}"
        region     = "us-east-1"
      }

     module "vpc-custom" {
       source = "github.com/grey-systems/terraform-multitier-vpc.git?ref=master"

       availability_zones = "us-east-1a,us-east-1b"
       cidr_block = "10.2.0.0/16"
       public_cidr_blocks = "10.2.0.0/24,10.2.0.1/24"
       private_cidr_blocks = "10.2.128.0/24,10.0.2.129.0/24"
       environment = "testing"
       short_identifier = "test"
       # It should be your firewall public IP
       customer_gateway_ip = "92.18.128.4"
       customer_gateway_name = "my-testing-hq-gateway"
       subnets_vpn = "192.168.0.0/24"
     }



Inputs
---------

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| availability_zones | List of AZ to spare the different subnets  | list | - | yes |
| cidr_block | VPC Main CIDR block  | string | - | yes |
| customer_gateway_ip | The IP of the counterpart of the VPN connection.  | string | - | yes |
| customer_gateway_name | Name for customer gateway  | string | - | yes |
| environment |  Environment name. Used to name the different resources for an easy identification in AWS console | string | - | yes |
| private_cidr_blocks | List of private Subnets CIDRs. The module will create a private subnet for every cidr_block  | list | - | yes |
| public_cidr_blocks |  List of public Subnets CIDRs. The module will create a public subnet for every cidr_block  | list | - | yes |
| short_identifier | Short environment name. Used to name the different resources for an easy identification in AWS console  | string | - | yes |
| subnets_vpn | List of cidr blocks to be configured as static routes in the AWS VPN  | string | `` | no |


Outputs
------------
| Name | Description |
|------|-------------|
| default_vpc_secgroup_id |  id of the default security group of the VPC |
| nat_public_ips | List of public IPs of the NAT gateways created (1 for every single private subnet). Comma separated list |
| private_subnets_ids | List of ids for the private subnets |
| public_subnets_ids | List of ids for the public subnets |
| vpc_id | VPC Id |
| vpn_gw_id | VPN Gateway Id  |

Contributing
------------
Everybody is welcome to contribute. Please, see [`CONTRIBUTING`][contrib] for further information.

[contrib]: CONTRIBUTING.md

Bug Reports
-----------

Bug reports can be sent directly to authors and/or using github's issues.


-------

Copyright (c) 2017 Grey Systems ([www.greysystems.eu](http://www.greysystems.eu))

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
