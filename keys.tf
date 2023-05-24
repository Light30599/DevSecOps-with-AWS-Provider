#Create aws_key_pair and store the public key onto AWS
resource "aws_key_pair" "mtc_auth" {
  key_name = "${var.environment_slug}-ansible-key"
  #public_key = file(var.ssh_pub_key_file)
  public_key = tls_private_key.rsa.public_key_openssh
}

#Create tls_private_key resource inside Terraform file
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Store private key :  Generate and save private key(aws_keys_pairs.pem) in current directory
resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = var.ssh_pub_key_file

  provisioner "local-exec" {
    command = "chmod 600 ${var.ssh_pub_key_file}"
  }

}
