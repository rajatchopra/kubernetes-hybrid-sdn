#!/bin/bash

ip route add 11.128.0.0/16 via 10.128.0.1 dev k8s-openshift-m 
iptables -I INPUT 1 -p udp -m udp --dport 4789 -j ACCEPT

