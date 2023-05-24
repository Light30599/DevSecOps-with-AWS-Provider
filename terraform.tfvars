subnet_prefix           = "172.16.10.0/24"
vpc_cidr_block          = "172.16.0.0/16"
host_os                 = "linux"
instances_configuration = ["172.16.10.100"]





# Linux Virtual Machine
linux_instance_type               = "t2.micro"
linux_associate_public_ip_address = true
linux_root_volume_size            = 20
linux_root_volume_type            = "gp2"
linux_data_volume_size            = 10
linux_data_volume_type            = "gp2"


# Jenkins Virtual Machine
jenkins_instance_type = "t2.medium"


# WAF terraform configuration variables
