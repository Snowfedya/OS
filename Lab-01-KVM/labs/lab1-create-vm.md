# Лабораторная работа 1: Создание виртуальной машины в KVM

## 🎯 Цель работы

Научиться создавать и настраивать виртуальные машины с использованием KVM/QEMU и libvirt, освоить базовые команды управления жизненным циклом VM.

## 📋 Предварительные условия

- Хост-система с установленным KVM (выполнен `setup-host.sh`)
- Базовая VM развернута (выполнен `deploy.sh`)
- Доступ к командной строке с правами sudo
- Образ ОС для установки (Ubuntu/Debian ISO или cloud image)

## 📚 Теоретическая часть

### Что такое KVM?

**KVM (Kernel-based Virtual Machine)** — это модуль ядра Linux, превращающий его в гипервизор типа 1 (bare-metal). KVM использует аппаратную виртуализацию (Intel VT-x/AMD-V) для запуска изолированных виртуальных машин.

**Ключевые компоненты:**
- **KVM** — модуль ядра, обеспечивающий виртуализацию CPU и памяти
- **QEMU** — эмулятор устройств (диск, сеть, видео и др.)
- **libvirt** — API и набор инструментов для управления VM

### Методы создания VM

1. **virt-install** — CLI утилита для создания VM (автоматизация)
2. **virt-manager** — GUI инструмент (визуальное управление)
3. **virsh + XML** — прямое определение через конфигурацию

## 🔬 Практическая часть

### Задание 1.1: Создание VM через virt-install

**Шаг 1:** Скачайте cloud image Ubuntu (быстрая установка)

```bash
cd /var/lib/libvirt/images/
sudo wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img \
  -O ubuntu-22.04-cloud.img
```

**Шаг 2:** Создайте копию образа для новой VM

```bash
sudo cp ubuntu-22.04-cloud.img lab1-vm1.qcow2
sudo qemu-img resize lab1-vm1.qcow2 +10G  # Расширить до 20GB
```

**Шаг 3:** Создайте VM командой virt-install

```bash
sudo virt-install \
  --name lab1-vm1 \
  --ram 1024 \
  --vcpus 1 \
  --disk path=/var/lib/libvirt/images/lab1-vm1.qcow2,device=disk,bus=virtio \
  --os-variant ubuntu22.04 \
  --network network=default,model=virtio \
  --graphics none \
  --console pty,target_type=serial \
  --import \
  --noautoconsole
```

**Объяснение параметров:**
- `--name` — имя VM в libvirt
- `--ram` — объем RAM в МБ
- `--vcpus` — количество виртуальных CPU
- `--disk` — путь к диску и тип шины (virtio для производительности)
- `--os-variant` — тип ОС (для оптимизации)
- `--network` — подключение к сети (default = NAT)
- `--graphics none` — без графического интерфейса
- `--import` — использовать существующий образ
- `--noautoconsole` — не подключаться к консоли автоматически

**Шаг 4:** Проверьте создание VM

```bash
virsh list --all
```

**Ожидаемый вывод:**
```
 Id   Name        State
-----------------------------
 1    kvm-lab-vm  running
 2    lab1-vm1    running
```

### Задание 1.2: Управление жизненным циклом VM

**Остановка VM (корректное выключение):**
```bash
virsh shutdown lab1-vm1
```

**Принудительное выключение (аналог выдергивания шнура):**
```bash
virsh destroy lab1-vm1
```

**Запуск VM:**
```bash
virsh start lab1-vm1
```

**Перезагрузка VM:**
```bash
virsh reboot lab1-vm1
```

**Приостановка (pause) VM:**
```bash
virsh suspend lab1-vm1
virsh resume lab1-vm1
```

**Автозапуск VM при загрузке хоста:**
```bash
virsh autostart lab1-vm1         # Включить
virsh autostart --disable lab1-vm1  # Выключить
```

### Задание 1.3: Получение информации о VM

**Общая информация:**
```bash
virsh dominfo lab1-vm1
```

**Использование ресурсов:**
```bash
virsh domstats lab1-vm1
```

**XML конфигурация:**
```bash
virsh dumpxml lab1-vm1
```

**Просмотр консоли (подключение к последовательному порту):**
```bash
virsh console lab1-vm1
# Выход: Ctrl+]
```

### Задание 1.4: Редактирование конфигурации VM

**Изменить параметры VM (откроется редактор):**
```bash
virsh edit lab1-vm1
```

**Изменения вступают в силу после перезапуска VM:**
```bash
virsh shutdown lab1-vm1
virsh start lab1-vm1
```

**Пример изменений в XML:**
- Увеличение RAM: `<memory unit='KiB'>2097152</memory>` (2GB)
- Увеличение vCPU: `<vcpu placement='static'>2</vcpu>`

### Задание 1.5: Удаление VM

**Полное удаление VM с диском:**
```bash
virsh destroy lab1-vm1           # Выключить если запущена
virsh undefine lab1-vm1 --remove-all-storage  # Удалить с диском
```

**Удаление без удаления диска:**
```bash
virsh undefine lab1-vm1
# Диск останется в /var/lib/libvirt/images/
```

## ✅ Контрольные вопросы

1. В чем разница между `virsh shutdown` и `virsh destroy`?
2. Что такое virtio и почему это важно для производительности?
3. Как проверить, что VM использует аппаратную виртуализацию?
4. Зачем нужен параметр `--os-variant` в virt-install?
5. Где хранятся XML конфигурации VM в libvirt?

## 🎓 Упражнения для самостоятельной работы

1. **Создайте 3 VM** с разными параметрами:
   - `lab1-small`: 512MB RAM, 1 vCPU
   - `lab1-medium`: 2GB RAM, 2 vCPU
   - `lab1-large`: 4GB RAM, 4 vCPU

2. **Настройте автозапуск** для одной из VM

3. **Создайте скрипт** для массового создания VM:
   ```bash
   for i in {1..5}; do
       # Ваш код здесь
   done
   ```

4. **Измените описание VM**:
   ```bash
   virsh desc lab1-vm1 --title "Тестовая VM #1"
   virsh desc lab1-vm1 --new-desc "Создана $(date) для лабораторных работ"
   ```

## 🔍 Ожидаемые результаты

После выполнения работы вы должны:
- ✅ Уметь создавать VM через virt-install
- ✅ Управлять жизненным циклом VM (старт/стоп/перезагрузка)
- ✅ Получать информацию о VM через virsh
- ✅ Редактировать конфигурацию VM
- ✅ Правильно удалять VM

## 📖 Дополнительные ресурсы

- [KVM Official Documentation](https://www.linux-kvm.org/page/Documents)
- [libvirt Documentation](https://libvirt.org/docs.html)
- [virt-install Man Page](https://linux.die.net/man/1/virt-install)
- [QEMU Documentation](https://www.qemu.org/documentation/)

---

**Следующая работа:** [lab2-resource-management.md](lab2-resource-management.md) — Управление ресурсами VM
