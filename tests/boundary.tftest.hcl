# boundary.tftest.hcl

provider "aws" {
  region = "us-east-2"
}

variables {
  name = "test-terraform-aws-boundary"
}

run "setup_vpc" {
  command = apply

  variables {
    cidr             = "10.0.0.0/16"
    azs              = ["us-east-2a", "us-east-2b"]
    public_subnets   = ["10.0.0.0/24", "10.0.1.0/24"]
    private_subnets  = ["10.0.2.0/24", "10.0.3.0/24"]
    database_subnets = ["10.0.16.0/24", "10.0.17.0/24"]

    create_database_subnet_route_table = true
    create_database_nat_gateway_route  = false

    enable_nat_gateway   = true
    single_nat_gateway   = true
    enable_dns_hostnames = true
  }

  module {
    source  = "terraform-aws-modules/vpc/aws"
    version = "5.1.1"
  }
}

run "setup_boundary" {
  command = apply

  variables {
    vpc_id                   = run.setup_vpc.vpc_id
    vpc_cidr_block           = run.setup_vpc.vpc_cidr_block
    public_subnet_ids        = run.setup_vpc.public_subnets
    private_subnet_ids       = run.setup_vpc.database_subnets
    allow_cidr_blocks_to_api = ["0.0.0.0/0"]
  }
}

run "check_boundary_database" {
  command = plan

  variables {
    vpc_id                   = run.setup_vpc.vpc_id
    vpc_cidr_block           = run.setup_vpc.vpc_cidr_block
    public_subnet_ids        = run.setup_vpc.public_subnets
    private_subnet_ids       = run.setup_vpc.database_subnets
    allow_cidr_blocks_to_api = ["0.0.0.0/0"]
  }

  assert {
    condition     = !aws_db_instance.boundary.publicly_accessible
    error_message = "Boundary database should not be publicly accessible"
  }

  assert {
    condition     = aws_db_instance.boundary.storage_encrypted
    error_message = "Boundary database should have storage encrypted"
  }

  assert {
    condition     = tonumber(aws_db_instance.boundary.engine_version) > 13.0
    error_message = "Boundary database should be greater than PostgreSQL 13"
  }
}

run "check_boundary_workers" {
  command = plan

  variables {
    vpc_id                   = run.setup_vpc.vpc_id
    vpc_cidr_block           = run.setup_vpc.vpc_cidr_block
    public_subnet_ids        = run.setup_vpc.public_subnets
    private_subnet_ids       = run.setup_vpc.database_subnets
    allow_cidr_blocks_to_api = ["0.0.0.0/0"]
  }

  assert {
    condition     = length(aws_instance.worker.0.ebs_block_device) > 0
    error_message = "Set up EBS block device for worker audit logs"
  }

  assert {
    condition     = contains(aws_security_group_rule.allow_9201_worker.cidr_blocks, run.setup_vpc.vpc_cidr_block)
    error_message = "Boundary worker should allow VPC traffic to port 9201 for controllers and other workers"
  }

  assert {
    condition     = aws_security_group_rule.allow_9202_worker.cidr_blocks == tolist(var.allow_cidr_blocks_to_workers)
    error_message = "Boundary worker should allow specific traffic to port 9202 for proxy connections"
  }
}

run "check_e2e" {
  command = apply

  variables {
    boundary_lb = run.setup_boundary.boundary_lb
  }

  module {
    source = "./tests/integration"
  }
}
