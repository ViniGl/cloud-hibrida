#########################################################################################
/*
Proximo passo:
     script openvpn 
          port forwarding problema
*/
#########################################################################################


###################################OpenStack#############################################

## Conection AUTH
provider "openstack" {
  user_name   = "admin"
  tenant_name = "admin"
  password    = "yaagh4OoquoBe4uu"
  auth_url    = "http://192.168.2.53:5000/v3"
  region      = "RegionOne"
}

## Security Group
resource "openstack_networking_secgroup_v2" "secgroup_1" {
  name        = "ProjetoSG"
  description = "Security group do projeto"
}

## SSH ingress
resource "openstack_networking_secgroup_rule_v2" "rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_1.id}"
}

resource "openstack_networking_secgroup_rule_v2" "rule_2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  port_range_min    = 0
  port_range_max    = 0
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.secgroup_1.id}"
}

## Float ip pool
resource "openstack_networking_floatingip_v2" "wbIp" {
  pool = "ext_net"
}

## Key pair
resource "openstack_compute_keypair_v2" "keyPair" {
  name       = "key_projeto"
  public_key = "${var.public_key}"
}

## Instance configuration
resource "openstack_compute_instance_v2" "webServer" {
  name      = "DB"
  region    = "RegionOne"
  image_id  = "d3de55ef-15e2-49c5-9b6d-4401f46c631a" #Bionic
  flavor_id = "d82e67e6-6d74-4e43-8e8e-a4d9403f7e68" #m1.medium
  key_pair  = "key_projeto"
  security_groups = ["default"]
  
  depends_on = [
      aws_instance.OpenVPN,
      openstack_blockstorage_volume_v3.volumeWS
  ]

  network {
    uuid = "737de4e8-a62d-4b19-9a3d-285389b75f46"
    name = "internal"
  }

   block_device {
    uuid                  = "d3de55ef-15e2-49c5-9b6d-4401f46c631a"
    source_type           = "image"
    destination_type      = "local"
    boot_index            = 0
    delete_on_termination = true
  }


   block_device {
    uuid                  = "${openstack_blockstorage_volume_v3.volumeWS.id}"
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 1
    delete_on_termination = true
  }

  
}


## Associate float ip
resource "openstack_compute_floatingip_associate_v2" "wbIp" {
  floating_ip = "${openstack_networking_floatingip_v2.wbIp.address}"
  instance_id = "${openstack_compute_instance_v2.webServer.id}"
  fixed_ip    = "${openstack_compute_instance_v2.webServer.network.0.fixed_ip_v4}"
}

## Instances's environment 

resource "null_resource" "ws_env" {

  depends_on = [
      openstack_compute_floatingip_associate_v2.wbIp,
      aws_instance.OpenVPN
  ]

  # triggers = {
  #     build_number = "${timestamp()}"
  # }
    

  provisioner "file" {
    source      = "./privateCloud/webServer/bootstrap_ws.py"
    destination = "/home/ubuntu/bootstrap_ws.py"

   
    connection {
      host = "${openstack_compute_floatingip_associate_v2.wbIp.floating_ip}"
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("${var.key_name}")}"
      timeout = "2m"
      agent = false
    }
  }

  provisioner "file" {
    source      = "./privateCloud/webServer/hook-mysql.py"
    destination = "/home/ubuntu/hook-mysql.py"

   
    connection {
      host = "${openstack_compute_floatingip_associate_v2.wbIp.floating_ip}"
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("${var.key_name}")}"
      timeout = "2m"
      agent = false
    }
  }

  provisioner "file" {
    source      = "./privateCloud/webServer/requirements.py"
    destination = "/home/ubuntu/requirements.py"

   
    connection {
      host = "${openstack_compute_floatingip_associate_v2.wbIp.floating_ip}"
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("${var.key_name}")}"
      timeout = "2m"
      agent = false
    }
  }

    provisioner "file" {
    source      = "./privateCloud/webServer/openvpnCred"
    destination = "/home/ubuntu/openvpnCred"

   
    connection {
      host = "${openstack_compute_floatingip_associate_v2.wbIp.floating_ip}"
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("${var.key_name}")}"
      timeout = "2m"
      agent = false
    }
  }

  provisioner "file" {
    source      = "./privateCloud/webServer/client.ovpn"
    destination = "/home/ubuntu/client.ovpn"

   
    connection {
      host = "${openstack_compute_floatingip_associate_v2.wbIp.floating_ip}"
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("${var.key_name}")}"
      timeout = "2m"
      agent = false
    }
  }

  provisioner "file" {
    source      = "./privateCloud/webServer/setIp.sh"
    destination = "/home/ubuntu/setIp.sh"

   
    connection {
      host = "${openstack_compute_floatingip_associate_v2.wbIp.floating_ip}"
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("${var.key_name}")}"
      timeout = "2m"
      agent = false
    }
  }
  
  provisioner "remote-exec" {
    connection {
      host = "${openstack_compute_floatingip_associate_v2.wbIp.floating_ip}"
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("${var.key_name}")}"
      timeout = "2m"
      agent = false
    }

    inline = [
      "python3 /home/ubuntu/bootstrap_ws.py",
      "/home/ubuntu/setIp.sh ${aws_instance.OpenVPN.public_ip}",
      "pip3 install -r requirements.txt",
      "touch ~/script_inicializacao",
      "echo '#!/bin/bash' >> ~/script_inicializacao",
      "echo 'tmux new-session -d -s hook 'python3 hook-mysql.py ${openstack_compute_floatingip_associate_v2.dbIp.floating_ip}'' >> ~/script_inicializacao",
      "echo 'tmux new-session -d -s ovpn 'sudo openvpn client.ovpn < openvpnCred'' >> ~/script_inicializacao",
      "sudo mv ~/script_inicializacao /etc/init.d/",
      "sudo chmod +x /etc/init.d/script_inicializacao",
      "python3 ~/createDB.py ${openstack_compute_floatingip_associate_v2.dbIp.floating_ip}",
      "tmux new-session -d -s hook 'python3 hook-mysql.py'",
      "echo python Started",
      "tmux new-session -d -s ovpn 'sudo openvpn client.ovpn < openvpnCred'",
    ]
  } 
   
}

