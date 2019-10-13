# root zone was created externally,
# we don't manage the zone in this infra project of the blog because zone is shared by many services
data "aws_ssm_parameter" "public_zone_id" {
  name = "/kudu/dns/public_zone_id"
}

locals {
  root_zone_id = data.aws_ssm_parameter.public_zone_id.value
}

terraform {
  backend "s3" {
    bucket         = "kudu-terraform-infra"
    region         = "eu-west-1"
    dynamodb_table = "kudu-terraform-locks"
  }
}

# Configure the AWS Provider
provider "aws" {
  # You can provide your credentials via the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY, environment variables
  region     = "eu-west-1"
}

# List of IPs on https://help.github.com/en/articles/setting-up-an-apex-domain#configuring-a-records-with-your-dns-provider
resource "aws_route53_record" "www" {
  zone_id = local.root_zone_id
  name    = "kudulab.io"
  type    = "A"
  ttl     = 3600
  records = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153"
  ]
}
