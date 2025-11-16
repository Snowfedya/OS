# Lab-03: Контейнеризация приложений с Docker

## 📋 Обзор
Изучение **контейнеризации приложений** с Docker — платформы для упаковки, распространения и запуска приложений в изолированных контейнерах.

**Ключевые концепции:**
- Dockerfile — инструкции для сборки образов
- Docker Images — неизменяемые шаблоны
- Docker Containers — запущенные экземпляры образов
- Docker Compose — оркестрация multi-container приложений
- Volumes — персистентное хранение данных
- Networks — связность между контейнерами

## 💻 Требования
- Ubuntu 20.04+ / Debian 11+ / macOS / Windows with WSL2
- 4GB RAM
- 20GB дискового пространства
- Docker 24.0+ & Docker Compose 2.0+

## ⚡ Быстрый старт

### Установка Docker
```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com | sudo bash
sudo usermod -aG docker $USER
newgrp docker

# Проверка
docker --version
docker compose version
```

### Запуск лабораторного стека
```bash
cd Lab-03-Docker

# Собрать образы
./scripts/build-all.sh

# Запустить все сервисы
./scripts/start.sh

# Проверка
curl http://localhost:5000
curl http://localhost:3000/api/info
```

## 📚 Лабораторные работы

### [Lab 1: Основы Dockerfile](labs/lab1-dockerfile-basics.md) ⏱️ 45 мин
**Темы:**
- Структура Dockerfile
- Multi-stage builds
- Оптимизация слоев
- .dockerignore

**Ключевые команды:**
```bash
docker build -t myapp:v1 .
docker run -p 8080:80 myapp:v1
docker inspect myapp:v1
```

### [Lab 2: Docker Networks](labs/lab2-docker-networks.md) ⏱️ 40 мин
**Темы:**
- Bridge networks
- Host networking
- Service discovery
- DNS resolution

**Примеры:**
```bash
docker network create my-net
docker run --network my-net nginx
docker network inspect my-net
```

### [Lab 3: Volumes & Data](labs/lab3-volumes-mounts.md) ⏱️ 40 мин
**Темы:**
- Named volumes
- Bind mounts
- tmpfs mounts
- Backup/restore

```bash
docker volume create app-data
docker run -v app-data:/data nginx
docker volume ls
```

### [Lab 4: Docker Compose](labs/lab4-docker-compose.md) ⏱️ 60 мин
**Темы:**
- docker-compose.yml структура
- Multi-container приложения
- Environment variables
- Scaling services

```bash
docker-compose up -d
docker-compose ps
docker-compose logs -f
docker-compose down
```

### [Lab 5: Registry & Distribution](labs/lab5-registry-push.md) ⏱️ 30 мин
**Темы:**
- Docker Hub
- Private registry
- Image tagging
- Push/Pull operations

```bash
docker tag myapp:latest myrepo/myapp:v1
docker push myrepo/myapp:v1
docker pull myrepo/myapp:v1
```

## 🏗️ Архитектура лабораторного стека

```
┌─────────────┐      ┌─────────────┐
│   Web App   │◄────►│  API Service│
│  (Flask)    │      │  (Node.js)  │
│  Port 5000  │      │  Port 3000  │
└──────┬──────┘      └──────┬──────┘
       │                     │
       │    ┌───────────┐   │
       └───►│PostgreSQL │◄──┘
       │    │(Database) │   │
       │    └───────────┘   │
       │                     │
       └────►┌───────────┐◄─┘
              │   Redis   │
              │  (Cache)  │
              └───────────┘
```

## ✅ Контрольный список
- [ ] Docker установлен и работает
- [ ] Образы собраны успешно
- [ ] Стек запущен через docker-compose
- [ ] Все сервисы healthy
- [ ] Web доступен на :5000
- [ ] API доступен на :3000
- [ ] База данных работает
- [ ] Volumes персистентны

## 🧪 Тестирование
```bash
cd tests/

# Проверка образов
./test-image-build.sh

# Проверка запуска
./test-container-run.sh

# Проверка стека
./test-compose-stack.sh

# Проверка сети
./test-networking.sh

# Проверка данных
./test-data-persistence.sh
```

## 🐛 Troubleshooting

### Контейнер сразу останавливается
```bash
# Посмотреть логи
docker logs container-name

# Запустить в интерактивном режиме
docker run -it myapp /bin/sh
```

### Порт уже занят
```bash
# Найти процесс
sudo lsof -i :5000
sudo netstat -tulpn | grep 5000

# Убить процесс или изменить порт
docker run -p 5001:5000 myapp
```

### Образ не собирается
```bash
# Очистить build cache
docker builder prune

# Собрать без cache
docker build --no-cache -t myapp .
```

### Нет места на диске
```bash
# Очистить неиспользуемые образы
docker image prune -a

# Очистить volumes
docker volume prune

# Полная очистка
docker system prune -a --volumes
```

## 📖 Best Practices

### Dockerfile
```dockerfile
# ✅ Хорошо: минимальный base image
FROM python:3.11-slim

# ✅ Хорошо: один RUN для установки пакетов
RUN apt-get update && apt-get install -y \
    package1 \
    package2 \
    && rm -rf /var/lib/apt/lists/*

# ✅ Хорошо: COPY requirements отдельно (cache)
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .

# ✅ Хорошо: non-root user
USER appuser

# ❌ Плохо: root пользователь
# ❌ Плохо: FROM ubuntu (слишком большой)
# ❌ Плохо: много RUN команд
```

### docker-compose.yml
```yaml
# ✅ Хорошо: версия указана
version: '3.8'

services:
  app:
    # ✅ Хорошо: healthcheck
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost"]
    
    # ✅ Хорошо: restart policy
    restart: unless-stopped
    
    # ✅ Хорошо: зависимости
    depends_on:
      db:
        condition: service_healthy
```

## 📖 Дополнительные ресурсы
- [Docker Documentation](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Compose Spec](https://docs.docker.com/compose/compose-file/)

---
**Следующий модуль:** [Lab-04-Integration](../Lab-04-Integration/README-Integration.md)
