# ===========================
# Script todo-en-uno para descubrir segmentos activos en redes internas
# ===========================

# 1. Generar segmentos /24 comunes
$segmentosFile = ".\segmentos_comunes.txt"
$segmentos = @()

# 192.168.0.0/16 → 256 segmentos
for ($i = 0; $i -lt 256; $i++) {
    $segmentos += "192.168.$i.0/24"
}

# 10.0.0.0/16 → 256 segmentos (ajustable)
for ($i = 0; $i -lt 256; $i++) {
    $segmentos += "10.0.$i.0/24"
}

# 172.16.0.0 - 172.31.255.0 → 16*256 segmentos (aquí solo los más comunes por tiempo)
for ($j = 16; $j -le 31; $j++) {
    for ($i = 0; $i -lt 16; $i++) {  # Puedes subir a 256 si tienes tiempo
        $segmentos += "172.$j.$i.0/24"
    }
}

$segmentos | Out-File $segmentosFile
Write-Host "[+] Segmentos generados: $segmentosFile" -ForegroundColor Green

# 2. Ejecutar Nmap ping scan (solo host discovery)
$nmapOutput = ".\barrido_liviano.gnmap"
$nmapCmd = "nmap -sn -iL `"$segmentosFile`" --max-retries 1 --min-parallelism 20 -oG `"$nmapOutput`""
Write-Host "[*] Ejecutando Nmap... esto puede tardar varios minutos." -ForegroundColor Yellow
Invoke-Expression $nmapCmd
Write-Host "[+] Escaneo terminado. Analizando resultados..." -ForegroundColor Green

# 3. Extraer IPs activas y sus subredes
$ipsActivas = Select-String -Path $nmapOutput -Pattern "Up" | ForEach-Object {
    ($_ -split " ")[1]
}

$segmentosActivos = $ipsActivas | ForEach-Object {
    $partes = $_.Split(".")
    "$($partes[0]).$($partes[1]).$($partes[2]).0/24"
} | Sort-Object -Unique

# 4. Guardar resultados
$resultadoFinal = ".\segmentos_activos.txt"
$segmentosActivos | Out-File $resultadoFinal
Write-Host "[✔] Segmentos activos detectados:" -ForegroundColor Cyan
$segmentosActivos | ForEach-Object { Write-Host "  $_" }
Write-Host "`n[+] Archivo guardado en: $resultadoFinal" -ForegroundColor Green
