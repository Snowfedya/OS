# Lab-02: Контейнеризация на уровне ОС с LXC/LXD

## 📋 Обзор
Изучение **системной контейнеризации** через LXC/LXD — технологии запуска изолированных Linux систем, использующих общее ядро хоста.

**Ключевые технологии:**
- LXC (Linux Containers) — низкоуровневая библиотека
- LXD — системный демон управления контейнерами
- Namespaces — изоляция ресурсов
- Cgroups — ограничение ресурсов

## 💻 Требования
- Ubuntu 20.04+ / Debian 11+
- 4GB RAM минимум
- 20GB свободного места
- Kernel 4.18+

## ⚡ Быстрый старт

```bash
cd Lab-02-LXC/scripts

# 1. Инициализация LXD
sudo ./init-lxd.sh

# 2. Создание контейнера
./deploy.sh

# 3. Вход в контейнер
lxc exec lxc-lab-container -- bash
```

## 📚 Лабораторные работы

### [Lab 1: Изоляция через Namespaces](labs/lab1-namespace-isolation.md) ⏱️ 30 мин
- PID namespace
- Mount namespace  
- Network namespace
- User namespace

### [Lab 2: Управление ресурсами через cgroups](labs/lab2-cgroups-resource-control.md) ⏱️ 45 мин
- CPU limits
- Memory limits
- I/O limits
- Priority управление

### [Lab 3: Сетевая конфигурация](labs/lab3-network-config-lxd.md) ⏱️ 40 мин
- Bridge networks
- Macvlan
- Static IP
- Port proxy

### [Lab 4: Снэпшоты и шаблоны](labs/lab4-snapshots-templates.md) ⏱️ 30 мин
- Snapshots
- Restore
- Templates
- Publishing images

### [Lab 5: System Containers](labs/lab5-system-containers.md) ⏱️ 30 мин
- Systemd в контейнере
- SSH доступ
- Multi-service containers

## ✅ Контрольный список
- [ ] LXD инициализирован
- [ ] Базовый контейнер создан
- [ ] Namespaces изучены
- [ ] Cgroups настроены
- [ ] Сеть сконфигурирована
- [ ] Snapshot создан

## 🧪 Тестирование
```bash
cd tests/
./test-namespace-isolation.sh
./test-cgroups-limits.sh
./test-network.sh
./test-snapshots.sh
```

## 🐛 Troubleshooting

### LXD не запускается
```bash
sudo snap restart lxd
sudo lxd init
```

### Контейнер не получает IP
```bash
lxc network list
lxc network show lxdbr0
systemctl restart snap.lxd.daemon
```

## 📖 Ресурсы
- [LXD Documentation](https://linuxcontainers.org/lxd/docs/master/)
- [LXC Manual](https://linuxcontainers.org/lxc/manpages/)

---
**Следующий модуль:** [Lab-03-Docker](../Lab-03-Docker/README-Docker.md)