## Create volume
resource "openstack_blockstorage_volume_v3" "volumeWS" {
  region      = "RegionOne"
  name        = "volumeWS"
  description = "Volume utilizando o snapshot do banco de dados privado"
  source_replica = "50c95ae5-e6b3-4a62-9a03-860d42a724cc"
  size        = 20
  metadata    = {
    attached_mode = "rw"
  }
}

##DB 

## Create volume
resource "openstack_blockstorage_volume_v3" "volumeDB" {
  region      = "RegionOne"
  name        = "volumeDB"
  description = "Volume utilizando o snapshot do banco de dados privado"
  source_replica = "50c95ae5-e6b3-4a62-9a03-860d42a724cc"
  size        = 20
  metadata    = {
    attached_mode = "rw"
  }
}

## Key pair
resource "openstack_compute_keypair_v2" "keyPair" {
  name       = "key_projeto"
  public_key = "${var.public_key}"
}

## Instance configuration DB
resource "openstack_compute_instance_v2" "DB" {
  name      = "DB"
  region    = "RegionOne"
  image_id  = "d3de55ef-15e2-49c5-9b6d-4401f46c631a" #Bionic
  flavor_id = "d82e67e6-6d74-4e43-8e8e-a4d9403f7e68" #m1.medium
  key_pair  = "key_projeto"
  security_groups = ["default"]
  
  depends_on = [
      openstack_blockstorage_volume_v3.volumeDB
  ]

  network {
    uuid = "737de4e8-a62d-4b19-9a3d-285389b75f46"
    name = "internal"
  }

   block_device {
    uuid                  = "d3de55ef-15e2-49c5-9b6d-4401f46c631a"
    source_type           = "image"
    destination_type      = "local"
    boot_index            = 0
    delete_on_termination = true
  }


   block_device {
    uuid                  = "${openstack_blockstorage_volume_v3.volumeDB.id}"
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 1
    delete_on_termination = true
  }

  
}

## Float ip pool
resource "openstack_networking_floatingip_v2" "dbIp" {
  pool = "ext_net"
}

## Associate float ip
resource "openstack_compute_floatingip_associate_v2" "dbIp" {
  floating_ip = "${openstack_networking_floatingip_v2.dbIp.address}"
  instance_id = "${openstack_compute_instance_v2.webServer.id}"
  fixed_ip    = "${openstack_compute_instance_v2.webServer.network.0.fixed_ip_v4}"
}

resource "null_resource" "db_env" {

  provisioner "file" {
    source      = "./bootstrap_db.py"
    destination = "/home/ubuntu/bootstrap_db.py"

  
    connection {
      host = "${openstack_compute_floatingip_associate_v2.dbIp.floating_ip}"
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("${var.key_name}")}"
      timeout = "2m"
      agent = false
    }
  }

   provisioner "file" {
    source      = "./createDB.py"
    destination = "/home/ubuntu/createDB.py"

  
    connection {
      host = "${openstack_compute_floatingip_associate_v2.dbIp.floating_ip}"
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("${var.key_name}")}"
      timeout = "2m"
      agent = false
    }
  }
    
  provisioner "remote-exec" {
    connection {
      host = "${openstack_compute_floatingip_associate_v2.dbIp.floating_ip}"
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("${var.key_name}")}"
      timeout = "2m"
      agent = false
    }

    inline = [
      "python3 /home/ubuntu/bootstrap_db.py",
      "python3 /home/ubuntu/createDB.py"
    ]
  }
}

