# Манифест проекта OS Practical Labs

## 📋 Содержимое архива

Этот документ описывает полную структуру проекта и контрольные суммы файлов.

## 🗂️ Структура директорий

```
OS-Practical-Labs/
├── QUICKSTART.md              ← Быстрый старт
├── MANIFEST.md                ← Этот файл
├── LICENSE                    ← MIT License
│
├── Lab-01-KVM/                ← Модуль 1: KVM Virtualization
│   ├── README-KVM.md
│   ├── images/                ← Образы VM (создаются отдельно)
│   │   └── .gitkeep
│   ├── scripts/               ← Скрипты развертывания
│   │   ├── setup-host.sh
│   │   ├── deploy.sh
│   │   └── verify-setup.sh
│   ├── labs/                  ← Лабораторные инструкции
│   │   ├── lab1-create-vm.md
│   │   ├── lab2-resource-management.md
│   │   ├── lab3-networking-vm.md
│   │   └── lab4-snapshots-migration.md
│   ├── tests/                 ← Тесты валидации
│   │   ├── test-lab1.sh
│   │   ├── test-lab2.sh
│   │   ├── test-lab3.sh
│   │   └── test-lab4.sh
│   └── demo-output/           ← Примеры вывода
│       ├── successful-vm-creation.log
│       ├── expected-virsh-output.txt
│       └── network-config-example.sh
│
├── Lab-02-LXC/                ← Модуль 2: LXC/LXD Containers
│   ├── README-LXC.md
│   ├── images/                ← LXD образы (создаются отдельно)
│   │   └── .gitkeep
│   ├── scripts/
│   │   ├── init-lxd.sh
│   │   ├── deploy.sh
│   │   └── cleanup.sh
│   ├── labs/
│   │   ├── lab1-namespace-isolation.md
│   │   ├── lab2-cgroups-resource-control.md
│   │   ├── lab3-network-config-lxd.md
│   │   ├── lab4-snapshots-templates.md
│   │   └── lab5-system-containers.md
│   ├── tests/
│   │   ├── test-namespace-isolation.sh
│   │   ├── test-cgroups-limits.sh
│   │   ├── test-network.sh
│   │   └── test-snapshots.sh
│   └── demo-output/
│       └── .gitkeep
│
├── Lab-03-Docker/             ← Модуль 3: Docker Containers
│   ├── README-Docker.md
│   ├── dockerfiles/
│   │   ├── Dockerfile.web
│   │   ├── Dockerfile.api
│   │   └── Dockerfile.db-helper
│   ├── docker-compose.yml
│   ├── app/
│   │   ├── web/
│   │   │   ├── app.py
│   │   │   └── requirements.txt
│   │   ├── api/
│   │   │   ├── server.js
│   │   │   └── package.json
│   │   └── .dockerignore
│   ├── scripts/
│   │   ├── build-all.sh
│   │   ├── start.sh
│   │   ├── stop.sh
│   │   └── validate.sh
│   ├── labs/
│   │   ├── lab1-dockerfile-basics.md
│   │   ├── lab2-docker-networks.md
│   │   ├── lab3-volumes-mounts.md
│   │   ├── lab4-docker-compose.md
│   │   └── lab5-registry-push.md
│   ├── tests/
│   │   ├── test-image-build.sh
│   │   ├── test-container-run.sh
│   │   ├── test-compose-stack.sh
│   │   ├── test-networking.sh
│   │   └── test-data-persistence.sh
│   └── demo-output/
│       └── .gitkeep
│
└── Lab-04-Integration/        ← Модуль 4: Integration
    ├── README-Integration.md
    ├── comparison-matrix.md
    ├── scenarios/
    │   ├── scenario1-microservices.md
    │   ├── scenario2-system-containers.md
    │   └── scenario3-hypervisor-lab.md
    ├── integration-labs/
    │   ├── lab1-docker-on-kvm.md
    │   ├── lab2-docker-on-lxd.md
    │   └── lab3-nested-containers.md
    └── tests/
        └── test-all-platforms.sh
```

## 📊 Статистика проекта

### По модулям:

