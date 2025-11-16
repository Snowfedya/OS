# Лабораторная работа 4: Снэпшоты и миграция виртуальных машин

## 🎯 Цель работы

Освоить технологии снэпшотов (моментальных снимков) VM, клонирование, резервное копирование и миграцию VM между хостами.

## 📋 Предварительные условия

- Выполнены Lab 1-3
- Работающая VM с данными для тестирования
- Достаточно дискового пространства для снэпшотов

## 📚 Теоретическая часть

### Типы снэпшотов в KVM

1. **Internal Snapshots** — хранятся внутри qcow2 образа
   - Быстрое создание/восстановление
   - Ограничение: только для qcow2 дисков
   - Используют Copy-on-Write

2. **External Snapshots** — новые файлы для изменений
   - Работают с любыми форматами дисков
   - Более гибкие, но сложнее управлять
   - Цепочка файлов (backing chain)

3. **VM Snapshots** — полное состояние VM (диск + память + устройства)
   - Сохраняют running state
   - Требуют больше места

### Миграция VM

- **Offline Migration** — VM выключена
- **Live Migration** — VM работает во время переноса
- **Storage Migration** — перенос дисков между storage pools

## 🔬 Практическая часть

### Задание 4.1: Internal Snapshots

**Шаг 1:** Проверьте формат диска VM

```bash
virsh domblklist kvm-lab-vm
qemu-img info /var/lib/libvirt/images/kvm-lab-vm.qcow2
```

**Убедитесь что формат qcow2 (internal snapshots работают только с qcow2).**

**Шаг 2:** Создайте данные для тестирования

```bash
virsh console kvm-lab-vm
# Внутри VM:
echo "Version 1 - Before snapshot" > /tmp/test-data.txt
cat /tmp/test-data.txt
exit  # Ctrl+]
```

**Шаг 3:** Создайте снэпшот

```bash
virsh snapshot-create-as kvm-lab-vm \
  snapshot1 \
  "Initial state before modifications" \
  --disk-only
```

**Для полного снэпшота с памятью (если VM запущена):**

```bash
virsh snapshot-create-as kvm-lab-vm \
  snapshot-with-memory \
  "Full VM state including memory"
```

**Шаг 4:** Проверьте список снэпшотов

```bash
virsh snapshot-list kvm-lab-vm
virsh snapshot-info kvm-lab-vm snapshot1
```

**Шаг 5:** Измените данные в VM

```bash
virsh console kvm-lab-vm
# Внутри VM:
echo "Version 2 - After snapshot" > /tmp/test-data.txt
echo "Additional changes" >> /tmp/test-data.txt
cat /tmp/test-data.txt
```

**Шаг 6:** Создайте второй снэпшот

```bash
virsh snapshot-create-as kvm-lab-vm \
  snapshot2 \
  "After modifications"
```

**Шаг 7:** Восстановите первый снэпшот

```bash
# Выключите VM перед восстановлением
virsh shutdown kvm-lab-vm
sleep 5

# Восстановите снэпшот
virsh snapshot-revert kvm-lab-vm snapshot1

# Запустите VM
virsh start kvm-lab-vm
```

**Шаг 8:** Проверьте восстановление

```bash
virsh console kvm-lab-vm
# Внутри VM:
cat /tmp/test-data.txt
# Должно быть: "Version 1 - Before snapshot"
```

**Шаг 9:** Удалите снэпшот

```bash
virsh snapshot-delete kvm-lab-vm snapshot2
virsh snapshot-list kvm-lab-vm
```

### Задание 4.2: External Snapshots

External snapshots создают новый файл для изменений, оставляя оригинальный диск read-only.

**Шаг 1:** Создайте external snapshot

```bash
virsh snapshot-create-as kvm-lab-vm \
  external-snap1 \
  "External snapshot test" \
  --disk-only \
  --diskspec vda,snapshot=external
```

**Шаг 2:** Проверьте цепочку дисков

```bash
virsh domblklist kvm-lab-vm
qemu-img info /var/lib/libvirt/images/kvm-lab-vm.qcow2
```

**Вы увидите новый файл типа:**
```
/var/lib/libvirt/images/kvm-lab-vm.external-snap1
```

**Шаг 3:** Просмотрите backing chain

```bash
qemu-img info --backing-chain /var/lib/libvirt/images/kvm-lab-vm.external-snap1
```

**Шаг 4:** Commit изменений обратно

```bash
# Commit текущих изменений в базовый образ
virsh blockcommit kvm-lab-vm vda --active --pivot
```

### Задание 4.3: Клонирование VM

**Полное клонирование VM (включая диски):**

```bash
virt-clone \
  --original kvm-lab-vm \
  --name kvm-lab-vm-clone \
  --file /var/lib/libvirt/images/kvm-lab-vm-clone.qcow2
```

**Клонирование с использованием linked clones (экономия места):**

```bash
# Создать базовый образ (backing file)
qemu-img create -f qcow2 \
  -b /var/lib/libvirt/images/kvm-lab-vm.qcow2 \
  -F qcow2 \
  /var/lib/libvirt/images/linked-clone.qcow2
```

**Проверьте клон:**

```bash
virsh list --all | grep clone
virsh start kvm-lab-vm-clone
```

### Задание 4.4: Резервное копирование VM

**Метод 1: Backup через snapshot**

