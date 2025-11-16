# Lab-01: Аппаратная виртуализация с KVM

## 📋 Обзор

Этот модуль посвящен изучению **аппаратной виртуализации** с использованием **KVM (Kernel-based Virtual Machine)** — встроенного в ядро Linux гипервизора типа 1. Вы научитесь создавать, настраивать и управлять виртуальными машинами, оптимизировать производительность и работать с сетевой инфраструктурой.

**Ключевые технологии:**
- KVM — модуль ядра для виртуализации
- QEMU — эмулятор устройств
- libvirt — API управления виртуализацией
- virsh — CLI инструмент управления

## 🎯 Цели обучения

После прохождения этого модуля вы сможете:

- ✅ Устанавливать и настраивать KVM на Linux хостах
- ✅ Создавать и управлять виртуальными машинами
- ✅ Оптимизировать использование ресурсов (CPU, память, I/O)
- ✅ Настраивать виртуальные сети (NAT, Bridge, изолированные)
- ✅ Работать со снэпшотами и миграцией VM
- ✅ Выполнять мониторинг и troubleshooting

## 💻 Требования к хосту

### Минимальные требования:
- **ОС:** Ubuntu 20.04+ / Debian 11+ / Fedora 35+ / RHEL 8+
- **CPU:** x86-64 с поддержкой VT-x (Intel) или AMD-V (AMD)
- **RAM:** Минимум 8GB (рекомендуется 16GB)
- **Диск:** 50GB свободного места
- **Сеть:** Активное подключение к интернету

### Проверка поддержки виртуализации:

```bash
# Проверка CPU флагов
grep -E '(vmx|svm)' /proc/cpuinfo

# Установка cpu-checker
sudo apt-get install -y cpu-checker
kvm-ok
```

**Ожидаемый вывод:**
```
INFO: /dev/kvm exists
KVM acceleration can be used
```

## ⚡ Быстрый старт (5 минут)

### Шаг 1: Подготовка хоста

```bash
cd Lab-01-KVM/scripts
sudo ./setup-host.sh
```

Этот скрипт:
- Проверит поддержку виртуализации
- Установит необходимые пакеты (KVM, libvirt, QEMU)
- Настроит сервис libvirtd
- Создаст storage pool по умолчанию
- Добавит текущего пользователя в группы libvirt/kvm

### Шаг 2: Подготовка образа VM

**Вариант А: Использовать cloud image (быстро)**

```bash
cd images/
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img \
  -O ubuntu-kvm-lab.qcow2
```

**Вариант Б: Создать custom образ (для продвинутых)**

```bash
sudo virt-install \
  --name=kvm-lab-base \
  --ram=2048 \
  --vcpus=2 \
  --disk path=/var/lib/libvirt/images/kvm-lab.qcow2,size=20 \
  --os-variant=ubuntu22.04 \
  --location=http://archive.ubuntu.com/ubuntu/dists/jammy/main/installer-amd64/ \
  --graphics=none \
  --console=pty,target_type=serial \
  --extra-args='console=ttyS0,115200n8'

# После установки:
# Внутри VM: apt-get install -y qemu-guest-agent libvirt-clients
# Затем: cp /var/lib/libvirt/images/kvm-lab.qcow2 images/ubuntu-kvm-lab.qcow2
```

### Шаг 3: Развертывание Lab VM

```bash
cd Lab-01-KVM/scripts
./deploy.sh
```

### Шаг 4: Проверка установки

```bash
./verify-setup.sh
```

**Ожидаемый результат:** Все проверки должны пройти успешно (✓ PASS).

### Шаг 5: Подключение к VM

```bash
virsh console kvm-lab-vm
# Выход из консоли: Ctrl+]
```

## 📚 Структура лабораторных работ

### [Lab 1: Создание виртуальных машин](labs/lab1-create-vm.md) ⏱️ 45 мин
**Что вы изучите:**
- Создание VM через virt-install
- Управление жизненным циклом (start/stop/reboot)
- Получение информации о VM
- Редактирование конфигурации
- Удаление VM

**Ключевые команды:**
```bash
virt-install --name vm1 --ram 1024 --vcpus 1 ...
virsh list --all
virsh start/shutdown/destroy vm1
virsh dominfo vm1
```

