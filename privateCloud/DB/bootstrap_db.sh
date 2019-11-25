#!/bin/bash


sudo apt install python3-pip -y

sudo apt install mysql-server -y


echo "CREATE USER 'vini'@'%' IDENTIFIED BY '12345678';" | sudo mysql -uroot
echo "GRANT ALL PRIVILEGES ON *.* TO 'vini'@'%' WITH GRANT OPTION;" | sudo mysql -uroot