########################AWS##############################################################
provider "aws" {
  profile    = "default"
  region     = var.region
}


#OPENVPN
resource "aws_security_group" "openvpn" {
  name = "openvpn_sg"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 945
    to_port = 945
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 943
    to_port = 943
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 1194
    to_port = 1194
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "OpenVPN" {
  #ami           = "ami-04dfedf036a72cfe6" #Imagem configurada
  ami           = "ami-04b9e92b5572fa0d1" #Ubuntu 18.04 x86
  instance_type = "t2.micro"

  tags = {
    Name = "OpenVPN - Vini"
    Owner = "Vini"
  }

  key_name = "${aws_key_pair.keypaircreator.key_name}"
  
  depends_on = [
      aws_security_group.openvpn
  ]

  vpc_security_group_ids = ["${aws_security_group.openvpn.id}"]
}

resource "null_resource" "ovpn_env" {

  depends_on = [
      aws_instance.OpenVPN
  ]

  # triggers = {
  #     build_number = "${timestamp()}"
  # }
    

  provisioner "file" {
    source      = "./publicCloud/ovpn/createOVPN.py"
    destination = "/home/ubuntu/createOVPN.py"

   
    connection {
      host = "${aws_instance.OpenVPN.public_ip}"
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("${var.key_name}")}"
      timeout = "2m"
      agent = false
    }
  }

  provisioner "file" {
    source      = "./publicCloud/ovpn/port_forwarding.sh"
    destination = "/home/ubuntu/port_forwarding.sh"

   
    connection {
      host = "${aws_instance.OpenVPN.public_ip}"
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("${var.key_name}")}"
      timeout = "2m"
      agent = false
    }
  }
  provisioner "remote-exec" {
    connection {
      host = "${aws_instance.OpenVPN.public_ip}"
      type = "ssh"
      user = "ubuntu"
      private_key = "${file("${var.key_name}")}"
      timeout = "2m"
      agent = false
    }

    inline = [
      "python3 createOVPN.py ${aws_instance.OpenVPN.private_ip}"
    ]
  } 
   
}

##########################################################################################



### https://medium.com/@ratulbasak93/aws-elb-and-autoscaling-using-terraform-9999e6266734

data "aws_availability_zones" "all" {}

##############################AUTO SCALING#############################################

resource "aws_key_pair" "keypaircreator" {
  key_name   = "ViniKey"
  public_key = "${var.public_key}"
}

### Creating Security Group for EC2
resource "aws_security_group" "instance" {
  name = "securiry_group_projeto_vini"
  ingress {
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


## Creating Launch Configuration
data "template_file" "bootstrap-webserver" {
  template = "${file("start.tpl")}"
  
  vars = {
      ovpn_ip = "${aws_instance.OpenVPN.public_ip}"
  }
}

resource "aws_launch_configuration" "projeto_configs" {

  image_id               = "ami-04b9e92b5572fa0d1"
  instance_type          = "t2.micro"
  security_groups        = ["${aws_security_group.instance.id}"]
  key_name               = "${aws_key_pair.keypaircreator.key_name}"
  lifecycle {
    create_before_destroy = true
  }

  user_data = "${data.template_file.bootstrap-webserver.rendered}"
}



## Creating AutoScaling Group
resource "aws_autoscaling_group" "autoScaleGroup" {
  name                      = "Autoscaling - Vini"
  launch_configuration = "${aws_launch_configuration.projeto_configs.name}"
  availability_zones =  ["us-east-1a", "us-east-1b", "us-east-1c"]
  min_size = 2
  max_size = 10
  load_balancers = ["${aws_elb.projeto_vini_lb.name}"]
  health_check_type = "ELB"
  tag {
    key = "Name"
    value = "WebServer - Vini"
    propagate_at_launch = true
  }
   tag {
    key                 = "Owner"
    value               = "Vini"
    propagate_at_launch = true
  }

}
##############################################################################

####################Load Balancer########################################

## Security Group for ELB
resource "aws_security_group" "elb" {
  name = "projeto_vini"
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### Creating ELB
resource "aws_elb" "projeto_vini_lb" {
  name = "projetoViniLB"
  security_groups = ["${aws_security_group.elb.id}"]

  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:5000/healthcheck"
  }
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "5000"
    instance_protocol = "http"
  }

  tags = {
    Name = "LB - Vini"
  }
}