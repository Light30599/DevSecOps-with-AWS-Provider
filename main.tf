#terraform init
#terraform plan
#terraform validate
#terraform apply
#terraform destroy
#terraform refresh
#terraform state [list,show]: list all resources
#terraform apply --auto-approve
#terraform output -json
#########################Config#############################

# 1. Create vpc
#configure virtual private cloud
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment_slug}-VPC"
    #created = "<=username>"
    Environment = "${var.environment_name}"
  }
}
# 2. Create Internet Gateway
resource "aws_internet_gateway" "gw-vpc" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment_slug}-GW-VPC"
  }
}
# 3. Create Custom Route Table
resource "aws_route_table" "webserver-route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw-vpc.id
  }

  #route {
  #  ipv6_cidr_block        = "::/0"
  #  egress_only_gateway_id = aws_egress_only_gateway.gw-prod-vpc.id
  #}

  tags = {
    Name = "${var.environment_slug}-Router"
  }
}
# 4. Create a Subnet
#configurate subnet A inside VPC
resource "aws_subnet" "webserver_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_prefix
  availability_zone       = var.subnet-region
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.environment_slug}-subnet-${var.subnet-region}"
    Environment = "${var.environment_name}"
  }
}



# 5. Associate Subnet with Route Table
resource "aws_route_table_association" "ass-subnet-route" {
  subnet_id      = aws_subnet.webserver_subnet.id
  route_table_id = aws_route_table.webserver-route-table.id
}
# 6. Create Security Group to alliw port 22,80,443
# security.tf file

# 7. Create a Network interface with an ip in the subnet that was created in step 4
#configurate  network interface for web-server instance
resource "aws_network_interface" "web-server" {
  count           = length(var.instances_configuration)
  subnet_id       = aws_subnet.webserver_subnet.id
  private_ips     = ["${element(var.instances_configuration, count.index)}"]
  security_groups = [aws_security_group.webserver_sg.id]
  /*
  attachment {
    instance     = aws_instance.test.id
    device_index = 1
  }
  */
  tags = {
    Name        = "${var.environment_slug}-webserver-interface-${count.index}"
    Environment = "${var.environment_name}"
  }
}

# Aws EC2 instance WAF interface
resource "aws_network_interface" "waf-interface" {
  subnet_id       = aws_subnet.webserver_subnet.id
  private_ips     = [var.waf_private_ip]
  security_groups = [aws_security_group.waf_sg.id]
  /*
  attachment {
    instance     = aws_instance.test.id
    device_index = 1
  }
  */
  tags = {
    Name        = "${var.environment_slug}-WAF-interface"
    Environment = "${var.environment_name}"
  }
}

resource "aws_network_interface" "devops_admin-interface" {
  subnet_id       = aws_subnet.webserver_subnet.id
  private_ips     = [var.devops_admin_interface_private_ip]
  security_groups = [aws_security_group.administrator_sg.id]
  /*
  attachment {
    instance     = aws_instance.test.id
    device_index = 1
  }
  */
  tags = {
    Name        = "${var.environment_slug}-devops-admin-interface"
    Environment = "${var.environment_name}"
  }
}
resource "aws_network_interface" "jenkins-interface" {
  subnet_id       = aws_subnet.webserver_subnet.id
  private_ips     = [var.jenkins_private_ip]
  security_groups = [aws_security_group.jenkins_sg.id]
  /*
  attachment {
    instance     = aws_instance.test.id
    device_index = 1
  }
  */
  tags = {
    Name        = "${var.environment_slug}-jenkins-interface"
    Environment = "${var.environment_name}"
  }
}
# 8. Assign an elastic IP to the network interface created in step 7
#resource "aws_eip" "one" {
#  vpc                       = true
#  network_interface         = aws_network_interface.web-server.id
#  associate_with_private_ip = "172.16.10.100"
#  depends_on                = [aws-aws_internet_gateway.gw]
#}
# 9. Create ec2-user server and install/enable apache2
#Configure instance



