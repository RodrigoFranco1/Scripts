# ===========================
# Script todo-en-uno para descubrir segmentos activos - VERSIÓN CORREGIDA
# ===========================

# Verificar si Nmap está instalado
if (-not (Get-Command "nmap" -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Nmap no está instalado o no está en el PATH" -ForegroundColor Red
    Write-Host "    Descarga Nmap desde: https://nmap.org/download.html" -ForegroundColor Yellow
    exit 1
}

# 1. Generar segmentos /24 comunes
$segmentosFile = ".\segmentos_comunes.txt"
$segmentos = @()

Write-Host "[*] Generando segmentos de red..." -ForegroundColor Yellow

# 192.168.0.0/16 → 256 segmentos
for ($i = 0; $i -lt 256; $i++) {
    $segmentos += "192.168.$i.0/24"
}

# 10.0.0.0/16 → 256 segmentos (ajustable)
for ($i = 0; $i -lt 256; $i++) {
    $segmentos += "10.0.$i.0/24"
}

# 172.16.0.0 - 172.31.255.0 → Segmentos más comunes
for ($j = 16; $j -le 31; $j++) {
    for ($i = 0; $i -lt 16; $i++) {  # Reducido para pruebas iniciales
        $segmentos += "172.$j.$i.0/24"
    }
}

# Guardar segmentos en archivo
try {
    $segmentos | Out-File $segmentosFile -Encoding UTF8
    Write-Host "[+] Segmentos generados: $($segmentos.Count) redes" -ForegroundColor Green
    Write-Host "[+] Archivo guardado: $segmentosFile" -ForegroundColor Green
}
catch {
    Write-Host "[ERROR] Al crear archivo de segmentos: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 2. Ejecutar Nmap ping scan (solo host discovery)
$nmapOutput = ".\barrido_liviano.gnmap"
$nmapCmd = "nmap -sn -iL `"$segmentosFile`" --max-retries 1 --min-parallelism 20 --max-parallelism 50 -oG `"$nmapOutput`""

Write-Host "[*] Ejecutando Nmap... esto puede tardar varios minutos." -ForegroundColor Yellow
Write-Host "[*] Comando: $nmapCmd" -ForegroundColor Gray

try {
    # Ejecutar con manejo de errores
    $process = Start-Process -FilePath "nmap" -ArgumentList "-sn", "-iL", "`"$segmentosFile`"", "--max-retries", "1", "--min-parallelism", "20", "--max-parallelism", "50", "-oG", "`"$nmapOutput`"" -Wait -PassThru -NoNewWindow
    
    if ($process.ExitCode -ne 0) {
        Write-Host "[ERROR] Nmap terminó con código de error $($process.ExitCode)" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "[ERROR] Ejecutando Nmap: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "[+] Escaneo terminado. Analizando resultados..." -ForegroundColor Green

# 3. Verificar que el archivo de salida existe
if (-not (Test-Path $nmapOutput)) {
    Write-Host "[ERROR] No se encontró el archivo de salida de Nmap: $nmapOutput" -ForegroundColor Red
    exit 1
}

# 4. Extraer IPs activas y sus subredes con mejor manejo de errores
try {
    $lineasUp = Select-String -Path $nmapOutput -Pattern "Up" -ErrorAction Stop
    
    if ($lineasUp.Count -eq 0) {
        Write-Host "[AVISO] No se encontraron hosts activos en el escaneo" -ForegroundColor Yellow
        Write-Host "[*] Revisa la conectividad de red y los rangos escaneados" -ForegroundColor Gray
        exit 0
    }
    
    $ipsActivas = $lineasUp | ForEach-Object {
        # Mejor parsing de la línea de Nmap
        if ($_.Line -match "Host: (\d+\.\d+\.\d+\.\d+).*Status: Up") {
            $matches[1]
        }
    } | Where-Object { $_ -ne $null }
    
    Write-Host "[+] IPs activas encontradas: $($ipsActivas.Count)" -ForegroundColor Green
    
    # Extraer segmentos únicos
    $segmentosActivos = $ipsActivas | ForEach-Object {
        if ($_ -match "^(\d+\.\d+\.\d+)\.\d+$") {
            "$($matches[1]).0/24"
        }
    } | Where-Object { $_ -ne $null } | Sort-Object -Unique
    
}
catch {
    Write-Host "[ERROR] Procesando resultados de Nmap: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "[*] Verifica el formato del archivo: $nmapOutput" -ForegroundColor Gray
    exit 1
}

# 5. Guardar y mostrar resultados
if ($segmentosActivos.Count -gt 0) {
    $resultadoFinal = ".\segmentos_activos.txt"
    
    try {
        $segmentosActivos | Out-File $resultadoFinal -Encoding UTF8
        
        Write-Host ""
        Write-Host "[RESULTADOS] Segmentos activos detectados ($($segmentosActivos.Count)):" -ForegroundColor Cyan
        $segmentosActivos | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
        Write-Host ""
        Write-Host "[+] Archivo guardado en: $resultadoFinal" -ForegroundColor Green
        
        # Estadísticas adicionales
        Write-Host ""
        Write-Host "[INFO] Estadísticas:" -ForegroundColor Gray
        Write-Host "    - Segmentos escaneados: $($segmentos.Count)" -ForegroundColor Gray
        Write-Host "    - Hosts activos: $($ipsActivas.Count)" -ForegroundColor Gray
        Write-Host "    - Segmentos con hosts activos: $($segmentosActivos.Count)" -ForegroundColor Gray
    }
    catch {
        Write-Host "[ERROR] Guardando resultados: $($_.Exception.Message)" -ForegroundColor Red
    }
}
else {
    Write-Host "[AVISO] No se detectaron segmentos activos" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[INFO] Script completado" -ForegroundColor Green
