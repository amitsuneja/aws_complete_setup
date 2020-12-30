resource "aws_launch_configuration" "WebServer-launch-configuration" {
    name                        = "WebServer-launch-configuration"
    image_id                    = var.CENTOS7_CUSTOMIZED_AMI
    instance_type               = var.NAT_INST_TYPE
    #iam_instance_profile       = aws_iam_instance_profile.ecs-instance-profile.id

    root_block_device {
      volume_type = "standard"
      volume_size = 100
      delete_on_termination = true
    }

    lifecycle {
      create_before_destroy = true
    }

    security_groups             = [aws_security_group.LoadBalancerSG.id]
    associate_public_ip_address = true
    key_name                    = var.NAT_INST_KEY_NAME
    user_data                   = <<EOF
                                  #!/bin/bash
                                  yum install -y httpd
                                  systemctl enable httpd
                                  systemctl start httpd
                                  echo "I am Web Server" > /var/www/html/index.html
                                  EOF
}
