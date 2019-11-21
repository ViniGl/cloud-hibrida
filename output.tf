output "OpenVPN" {
    value = ["${aws_instance.OpenVPN.*.public_ip}"]
}

output "openstack_ip"{
    value = ["${openstack_compute_floatingip_associate_v2.wbIp.floating_ip}"]
}

output "LB_IP" {
    value = ["${aws_elb.projeto_vini_lb.dns_name}"]
}
