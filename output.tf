# extract information about resource output

# the allocated public IP
output "webserver_ip" {
  value = aws_instance.webserver[*].public_ip
}

# the allocated public DNS
output "webserver_dns" {
  value = aws_instance.webserver[*].public_dns
}

output "devop_administrator_ip" {
  value = aws_instance.devop_administrator.public_ip
}

output "devop_administrator_dns" {
  value = aws_instance.devop_administrator.public_dns
}

output "jenkins_ip" {
  value = aws_instance.jenkins_server.public_ip
}

output "jenkins_dns" {
  value = aws_instance.jenkins_server.public_dns
}

output "jenkin_web_link" {
  value = "Check Web Site : ${aws_instance.jenkins_server.public_dns}:8080"
}
##############################################################################







/*
# process 'terraform.env' template
# tflint-ignore: terraform_required_providers
data "template_file" "terraform_dotenv" {
  template = file("terraform.env.tpl")
  vars = {
    tf_public_ip        = aws_instance.webserver.public_ip
    tf_public_dns       = aws_instance.webserver.public_dns
    tf_environment_name = var.environment_name
    tf_environment_slug = var.environment_slug
    tf_environment_type = var.environment_type
  }
}

# generate the 'terraform.env' file to propagate required variables (public IP address, env name & type)
# tflint-ignore: terraform_required_providers
resource "local_file" "terraform_dotenv" {
  content  = data.template_file.terraform_dotenv.rendered
  filename = "terraform.env"
}
*/


##############################################################################
# WAF OUTPUT VARIABLES
output "waf_ip" {
  value = aws_instance.waf_ec2.public_ip
}
output "waf_public_dns" {
  value = aws_instance.waf_ec2.public_dns
}
