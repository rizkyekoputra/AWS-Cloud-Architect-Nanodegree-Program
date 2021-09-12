# TODO: Designate a cloud provider, region, and credentials
provider "aws" {
  access_key = ""
  secret_key = ""
  region = "us-east-1"
}

# TODO: provision 4 AWS t2.micro EC2 instances named Udacity T2
resource "aws_instance" "UdacityT2" {
  count = "4"
  ami = "ami-087c17d1fe0178315"
  instance_type = "t2.micro"
  subnet_id = "subnet-06025568f6c664780"
  tags = {
    name = "Udacity T2"
  }
}
