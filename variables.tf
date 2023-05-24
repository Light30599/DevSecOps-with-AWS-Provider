#define variable

variable "host_os" {
  type    = string
  default = "linux"
}

variable "subnet_prefix" {
  description = "cidr block for the subnet 172.16.10.0/24"
  #default = "172.16.10.0/24"
  #type = string

}

variable "vpc_cidr_block" {
  description = "cidr block for the vpc"
  type        = string
}

variable "subnet-region" {
  type    = string
  default = "us-east-1a"
}


# provided by the GitLab CI template
variable "environment_type" {
  description = "Environment Type"
  type        = string
  default     = "dev"
}

# provided by the GitLab CI template
variable "environment_name" {
  description = "Environment Name"
  type        = string
  default     = "dev"
}

# provided by the GitLab CI template
variable "environment_slug" {
  description = "Environment FQDN"
  type        = string
  default     = "dev"
}

variable "linux_instance_type" {
  type        = string
  description = "EC2 instance type for Linux Server"
  default     = "t2.micro"
}

variable "jenkins_instance_type" {
  type        = string
  description = "EC2 instance type for Jenkins Server"
  default     = "t2.medium"
}


variable "linux_associate_public_ip_address" {
  type        = bool
  description = "Associate a public IP address to the EC2 instance"
  default     = true
}
variable "linux_root_volume_size" {
  type        = number
  description = "Volumen size of root volumen of Linux Server"
}
variable "linux_data_volume_size" {
  type        = number
  description = "Volumen size of data volumen of Linux Server"
}
variable "linux_root_volume_type" {
  type        = string
  description = "Volumen type of root volumen of Linux Server."
  default     = "gp2"
}
variable "linux_data_volume_type" {
  type        = string
  description = "Volumen type of data volumen of Linux Server"
  default     = "gp2"
}

variable "ssh_pub_key_file" {
  description = "SSH public key file"
  type        = string
  default     = "dev-ansible-key.pem"
  sensitive   = true
}


variable "ssh_user_name" {
  description = "SSH username"
  type        = string
  default     = "ec2-user"
}

variable "devops_admin_interface_private_ip" {
  description = "devops admin interface private IP"
  type        = string
  default     = "172.16.10.225"
}

variable "jenkins_private_ip" {
  description = "jenkins interface private IP"
  type        = string
  default     = "172.16.10.226"
}

variable "waf_private_ip" {
  description = "jenkins interface private IP"
  type        = string
  default     = "172.16.10.227"
}


/*
variable "server_count" {
  description = "Server App Machine Number"
  type        = number
  default     = 1
  validation {
    error_message = "Accepted Server count values: 1-16."
    condition     = var.server_count >= 1 && var.server_count <= 16 && floor(var.server_count) == var.server_count
  }
}
*/

variable "instances_configuration" {
  description = "The total configuration, List of Objects/Dictionary"
  default     = []
}


variable "ansible_forks_count" {
  description = "The maximum number of simultaneous hosts"
  default     = 50
}

variable "ansible_log_path" {
  description = "Setting the ansible log path"
  default     = "/var/log/ansible.log"
}

variable "ami_linux" {
  default     = "ami-005f9685cb30f234b"
  description = "AMI Linux"
}

variable "ami_waf_ubutnu" {
  default     = "ami-0aa2b7722dc1b5612"
  description = "AMI WAF Ubutnu"
}

###################### WAF ############################