```bash
#!/bin/bash
VM_NAME="kvm-lab-vm"
BACKUP_DIR="/backup/vms"
DATE=$(date +%Y%m%d-%H%M%S)

# Создать снэпшот
virsh snapshot-create-as $VM_NAME backup-temp --disk-only --no-metadata

# Скопировать оригинальный диск
DISK=$(virsh domblklist $VM_NAME | grep vda | awk '{print $2}')
cp $DISK $BACKUP_DIR/${VM_NAME}-${DATE}.qcow2

# Commit изменений обратно
virsh blockcommit $VM_NAME vda --active --pivot

echo "Backup completed: $BACKUP_DIR/${VM_NAME}-${DATE}.qcow2"
```

**Метод 2: Backup выключенной VM**

```bash
# Выключить VM
virsh shutdown kvm-lab-vm

# Дождаться полного выключения
while virsh list | grep -q kvm-lab-vm; do
  sleep 2
done

# Backup XML конфигурации
virsh dumpxml kvm-lab-vm > /backup/kvm-lab-vm.xml

# Backup диска
cp /var/lib/libvirt/images/kvm-lab-vm.qcow2 \
   /backup/kvm-lab-vm-$(date +%Y%m%d).qcow2

# Запустить обратно
virsh start kvm-lab-vm
```

**Восстановление из backup:**

```bash
# Скопировать диск обратно
cp /backup/kvm-lab-vm-20231116.qcow2 \
   /var/lib/libvirt/images/kvm-lab-vm.qcow2

# Пересоздать VM из XML
virsh define /backup/kvm-lab-vm.xml
virsh start kvm-lab-vm
```

### Задание 4.5: Offline миграция VM

Перенос VM на другой хост (требуется общий NFS storage или ручное копирование).

**На исходном хосте:**

```bash
# Выключить VM
virsh shutdown kvm-lab-vm

# Экспортировать XML конфигурацию
virsh dumpxml kvm-lab-vm > /tmp/kvm-lab-vm.xml

# Скопировать диск на целевой хост
scp /var/lib/libvirt/images/kvm-lab-vm.qcow2 \
    user@target-host:/var/lib/libvirt/images/

# Скопировать XML конфигурацию
scp /tmp/kvm-lab-vm.xml user@target-host:/tmp/

# Отключить VM на исходном хосте
virsh undefine kvm-lab-vm
```

**На целевом хосте:**

```bash
# Импортировать VM
virsh define /tmp/kvm-lab-vm.xml

# Запустить VM
virsh start kvm-lab-vm
```

### Задание 4.6: Live Migration (требуется общий storage)

Live migration переносит запущенную VM между хостами без простоя.

**Требования:**
- Общий NFS/iSCSI storage для дисков VM
- Одинаковая версия libvirt на обоих хостах
- Сетевая связность между хостами

**На обоих хостах настройте libvirt для миграции:**

```bash
# Включить TCP подключения libvirt
sudo nano /etc/libvirt/libvirtd.conf
```

Раскомментируйте:
```
listen_tls = 0
listen_tcp = 1
auth_tcp = "none"
tcp_port = "16509"
```

```bash
sudo systemctl restart libvirtd
```

**Выполните live migration:**

```bash
virsh migrate --live kvm-lab-vm \
  qemu+tcp://target-host/system \
  --unsafe
```

**С копированием storage (без общего хранилища):**

```bash
virsh migrate --live kvm-lab-vm \
  qemu+tcp://target-host/system \
  --copy-storage-all \
  --persistent
```

**Мониторинг прогресса миграции:**

```bash
virsh domjobinfo kvm-lab-vm
```

### Задание 4.7: Storage Migration

Перенос дисков VM между storage pools.

**Создайте новый storage pool:**

```bash
virsh pool-define-as new-pool dir - - - - "/var/lib/libvirt/images-new"
virsh pool-build new-pool
virsh pool-start new-pool
virsh pool-autostart new-pool
```

**Выполните storage migration:**

```bash
# Offline migration (VM выключена)
virsh migrate kvm-lab-vm \
  --copy-storage-all \
  qemu:///system \
  --migrate-disks vda

# Или через blockcopy (VM работает)
virsh blockcopy kvm-lab-vm vda \
  /var/lib/libvirt/images-new/kvm-lab-vm.qcow2 \
  --wait --pivot
```

## ✅ Контрольные вопросы

1. В чем разница между internal и external snapshots?
2. Что такое backing chain и зачем он нужен?
3. Как безопасно сделать backup работающей VM?
4. Какие требования для live migration?
5. Что делает команда blockcommit?

## 🎓 Упражнения для самостоятельной работы

1. **Automated backup script:** напишите скрипт для автоматического backup всех VM
2. **Snapshot rotation:** реализуйте ротацию снэпшотов (хранить последние 7)
3. **Disaster recovery plan:** создайте процедуру восстановления после сбоя
4. **Live migration test:** настройте два хоста и проведите live migration

## 🔍 Ожидаемые результаты

После выполнения работы вы должны:
- ✅ Создавать и восстанавливать снэпшоты VM
- ✅ Клонировать VM
- ✅ Выполнять backup и restore VM
- ✅ Мигрировать VM между хостами
- ✅ Управлять storage migration

## 📖 Дополнительные ресурсы

- [libvirt Snapshots](https://wiki.libvirt.org/page/Snapshots)
- [QEMU Disk Images](https://qemu-project.gitlab.io/qemu/system/images.html)
- [KVM Migration](https://www.linux-kvm.org/page/Migration)

---

**Завершение Lab-01-KVM**

Поздравляем! Вы освоили основы работы с KVM:
- ✅ Создание и управление VM
- ✅ Управление ресурсами (CPU, Memory, I/O)
- ✅ Конфигурация сети
- ✅ Снэпшоты и миграция

**Следующий модуль:** [Lab-02-LXC](../../Lab-02-LXC/README-LXC.md) — Контейнеризация на уровне ОС
