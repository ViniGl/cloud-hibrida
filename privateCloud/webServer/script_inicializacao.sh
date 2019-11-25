#!/bin/bash

tmux new-session -d -s hook "python3 hook-mysql.py #IP_PRIVADO"
tmux new-session -d -s ovpn 'sudo openvpn client.ovpn < openvpnCred'
