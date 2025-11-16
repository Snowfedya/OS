# Лабораторная работа 3: Конфигурация сети виртуальных машин

## 🎯 Цель работы

Освоить настройку сетевых режимов в KVM: NAT, Bridge, изолированные сети, научиться создавать виртуальные сети и настраивать связность между VM.

## 📋 Предварительные условия

- Выполнены Lab 1-2
- Минимум 2 работающие VM для тестирования связности
- Базовое понимание сетевых концепций (IP, DHCP, NAT, Bridge)

## 📚 Теоретическая часть

### Сетевые режимы в libvirt

1. **NAT (Network Address Translation)** — default режим
   - VM получают private IP (192.168.122.0/24)
   - Доступ в интернет через хост
   - VM недоступны извне без port forwarding

2. **Bridge (Мост)** — прямое подключение к LAN хоста
   - VM получают IP в той же сети что и хост
   - Видны как физические машины в сети
   - Требует настройки bridge на хосте

3. **Isolated (Изолированная)** — внутренняя сеть без выхода
   - VM видят только друг друга
   - Нет доступа в интернет
   - Для изолированных тестовых окружений

4. **Host-only** — доступ только с хоста
   - VM видны только хосту
   - Без доступа в интернет

## 🔬 Практическая часть

### Задание 3.1: Работа с default NAT сетью

**Шаг 1:** Проверьте существующие виртуальные сети

```bash
virsh net-list --all
```

**Ожидаемый вывод:**
```
 Name      State    Autostart   Persistent
--------------------------------------------
 default   active   yes         yes
```

**Шаг 2:** Просмотрите конфигурацию default сети

```bash
virsh net-dumpxml default
```

**Ключевые элементы конфигурации:**
```xml
<network>
  <name>default</name>
  <bridge name='virbr0'/>
  <forward mode='nat'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'/>
    </dhcp>
  </ip>
</network>
```

**Шаг 3:** Проверьте сетевой интерфейс на хосте

```bash
ip addr show virbr0
brctl show virbr0  # или: bridge link show
```

**Шаг 4:** Получите IP адреса VM

```bash
virsh domifaddr kvm-lab-vm
# или через DHCP leases:
virsh net-dhcp-leases default
```

**Шаг 5:** Проверьте связность VM -> Интернет

```bash
virsh console kvm-lab-vm
# Внутри VM:
ping -c 4 8.8.8.8
ping -c 4 google.com
curl -I https://www.google.com
```

### Задание 3.2: Создание изолированной сети

Изолированная сеть для тестирования без доступа в интернет.

**Шаг 1:** Создайте XML конфигурацию сети

```bash
cat > /tmp/isolated-net.xml << 'EOF'
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
```

**Шаг 2:** Создайте и запустите сеть

```bash
virsh net-define /tmp/isolated-net.xml
virsh net-start isolated
virsh net-autostart isolated
```

**Шаг 3:** Проверьте создание

```bash
virsh net-list --all
virsh net-info isolated
```

**Шаг 4:** Подключите VM к изолированной сети

```bash
# Создайте новую VM или подключите существующую
virsh attach-interface kvm-lab-vm network isolated \
  --model virtio \
  --config --live
```

**Шаг 5:** Проверьте подключение

```bash
virsh domiflist kvm-lab-vm
```

**Шаг 6:** Проверьте изоляцию

```bash
virsh console kvm-lab-vm
# Внутри VM:
ip addr  # Должны увидеть новый интерфейс с IP 10.10.10.x
ping 10.10.10.1  # Должен работать (gateway)
ping 8.8.8.8     # НЕ должен работать (изоляция)
```

### Задание 3.3: Создание Linux Bridge для bridged networking

**Шаг 1:** Установите bridge-utils (если не установлен)

```bash
sudo apt-get install -y bridge-utils
```

**Шаг 2:** Создайте bridge интерфейс на хосте

```bash
# Определите ваш основной сетевой интерфейс
ip addr show

# Пример для eth0 (замените на ваш интерфейс)
sudo nmcli connection add type bridge con-name br0 ifname br0
sudo nmcli connection add type bridge-slave con-name br0-eth0 ifname eth0 master br0
sudo nmcli connection up br0
```

**Альтернативно (через netplan на Ubuntu):**

```bash
sudo nano /etc/netplan/01-netcfg.yaml
```

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
  bridges:
    br0:
      dhcp4: yes
      interfaces:
        - eth0
