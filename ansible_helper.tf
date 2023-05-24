# generate the Ansible inventory file (in './tf-output' directory, that is stored as a job artifact)
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.root}/templates/inventory.tftpl",
    {
      workers-dns = aws_instance.webserver.*.private_dns,
      workers-ip  = aws_instance.webserver.*.private_ip,
      workers-id  = aws_instance.webserver.*.id,
      jenkins_dns = aws_instance.jenkins_server.private_dns,
      jenkins_ip  = aws_instance.jenkins_server.private_ip,
      jenkins_id  = aws_instance.jenkins_server.id,
      waf_dns     = aws_instance.waf_ec2.private_dns,
      waf_ip      = aws_instance.waf_ec2.private_ip,
      waf_id      = aws_instance.waf_ec2.id
    }
  )
  filename = "${path.root}/tf-output/inventory"
}


# generate the Ansible.cfg file (in 'remote machine' directory, that is stored as a job artifact)
resource "local_file" "ansible_config" {
  content = templatefile("${path.root}/templates/ansible.cfg.tftpl",
    {
      ansible_inventory_path   = "/home/ec2-user/ansible/inventory",
      anisble_private_key_path = "/home/ec2-user/.ssh/id_rsa"
      ansible_user             = var.ssh_user_name
      ansible_forks_count      = var.ansible_forks_count
      ansible_log_path         = var.ansible_log_path
    }
  )
  filename = "${path.root}/tf-output/ansible.cfg"
}


# wating for devops server user data init.
# TODO: Need to switch to signaling based solution instead of waiting. 
resource "time_sleep" "wait_for_devops_init" {
  depends_on = [aws_instance.devop_administrator]

  #create_duration = "120s"
  create_duration = "60s"
  triggers = {
    "always_run" = timestamp()
  }
}

resource "null_resource" "provisioner" {
  depends_on = [
    local_file.ansible_inventory,
    local_file.ansible_config,
    time_sleep.wait_for_devops_init,
    aws_instance.devop_administrator
  ]

  triggers = {
    "always_run" = timestamp()
  }

  provisioner "file" {
    source      = "${path.root}/tf-output"
    destination = "/home/ec2-user/ansible/"

    connection {
      type        = "ssh"
      host        = aws_instance.devop_administrator.public_ip
      user        = var.ssh_user_name
      private_key = tls_private_key.rsa.private_key_pem
      agent       = false
      insecure    = true
    }
  }
}


resource "null_resource" "copy_ansible_playbooks" {
  depends_on = [
    null_resource.provisioner,
    time_sleep.wait_for_devops_init,
    aws_instance.devop_administrator,
  ]

  triggers = {
    "always_run" = timestamp()
  }

  provisioner "file" {
    source      = "${path.root}/ansible/"
    destination = "/home/ec2-user/ansible/"

    connection {
      type        = "ssh"
      host        = aws_instance.devop_administrator.public_ip
      user        = var.ssh_user_name
      private_key = tls_private_key.rsa.private_key_pem
      insecure    = true
      agent       = false
    }

  }
}


resource "null_resource" "run_ansible" {
  depends_on = [
    null_resource.provisioner,
    null_resource.copy_ansible_playbooks,
    aws_instance.devop_administrator,
    aws_instance.webserver,
    aws_vpc.vpc,
    time_sleep.wait_for_devops_init
  ]

  triggers = {
    always_run = timestamp()
  }

  connection {
    type        = "ssh"
    host        = aws_instance.devop_administrator.public_ip
    user        = var.ssh_user_name
    private_key = tls_private_key.rsa.private_key_pem
    insecure    = true
    agent       = false
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'starting ansible playbooks...'",
      # jenkins running in port 8080
      #"sleep 60 && cd ./ansible && ansible-playbook jenkins-ansible/jenkins_master.yml",
      #"sleep 60 && cd ./ansible && ansible-playbook jenkins-ansible/jenkins_slave.yml",
      # SonarQube running in port 9000 with user admin and password admin
      #"sleep 60 && cd ./ansible && ansible-playbook jenkins-ansible/sonarQube.yml",
      # webserver running in port 80
      #"sleep 60 && cd ./ansible && ansible-playbook web-app-ansible/playbook.yml",
      # reverse proxy running in port 80 redirecting to webserver port 80 through path /app
      #"sleep 60 && cd ./ansible && ansible-playbook waf-app-ansible/waf-server-playbook.yml",
      # graylog running in port 9000 with credentials admin/admin
      #"sleep 60 && cd ./ansible && ansible-playbook waf-app-ansible/graylog.yml",
      # filebeat running in port 5044
      #"sleep 60 && cd ./ansible && ansible-playbook waf-app-ansible/filebeat.yml",
    ]
  }
}
