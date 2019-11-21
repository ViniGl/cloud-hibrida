variable "region" {
  default = "us-east-1"
}
variable "instance_type" {
  default = "t2.micro"
}

variable "public_key_path" {
  default = "~/.ssh"
}

variable "key_name" {
  default = "/home/cloudn/.ssh/id_rsa"
}

variable "amis" {
  default = {
      us-east-1 = "ami-0e39014c5aa5705fb"
  }
}

variable "public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCySFDkDvTTldiccFCjtwj+S9gJBWqXjPymCSrvBltSA3ppcMafHVCKhHrpOi/GNXGz2rdjgdTV14N0xzGqr+OIjJCepN+CvXi3oXPR6AeHaXXzTidbX8FW5PWAHwtTFz7xWYNH5dC2xBMY1TV2e1xyil70ZLukAHhTmEKPjPtHFCeE9h7hOWcT1aDRBuarSlpUeoYwVDqYdO+viA5V5GzzHI3zgrQQe+Ot+9BvwJ/oenCksk1FdqTjoxZduU9ImKCqIPpG03h4S6i6cagBdnrUQ7LlNw0/muuwurassLbJ7LoBhaxUqHXtI7WMVj5P00jwI8KhZ33n+IzcWo1RY5Yz cloudn@maas"
}
