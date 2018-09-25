#!/bin/bash

# windows node IP
REMOTE_IP=172.17.11.4
NODE_NAME=openshift-master-node
ROUTER_IP=11.128.0.2/16
ROUTER_MAC=0a:00:64:41:01:01

ovs-vsctl add-br br-win
ovs-vsctl add-port br-win vxlan-win1 -- set interface vxlan-win1 type=vxlan  options:remote_ip=${REMOTE_IP} options:key=flow

ovs-vsctl add-port br-win patch-br-win-int -- set interface patch-br-win-int type=patch options:peer=patch-br-int-win
ovs-vsctl add-port br-int patch-br-int-win -- set interface patch-br-int-win type=patch options:peer=patch-br-win-int external-ids:iface-id=${NODE_NAME}-win

ovn-nbctl ls-add ext_${NODE_NAME}-win
ovn-nbctl --may-exist lsp-add ext_${NODE_NAME}-win ${NODE_NAME}-win -- lsp-set-addresses ${NODE_NAME}-win unknown
ovn-nbctl --may-exist lsp-add ext_${NODE_NAME}-win etor-${NODE_NAME}-win -- set logical_switch_port etor-${NODE_NAME}-win type=router options:router-port=rtoe-${NODE_NAME}-win addresses=\"${ROUTER_MAC}\"

ovn-nbctl --may-exist lrp-add GR_${NODE_NAME} rtoe-${NODE_NAME}-win ${ROUTER_MAC} ${ROUTER_IP}
