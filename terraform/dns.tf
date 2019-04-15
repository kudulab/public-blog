# root zone was created externally,
# we don't manage the zone in infra of the blog because zone is shared by many services
variable "root_zone_id" {
  default = "Z1B6OG086ITGV2"
}

terraform {
  backend "consul" {
    address = "http://consul.ai-traders.com:8500"
  }
}

# Configure the AWS Provider
provider "aws" {
  # You can provide your credentials via the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY, environment variables
  region     = "us-east-1"
}

# List of IPs on https://help.github.com/en/articles/setting-up-an-apex-domain#configuring-a-records-with-your-dns-provider
resource "aws_route53_record" "www" {
  zone_id = "${var.root_zone_id}"
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
