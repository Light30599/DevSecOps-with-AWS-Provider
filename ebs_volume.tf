/*
resource "aws_ebs_volume" "myvol" {
  count           = length(var.instances_configuration)
  availability_zone = aws_instance.webserver[count.index].availability_zone
  size              = 1


  tags = {
    Name = "${var.environment_slug}-webserver-ebs-volume-${count.index}"
  }
}


resource "aws_volume_attachment" "my_ebs_attach_ec2" {
  count           = length(var.instances_configuration)
  force_detach = true
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.myvol.id
  instance_id = aws_instance.webserver[count.index].id
}	
*/