resource "aws_instance" "webserver" {
  count             = length(var.instances_configuration)
  ami               = var.ami_linux
  instance_type     = var.linux_instance_type
  availability_zone = var.subnet-region
  key_name          = aws_key_pair.mtc_auth.id
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-server[count.index].id
  }
  # root disk
  root_block_device {
    volume_size           = var.linux_root_volume_size
    volume_type           = var.linux_root_volume_type
    delete_on_termination = true
    encrypted             = true
  }
  /*
  # extra disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = var.linux_data_volume_size
    volume_type           = var.linux_data_volume_type
    encrypted             = true
    delete_on_termination = true
  }
  */


  tags = {
    Name        = "${var.environment_slug}-webserver-${count.index}"
    Environment = "${var.environment_name}"
  }

  depends_on = [
    aws_key_pair.mtc_auth
  ]
}




resource "aws_instance" "devop_administrator" {
  ami               = var.ami_linux
  instance_type     = var.linux_instance_type
  availability_zone = var.subnet-region
  key_name          = aws_key_pair.mtc_auth.id
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.devops_admin-interface.id
  }
  # root disk
  root_block_device {
    volume_size           = var.linux_root_volume_size
    volume_type           = var.linux_root_volume_type
    delete_on_termination = true
    encrypted             = true
  }
  /*
  # extra disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = var.linux_data_volume_size
    volume_type           = var.linux_data_volume_type
    encrypted             = true
    delete_on_termination = true
  }
  */
  user_data = <<-EOF
                #!/bin/bash
                sudo echo "PubkeyAcceptedKeyTypes=+ssh-rsa" >> /etc/ssh/sshd_config.d/10-insecure-rsa-keysig.conf
                sudo systemctl reload sshd
                echo "${tls_private_key.rsa.private_key_pem}" >> /home/ec2-user/.ssh/id_rsa
                chown ec2-user /home/ec2-user/.ssh/id_rsa
                chgrp ec2-user /home/ec2-user/.ssh/id_rsa
                chmod 600   /home/ec2-user/.ssh/id_rsa
                echo "starting ansible install"
                sudo yum update -y
                sudo amazon-linux-extras install ansible2 -y
                sudo yum install -y git
                ansible --version
                # this command may need to be run twice
                ansible-galaxy install -r /home/ec2-user/ansible/waf-server-ansible/roles/graylog-ansible-role/requirements.yml
                EOF
  /*
  #!/bin/bash
  $ sudo amazon-linux-extras install epel -y
  $ sudo yum repolist
  $ sudo yum-config-manager --enable epel
  $ sudo amazon-linux-extras disable ansible2
  $ sudo yum --enablerepo epel install ansible
  $ ansible --version
  */
  tags = {
    Name        = "${var.environment_slug}-devops-administrator"
    Environment = "${var.environment_name}"
  }

  depends_on = [
    aws_key_pair.mtc_auth
  ]
}



resource "aws_instance" "jenkins_server" {
  ami               = var.ami_linux
  instance_type     = var.jenkins_instance_type
  availability_zone = var.subnet-region
  key_name          = aws_key_pair.mtc_auth.id
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.jenkins-interface.id
  }
  # root disk
  root_block_device {
    volume_size           = var.linux_root_volume_size
    volume_type           = var.linux_root_volume_type
    delete_on_termination = true
    encrypted             = true
  }
  /*
  # extra disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = var.linux_data_volume_size
    volume_type           = var.linux_data_volume_type
    encrypted             = true
    delete_on_termination = true
  }
  */


  tags = {
    Name        = "${var.environment_slug}-jenkins"
    Environment = "${var.environment_name}"
  }

  depends_on = [
    aws_key_pair.mtc_auth
  ]
}



# Create AWS EC2 instance for WAF (Web Application Firewall) and configure it to protect the web server
resource "aws_instance" "waf_ec2" {
  ami               = var.ami_linux
  instance_type     = var.jenkins_instance_type
  availability_zone = var.subnet-region
  key_name          = aws_key_pair.mtc_auth.id
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.waf-interface.id
  }
  # root disk
  root_block_device {
    volume_size           = var.linux_root_volume_size
    volume_type           = var.linux_root_volume_type
    delete_on_termination = true
    encrypted             = true
  }
  /*
  # extra disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = var.linux_data_volume_size
    volume_type           = var.linux_data_volume_type
    encrypted             = true
    delete_on_termination = true
  }
  */
  # user_data load bash script from userdata.tpl file

  user_data = file("modsecurity.sh")

  tags = {
    Name        = "${var.environment_slug}-WAF"
    Environment = "${var.environment_name}"
  }

  depends_on = [
    aws_key_pair.mtc_auth
  ]
}

