# 🐧 OS Practical Labs: Виртуализация и Контейнеризация

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Version](https://img.shields.io/badge/version-1.0-green.svg)
![Labs](https://img.shields.io/badge/labs-17-orange.svg)

## 📖 О проекте

**OS Practical Labs** — это комплексный практический курс по изучению технологий виртуализации и контейнеризации в Linux. Курс включает **4 модуля**, **17 лабораторных работ** и **14 автоматических тестов** для проверки знаний.

### Что вы изучите:

- 🖥️ **KVM** — Аппаратная виртуализация (полноценные VM)
- 📦 **LXC/LXD** — Системные контейнеры (легковесные Linux системы)
- 🐳 **Docker** — Контейнеризация приложений (микросервисы)
- 🔗 **Integration** — Как выбрать и комбинировать технологии

## ⚡ Быстрый старт

```bash
# Скачайте и распакуйте архив
unzip OS-Practical-Labs.zip
cd OS-Practical-Labs

# Читайте быстрый старт
cat QUICKSTART.md

# Выберите модуль и начните
cd Lab-01-KVM    # или Lab-02-LXC, или Lab-03-Docker
cat README-*.md
```

## 📚 Структура курса

| Модуль | Технология | Лабораторных | Время | Сложность |
|--------|------------|--------------|-------|-----------|
| **[Lab-01](Lab-01-KVM/README-KVM.md)** | KVM (Аппаратная виртуализация) | 4 | ~4ч | ⭐⭐⭐ |
| **[Lab-02](Lab-02-LXC/README-LXC.md)** | LXC/LXD (Системные контейнеры) | 5 | ~3ч | ⭐⭐ |
| **[Lab-03](Lab-03-Docker/README-Docker.md)** | Docker (Контейнеры приложений) | 5 | ~4ч | ⭐⭐ |
| **[Lab-04](Lab-04-Integration/README-Integration.md)** | Интеграция и выбор технологий | 3 | ~2ч | ⭐⭐⭐ |

**Общее время прохождения:** ~13 часов

## 🎯 Для кого этот курс?

### ✅ Идеально подходит для:
- **Системных администраторов** — управление инфраструктурой
- **DevOps инженеров** — контейнеризация и оркестрация
- **Разработчиков** — локальная разработка и тестирование
- **Студентов IT** — изучение современных технологий
- **Всех интересующихся Linux** — практические навыки

### 📋 Предварительные требования:
- Базовые знания Linux (командная строка)
- Понимание сетей (IP, DNS, routing)
- Опыт работы с shell scripting (желательно)

## 💻 Системные требования

### Минимальные:
- **CPU:** 4 cores с VT-x/AMD-V
- **RAM:** 8 GB
- **Disk:** 50 GB свободного места
- **OS:** Ubuntu 20.04+ / Debian 11+ / Fedora 35+
- **Kernel:** 4.18+
- **Network:** Активное подключение к интернету

### Рекомендуемые:
- **CPU:** 8+ cores
- **RAM:** 16 GB
- **Disk:** 100 GB SSD
- **OS:** Ubuntu 22.04 LTS

## 🚀 Что внутри каждого модуля?

### Lab-01: KVM (Аппаратная виртуализация)
```
✨ Научитесь:
├─ Создавать виртуальные машины
├─ Управлять ресурсами (CPU, память, I/O)
├─ Настраивать виртуальные сети
└─ Работать со снэпшотами и миграцией

🛠️ Инструменты: virsh, virt-install, libvirt, QEMU
⏱️ Время: ~4 часа
📖 Лабораторных: 4
```

### Lab-02: LXC/LXD (Системные контейнеры)
```
✨ Научитесь:
├─ Понимать изоляцию через namespaces
├─ Управлять ресурсами через cgroups
├─ Конфигурировать сети в LXD
└─ Создавать снэпшоты и шаблоны

🛠️ Инструменты: lxc, lxd, lxc-ls
⏱️ Время: ~3 часа
📖 Лабораторных: 5
```

### Lab-03: Docker (Контейнеры приложений)
```
✨ Научитесь:
├─ Писать эффективные Dockerfiles
├─ Работать с Docker networks и volumes
├─ Использовать docker-compose
└─ Публиковать образы в registry

🛠️ Инструменты: docker, docker-compose
⏱️ Время: ~4 часа
📖 Лабораторных: 5
```

### Lab-04: Integration (Интеграция)
```
✨ Научитесь:
├─ Сравнивать технологии по критериям
├─ Выбирать оптимальное решение
├─ Комбинировать технологии
└─ Решать реальные архитектурные задачи

📊 Bonus: Comparison Matrix
⏱️ Время: ~2 часа
📖 Лабораторных: 3
```

## 🧪 Автоматическое тестирование

Каждый модуль включает тесты для валидации:

```bash
# KVM тесты
cd Lab-01-KVM/tests
./test-lab1.sh  # Создание VM
./test-lab2.sh  # Управление ресурсами
./test-lab3.sh  # Сети
./test-lab4.sh  # Снэпшоты

# LXC тесты
cd Lab-02-LXC/tests
./test-namespace-isolation.sh
./test-cgroups-limits.sh

# Docker тесты
cd Lab-03-Docker/tests
./test-image-build.sh
./test-compose-stack.sh

# Integration тест
cd Lab-04-Integration/tests
./test-all-platforms.sh  # Проверка всех платформ
```

## 📖 Документация

### Главные документы:
- **[QUICKSTART.md](QUICKSTART.md)** — начните здесь!
- **[MANIFEST.md](MANIFEST.md)** — полное описание проекта
- **LICENSE** — MIT лицензия

### Модули:
- **[Lab-01-KVM/README-KVM.md](Lab-01-KVM/README-KVM.md)**
- **[Lab-02-LXC/README-LXC.md](Lab-02-LXC/README-LXC.md)**
- **[Lab-03-Docker/README-Docker.md](Lab-03-Docker/README-Docker.md)**
- **[Lab-04-Integration/README-Integration.md](Lab-04-Integration/README-Integration.md)**

### Дополнительные ресурсы:
- **[comparison-matrix.md](Lab-04-Integration/comparison-matrix.md)** — сравнение KVM vs LXC vs Docker

## 🎓 Сертификаты и следующие шаги

После прохождения курса рекомендуем:

### Сертификации:
- **Docker Certified Associate (DCA)**
- **Certified Kubernetes Administrator (CKA)**
- **Red Hat Certified Specialist in Containers**

### Дальнейшее изучение:
- **Kubernetes** — оркестрация контейнеров
- **Proxmox VE** — веб-управление KVM
- **OpenStack** — облачная платформа
- **Ansible** — автоматизация инфраструктуры

## 🤝 Вклад в проект

Мы приветствуем вклад в развитие проекта!

```bash
# Нашли ошибку?
# Создайте issue с описанием

# Хотите добавить лабораторную?
# Форкните репозиторий и создайте pull request
```

## 📞 Поддержка и контакты

- **Email:** labs@example.com
- **Issues:** https://github.com/os-practical-labs/issues
- **Telegram:** @os_practical_labs (example)

## 📜 Лицензия

Этот проект распространяется под лицензией **MIT License**.  
См. файл [LICENSE](LICENSE) для подробностей.

## 🌟 Благодарности

Проект создан **OS Practical Labs Team** для обучающихся и профессионалов.

Особая благодарность:
- Сообществу Linux и Open Source
- Разработчикам KVM, LXC, Docker
- Всем контрибьюторам и тестерам

---

## 🚀 Готовы начать?

```bash
# 1. Прочитайте быстрый старт
cat QUICKSTART.md

# 2. Выберите модуль
cd Lab-03-Docker  # Начните с Docker (самый простой)

# 3. Следуйте инструкциям
cat README-Docker.md
./scripts/build-all.sh
./scripts/start.sh

# 4. Проверьте результат
docker ps
curl http://localhost:5000
```

---

**Версия:** 1.0  
**Дата релиза:** 2024-11-16  
**Авторы:** OS Practical Labs Team  
**Статус:** ✅ Stable Release

**Счастливого обучения! 🎉**
