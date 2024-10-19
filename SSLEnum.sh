#!/bin/bash
# Script para identificar subdominios, sus direcciones IP y obtener información de Shodan
# USO: ./script.sh dominio.com TU_SHODAN_API_KEY

# Verifica si se proporcionaron los argumentos necesarios
if [ "$#" -ne 2 ]; then
    echo "Uso: $0 <dominio.com> <apikey_shodan>"
    exit 1
fi

DOMINIO=$1
SHODAN_API_KEY=$2

# Obtiene el directorio donde se encuentra el script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
OUTPUT_DIR="$SCRIPT_DIR/SSLOutput"

# Crea el directorio SSLOutput si no existe
mkdir -p "$OUTPUT_DIR"

echo "Enumerando subdominios y obteniendo IPs para: $DOMINIO"

# Configura la API key de Shodan
shodan init "$SHODAN_API_KEY"

# Archivos temporales
SUBDOMAINS_LIST="$OUTPUT_DIR/subdomainlist"
IP_ADDRESSES_LIST="$OUTPUT_DIR/ip-addresses.txt"
CRTSH_OUTPUT_JSON="$OUTPUT_DIR/crtsh_output.json"

# Paso 1: Obtener los logs de transparencia del certificado
curl -s "https://crt.sh/?q=${DOMINIO}&output=json" | jq . > "$CRTSH_OUTPUT_JSON"

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

echo "Proceso completado. Revisa los archivos en $OUTPUT_DIR para los resultados."
