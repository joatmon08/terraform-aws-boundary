# boundary.tftest.hcl

provider "aws" {
  region = "us-east-2"
}

run "setup" {
  command = plan
  module {
    source = "../."
  }
}

run "boundary_database" {

  command = plan

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
