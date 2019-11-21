#!/bin/sh

sudo echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf
sudo sysctl -p


sudo echo '# START OPENVPN RULES' >> /etc/ufw/before.rules
sudo echo '# NAT table rules' >> /etc/ufw/before.rules
sudo echo '*nat' >> /etc/ufw/before.rules
sudo echo '-F' >> /etc/ufw/before.rules
sudo echo ':PREROUTING ACCEPT [0:0]' >> /etc/ufw/before.rules
sudo echo "-A PREROUTING -i eth0 -d $1 -p tcp -m multiport --dports 5000:65535 -j DNAT --to-destination 10.8.0.2" >> /etc/ufw/before.rules
sudo echo ':POSTROUTING ACCEPT [0:0]' >> /etc/ufw/before.rules
sudo echo '# Allow traffic from OpenVPN client to eth0' >> /etc/ufw/before.rules
sudo echo '# -A POSTROUTING -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j MASQUERADE' >> /etc/ufw/before.rules
sudo echo '-A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE' >> /etc/ufw/before.rules
sudo echo 'COMMIT' >> /etc/ufw/before.rules
sudo echo '# END OPENVPN RULES' >> /etc/ufw/before.rules

sudo sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/g' /etc/default/ufw

sudo ufw disable
echo 'y' |sudo ufw --force enable

# echo "push "redirect-gateway def1 bypass-dhcp"" >> /etc/openvpn/server.conf
# echo "push "dhcp-option DNS 208.67.222.222"" >> /etc/openvpn/server.conf
# echo "push "dhcp-option DNS 208.67.220.220"" >> /etc/openvpn/server.conf
