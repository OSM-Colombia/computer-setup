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

set -u
set -e

declare -r VERSION="2024-10-03"

# Mirar si el script está corriendo como root
if [[ $EUID -ne 0 ]]; then
    echo "Este script debe ser ejecutado como root"
    exit 1
fi

# Revisar y obtener la distro del PC
linux_distro=$(grep '^NAME=' /etc/os-release | cut -d '"' -f 2)

# Update de toda la vida
sudo apt update
sudo apt upgrade -y

install_mapas(){
    echo "Empezando con la instalación de ODM, JOSM y más programas para mapear!"
        # Para instalar OpenDroneMap (ODM) se requiere de unos
        # requerimientos, por lo tanto, se verifican o instalan
        # (si es necesario) estos mismos. Ver:
        # https://github.com/OpenDroneMap/WebODM/?tab=readme-ov-file#requirements
        # para más información



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

        ####### Instalar JOSM #######

        # Instalar Java

        # Mirar si Java está instalado, si no, instalarlo
        if command -v java &>/dev/null; then
            echo "Java ya está instalado"
            java -version
        else
            echo "Java no está instalado, se va a instalar"
            echo "Instalando OpenJDK 11..."
            sudo apt update
            sudo apt install -y openjdk-11-jre
        fi

        # Instalar JOSM
        sudo add-apt-repository ppa:josm/ppa
        sudo apt update
        sudo apt install -y josm

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
}

install_3D() {
    # Instalación de varios programas para diseño 3D
    echo "Empezando instalación de OrcaSlicer y Blender..."
    cd ~/Desktop || { echo "Error: No se pudo acceder a ~/Desktop"; exit 1; }
    wget https://github.com/SoftFever/OrcaSlicer/releases/download/v2.2.0/OrcaSlicer_Linux_V2.2.0.AppImage
    chmod +x OrcaSlicer_Linux_V2.2.0.AppImage
    cd $HOME
    echo "OrcaSlicer se descargó correctamente"
    if ["$linux_distro" == "Ubuntu"]; then
        sudo apt install libfuse2 && blender -y
    fi
}


read -p "¿Qué quieres instalar? (Suite 3D [1] / Suite Mapas [2] / Config Natural [3]): " option


case $option in
    1)
        install_3D
        ;;
    2)
        install_mapas
        ;;
    *)
        echo "Opción inválida. Por favor elige, 1, 2, o 3."
        ;;
esac