### [Lab 2: Управление ресурсами](labs/lab2-resource-management.md) ⏱️ 60 мин
**Что вы изучите:**
- CPU shares и CPU quota
- CPU pinning для оптимизации
- Управление памятью (статическое и динамическое)
- Ограничение дисковой I/O
- Мониторинг производительности

**Ключевые команды:**
```bash
virsh schedinfo vm1 --set cpu_shares=2048
virsh vcpupin vm1 0 0  # Pin vCPU 0 to core 0
virsh setmem vm1 2G --live
virsh blkdeviotune vm1 vda --total-iops-sec 1000
virsh domstats vm1
```

### [Lab 3: Конфигурация сети](labs/lab3-networking-vm.md) ⏱️ 60 мин
**Что вы изучите:**
- Сетевые режимы (NAT, Bridge, Isolated)
- Создание виртуальных сетей
- Статические IP через DHCP
- Port forwarding
- Тестирование связности

**Ключевые команды:**
```bash
virsh net-list --all
virsh net-define isolated-net.xml
virsh net-start isolated
virsh net-dhcp-leases default
virsh attach-interface vm1 network isolated
```

### [Lab 4: Снэпшоты и миграция](labs/lab4-snapshots-migration.md) ⏱️ 60 мин
**Что вы изучите:**
- Internal и external snapshots
- Клонирование VM
- Backup и восстановление
- Offline и live migration
- Storage migration

**Ключевые команды:**
```bash
virsh snapshot-create-as vm1 snap1 "Description"
virsh snapshot-list vm1
virsh snapshot-revert vm1 snap1
virt-clone --original vm1 --name vm1-clone
virsh migrate --live vm1 qemu+tcp://target/system
```

## ✅ Контрольный список (Checklist)

Отметьте выполненные пункты:

### Подготовка среды
- [ ] Проверена поддержка виртуализации (VT-x/AMD-V)
- [ ] Установлены пакеты KVM/libvirt/QEMU
- [ ] Сервис libvirtd запущен и активен
- [ ] Пользователь добавлен в группы libvirt/kvm
- [ ] Storage pool создан и активен
- [ ] Default network работает

### Lab 1: Создание VM
- [ ] Создана VM через virt-install
- [ ] VM успешно запускается
- [ ] Подключение к консоли работает
- [ ] VM корректно выключается
- [ ] Настроен автозапуск VM

### Lab 2: Управление ресурсами
- [ ] Изменены CPU shares
- [ ] Установлен CPU quota
- [ ] Настроен CPU pinning
- [ ] Изменена память VM (setmem)
- [ ] Установлены лимиты I/O
- [ ] Мониторинг показывает корректные данные

### Lab 3: Сеть
- [ ] Создана изолированная сеть
- [ ] VM подключена к новой сети
- [ ] Настроен статический IP
- [ ] Пробросан порт через NAT
- [ ] Проверена связность между VM

### Lab 4: Снэпшоты и миграция
- [ ] Создан snapshot
- [ ] Восстановление из snapshot работает
- [ ] VM клонирована успешно
- [ ] Выполнен backup VM
- [ ] Протестирована миграция (опционально)

## 🔍 Ожидаемые результаты

После выполнения всех лабораторных работ вы должны:

1. **Понимать архитектуру KVM:**
   - Роль модуля KVM в ядре
   - Взаимодействие KVM + QEMU + libvirt
   - Разница между паравиртуализацией и полной виртуализацией

2. **Уметь управлять VM:**
   - Создавать VM разными способами
   - Настраивать ресурсы и производительность
   - Конфигурировать сетевую связность
   - Выполнять backup и восстановление

3. **Применять на практике:**
   - Развертывать виртуальные среды для тестирования
   - Оптимизировать использование ресурсов хоста
   - Изолировать сервисы в отдельных VM
   - Выполнять миграцию для обслуживания хостов

## 🧪 Тестирование знаний

Запустите тесты для проверки выполнения работ:

```bash
cd tests/

# Проверка Lab 1
./test-lab1.sh

# Проверка Lab 2
./test-lab2.sh

# Проверка Lab 3
./test-lab3.sh

# Проверка Lab 4
./test-lab4.sh

# Запустить все тесты
for test in test-lab*.sh; do
    echo "Running $test..."
    ./$test
    echo ""
done
```

