#!/bin/bash

# Detectar discos de 1GB y 2GB
DISCO_1=$(lsblk | grep 1G | awk '{print $1}')
DISCO_2=$(lsblk | grep 2G | awk '{print $1}' | head -n1)
DISCO_1G=$DISCO_1
DISCO_2G=$DISCO_2

# Particionar ambos discos
sudo fdisk /dev/$DISCO_1G << EOF
n
p
1


t
8E
w
EOF

sudo fdisk /dev/$DISCO_2G << EOF
n
p
1


t
8E
w
EOF

# Limpiar particiones previas en los discos
sudo wipefs -a /dev/${DISCO_1G}1
sudo wipefs -a /dev/${DISCO_2G}1

# Crear PVs en las particiones nuevas
sudo pvcreate /dev/${DISCO_1G}1
sudo pvcreate /dev/${DISCO_2G}1

# Crear volume groups
sudo vgcreate vg_datos /dev/${DISCO_2G}1
sudo vgcreate vg_temp /dev/${DISCO_1G}1

sudo lvcreate -L 5M vg_datos -n lv_docker
sudo lvcreate -L 1.5G vg_datos -n lv_workareas
sudo lvcreate -L 512M vg_temp -n lv_swap

# Formatear y activar memoria swap
sudo mkswap /dev/vg_temp/lv_swap
sudo swapon /dev/vg_temp/lv_swap

# Formatear volumenes
sudo mkfs.ext4 /dev/vg_datos/lv_workareas
sudo mkfs.ext4 /dev/vg_datos/lv_docker

# Crear puntos de montaje
sudo mkdir -p /work
sudo mount /dev/vg_datos/lv_workareas /work



