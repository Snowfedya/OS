# Лабораторная работа 2: Управление ресурсами виртуальных машин

## 🎯 Цель работы

Освоить продвинутые техники управления ресурсами VM: CPU pinning, настройка памяти, ограничение I/O, управление приоритетами и мониторинг производительности.

## 📋 Предварительные условия

- Выполнена Lab 1 (создание VM)
- Работающая VM (можно использовать `kvm-lab-vm` или создать новую)
- Понимание базовых концепций CPU, памяти, I/O

## 📚 Теоретическая часть

### Модель ресурсов в KVM

KVM использует **cgroups (Control Groups)** для управления ресурсами через libvirt:

- **CPU** — vCPU threads привязываются к физическим ядрам
- **Memory** — управление через QEMU + kernel (balloon driver, KSM)
- **I/O** — блокировочные device приоритеты через cgroups blkio
- **Network** — Traffic Control (tc) + Linux network stack

### CPU Scheduling

KVM поддерживает несколько моделей:
- **shares** — относительные доли CPU (default: 1024)
- **quota/period** — абсолютные лимиты (% CPU time)
- **pinning** — привязка vCPU к физическим ядрам

## 🔬 Практическая часть

### Задание 2.1: CPU Shares (относительные приоритеты)

CPU shares определяют относительные доли CPU между VM при конкуренции за ресурсы.

**Шаг 1:** Проверьте текущие shares VM

```bash
virsh schedinfo kvm-lab-vm
```

**Ожидаемый вывод:**
```
Scheduler      : posix
cpu_shares     : 1024
vcpu_period    : 100000
vcpu_quota     : -1
```

**Шаг 2:** Создайте две VM для тестирования

```bash
# VM с низким приоритетом
sudo virt-install \
  --name cpu-low \
  --ram 512 \
  --vcpus 1 \
  --disk path=/var/lib/libvirt/images/cpu-low.qcow2,size=5 \
  --os-variant ubuntu22.04 \
  --network=default \
  --graphics=none \
  --import \
  --noautoconsole

# VM с высоким приоритетом
sudo virt-install \
  --name cpu-high \
  --ram 512 \
  --vcpus 1 \
  --disk path=/var/lib/libvirt/images/cpu-high.qcow2,size=5 \
  --os-variant ubuntu22.04 \
  --network=default \
  --graphics=none \
  --import \
  --noautoconsole
```

**Шаг 3:** Установите разные приоритеты

```bash
# Низкий приоритет (512 shares = 50% от дефолта)
virsh schedinfo cpu-low --set cpu_shares=512

# Высокий приоритет (2048 shares = 200% от дефолта)
virsh schedinfo cpu-high --set cpu_shares=2048
```

**Шаг 4:** Проверьте изменения

```bash
virsh schedinfo cpu-low
virsh schedinfo cpu-high
```

**Результат:** При конкуренции за CPU, `cpu-high` получит в ~4 раза больше времени CPU.

### Задание 2.2: CPU Quota (абсолютные лимиты)

CPU quota ограничивает максимальное использование CPU независимо от конкуренции.

**Ограничить VM до 50% одного ядра:**

```bash
virsh schedinfo kvm-lab-vm \
  --set vcpu_quota=50000 \
  --set vcpu_period=100000
```

**Объяснение:**
- `vcpu_period` = 100000 микросекунд (100ms) — период планирования
- `vcpu_quota` = 50000 микросекунд (50ms) — максимум CPU времени за период
- Результат: 50ms / 100ms = 50% CPU

**Ограничить VM до 150% (1.5 ядра):**

```bash
virsh schedinfo kvm-lab-vm \
  --set vcpu_quota=150000 \
  --set vcpu_period=100000
```

**Убрать ограничения:**

```bash
virsh schedinfo kvm-lab-vm --set vcpu_quota=-1
```

**Тест производительности:**

```bash
# Внутри VM запустите CPU stress test
virsh console kvm-lab-vm
# Внутри VM:
stress-ng --cpu 4 --timeout 60s --metrics-brief

# На хосте мониторьте использование:
watch -n 1 'virsh domstats kvm-lab-vm | grep cpu'
```

### Задание 2.3: CPU Pinning (привязка к ядрам)

CPU pinning привязывает vCPU к конкретным физическим ядрам, улучшая производительность за счет уменьшения cache misses.

**Шаг 1:** Проверьте топологию CPU хоста

```bash
lscpu | grep -E "^CPU\(s\)|NUMA|Model name"
virsh nodeinfo
```

**Шаг 2:** Проверьте текущую привязку

```bash
virsh vcpupin kvm-lab-vm
```

**Ожидаемый вывод (без pinning):**
```
 VCPU   CPU Affinity
-------------------------
 0      0-7
 1      0-7
```

**Шаг 3:** Привяжите vCPU к конкретным ядрам

