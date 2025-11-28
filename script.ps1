# ----------------------------------------------------------
# Star Citizen Instalador de Traduccion
# ----------------------------------------------------------

# Archivo de configuración
$ConfigFile = ".\config.ini"

# ----------------------------------------------------------
# Función: Cargar config
# ----------------------------------------------------------
function Load-Config {
    if (!(Test-Path $ConfigFile)) {
        @"
SCPATH=
ModIns=
"@ | Set-Content $ConfigFile -Encoding UTF8
    }

    $global:SCPATH = ""
    $global:ModIns = ""

    foreach ($line in Get-Content $ConfigFile) {
        if ($line -match "^(.*?)=(.*)$") {
            $key = $matches[1]
            $value = $matches[2]

            switch ($key) {
                "SCPATH" { $global:SCPATH = $value }
                "ModIns" { $global:ModIns = $value }
            }
        }
    }
}

# ----------------------------------------------------------
# Función: Guardar config
# ----------------------------------------------------------
function Save-Config {
@"
SCPATH=$SCPATH
ModIns=$ModIns
"@ | Set-Content $ConfigFile -Encoding UTF8
}

# ----------------------------------------------------------
# Función: Consultar última versión del mod en GitHub
# ----------------------------------------------------------
function Get-LatestModVersion {
    $url = "https://api.github.com/repos/Thord82/Star_citizen_ES/releases/latest"
    try {
        $response = Invoke-RestMethod -Uri $url -Headers @{ "User-Agent" = "PowerShell" }
        return $response.tag_name
    }
    catch {
        Write-Host "No se pudo obtener la version." -ForegroundColor Red
        return "DESCONOCIDA"
    }
}

# ----------------------------------------------------------
# Función: Mostrar menú con bloques coloreados
# ----------------------------------------------------------
function Show-Menu {
    Clear-Host

    # Colores
    $titleColor = "DarkMagenta"
    $infoColor = "Cyan"
    $valueColor = "Yellow"
    $optionColor = "Green"
    $shadowColor = "DarkGray"

    # Consultar siempre la última versión disponible
    $global:ModVer = Get-LatestModVersion

    $scpathDisplay = if ($SCPATH) { $SCPATH } else { "NINGUNA" }
    $modInsDisplay = if ($ModIns) { $ModIns } else { "NO INSTALADO" }
    $modVerDisplay = $ModVer

    $width = 60

    # -------------------------------
    # Título centrado
    $title = "INSTALADOR DE TRADUCCION HISPANA STAR CITIZEN"
    $pad = " " * ([math]::Max(0, (($width - $title.Length)/2)))
    Write-Host "+" + ("=" * ($width)) + "+" -ForegroundColor $shadowColor
    Write-Host "|$pad$title$pad|" -ForegroundColor $titleColor
    Write-Host "+" + ("=" * ($width)) + "+" -ForegroundColor $shadowColor
    Write-Host ""

    # -------------------------------
    # Bloque de información con “sombra”
    Write-Host "+" + ("-" * ($width)) + "+" -ForegroundColor $shadowColor
    Write-Host ("| DIRECCION DE INSTALACION DE STAR CITIZEN: $scpathDisplay".PadRight($width) + "|") -ForegroundColor $infoColor
    Write-Host "+" + ("+" * ($width)) + "+" -ForegroundColor $shadowColor
    Write-Host ("| ULTIMA TRADUCCION INSTALADA: $modInsDisplay".PadRight($width) + "|") -ForegroundColor $infoColor
    Write-Host ("| ULTIMA TRADUCCION DISPONIBLE: $modVerDisplay".PadRight($width) + "|") -ForegroundColor $valueColor
    Write-Host "+" + ("-" * ($width)) + "+" -ForegroundColor $shadowColor
    Write-Host ""

    # -------------------------------
    # Bloque de opciones con “sombra”
    Write-Host "+" + ("-" * ($width)) + "+" -ForegroundColor $shadowColor
    Write-Host "| OPCIONES:".PadRight($width) + "|" -ForegroundColor $optionColor
    Write-Host ""
    Write-Host "| 1 - Cambiar carpeta de instalacion".PadRight($width) + "|" -ForegroundColor $optionColor
    Write-Host "| 2 - Comprobar ultima version del mod".PadRight($width) + "|" -ForegroundColor $optionColor
    Write-Host "| 3 - Actualizar traduccion".PadRight($width) + "|" -ForegroundColor $optionColor
    Write-Host "| 4 - Usa mi codigo referral para tu cuenta :-P".PadRight($width) + "|" -ForegroundColor $optionColor
    Write-Host "| 5 - Salir".PadRight($width) + "|" -ForegroundColor $optionColor
    Write-Host "+" + ("-" * ($width)) + "+" -ForegroundColor $shadowColor
}