```

```bash
sudo netplan apply
```

**Шаг 3:** Создайте bridged сеть в libvirt

```bash
cat > /tmp/bridged-net.xml << 'EOF'
<network>
  <name>host-bridge</name>
  <forward mode="bridge"/>
  <bridge name="br0"/>
</network>
EOF

virsh net-define /tmp/bridged-net.xml
virsh net-start host-bridge
virsh net-autostart host-bridge
```

**Шаг 4:** Подключите VM к bridge

```bash
# При создании новой VM:
virt-install \
  --name bridged-vm \
  --network bridge=br0,model=virtio \
  # ... остальные параметры
```

**Результат:** VM получит IP в той же подсети что и физический хост.

### Задание 3.4: Port Forwarding в NAT сети

Пробросить порт 8080 хоста на порт 80 VM.

**Шаг 1:** Отредактируйте конфигурацию default сети

```bash
virsh net-edit default
```

**Шаг 2:** Добавьте правило port forwarding

Найдите секцию `<ip>` и добавьте после `<dhcp>`:

```xml
<network>
  <name>default</name>
  <!-- ... existing config ... -->
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'/>
    </dhcp>
  </ip>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
</network>
```

**Шаг 3:** Используйте iptables для проброса порта

```bash
# Получите IP VM
VM_IP=$(virsh domifaddr kvm-lab-vm | grep -oP '\d+\.\d+\.\d+\.\d+' | head -1)

# Добавьте правило DNAT
sudo iptables -t nat -A PREROUTING -p tcp --dport 8080 \
  -j DNAT --to-destination ${VM_IP}:80

# Разрешите forwarding
sudo iptables -I FORWARD -p tcp -d ${VM_IP} --dport 80 -j ACCEPT
```

**Шаг 4:** Проверьте работу

```bash
# Внутри VM запустите веб-сервер:
python3 -m http.server 80

# На хосте проверьте доступ:
curl http://localhost:8080
```

### Задание 3.5: Статические IP адреса через DHCP

**Шаг 1:** Получите MAC адрес VM

```bash
virsh domiflist kvm-lab-vm
```

**Шаг 2:** Добавьте статический lease

```bash
virsh net-update default add ip-dhcp-host \
  "<host mac='52:54:00:XX:XX:XX' name='kvm-lab-vm' ip='192.168.122.10'/>" \
  --live --config
```

**Шаг 3:** Перезапустите сеть и VM

```bash
virsh net-destroy default
virsh net-start default
virsh reboot kvm-lab-vm
```

**Шаг 4:** Проверьте новый IP

```bash
virsh domifaddr kvm-lab-vm
```

### Задание 3.6: Тестирование связности между VM

**Создайте 3 VM в одной сети:**

```bash
for i in {1..3}; do
  virt-install \
    --name net-test-vm$i \
    --ram 512 \
    --vcpus 1 \
    --disk path=/var/lib/libvirt/images/net-test-vm$i.qcow2,size=5 \
    --network network=default \
    --import \
    --noautoconsole
done
```

**Проверьте связность:**

```bash
# Получите IP всех VM
virsh net-dhcp-leases default

# Подключитесь к VM1
virsh console net-test-vm1

# Внутри VM1:
ping -c 4 <IP_VM2>
ping -c 4 <IP_VM3>
```

## ✅ Контрольные вопросы

1. В чем разница между NAT и Bridge режимами?
2. Когда использовать изолированную сеть?
3. Как пробросить порт из VM наружу в NAT режиме?
4. Что такое virbr0 и для чего используется?
5. Как настроить статический IP для VM?

## 🎓 Упражнения для самостоятельной работы

1. **Multi-homed VM:** создайте VM с двумя сетевыми интерфейсами в разных сетях
2. **Custom subnet:** создайте NAT сеть с подсетью 172.16.0.0/24
3. **VLAN:** настройте VLAN tagging для VM
4. **DNS server:** поднимите dnsmasq для custom DNS записей

## 🔍 Ожидаемые результаты

После выполнения работы вы должны:
- ✅ Понимать сетевые режимы KVM (NAT/Bridge/Isolated)
- ✅ Создавать виртуальные сети через libvirt
- ✅ Настраивать связность между VM
- ✅ Пробрасывать порты через NAT
- ✅ Назначать статические IP через DHCP

## 📖 Дополнительные ресурсы

- [libvirt Networking](https://wiki.libvirt.org/page/Networking)
- [Linux Bridge](https://wiki.archlinux.org/title/Network_bridge)
- [iptables NAT](https://www.karlrupp.net/en/computer/nat_tutorial)

---

**Следующая работа:** [lab4-snapshots-migration.md](lab4-snapshots-migration.md)
