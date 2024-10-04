#!/usr/bin/env sh

# Este script instala dependencias y programas para
# las actividades de talleres al momento de utilizar
# los computadores.
#
# Este script ha sido probado en una máquina virtual
# Linux Mint con 4 GB de memoria RAM y 50 GB de disco
# puede que cambien algunas cosas si se cambia de distro.
#
# Autor: Ludwig Alvarado - Ludway
# Versión: 2024-10-03

declare -r VERSION="2024-10-03"

# Mirar si el script está corriendo como root
if [[ $EUID -ne 0 ]]; then
    echo "Este script debe ser ejecutado como root"
    exit 1
fi

# Para instalar OpenDroneMap (ODM) se requiere de unos
# requerimientos, por lo tanto, se verifican o instalan
# (si es necesario) estos mismos. Ver:
# https://github.com/OpenDroneMap/WebODM/?tab=readme-ov-file#requirements
# para más información

# Update de toda la vida
sudo apt update

# Instalar Python
if command -v python3 &>/dev/null; then
    echo "Python ya está instalado."
else
    echo "Python no está instalado. Se procede a instalar Python..."
    sudo apt install -y python3
fi

# Instalar pip
if command -v pip3 &>/dev/null; then
    echo "pip ya está instalado"
else
    echo "pip no está instalado. Se procede a instalar pip..."
    sudo apt install -y python3-pip
fi

# Instalar git
if command -v git &>/dev/null; then
    echo "Git ya está instalado!"
else
    echo "Git no está instalado. Se procede a instalar git..."
    sudo apt install -y git
fi

####### Instalar docker #######

# Instalar Docker Engine
# Para esto se va a utilizar la documentación directa de:
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
# únicamente se le agrega el parámetro -y

# Agregar llave GPG oficial de Docker:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# agregar los repositorios a los recursos Apt
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Instalar los paquetes de Docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Instalar Docker Desktop
# Se sigue la documentación disponible en:
# https://docs.docker.com/desktop/install/linux/ubuntu/
#
# Instalar el paquete DEB
curl -O https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb?_gl=1*1muk0dy*_gcl_au*ODM4MzIzMTE1LjE3MjgwMTY0ODE.*_ga*MjU5MTMyOTA4LjE3MjU1NDU1NDQ.*_ga_XJWPQMJYHQ*MTcyODAxNjQ4MC4yLjEuMTcyODAxODExNi42MC4wLjA.

# Instalar el paquete:
sudo apt-get update
sudo apt-get install -y ./docker-desktop-amd64.deb

####### Instalar OpenDroneMap #######

git clone https://github.com/OpenDroneMap/WebODM --config core.autocrlf=input --depth 1
cd WebODM
./webodm.sh start
