import os
import subprocess

os.system('sudo apt update')
os.system('sudo apt install python3-pip -y')
os.system('sudo apt install mysql-server -y')

create_user="CREATE USER 'vini'@'localhost' IDENTIFIED BY '123';"
user_priv="GRANT ALL PRIVILEGES ON *.* TO 'vini'@'localhost' WITH GRANT OPTION;"

mysql_cmd = "sudo mysql -u root".split(" ")

p1 = subprocess.Popen(['echo', f'{create_user}'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
mysql = subprocess.Popen(mysql_cmd,  stdin=p1.stdout, stdout=subprocess.PIPE)
p1.stdout.close()  # Allow p1 to receive a SIGPIPE if p2 exits.
output,err = mysql.communicate() 


p2 = subprocess.Popen(['echo',  f'{user_priv}'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
mysql = subprocess.Popen(mysql_cmd,  stdin=p2.stdout, stdout=subprocess.PIPE)
p2.stdout.close()  # Allow p1 to receive a SIGPIPE if p2 exits.
output,err = mysql.communicate() 


