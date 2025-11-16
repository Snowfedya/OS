# Сравнительная таблица: KVM vs LXC vs Docker

## 📊 Подробное сравнение технологий виртуализации и контейнеризации

| Критерий | KVM | LXC/LXD | Docker |
|----------|-----|---------|--------|
| **Тип** | Аппаратная виртуализация | Системная контейнеризация | Контейнеризация приложений |
| **Изоляция** | Полная (отдельное ядро) | Разделяемое ядро, namespaces | Разделяемое ядро, namespaces |
| **Overhead** | Высокий (~10-15%) | Минимальный (~1-2%) | Минимальный (~1-2%) |
| **Время запуска** | 30-60 секунд | 1-5 секунд | < 1 секунды |
| **Размер образа** | GB (полная ОС) | 100-500 MB | 10-200 MB |
| **Память footprint** | 512MB - 16GB | 100MB - 4GB | 10MB - 1GB |
| **ОС внутри** | Любая (Linux, Windows, BSD) | Только Linux | Только Linux |
| **Use Case** | Полная изоляция, разные ОС | System containers, dev environments | Microservices, приложения |
| **Безопасность** | Максимальная (аппаратная изоляция) | Высокая (kernel namespaces) | Средняя (shared kernel) |
| **Performance** | 85-95% от bare metal | 95-99% от bare metal | 98-100% от bare metal |
| **Networking** | NAT, Bridge, Host | Bridge, macvlan, ovs | Bridge, overlay, host |
| **Storage** | qcow2, raw, lvm | dir, zfs, btrfs | overlay2, devicemapper |
| **Миграция** | Live migration (сложно) | Средне (CRIU) | Просто (образы) |
| **Управление** | libvirt, virsh | lxc, lxd | docker, docker-compose |
| **Orchestration** | oVirt, Proxmox | Не развита | Kubernetes, Swarm |
| **Главное преимущество** | Полная изоляция и гибкость | Производительность системных контейнеров | Портативность и простота |

## 🎯 Когда использовать?

### ✅ Используйте KVM когда:
- Нужна полная изоляция (разные клиенты/tenants)
- Требуется запуск Windows или других не-Linux ОС
- Критична безопасность (banking, healthcare)
- Нужны разные версии ядра
- Legacy приложения требуют специфичную ОС

### ✅ Используйте LXC/LXD когда:
- Нужны полноценные Linux системы с systemd
- Разработка и тестирование различных дистрибутивов
- Хостинг нескольких изолированных окружений
- Высокая производительность + изоляция
- Nested containers (Docker внутри LXD)

### ✅ Используйте Docker когда:
- Контейнеризация microservices
- CI/CD пайплайны
- Распространение приложений
- Быстрая разработка (dev == prod)
- Cloud-native приложения

## 💡 Практические сценарии

### Сценарий 1: SaaS Platform
```
┌─────────────────────────────────────┐
│         KVM Hypervisor              │
│  ┌──────────────┐  ┌──────────────┐ │
│  │  Tenant A VM │  │  Tenant B VM │ │
│  │              │  │              │ │
│  │  ┌─────────┐ │  │  ┌─────────┐ │ │
│  │  │ Docker  │ │  │  │ Docker  │ │ │
│  │  │ Services│ │  │  │ Services│ │ │
│  │  └─────────┘ │  │  └─────────┘ │ │
│  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────┘
```
**Объяснение:** KVM для изоляции между клиентами, Docker для микросервисов внутри.

### Сценарий 2: Development Environment
```
┌─────────────────────────────────────┐
│          LXD Host                   │
│  ┌──────────────┐  ┌──────────────┐ │
│  │ Ubuntu 20.04 │  │ Ubuntu 22.04 │ │
│  │  Container   │  │  Container   │ │
│  │              │  │              │ │
│  │ Docker       │  │ Docker       │ │
│  │ inside       │  │ inside       │ │
│  └──────────────┘  └──────────────┘ │
└─────────────────────────────────────┘
```
**Объяснение:** LXD для разных версий ОС, Docker для приложений.

### Сценарий 3: Pure Microservices
```
┌─────────────────────────────────────┐
│       Docker Swarm / Kubernetes     │
│  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐   │
│  │ Web │ │ API │ │ DB  │ │Cache│   │
│  └─────┘ └─────┘ └─────┘ └─────┘   │
└─────────────────────────────────────┘
```
**Объяснение:** Только Docker для максимальной портативности.

## 📈 Performance Benchmarks

### CPU Performance (% от bare metal)
- **KVM:** 85-95%
- **LXC:** 95-99%
- **Docker:** 98-100%

### Memory Overhead
- **KVM:** +512MB минимум
- **LXC:** +50MB
- **Docker:** +10MB

### I/O Performance (% от bare metal)
- **KVM (virtio):** 80-90%
- **LXC:** 95-98%
- **Docker (overlay2):** 95-99%

## 🔐 Security Considerations

| Угроза | KVM | LXC | Docker |
|--------|-----|-----|--------|
| Kernel exploits | ✅ Защищен (изоляция) | ⚠️ Уязвим | ⚠️ Уязвим |
| Escape to host | ✅ Сложно | ⚠️ Возможно | ⚠️ Возможно |
| Resource exhaustion | ✅ Изолировано | ✅ Cgroups | ✅ Cgroups |
| Network attacks | ✅ Изолировано | ⚠️ Shared bridge | ⚠️ Shared network |

## 🎓 Рекомендации

### Production Workloads
1. **Critical systems:** KVM
2. **System services:** LXC
3. **Applications:** Docker

### Development
1. **Testing different OS:** LXC
2. **App development:** Docker
3. **Full isolation testing:** KVM

### Cost Optimization
1. **High density:** Docker
2. **Medium density:** LXC
3. **Low density:** KVM

---
**Источники:** Linux Kernel Documentation, Docker Documentation, libvirt Documentation, Production benchmarks
