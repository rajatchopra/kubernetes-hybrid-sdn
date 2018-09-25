#!/bin/bash

ovs-vsctl add-br br-demo
ovs-vsctl add-port br-demo vxlan-win-demo -- set interface vxlan-win-demo type=vxlan  options:remote_ip=172.17.11.2 options:key=flow

# veth pair
ip link add 'ovs-lbr' type veth peer name 'lbr-ovs'
brctl addbr demobr
brctl addif demobr lbr-ovs
ovs-vsctl add-port br-demo ovs-lbr
ip addr add 11.128.0.5/16 dev demobr
ip link set dev demobr up

#oflow
ovs-ofctl -O OpenFlow13 add-flow br-demo 'in_port=vxlan-win-demo, actions=output:ovs-lbr'
ovs-ofctl -O OpenFlow13 add-flow br-demo 'in_port=ovs-lbr, actions=output:vxlan-win-demo'

# open vxlan
iptables -I INPUT 1 -p udp -m udp --dport 4789 -j ACCEPT
