#!/bin/bash

# Script para identificar subdominios, sus direcciones IP y obtener información de Shodan
# Verifica si se proporcionó un dominio como argumento
if [ "$#" -ne 1 ]; then
    echo "Uso: $0 <dominio.com>"
    exit 1
fi

DOMINIO=$1

echo "Enumerando subdominios y obteniendo IPs para: $DOMINIO"

# Directorio de trabajo temporal
WORKDIR=$(mktemp -d)
echo "Directorio de trabajo: $WORKDIR"

# Archivos temporales
SUBDOMAINS_LIST="$WORKDIR/subdomainlist"
IP_ADDRESSES_LIST="$WORKDIR/ip-addresses.txt"

# Paso 1: Obtener los logs de transparencia del certificado
curl -s "https://crt.sh/?q=${DOMINIO}&output=json" | jq . > "$WORKDIR/crtsh_output.json"

# Paso 2: Filtrar los dominios únicos
curl -s "https://crt.sh/?q=${DOMINIO}&output=json" | jq . | grep name | cut -d":" -f2 | grep -v "CN=" | cut -d'"' -f2 | awk '{gsub(/\\n/,"\n");}1;' | sort -u > "$SUBDOMAINS_LIST"

# Paso 3: Identificar hosts directamente accesibles desde Internet
while IFS= read -r subdomain; do
    host "$subdomain" | grep "has address" | grep "$DOMINIO" | cut -d" " -f4 >> "$IP_ADDRESSES_LIST"
done < "$SUBDOMAINS_LIST"

# Paso 4: Extraer información de Shodan
while IFS= read -r ip; do
    shodan host "$ip"
done < "$IP_ADDRESSES_LIST"

# Limpieza (opcional, descomentar si deseas eliminar el directorio de trabajo)
# rm -rf "$WORKDIR"

echo "Proceso completado. Revisa los archivos en $WORKDIR para los resultados."
