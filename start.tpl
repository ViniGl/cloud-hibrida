#!/bin/bash

cd /home/ubuntu/
git clone https://github.com/ViniGl/webserver
sudo apt update -y
sudo apt install python3-pip -y
cd webserver
pip3 install -r requirements.txt
touch ~/script_inicializacao
echo '#!/bin/bash' >> ~/script_inicializacao
echo "python3 /home/ubuntu/webserver/webServer.py ${ovpn_ip} &" >> ~/script_inicializacao
sudo chmod +x ~/script_inicializacao
sudo mv ~/script_inicializacao /etc/init.d/
python3 /home/ubuntu/webserver/webServer.py ${ovpn_ip}