## 🐛 Решение проблем (Troubleshooting)

### Проблема 1: KVM модуль не загружается
**Симптомы:** `modprobe kvm` возвращает ошибку

**Решение:**
```bash
# Проверьте, включена ли виртуализация в BIOS
grep -E '(vmx|svm)' /proc/cpuinfo

# Если пусто — включите VT-x/AMD-V в BIOS/UEFI

# Загрузите модуль вручную
sudo modprobe kvm
sudo modprobe kvm_intel  # Или kvm_amd для AMD
```

### Проблема 2: libvirtd не запускается
**Симптомы:** `systemctl status libvirtd` показывает failed

**Решение:**
```bash
# Проверьте логи
journalctl -u libvirtd -n 50

# Переустановите libvirt
sudo apt-get install --reinstall libvirt-daemon-system

# Проверьте конфликтующие процессы
sudo lsof /var/run/libvirt/libvirt-sock
```

### Проблема 3: VM не получает IP от DHCP
**Симптомы:** `virsh domifaddr vm` не показывает IP

**Решение:**
```bash
# Проверьте, что default network активна
virsh net-list
virsh net-start default

# Проверьте DHCP leases
virsh net-dhcp-leases default

# Проверьте firewall
sudo iptables -L -n | grep virbr0

# Перезапустите VM
virsh reboot vm
```

### Проблема 4: Permission denied при доступе к /dev/kvm
**Симптомы:** `ERROR: Could not access KVM kernel module`

**Решение:**
```bash
# Добавьте пользователя в группу kvm
sudo usermod -aG kvm $USER

# Проверьте права
ls -l /dev/kvm

# Перелогиньтесь
newgrp kvm
```

### Проблема 5: VM тормозит (низкая производительность)
**Симптомы:** VM работает медленно

**Решение:**
```bash
# 1. Проверьте, используется ли virtio
virsh domblklist vm  # Должно быть virtio
virsh domiflist vm   # Модель должна быть virtio

# 2. Проверьте CPU pinning
virsh vcpupin vm

# 3. Включите huge pages
sudo sysctl vm.nr_hugepages=512

# 4. Проверьте I/O scheduler
cat /sys/block/sda/queue/scheduler
# Лучше: [mq-deadline] или [none]
```

## 📖 Дополнительные ресурсы

### Официальная документация:
- [KVM Documentation](https://www.linux-kvm.org/page/Documents)
- [libvirt Documentation](https://libvirt.org/docs.html)
- [QEMU Documentation](https://www.qemu.org/documentation/)
- [Red Hat Virtualization Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_virtualization/)

### Книги и курсы:
- "Mastering KVM Virtualization" by Humble Devassy Chirammal
- "KVM Virtualization Cookbook" by Konstantin Ivanov
- Linux Foundation: Introduction to Virtualization

### Полезные инструменты:
- **virt-manager** — GUI для управления VM
- **virt-top** — мониторинг VM (аналог top)
- **guestfish** — доступ к файловой системе VM без запуска
- **virt-builder** — быстрое создание образов

### Сообщество:
- [KVM Forum](https://events.linuxfoundation.org/kvm-forum/)
- [libvirt Users Mailing List](https://libvirt.org/contact.html)
- [/r/VFIO Reddit](https://www.reddit.com/r/VFIO/)

## 🎓 Дальнейшие направления изучения

После освоения базового KVM рекомендуем изучить:

1. **VFIO GPU Passthrough** — пробрасывание GPU в VM
2. **oVirt** — платформа управления виртуализацией
3. **Kubernetes + KubeVirt** — запуск VM в Kubernetes
4. **Nested Virtualization** — VM внутри VM
5. **NUMA Tuning** — оптимизация для NUMA систем

---

## 🎯 Следующий модуль

После завершения Lab-01-KVM переходите к:
**[Lab-02-LXC](../Lab-02-LXC/README-LXC.md)** — Контейнеризация на уровне ОС

---

**Версия:** 1.0  
**Последнее обновление:** 2024-11-16  
**Авторы:** OS Practical Labs Team  
**Лицензия:** MIT
