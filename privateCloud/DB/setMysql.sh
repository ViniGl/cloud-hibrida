#!/bin/bash

sed -i "s/bind-address		= 127.0.0.1/bind-address		= 0.0.0.0/g"  /etc/mysql/mysql.conf.d/mysqld.cnf


