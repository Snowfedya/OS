# Лабораторная 1: Изоляция через Namespaces

## 🎯 Цель
Изучить механизмы изоляции процессов, файловой системы и сети через namespaces в LXC.

## 📚 Теория
**Linux Namespaces** обеспечивают изоляцию:
- **PID** — изоляция процессов
- **Mount** — изоляция файловой системы
- **Network** — изоляция сети
- **UTS** — изоляция hostname
- **IPC** — изоляция межпроцессного взаимодействия
- **User** — изоляция пользователей

## 🔬 Практика

### Задание 1.1: PID Namespace

```bash
# Создать контейнер
lxc launch ubuntu:22.04 ns-test

# Внутри контейнера процессы видят только свои PID
lxc exec ns-test -- ps aux

# На хосте процессы контейнера видны с другими PID
ps aux | grep ns-test
```

### Задание 1.2: Mount Namespace

```bash
# Создать файл внутри контейнера
lxc exec ns-test -- touch /test-file

# На хосте этот файл НЕ виден
ls /test-file  # Ошибка

# Но виден в rootfs контейнера
ls /var/snap/lxd/common/lxd/storage-pools/default/containers/ns-test/rootfs/test-file
```

### Задание 1.3: Network Namespace

```bash
# Сетевой стек изолирован
lxc exec ns-test -- ip addr  # Видит только veth интерфейс контейнера
ip addr                       # Хост видит свои интерфейсы
```

## ✅ Контрольные вопросы
1. Какие namespace использует LXC?
2. Как проверить namespace процесса?
3. В чем разница между namespace и cgroups?
