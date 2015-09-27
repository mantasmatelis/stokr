#!/bin/bash
/usr/local/sbin/openvpn --config <(echo $'client\ndev tap1\nproto udp\nresolv-retry infinite\nnobind\npersist-key\npersist-tun\nca ca.crt\nverb 3\nauth-user-pass\n') --remote $1 --auth-user-pass <(echo $'Administrator\n'$2)