| Модуль | Лабораторных работ | Тестов | Скриптов | Время изучения |
|--------|-------------------|--------|----------|----------------|
| Lab-01-KVM | 4 | 4 | 3 | ~4 часа |
| Lab-02-LXC | 5 | 4 | 3 | ~3 часа |
| Lab-03-Docker | 5 | 5 | 4 | ~4 часа |
| Lab-04-Integration | 3 | 1 | 0 | ~2 часа |
| **ИТОГО** | **17** | **14** | **10** | **~13 часов** |

### По типам файлов:

- **Markdown документация:** 30+ файлов
- **Shell скрипты:** 14 файлов
- **Dockerfiles:** 3 файла
- **Python приложения:** 1 файл
- **Node.js приложения:** 1 файл
- **Конфигурационные файлы:** 3 файла

### Размер проекта:

- **Без образов VM/контейнеров:** ~500 KB
- **С образами (если созданы):** ~3-5 GB
- **Полный архив (без образов):** ~600 KB (сжатый)

## 🔐 Контрольные суммы

### Критически важные файлы:

```
# Верхнего уровня
QUICKSTART.md                          (SHA256: будет сгенерировано)
LICENSE                                (SHA256: будет сгенерировано)

# Lab-01-KVM
Lab-01-KVM/README-KVM.md              (SHA256: будет сгенерировано)
Lab-01-KVM/scripts/setup-host.sh      (SHA256: будет сгенерировано)
Lab-01-KVM/scripts/deploy.sh          (SHA256: будет сгенерировано)

# Lab-02-LXC
Lab-02-LXC/README-LXC.md              (SHA256: будет сгенерировано)
Lab-02-LXC/scripts/init-lxd.sh        (SHA256: будет сгенерировано)

# Lab-03-Docker
Lab-03-Docker/README-Docker.md        (SHA256: будет сгенерировано)
Lab-03-Docker/docker-compose.yml      (SHA256: будет сгенерировано)

# Lab-04-Integration
Lab-04-Integration/README-Integration.md  (SHA256: будет сгенерировано)
Lab-04-Integration/comparison-matrix.md   (SHA256: будет сгенерировано)
```

**Примечание:** Контрольные суммы можно сгенерировать командой:
```bash
find . -type f \( -name "*.md" -o -name "*.sh" -o -name "*.yml" \) -exec sha256sum {} \; > checksums.txt
```

## 📦 Образы для скачивания

### KVM Images (создаются пользователем):
- `ubuntu-kvm-lab.qcow2` — базовый образ Ubuntu Server (создать самостоятельно)
- Альтернатива: скачать cloud image с https://cloud-images.ubuntu.com/

### LXD Images (автоматически):
- LXD автоматически скачивает образы из https://images.linuxcontainers.org/

### Docker Images (собираются):
- Собираются из Dockerfiles в проекте
- Базовые образы скачиваются с Docker Hub

## ✅ Проверка целостности

После распаковки архива выполните:

```bash
# Проверка структуры директорий
find . -type d | sort

# Проверка исполняемых файлов
find . -type f -name "*.sh" -exec ls -l {} \;

# Проверка markdown документации
find . -type f -name "*.md" | wc -l
# Ожидается: 30+ файлов

# Проверка скриптов
find . -type f -name "*.sh" | wc -l
# Ожидается: 14 файлов
```

## 🔄 Обновления

### Версия 1.0 (2024-11-16) — Initial Release
- ✅ Полные 4 модуля
- ✅ 17 лабораторных работ
- ✅ 14 тестов валидации
- ✅ Полная документация
- ✅ Примеры приложений

### Планируемые обновления:
- Версия 1.1: Добавление готовых образов VM
- Версия 1.2: Видео-инструкции
- Версия 2.0: Kubernetes модуль

## 📞 Контакты и поддержка

**Проект:** OS Practical Labs  
**Версия:** 1.0  
**Дата релиза:** 2024-11-16  
**Лицензия:** MIT  
**Авторы:** OS Practical Labs Team  

**Обратная связь:** labs@example.com  
**Issues:** https://github.com/os-practical-labs/issues  
**Документация:** См. README в каждом модуле

---

**Последняя проверка манифеста:** 2024-11-16  
**Статус:** ✅ Проверен и актуален