```bash
# vCPU 0 -> физическое ядро 0
virsh vcpupin kvm-lab-vm 0 0

# vCPU 1 -> физическое ядро 1
virsh vcpupin kvm-lab-vm 1 1
```

**Шаг 4:** Проверьте изменения

```bash
virsh vcpupin kvm-lab-vm
```

**Новый вывод:**
```
 VCPU   CPU Affinity
-------------------------
 0      0
 1      1
```

**Сброс привязки (разрешить использовать все ядра):**

```bash
virsh vcpupin kvm-lab-vm 0 0-7 --live
virsh vcpupin kvm-lab-vm 1 0-7 --live
```

### Задание 2.4: Управление памятью

**Проверка текущей памяти:**

```bash
virsh dominfo kvm-lab-vm | grep memory
```

**Установка максимальной и текущей памяти:**

```bash
# Изменить максимальную память (требует выключения VM)
virsh setmaxmem kvm-lab-vm 4G --config
virsh shutdown kvm-lab-vm
virsh start kvm-lab-vm

# Изменить текущую память (hot-plug, VM работает)
virsh setmem kvm-lab-vm 2G --live
```

**Memory Ballooning (динамическое изменение):**

Memory balloon позволяет возвращать неиспользуемую память обратно хосту.

```bash
# Проверить поддержку balloon
virsh dumpxml kvm-lab-vm | grep -A2 memballoon

# Установить текущую память через balloon
virsh setmem kvm-lab-vm 1G --current
```

**Мониторинг памяти:**

```bash
# Статистика памяти VM
virsh dommemstat kvm-lab-vm

# Реальное использование памяти
virsh domstats kvm-lab-vm | grep balloon
```

### Задание 2.5: Ограничение дисковой I/O

**Установить лимиты на чтение/запись:**

```bash
# Ограничить до 50 MB/s чтение, 25 MB/s запись
virsh blkdeviotune kvm-lab-vm vda \
  --total-bytes-sec 52428800 \
  --read-bytes-sec 52428800 \
  --write-bytes-sec 26214400

# Ограничить количество операций I/O (IOPS)
virsh blkdeviotune kvm-lab-vm vda \
  --total-iops-sec 1000 \
  --read-iops-sec 800 \
  --write-iops-sec 400
```

**Проверка лимитов:**

```bash
virsh blkdeviotune kvm-lab-vm vda
```

**Убрать лимиты:**

```bash
virsh blkdeviotune kvm-lab-vm vda --total-bytes-sec 0 --total-iops-sec 0
```

**Тест I/O производительности:**

```bash
# Внутри VM:
dd if=/dev/zero of=/tmp/testfile bs=1M count=1024 conv=fdatasync

# На хосте мониторинг:
virsh domblkstat kvm-lab-vm vda --human
```

### Задание 2.6: Мониторинг ресурсов

**Реал-тайм статистика:**

```bash
watch -n 1 'virsh domstats kvm-lab-vm'
```

**CPU статистика:**

```bash
virsh cpu-stats kvm-lab-vm
```

**Disk I/O статистика:**

```bash
virsh domblkstat kvm-lab-vm vda
```

**Network I/O статистика:**

```bash
virsh domifstat kvm-lab-vm vnet0
```

**Графический мониторинг через virt-top:**

```bash
sudo apt-get install -y virt-top
virt-top
```

## ✅ Контрольные вопросы

1. В чем разница между cpu_shares и cpu_quota?
2. Когда нужно использовать CPU pinning?
3. Что такое memory ballooning и как он работает?
4. Как ограничить I/O производительность для конкретного диска?
5. Какие метрики важны для мониторинга производительности VM?

## 🎓 Упражнения для самостоятельной работы

1. **Создайте сценарий конкуренции:** 3 VM с разными cpu_shares (512, 1024, 2048), запустите CPU stress test одновременно, сравните фактическое распределение CPU

2. **Настройте NUMA-aware VM:** для систем с NUMA архитектурой привяжите VM к конкретному NUMA узлу

3. **Benchmark I/O:** измерьте производительность диска с разными лимитами (fio/dd)

4. **Memory pressure test:** создайте VM с 1GB RAM, запустите приложение требующее 2GB, наблюдайте за balloon/swap

## 🔍 Ожидаемые результаты

После выполнения работы вы должны:
- ✅ Управлять CPU приоритетами и квотами
- ✅ Применять CPU pinning для оптимизации
- ✅ Настраивать память VM статически и динамически
- ✅ Ограничивать дисковую I/O производительность
- ✅ Мониторить ресурсы VM в реальном времени

## 📖 Дополнительные ресурсы

- [libvirt Resource Management](https://libvirt.org/cgroups.html)
- [QEMU Memory Management](https://wiki.qemu.org/Features/Memory)
- [CPU Pinning Best Practices](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/virtualization_tuning_and_optimization_guide/chap-virtualization_tuning_optimization_guide-numa)

---

**Следующая работа:** [lab3-networking-vm.md](lab3-networking-vm.md) — Конфигурация сети VM
