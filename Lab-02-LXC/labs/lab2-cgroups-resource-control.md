# Лабораторная 2: Управление ресурсами через cgroups

## 🎯 Цель
Научиться ограничивать CPU, память и I/O через control groups.

## 🔬 Практика

### CPU Limits
```bash
# Ограничить CPU до 50%
lxc config set container1 limits.cpu 1
lxc config set container1 limits.cpu.allowance 50%

# Проверка
lxc config show container1 | grep cpu
```

### Memory Limits
```bash
# Ограничить память до 512MB
lxc config set container1 limits.memory 512MB

# Swap
lxc config set container1 limits.memory.swap false
```

### I/O Limits
```bash
# Disk I/O priority
lxc config device set container1 root limits.read 10MB
lxc config device set container1 root limits.write 10MB
```

## ✅ Тест
Запустите stress test: `stress-ng --cpu 4 --vm 2 --vm-bytes 1G`
