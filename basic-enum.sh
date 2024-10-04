#!/bin/bash

# Definir colores
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # Sin color

# Función para mostrar el menú
mostrar_menu() {
  echo -e "${CYAN}Menú de Reconocimiento para Privesc:${NC}"
  echo -e "${YELLOW}1)${NC} Extraer la versión del OS y del Kernel"
  echo -e "${YELLOW}2)${NC} Listar procesos en ejecución"
  echo -e "${YELLOW}3)${NC} Listar directorios del sistema (/home)"
  echo -e "${YELLOW}4)${NC} Mostrar el historial de comandos"
  echo -e "${YELLOW}5)${NC} Ver archivos de configuración sensibles"
  echo -e "${YELLOW}6)${NC} Listar los privilegios del usuario actual"
  echo -e "${YELLOW}7)${NC} Buscar archivos SUID/SGID"
  echo -e "${YELLOW}8)${NC} Buscar contraseñas en archivos de configuración"
  echo -e "${YELLOW}9)${NC} Buscar tareas cron"
  echo -e "${YELLOW}10)${NC} Listar capacidades del kernel"
  echo -e "${YELLOW}11)${NC} Información de red"
  echo -e "${YELLOW}12)${NC} Ver si sudo puede ejecutarse sin contraseña"
  echo -e "${YELLOW}13)${NC} Salir"
  echo -n -e "${BLUE}Selecciona una opción [1-13]: ${NC}"
}

# Función para ejecutar la opción seleccionada
ejecutar_opcion() {
  case $1 in
    1)
      echo -e "${GREEN}OS Version:${NC} $(lsb_release -ds)"
      echo -e "${GREEN}Kernel Version:${NC} $(uname -r)"
      ;;
    2)
      echo -e "${GREEN}Procesos en ejecución:${NC}"
      ps au
      ;;
    3)
      echo -e "${GREEN}Directorios en /home:${NC}"
      ls /home
      ;;
    4)
      echo -e "${GREEN}Historial de comandos:${NC}"
      history
      ;;
    5)
      echo -e "${GREEN}Archivos de configuración sensibles:${NC}"
      echo -e "${RED}Contenido de /etc/passwd:${NC}"
      cat /etc/passwd
      echo -e "${RED}Contenido de /etc/shadow (si tienes permisos):${NC}"
      sudo cat /etc/shadow
      ;;
    6)
      echo -e "${GREEN}Privilegios del usuario actual:${NC}"
      sudo -l
      ;;
    7)
      echo -e "${GREEN}Buscando archivos SUID/SGID:${NC}"
      find / -perm -4000 2>/dev/null
      find / -perm -2000 2>/dev/null
      ;;
    8)
      echo -e "${GREEN}Buscando contraseñas en archivos de configuración:${NC}"
      grep -r "password" /etc/ 2>/dev/null
      ;;
    9)
      echo -e "${GREEN}Buscando tareas cron:${NC}"
      cat /etc/crontab
      ls -la /etc/cron.*
      ;;
    10)
      echo -e "${GREEN}Buscando capacidades del kernel:${NC}"
      getcap -r / 2>/dev/null
      ;;
    11)
      echo -e "${GREEN}Información de red:${NC}"
      ip a
      netstat -tuln
      ;;
    12)
      echo -e "${GREEN}Verificando si sudo puede ejecutarse sin contraseña:${NC}"
      sudo -l | grep "NOPASSWD"
      ;;
    13)
      echo "Saliendo..."
      exit 0
      ;;
    *)
      echo -e "${RED}Opción no válida. Intenta de nuevo.${NC}"
      ;;
  esac
}

# Bucle para mostrar el menú hasta que el usuario elija salir
while true; do
  mostrar_menu
  read opcion
  ejecutar_opcion $opcion
done
