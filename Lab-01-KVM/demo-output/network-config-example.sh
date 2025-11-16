#!/bin/bash
# Примеры сетевых конфигураций

# ========================================
# Пример 1: Создание изолированной сети
# ========================================
cat > /tmp/isolated-network.xml << 'EOF'
<network>
  <name>isolated</name>
  <bridge name='virbr-isolated'/>
  <ip address='10.10.10.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='10.10.10.10' end='10.10.10.100'/>
    </dhcp>
  </ip>
</network>
EOF

virsh net-define /tmp/isolated-network.xml
virsh net-start isolated
virsh net-autostart isolated

# ========================================
# Пример 2: NAT сеть с custom подсетью
# ========================================
cat > /tmp/nat-custom.xml << 'EOF'
<network>
  <name>nat-custom</name>
  <forward mode='nat'/>
  <bridge name='virbr-custom'/>
  <ip address='172.16.10.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='172.16.10.100' end='172.16.10.200'/>
      <host mac='52:54:00:AA:BB:CC' name='server1' ip='172.16.10.10'/>
      <host mac='52:54:00:DD:EE:FF' name='server2' ip='172.16.10.20'/>
    </dhcp>
  </ip>
</network>
EOF

virsh net-define /tmp/nat-custom.xml
virsh net-start nat-custom

# ========================================
# Пример 3: Bridged network
# ========================================
cat > /tmp/bridged-network.xml << 'EOF'
<network>
  <name>host-bridge</name>
  <forward mode="bridge"/>
  <bridge name="br0"/>
</network>
EOF

virsh net-define /tmp/bridged-network.xml
virsh net-start host-bridge

# ========================================
# Пример 4: Статический IP через DHCP
# ========================================
VM_MAC="52:54:00:12:34:56"
VM_IP="192.168.122.100"

virsh net-update default add ip-dhcp-host \
  "<host mac='$VM_MAC' name='static-vm' ip='$VM_IP'/>" \
  --live --config

# ========================================
# Пример 5: Port forwarding (iptables)
# ========================================
VM_IP="192.168.122.10"
HOST_PORT="8080"
VM_PORT="80"

# DNAT правило
iptables -t nat -A PREROUTING -p tcp --dport $HOST_PORT \
  -j DNAT --to-destination ${VM_IP}:${VM_PORT}

# Forward правило
iptables -I FORWARD -p tcp -d $VM_IP --dport $VM_PORT -j ACCEPT

# Сохранить правила
iptables-save > /etc/iptables/rules.v4

# ========================================
# Проверка конфигурации
# ========================================
echo "=== Список сетей ==="
virsh net-list --all

echo "=== Bridges на хосте ==="
ip link show type bridge

echo "=== DHCP leases ==="
virsh net-dhcp-leases default
