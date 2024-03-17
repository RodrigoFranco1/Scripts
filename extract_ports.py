#!/usr/bin/env python3
import sys
import re

def extract_ports_and_ip_from_nmap_output(file_path):
    # Expresión regular para encontrar los números de puerto y la dirección IP
    port_regex = re.compile(r'(\d+)/open')
    ip_regex = re.compile(r'Host: (\S+) ')
    
    ports = []
    ip_address = None
    with open(file_path, 'r') as file:
        for line in file:
            # Intentar extraer la dirección IP si aún no se ha encontrado
            if ip_address is None:
                ip_match = ip_regex.search(line)
                if ip_match:
                    ip_address = ip_match.group(1)
                    
            if "Ports:" in line:
                # Extraer todos los números de puerto de la línea
                found_ports = port_regex.findall(line)
                ports.extend(found_ports)
    
    # Unir los números de puerto con comas y sin espacios
    ports_string = ",".join(ports)
    # Preparar y mostrar el resultado final
    result = f"IP Address: {ip_address}\nOpen Ports: {ports_string}"
    print(result)

if __name__ == "__main__":
    # El primer argumento de la línea de comandos debe ser la ruta del archivo
    file_path = sys.argv[1]
    extract_ports_and_ip_from_nmap_output(file_path)
