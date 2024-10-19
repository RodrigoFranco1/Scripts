#!/bin/bash

# Limpia todos los contenedores Docker existentes en el sistema
cleanup_docker () {
    sudo docker stop $(sudo docker ps -aq)
    sudo docker rm $(sudo docker ps -aq)
    sudo docker rm $(sudo docker images -q)
    sudo docker volume rm $(sudo docker volume ls -q)
    sudo docker network rm $(sudo docker network ls -q)
    exit
    }


    echo -e "\n  Warning! This script is about to remove all docker containers and networks!" 
    read -n3 -p "  Press Y or y to proceed any other key to exit : " userinput 
    case $userinput in
        y|Y) cleanup_docker ;;
          *) exit ;;
    esac 