# ----------------------------------------------------------
# Funciones de opciones
# ----------------------------------------------------------
function Change-SCPATH {
	Clear-Host
    $newPath = Read-Host "Introduce la ruta donde esta instalado Star Citizen (por ejemplo 'D:\RSI\StarCitizen' )"
    if (!(Test-Path $newPath)) {
		Clear-Host
        Write-Host "La ruta no existe. Intentalo de nuevo." -ForegroundColor Red
		Write-Host ""
		Start-Sleep -seconds 4
		return
    }
    $global:SCPATH = $newPath
    Save-Config
	Clear-Host
    Write-Host "Ruta de Instalacion de STAR CITIZEN actualizada correctamente." -ForegroundColor Green
	Start-Sleep -Seconds 2
}

function Check-LatestModVersion {
    $latest = Get-LatestModVersion
	Clear-Host
    Write-Host "Ultima version encontrada: $latest" -ForegroundColor Cyan
	Start-Sleep -Seconds 2
}

function Referral {
	Clear-Host
    Write-Host "Abriendo Navegador" -ForegroundColor Cyan
	Start-Sleep -Seconds 2
	Start-Process "https://www.robertsspaceindustries.com/enlist?referral=STAR-M95W-FZB2"
}

function Update-Mod {
    if (!$SCPATH -or !(Test-Path $SCPATH)) {
		Clear-Host
        Write-Host "La carpeta de instalacion de Star Citizen no esta definida o no existe." -ForegroundColor Red
		Start-Sleep -Seconds 4
        return
    }

    $url = "https://api.github.com/repos/Thord82/Star_citizen_ES/releases/latest"
    try {
        $release = Invoke-RestMethod -Uri $url -Headers @{ "User-Agent" = "PowerShell" }
        $tag = $release.tag_name
        $asset = $release.assets | Select-Object -First 1

        $downloadUrl = $asset.browser_download_url
        $fileName = $asset.name
        $tempZip = ".\$fileName"

        Clear-Host
        Write-Host "Descargando $fileName…" -ForegroundColor Cyan
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tempZip

        Clear-Host
        Write-Host "Extrayendo en $SCPATH…" -ForegroundColor Cyan
        Expand-Archive -Path $tempZip -DestinationPath $SCPATH -Force

        Remove-Item $tempZip -Force
        
		Clear-Host
        Write-Host "Traduccion actualizada correctamente." -ForegroundColor Green
        $global:ModIns = $tag
        Save-Config
		Start-Sleep -seconds 4
    }
    catch {
		Clear-Host
        Write-Host "ERROR descargando o extrayendo el mod." -ForegroundColor Red
		Start-Sleep -seconds 4
    }
}

# ----------------------------------------------------------
# Bucle principal
# ----------------------------------------------------------
Load-Config

while ($true) {
    Show-Menu
    $opt = Read-Host "Elige una opcion"

    switch ($opt) {
        "1" { Change-SCPATH }
        "2" { Check-LatestModVersion }
        "3" { Update-Mod }
		"4" { Referral }
        "5" { exit }
        default { Write-Host "Opcion invalida." -ForegroundColor Red; Start-Sleep 2 }
    }
}

