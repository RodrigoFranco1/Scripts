#!/bin/bash

#Parte de la documentación de notion 


# Instalar dependencias necesarias
sudo apt-get install libaio1 python3-dev alien -y

# Clonar el repositorio de ODAT
git clone https://github.com/quentinhardy/odat.git
cd odat/
git submodule init
git submodule update

# Descargar e instalar Oracle Instant Client
wget https://download.oracle.com/otn_software/linux/instantclient/2112000/instantclient-basic-linux.x64-21.12.0.0.0dbru.zip
unzip instantclient-basic-linux.x64-21.12.0.0.0dbru.zip
wget https://download.oracle.com/otn_software/linux/instantclient/2112000/instantclient-sqlplus-linux.x64-21.12.0.0.0dbru.zip
unzip instantclient-sqlplus-linux.x64-21.12.0.0.0dbru.zip

# Configurar variables de entorno
export LD_LIBRARY_PATH=instantclient_21_12:$LD_LIBRARY_PATH
export PATH=$LD_LIBRARY_PATH:$PATH

# Instalar cx_Oracle usando pipx
pipx install cx_Oracle

# Instalar python-scapy usando pipx
sudo apt-get install python3-scapy -y
pipx install scapy

# Instalar otras dependencias de Python usando pipx
pipx install colorlog termcolor pycrypto passlib python-libnmap

# Instalar y activar argcomplete para la autocompletación
pipx install argcomplete
sudo activate-global-python-argcomplete
