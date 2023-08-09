locals {
  ami = "ami-0477d3aed9e98876c" #RHEL-9.2.0_HVM-20230503-x86_64-41-Hourly2-GP2
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data = file("/user_data/ec2_setup.sh")
  web_server = [
    {
        az        = "ap-northeast-1a"
        subnet_id = "${aws_subnet.my_pri_subnet["ap-northeast-1a"].id}"
        ip        = "172.16.2.100"
        name      = "web_server_1"
    },
    {
        az        = "ap-northeast-1c"
        subnet_id = "${aws_subnet.my_pri_subnet["ap-northeast-1c"].id}"
        ip        = "172.16.4.100"
        name      = "web_server_2"
    }
  ]
}

# ---------------------------
# EC2 Key pair
# ---------------------------
resource "aws_key_pair" "key_pair" {
  key_name   = "tf-key-pair"
  public_key = var.public_key
}

# ---------------------------
# EC2
# ---------------------------
resource "aws_instance" "web_server" {
  for_each          = { for i in local.web_server : i.az => i }
  ami               = local.ami
  instance_type     = local.instance_type
  availability_zone = each.value.az
  vpc_security_group_ids = local.vpc_security_group_ids
  subnet_id         = each.value.subnet_id
  private_ip        = each.value.ip
  key_name          = aws_key_pair.key_pair.key_name
  user_data         = local.user_data
  associate_public_ip_address = true
  tags = {
    Name = "${each.value.name}"
  }
}