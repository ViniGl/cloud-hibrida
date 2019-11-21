import os
import sys

priv_ip = sys.argv[1]

os.system('sudo apt update -y')
os.system('sudo apt install openvpn easy-rsa -y')
os.system('touch ~/.rnd')

os.system(f'sudo ~/port_forwarding.sh {priv_ip}')

os.system('sudo ufw allow 443/tcp')
os.system('sudo ufw allow 5000/tcp')
os.system('sudo ufw allow OpenSSH')

os.system('sudo cp -r ~/etc/* /etc/')

os.system('sudo systemctl start openvpn@server')


