#!/bin/bash

mac="0a:0a:10:10:10:10"
ip="11.128.0.1"

hex_ip=$(printf '%02x' ${ip//./ }; echo)
hex_mac=$(printf '%02s' ${mac//:/ }; echo)
echo ${hex_ip}
echo ${hex_mac}
actions=("move:NXM_OF_ETH_SRC[]->NXM_OF_ETH_DST[],\
                       mod_dl_src:${mac},\
                       load:0x2->NXM_OF_ARP_OP[],\
                       move:NXM_NX_ARP_SHA[]->NXM_NX_ARP_THA[],\
                       move:NXM_OF_ARP_SPA[]->NXM_OF_ARP_TPA[],\
                       load:0x${hex_mac}->NXM_NX_ARP_SHA[],\
                       load:0x${hex_ip}->NXM_OF_ARP_SPA[],\
                       in_port")
echo $actions

ovs-ofctl del-flows -O OpenFlow13 br-win "table=0, arp"
ovs-ofctl add-flow -O OpenFlow13 br-win "table=0,dl_type=0x0806,nw_dst=${ip},actions=${actions}"
