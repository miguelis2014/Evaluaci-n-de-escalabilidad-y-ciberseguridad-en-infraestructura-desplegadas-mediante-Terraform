<!-- TOC -->
  * [Example](#example)
  * [Reference Implementations](#reference-implementations)
    * [Standard 3-Tier VPC Pattern](#standard-3-tier-vpc-pattern)
      * [Enterprise Application VPC](#enterprise-application-vpc)
      * [Compact Application VPC](#compact-application-vpc)
    * [Network Architecture Guidelines](#network-architecture-guidelines)
      * [Subnet Sizing Standards](#subnet-sizing-standards)
      * [Required Tags](#required-tags)
      * [Routing Patterns](#routing-patterns)
  * [Requirements](#requirements)
  * [Providers](#providers)
  * [Modules](#modules)
  * [Resources](#resources)
  * [Inputs](#inputs)
  * [Outputs](#outputs)
<!-- TOC -->

## Example
```hcl
locals {
    common_tags ={
        "Owner" = "Prueba"
    }

vpc_name = "prueba"
environment = "test"
vpc_example = {
    region   = "eu-west-1"
    region_acronym = "ew1"
    azs      = ["a", "b"]
    vpc_cidr = "172.29.0.0/16"
    private_subnets_isolated = {
      00 = {
        sname = "a-isolated",
        AZ   = "a",
        CIDR = "172.29.0.0/21",
        tags = {}
      },
      01 = {
        sname = "b-isolated",
        AZ   = "b",
        CIDR = "172.29.8.0/21",
        tags = {}
      }
    }
    private_subnets_horizontal_1 = {
      00 = {
        sname = "a-horizontal1",
        AZ   = "a",
        CIDR = "172.29.16.0/21",
        tags = {}
      },
      01 = {
        sname = "b-horizontal1",
        AZ   = "b",
        CIDR = "172.29.24.0/21",
        tags = {}
      },
      02 = {
        sname = "a-horizontal2",
        AZ   = "a",
        CIDR = "172.29.32.0/21",
        tags = {}
      },
      03 = {
        sname = "b-horizontal2",
        AZ   = "b",
        CIDR = "172.29.40.0/21",
        tags = {}
      }
    }
    private_subnets_vertical_1 = {
      00 = {
        sname = "a-vertical1",
        AZ   = "a",
        CIDR = "172.29.48.0/21",
        tags = {}
      },
      01 = {
        sname = "b-vertical1",
        AZ   = "b",
        CIDR = "172.29.56.0/21",
        tags = {}
      },
      02 = {
        sname = "a-vertical2",
        AZ   = "a",
        CIDR = "172.29.64.0/21",
        tags = {}
      },
      03 = {
        sname = "b-vertical2",
        AZ   = "b",
        CIDR = "172.29.72.0/21",
        tags = {}
      }
    }
    private_subnets_nat = {
      00 = {
        sname = "a-privnat",
        AZ   = "a",
        CIDR = "172.29.80.0/21",
        tags = {}
      },
      01 = {
        sname = "b-privnat",
        AZ   = "b",
        CIDR = "172.29.88.0/21",
        tags = {}
      }
    }
    public_subnets = { 
      00 = {
        sname = "a-pub",
        AZ   = "a",
        CIDR = "172.29.96.0/21",
        tags = {}
      },
      01 = {
        sname = "b-pub",
        AZ   = "b",
        CIDR = "172.29.104.0/21",
        tags = {}
      }
    }
    public_subnets_nat = {
      00 = {
        sname = "a-natgtw",
        AZ   = "a",
        CIDR = "172.29.112.0/21",
        tags = {}
      },
      01 = {
        sname = "b-natgtw",
        AZ   = "b",
        CIDR = "172.29.120.0/21",
        tags = {}
      }
    }
    public_subnets_edge = {
      00 = {
        sname = "a-igw",
        AZ   = "a",
        CIDR = "172.29.128.0/21",
        tags = {}
      },
      01 = {
        sname = "b-igw",
        AZ   = "b",
        CIDR = "172.29.136.0/21",
        tags = {}
      }
    }
    dhcp_options_domain_name = "test"
    enable_dns_hostnames = true
    enable_dns_support = true
    instance_tenancy = "default"
    tags           = {"Test" = "true"}
  }
}

module "vpc-example" {
  source = "git::....."
  region = local.vpc_example.region
  region_acronym = local.vpc_example.region_acronym
  vpc_name = local.vpc_name
  azs      = local.vpc_example.azs
  environment = local.environment
  vpc_cidr        = local.vpc_example.vpc_cidr

  private_subnets_isolated = local.vpc_example.private_subnets_isolated
  private_subnets_horizontal_1 = local.vpc_example.private_subnets_horizontal_1
  private_subnets_vertical_1 = local.vpc_example.private_subnets_vertical_1
  private_subnets_nat = local.vpc_example.private_subnets_nat
  public_subnets  = local.vpc_example.public_subnets
  public_subnets_edge  = local.vpc_example.public_subnets_edge
  public_subnets_nat  = local.vpc_example.public_subnets_nat

  enable_dhcp_options = true
  dhcp_options_domain_name = local.vpc_example.dhcp_options_domain_name
  enable_dns_hostnames = local.vpc_example.enable_dns_hostnames
  enable_dns_support = local.vpc_example.enable_dns_support
  instance_tenancy = local.vpc_example.instance_tenancy
  common_tags = merge(local.common_tags, local.vpc_example.tags)
}

```

## Reference Implementations

### Standard 3-Tier VPC Pattern

[The following examples demonstrate the approved network architecture patterns used in production environments. These configurations follow organizational standards for subnet sizing, routing, and tagging.
](reference)
#### Enterprise Application VPC

This pattern is suitable for corporate applications requiring high availability across multiple AZs with Transit Gateway connectivity for hybrid cloud scenarios.

```hcl
locals {
  common_tags = {
    environment         = "production"
    app-criticality     = "critical-tier-1"
    exposure           = "internal"
    app-name           = "corp-application"
    business-area      = "it"
    management-partner = "internal-team"
    iac               = "terraform"
  }
  
  vpc_name = "corp-workload"
  environment = "production"
  vpc_config = {
    region          = "eu-west-1"
    region_acronym  = "ew1"
    azs            = ["a", "b", "c"]
    vpc_cidr       = "10.100.0.0/23"  # /23 provides 512 IPs
    
    # Application tier - /26 provides 64 IPs per AZ
    private_subnets_horizontal_1 = {
      00 = {
        sname = "a-app",
        AZ    = "a",
        CIDR  = "10.100.0.0/26",
        tags  = {}
      },
      01 = {
        sname = "b-app",
        AZ    = "b", 
        CIDR  = "10.100.0.64/26",
        tags  = {}
      },
      02 = {
        sname = "c-app",
        AZ    = "c",
        CIDR  = "10.100.0.128/26", 
        tags  = {}
      }
    }
    
    # Data tier - /26 provides 64 IPs per AZ
    private_subnets_horizontal_2 = {
      00 = {
        sname = "a-data",
        AZ    = "a",
        CIDR  = "10.100.0.192/26",
        tags  = {}
      },
      01 = {
        sname = "b-data", 
        AZ    = "b",
        CIDR  = "10.100.1.0/26",
        tags  = {}
      },
      02 = {
        sname = "c-data",
        AZ    = "c", 
        CIDR  = "10.100.1.64/26",
        tags  = {}
      }
    }
    
    # Transit Gateway tier - /28 provides 16 IPs per AZ
    private_subnets_horizontal_3 = {
      00 = {
        sname = "a-tgw",
        AZ    = "a",
        CIDR  = "10.100.1.128/28",
        tags  = {}
      },
      01 = {
        sname = "b-tgw",
        AZ    = "b",
        CIDR  = "10.100.1.144/28", 
        tags  = {}
      },
      02 = {
        sname = "c-tgw",
        AZ    = "c",
        CIDR  = "10.100.1.160/28",
        tags  = {}
      }
    }
    
    dhcp_options_domain_name = "production"
    enable_dns_hostnames = true
    enable_dns_support = true
    instance_tenancy = "default"
  }
}

module "vpc" {
  source = "../"
  
  region = local.vpc_config.region
  region_acronym = local.vpc_config.region_acronym
  vpc_name = local.vpc_name
  azs = local.vpc_config.azs
  environment = local.environment
  vpc_cidr = local.vpc_config.vpc_cidr
  
  private_subnets_horizontal_1 = local.vpc_config.private_subnets_horizontal_1
  private_subnets_horizontal_2 = local.vpc_config.private_subnets_horizontal_2  
  private_subnets_horizontal_3 = local.vpc_config.private_subnets_horizontal_3
  
  enable_dhcp_options = true
  dhcp_options_domain_name = local.vpc_config.dhcp_options_domain_name
  enable_dns_hostnames = local.vpc_config.enable_dns_hostnames
  enable_dns_support = local.vpc_config.enable_dns_support
  instance_tenancy = local.vpc_config.instance_tenancy
  
  common_tags = local.common_tags
}

# Transit Gateway Attachment (requires separate configuration)
resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  subnet_ids = [
    module.vpc.private_subnets_horizontal_3_id[0],
    module.vpc.private_subnets_horizontal_3_id[1], 
    module.vpc.private_subnets_horizontal_3_id[2]
  ]
  transit_gateway_id = var.transit_gateway_id
  vpc_id = module.vpc.vpc_id
  
  tags = merge(local.common_tags, {
    Name = "${local.vpc_name}-tgw-attachment"
  })
}
```

#### Compact Application VPC

This pattern is suitable for smaller applications with tighter IP address requirements, using /24 VPC CIDR and smaller subnet allocations.

```hcl
locals {
  common_tags = {
    environment             = "production"
    app-name               = "microservice-app"  
    business-area          = "ops"
    iac                    = "terraform"
    management-partner     = "devops-team"
    exposure               = "internal"
    app-criticality        = "medium"
    data-confidentiality   = "confidential"
    data-integrity-level   = "essential"
    data-availability-level = "critical"
  }
  
  vpc_name = "microservice-workload"
  environment = "production"

  vpc_config = {
    region          = "eu-west-1"
    region_acronym  = "ew1" 
    azs            = ["a", "b", "c"]
    vpc_cidr       = "10.200.0.0/24"  # /24 provides 256 IPs
    
    # Application tier - /27 provides 32 IPs per AZ
    private_subnets_horizontal_1 = {
      00 = {
        sname = "a-app",
        AZ    = "a",
        CIDR  = "10.200.0.0/27",
        tags  = {}
      },
      01 = {
        sname = "b-app", 
        AZ    = "b",
        CIDR  = "10.200.0.32/27",
        tags  = {}
      },
      02 = {
        sname = "c-app",
        AZ    = "c",
        CIDR  = "10.200.0.64/27",
        tags  = {}
      }
    }
    
    # Data tier - /27 provides 32 IPs per AZ
    private_subnets_horizontal_2 = {
      00 = {
        sname = "a-data",
        AZ    = "a", 
        CIDR  = "10.200.0.96/27",
        tags  = {}
      },
      01 = {
        sname = "b-data",
        AZ    = "b",
        CIDR  = "10.200.0.128/27",
        tags  = {}
      },
      02 = {
        sname = "c-data",
        AZ    = "c",
        CIDR  = "10.200.0.160/27", 
        tags  = {}
      }
    }
    
    # Transit Gateway tier - /28 provides 16 IPs per AZ
    private_subnets_horizontal_3 = {
      00 = {
        sname = "a-tgw",
        AZ    = "a",
        CIDR  = "10.200.0.192/28",
        tags  = {}
      },
      01 = {
        sname = "b-tgw",
        AZ    = "b", 
        CIDR  = "10.200.0.208/28",
        tags  = {}
      },
      02 = {
        sname = "c-tgw",
        AZ    = "c",
        CIDR  = "10.200.0.224/28",
        tags  = {}
      }
    }
    
    dhcp_options_domain_name = "production"
    enable_dns_hostnames = true
    enable_dns_support = true 
    instance_tenancy = "default"
  }
}

module "vpc" {
  source = "../"
  
  region = local.vpc_config.region
  region_acronym = local.vpc_config.region_acronym
  vpc_name = local.vpc_name
  azs = local.vpc_config.azs
  environment = local.environment
  vpc_cidr = local.vpc_config.vpc_cidr
  
  private_subnets_horizontal_1 = local.vpc_config.private_subnets_horizontal_1
  private_subnets_horizontal_2 = local.vpc_config.private_subnets_horizontal_2
  private_subnets_horizontal_3 = local.vpc_config.private_subnets_horizontal_3
  
  enable_dhcp_options = true
  dhcp_options_domain_name = local.vpc_config.dhcp_options_domain_name
  enable_dns_hostnames = local.vpc_config.enable_dns_hostnames 
  enable_dns_support = local.vpc_config.enable_dns_support
  instance_tenancy = local.vpc_config.instance_tenancy
  
  common_tags = local.common_tags
}
```

### IPAM Support

This module supports optional integration with AWS IPAM (IP Address Manager).
If `ipam_pool_id` is provided, the CIDR will be automatically assigned from that pool, avoiding overlaps and ensuring network governance.

Related Variables:

- `ipam_pool_id`: IPAM pool ID (optional)
- `netmask_length`: Requested block size (default `/16`)

If IPAM is not used, you can continue to use `cidr` as before.

### Network Architecture Guidelines

#### Subnet Types
> [!NOTE]
> This module supports creation of multiple subnet types based on their intended use.
- **private_subnets_isolated** (map): Private subnets each with its own route table (1 subnet -> 1 route table). No default routes included.
- **private_subnets_horizontal_1** (map): Private subnets sharing a route table per tier across AZs.
> [!IMPORTANT]
> Supports up to 3 horizontal subnet tiers using `private_subnets_horizontal_1`, `_2`, and `_3`.
```
          AZ1         |         AZ2         |         AZ3                          
                      |                     |                                      
  |-------------------------------------------------------------------------------|
  | ______________    |   ______________    |   ______________                    |
  | |            |    |   |            |    |   |            |                    |
  | |  subnet00  |    |   |     01     |    |   |     02     |    Horizontal      |
  | |____________|    |   |____________|    |   |____________|    Route table     |
  |                   |                     |                                     |
  |-------------------------------------------------------------------------------|
    ______________    |   ______________    |   ______________                     
    |            |    |   |            |    |   |            |                     
    |     03     |    |   |     04     |    |   |     05     |                     
    |____________|    |   |____________|    |   |____________|                     
                      |                     |                                      
                      |                     |                                      
```
- **private_subnets_vertical_1** (map): Private subnets sharing a route table per AZ.
> [!IMPORTANT]
> Supports up to 3 vertical subnet tiers using `private_subnets_vertical_1`, `_2`, and `_3`.
```
           AZ1         |         AZ2         |         AZ3        
                       |                     |                    
   |----------------|  |                     |                    
   | ______________ |  |   ______________    |   ______________   
   | |            | |  |   |            |    |   |            |   
   | |  subnet00  | |  |   |     01     |    |   |     02     |   
   | |____________| |  |   |____________|    |   |____________|   
   |                |  |                     |                    
   |                |  |                     |                    
   | ______________ |  |   ______________    |   ______________   
   | |            | |  |   |            |    |   |            |   
   | |     03     | |  |   |     04     |    |   |     05     |   
   | |____________| |  |   |____________|    |   |____________|   
   |                |  |                     |                    
   |                |  |                     |                    
   |    Vertical    |                                             
   |     Route      |                                             
   |     table      |                                             
   |                |                                             
   |                |                                             
   |----------------|                                             
```
- **private_subnets_nat** (map): Similar to isolated, but includes NAT gateway setup and default route to `0.0.0.0/0`.
- **public_subnets** (map): Public subnets with 1:1 route table and IGW, including `0.0.0.0/0` route.
- **public_subnets_nat** (map): Public subnets hosting NAT gateways. Shared route table. One NAT per AZ.
- **public_subnets_edge** (map): Public subnets with shared route table and direct IGW association. No default routes.


#### Subnet Sizing Standards

| Tier | Purpose | Subnet Size | IPs Available | Use Case |
|------|---------|-------------|---------------|----------|
| Application | Workload compute | /26 - /27 | 64 - 32 | EC2, ECS, Lambda |
| Data | Database services | /26 - /27 | 64 - 32 | RDS, ElastiCache, DocumentDB |
| Transit Gateway | Connectivity | /28 | 16 | TGW attachments only |

#### Required Tags

All VPC resources must include these mandatory tags:

- `environment`: Environment name (production, staging, development)
- `app-name`: Application identifier
- `business-area`: Organizational unit (it, ops, finance, etc)  
- `management-partner`: Team responsible for the infrastructure
- `iac`: Infrastructure as Code tool (terraform)
- `app-criticality`: Business criticality (critical-tier-1, critical-tier-2, medium, low)
- `exposure`: Network exposure level (public, internal, private)

Additional tags for sensitive workloads:
- `data-confidentiality`: Data classification level
- `data-integrity-level`: Data integrity requirements
- `data-availability-level`: Availability requirements

#### Routing Patterns

**Application Tier Routing:**
- Default route (0.0.0.0/0) points to Transit Gateway
- Enables communication with other VPCs and on-premises networks
- Isolated from internet traffic

**Data Tier Routing:**
- No default route (isolated)
- Only VPC-local traffic allowed
- Database-to-database communication within VPC

**Transit Gateway Tier Routing:**
- No routes configured (managed by TGW route tables)
- Used exclusively for TGW attachment subnets

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_eip.additional_nat_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip.nat_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.igw_dc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.private_subnets_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_subnets_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private_subnets_horizontal_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private_subnets_horizontal_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private_subnets_horizontal_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private_subnets_isolated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private_subnets_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private_subnets_vertical_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private_subnets_vertical_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private_subnets_vertical_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public_subnets_edge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public_subnets_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private_subnets_horizontal_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private_subnets_horizontal_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private_subnets_horizontal_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private_subnets_isolated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private_subnets_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private_subnets_vertical_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private_subnets_vertical_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private_subnets_vertical_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public_subnets_edge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public_subnets_edge-igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public_subnets_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.private_subnets_horizontal_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private_subnets_horizontal_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private_subnets_horizontal_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private_subnets_isolated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private_subnets_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private_subnets_vertical_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private_subnets_vertical_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private_subnets_vertical_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public_subnets_edge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public_subnets_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_dhcp_options.dhcp_options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options) | resource |
| [aws_vpc_dhcp_options_association.dhcp_options_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options_association) | resource |
| [aws_vpc_ipam_preview_next_cidr.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_ipam_preview_next_cidr) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_eips_per_natgw"></a> [additional\_eips\_per\_natgw](#input\_additional\_eips\_per\_natgw) | Additional EIPs to attach to a nat gateway. By default, this module associate 1 EIP for 1 Nat GW. This variable adds more. NOTE: There is a soft limit of 2. Request new quota value before if this variable get value greater than 2. | `number` | `0` | no |
| <a name="input_azs"></a> [azs](#input\_azs) | AZs in which the subnets will be launched. If you want to add new AZs, they must be consecutive to the last one. | `list(any)` | <pre>[<br/>  "a",<br/>  "b",<br/>  "c"<br/>]</pre> | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Extra tags to apply to resources | `map(any)` | `{}` | no |
| <a name="input_dhcp_options_domain_name"></a> [dhcp\_options\_domain\_name](#input\_dhcp\_options\_domain\_name) | The suffix domain name to use by default when resolving non Fully Qualified Domain Names | `string` | `""` | no |
| <a name="input_dhcp_options_domain_name_servers"></a> [dhcp\_options\_domain\_name\_servers](#input\_dhcp\_options\_domain\_name\_servers) | Specify a list of DNS server addresses for DHCP options set, default to AWS provided (requires enable\_dhcp\_options set to true) | `list(string)` | <pre>[<br/>  "AmazonProvidedDNS"<br/>]</pre> | no |
| <a name="input_dhcp_options_netbios_name_servers"></a> [dhcp\_options\_netbios\_name\_servers](#input\_dhcp\_options\_netbios\_name\_servers) | Specify a list of netbios servers for DHCP options set (requires enable\_dhcp\_options set to true) | `list(string)` | `[]` | no |
| <a name="input_dhcp_options_netbios_node_type"></a> [dhcp\_options\_netbios\_node\_type](#input\_dhcp\_options\_netbios\_node\_type) | Specify netbios node\_type for DHCP options set (requires enable\_dhcp\_options set to true) | `string` | `""` | no |
| <a name="input_dhcp_options_ntp_servers"></a> [dhcp\_options\_ntp\_servers](#input\_dhcp\_options\_ntp\_servers) | Specify a list of NTP servers for DHCP options set (requires enable\_dhcp\_options set to true) | `list(string)` | `[]` | no |
| <a name="input_enable_dhcp_options"></a> [enable\_dhcp\_options](#input\_enable\_dhcp\_options) | Should be true to create dhcp options | `bool` | `true` | no |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Should be true to enable DNS hostnames in the VPC | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Should be true to enable DNS support in the VPC | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the environment where the infrastructure is deployed (e.g., dev, test, prod) | `string` | `""` | no |
| <a name="input_horizontal_routes"></a> [horizontal\_routes](#input\_horizontal\_routes) | Flag to enable or disable the creation of route tables shared across availability zones (horizontal tiers) | `bool` | `true` | no |
| <a name="input_instance_tenancy"></a> [instance\_tenancy](#input\_instance\_tenancy) | A tenancy option for instances launched into the VPC | `string` | `"default"` | no |
| <a name="input_ipam_pool_id"></a> [ipam\_pool\_id](#input\_ipam\_pool\_id) | Optional: IPAM Pool ID to get a CIDR from automatically | `string` | `null` | no |
| <a name="input_netmask_length"></a> [netmask\_length](#input\_netmask\_length) | Optional: Netmask length to request from IPAM (e.g., 16, 17) | `number` | `16` | no |
| <a name="input_private_subnets_horizontal_1"></a> [private\_subnets\_horizontal\_1](#input\_private\_subnets\_horizontal\_1) | First block of horizontally grouped private subnets, sharing a route table across multiple AZs | `map(any)` | `{}` | no |
| <a name="input_private_subnets_horizontal_2"></a> [private\_subnets\_horizontal\_2](#input\_private\_subnets\_horizontal\_2) | Second block of horizontally grouped private subnets, sharing a route table across multiple AZs | `map(any)` | `{}` | no |
| <a name="input_private_subnets_horizontal_3"></a> [private\_subnets\_horizontal\_3](#input\_private\_subnets\_horizontal\_3) | Third block of horizontally grouped private subnets, sharing a route table across multiple AZs | `map(any)` | `{}` | no |
| <a name="input_private_subnets_isolated"></a> [private\_subnets\_isolated](#input\_private\_subnets\_isolated) | Map of isolated private subnets, each associated with a dedicated route table without default routes | `map(any)` | `{}` | no |
| <a name="input_private_subnets_nat"></a> [private\_subnets\_nat](#input\_private\_subnets\_nat) | Map of private subnets using NAT Gateway for internet access. Each subnet gets its own route table with a route to the NAT Gateway | `map(any)` | `{}` | no |
| <a name="input_private_subnets_vertical_1"></a> [private\_subnets\_vertical\_1](#input\_private\_subnets\_vertical\_1) | First block of vertically grouped private subnets, where all subnets in the same AZ share a route table | `map(any)` | `{}` | no |
| <a name="input_private_subnets_vertical_2"></a> [private\_subnets\_vertical\_2](#input\_private\_subnets\_vertical\_2) | Second block of vertically grouped private subnets, where all subnets in the same AZ share a route table | `map(any)` | `{}` | no |
| <a name="input_private_subnets_vertical_3"></a> [private\_subnets\_vertical\_3](#input\_private\_subnets\_vertical\_3) | Third block of vertically grouped private subnets, where all subnets in the same AZ share a route table | `map(any)` | `{}` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | `"project"` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | Map of public subnets, each with its own route table and default route to an Internet Gateway | `map(any)` | `{}` | no |
| <a name="input_public_subnets_edge"></a> [public\_subnets\_edge](#input\_public\_subnets\_edge) | Map of public subnets associated with a shared route table for Internet Gateway edge associations. This route table does not contain default routes. Maximum of 3 subnets supported (one per AZ) | `map(any)` | `{}` | no |
| <a name="input_public_subnets_nat"></a> [public\_subnets\_nat](#input\_public\_subnets\_nat) | Map of public subnets designated for hosting NAT Gateways. A single route table is shared across all subnets in this group. Maximum of 3 subnets supported (one per AZ) | `map(any)` | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region where the resources will be deployed | `string` | `"eu-west-1"` | no |
| <a name="input_region_acronym"></a> [region\_acronym](#input\_region\_acronym) | An acronym of the region name used. | `string` | `"ew1"` | no |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, and 3653. | `string` | `90` | no |
| <a name="input_traffic_type"></a> [traffic\_type](#input\_traffic\_type) | The type of traffic to capture. Valid values: ACCEPT,REJECT, ALL. | `string` | `"ALL"` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the VPC (only used if IPAM is not specified) | `string` | `null` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name of the VPC. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_internet_gateway_id_igw_dc"></a> [internet\_gateway\_id\_igw\_dc](#output\_internet\_gateway\_id\_igw\_dc) | id del internet gateway |
| <a name="output_nat_gateway_id_nat_gateway"></a> [nat\_gateway\_id\_nat\_gateway](#output\_nat\_gateway\_id\_nat\_gateway) | id de los nat gateways |
| <a name="output_private_subnets_horizontal_1_cidr"></a> [private\_subnets\_horizontal\_1\_cidr](#output\_private\_subnets\_horizontal\_1\_cidr) | n/a |
| <a name="output_private_subnets_horizontal_1_id"></a> [private\_subnets\_horizontal\_1\_id](#output\_private\_subnets\_horizontal\_1\_id) | private horizontal |
| <a name="output_private_subnets_horizontal_2_cidr"></a> [private\_subnets\_horizontal\_2\_cidr](#output\_private\_subnets\_horizontal\_2\_cidr) | n/a |
| <a name="output_private_subnets_horizontal_2_id"></a> [private\_subnets\_horizontal\_2\_id](#output\_private\_subnets\_horizontal\_2\_id) | n/a |
| <a name="output_private_subnets_horizontal_3_cidr"></a> [private\_subnets\_horizontal\_3\_cidr](#output\_private\_subnets\_horizontal\_3\_cidr) | n/a |
| <a name="output_private_subnets_horizontal_3_id"></a> [private\_subnets\_horizontal\_3\_id](#output\_private\_subnets\_horizontal\_3\_id) | n/a |
| <a name="output_private_subnets_isolated_cidr"></a> [private\_subnets\_isolated\_cidr](#output\_private\_subnets\_isolated\_cidr) | n/a |
| <a name="output_private_subnets_isolated_id"></a> [private\_subnets\_isolated\_id](#output\_private\_subnets\_isolated\_id) | Subnet output variables isolated private |
| <a name="output_private_subnets_nat_cidr"></a> [private\_subnets\_nat\_cidr](#output\_private\_subnets\_nat\_cidr) | n/a |
| <a name="output_private_subnets_nat_id"></a> [private\_subnets\_nat\_id](#output\_private\_subnets\_nat\_id) | private nat |
| <a name="output_private_subnets_vertical_1_cidr"></a> [private\_subnets\_vertical\_1\_cidr](#output\_private\_subnets\_vertical\_1\_cidr) | n/a |
| <a name="output_private_subnets_vertical_1_id"></a> [private\_subnets\_vertical\_1\_id](#output\_private\_subnets\_vertical\_1\_id) | private vertical |
| <a name="output_private_subnets_vertical_2_cidr"></a> [private\_subnets\_vertical\_2\_cidr](#output\_private\_subnets\_vertical\_2\_cidr) | n/a |
| <a name="output_private_subnets_vertical_2_id"></a> [private\_subnets\_vertical\_2\_id](#output\_private\_subnets\_vertical\_2\_id) | n/a |
| <a name="output_private_subnets_vertical_3_cidr"></a> [private\_subnets\_vertical\_3\_cidr](#output\_private\_subnets\_vertical\_3\_cidr) | n/a |
| <a name="output_private_subnets_vertical_3_id"></a> [private\_subnets\_vertical\_3\_id](#output\_private\_subnets\_vertical\_3\_id) | n/a |
| <a name="output_public_subnets_cidr"></a> [public\_subnets\_cidr](#output\_public\_subnets\_cidr) | n/a |
| <a name="output_public_subnets_edge_cidr"></a> [public\_subnets\_edge\_cidr](#output\_public\_subnets\_edge\_cidr) | n/a |
| <a name="output_public_subnets_edge_id"></a> [public\_subnets\_edge\_id](#output\_public\_subnets\_edge\_id) | public igw edge |
| <a name="output_public_subnets_id"></a> [public\_subnets\_id](#output\_public\_subnets\_id) | public |
| <a name="output_public_subnets_nat_cidr"></a> [public\_subnets\_nat\_cidr](#output\_public\_subnets\_nat\_cidr) | n/a |
| <a name="output_public_subnets_nat_id"></a> [public\_subnets\_nat\_id](#output\_public\_subnets\_nat\_id) | public nat gateway |
| <a name="output_route_tables_id_private_subnets_horizontal_1"></a> [route\_tables\_id\_private\_subnets\_horizontal\_1](#output\_route\_tables\_id\_private\_subnets\_horizontal\_1) | horizontal private route table id |
| <a name="output_route_tables_id_private_subnets_horizontal_2"></a> [route\_tables\_id\_private\_subnets\_horizontal\_2](#output\_route\_tables\_id\_private\_subnets\_horizontal\_2) | n/a |
| <a name="output_route_tables_id_private_subnets_horizontal_3"></a> [route\_tables\_id\_private\_subnets\_horizontal\_3](#output\_route\_tables\_id\_private\_subnets\_horizontal\_3) | n/a |
| <a name="output_route_tables_id_private_subnets_isolated"></a> [route\_tables\_id\_private\_subnets\_isolated](#output\_route\_tables\_id\_private\_subnets\_isolated) | Output variables for the route tables Isolated private route table id |
| <a name="output_route_tables_id_private_subnets_nat"></a> [route\_tables\_id\_private\_subnets\_nat](#output\_route\_tables\_id\_private\_subnets\_nat) | nat private route table id |
| <a name="output_route_tables_id_private_subnets_vertical_1"></a> [route\_tables\_id\_private\_subnets\_vertical\_1](#output\_route\_tables\_id\_private\_subnets\_vertical\_1) | vertical private route table id |
| <a name="output_route_tables_id_private_subnets_vertical_2"></a> [route\_tables\_id\_private\_subnets\_vertical\_2](#output\_route\_tables\_id\_private\_subnets\_vertical\_2) | n/a |
| <a name="output_route_tables_id_private_subnets_vertical_3"></a> [route\_tables\_id\_private\_subnets\_vertical\_3](#output\_route\_tables\_id\_private\_subnets\_vertical\_3) | n/a |
| <a name="output_route_tables_id_public_subnets"></a> [route\_tables\_id\_public\_subnets](#output\_route\_tables\_id\_public\_subnets) | public route table ids |
| <a name="output_route_tables_id_public_subnets_edge"></a> [route\_tables\_id\_public\_subnets\_edge](#output\_route\_tables\_id\_public\_subnets\_edge) | edge public route table ids |
| <a name="output_route_tables_id_public_subnets_nat"></a> [route\_tables\_id\_public\_subnets\_nat](#output\_route\_tables\_id\_public\_subnets\_nat) | public nat gateway route table id |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC output variables |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | n/a |
<!-- END_TF_DOCS -->
