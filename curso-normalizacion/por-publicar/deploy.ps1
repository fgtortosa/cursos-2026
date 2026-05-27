# Deploy script para el sitio independiente del curso de normalizacion.
# Genera la documentacion VitePress y la copia a la carpeta compartida P:\curso-normalizacion
# que IIS sirve en https://preproddesa.campus.ua.es/curso-normalizacion/

param(
    [switch]$SkipBuild = $false,
    [string]$DestinationPath = "P:\curso-normalizacion",
    [switch]$Preview = $false
)

$ErrorActionPreference = "Stop"

$ErrorColor = "Red"
$SuccessColor = "Green"
$InfoColor = "Cyan"
$WarningColor = "Yellow"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "========================================================" -ForegroundColor $InfoColor
Write-Host "  Curso Normalizacion - Deploy independiente" -ForegroundColor $InfoColor
Write-Host "========================================================" -ForegroundColor $InfoColor
Write-Host ""

$ProjectPath = $PSScriptRoot
$DistPath = Join-Path $ProjectPath ".vitepress\dist"
$WebConfigSource = Join-Path $ProjectPath "web.config"

Write-Host "Configuracion:" -ForegroundColor $InfoColor
Write-Host "  Proyecto: $ProjectPath"
Write-Host "  Output:   $DistPath"
Write-Host "  Destino:  $DestinationPath"
Write-Host "  URL IIS:  https://preproddesa.campus.ua.es/curso-normalizacion/"
Write-Host ""
Write-Host "Nota: el sidebar lo construye .vitepress/sidebar.mts en build, leyendo" -ForegroundColor $InfoColor
Write-Host "      _sidebar.json + los frontmatter title de cada index.md." -ForegroundColor $InfoColor
Write-Host ""

# Crear destino si no existe
if (-not (Test-Path $DestinationPath)) {
    Write-Host "La carpeta destino no existe: $DestinationPath" -ForegroundColor $WarningColor
    Write-Host "Se intentara crear..." -ForegroundColor $InfoColor
    try {
        New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
        Write-Host "Carpeta creada correctamente" -ForegroundColor $SuccessColor
    }
    catch {
        Write-Host "Error al crear la carpeta: $_" -ForegroundColor $ErrorColor
        exit 1
    }
}

# Paso 1: Build
if (-not $SkipBuild) {
    Write-Host "Paso 1: Generando documentacion..." -ForegroundColor $InfoColor
    Write-Host "----------------------------------------------------" -ForegroundColor $InfoColor

    Push-Location $ProjectPath
    try {
        if (Get-Command pnpm -ErrorAction SilentlyContinue) {
            Write-Host "Usando pnpm..." -ForegroundColor $InfoColor
            pnpm run docs:build
        }
        elseif (Get-Command npm -ErrorAction SilentlyContinue) {
            Write-Host "Usando npm..." -ForegroundColor $InfoColor
            npm run docs:build
        }
        else {
            throw "No se encontro pnpm ni npm."
        }

        if ($LASTEXITCODE -ne 0) {
            throw "El build ha fallado con codigo $LASTEXITCODE."
        }

        Write-Host "Build completado exitosamente" -ForegroundColor $SuccessColor
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor $ErrorColor
        Pop-Location
        exit 1
    }
    finally {
        Pop-Location
    }
}
else {
    Write-Host "Paso 1: Saltando build (--SkipBuild)" -ForegroundColor $WarningColor
}

Write-Host ""

# Paso 2: Verificar dist
Write-Host "Paso 2: Verificando archivos generados..." -ForegroundColor $InfoColor
Write-Host "----------------------------------------------------" -ForegroundColor $InfoColor

if (-not (Test-Path $DistPath)) {
    Write-Host "No se encontro la carpeta dist: $DistPath" -ForegroundColor $ErrorColor
    exit 1
}

$FileCount = @(Get-ChildItem -Path $DistPath -Recurse -File).Count
Write-Host "  Encontrados $FileCount archivos en dist/" -ForegroundColor $SuccessColor

Write-Host ""

# Paso 3: Sincronizar a P:\ con robocopy
Write-Host "Paso 3: Copiando archivos a $DestinationPath..." -ForegroundColor $InfoColor
Write-Host "----------------------------------------------------" -ForegroundColor $InfoColor

try {
    # /MIR espeja el origen
    # /R:2 /W:2 reintentos breves para bloqueos SMB
    # /NFL /NDL /NP /NJH /NJS salida limpia
    # /XF web.config -> NO borra el web.config existente en P:\ si difiere (lo gestionamos abajo)
    Write-Host "  Sincronizando con robocopy..." -ForegroundColor $InfoColor
    & robocopy $DistPath $DestinationPath /MIR /R:2 /W:2 /NFL /NDL /NP /NJH /NJS /XF "web.config" | Out-Null
    $robocopyExit = $LASTEXITCODE

    # robocopy: 0..7 = exito (con o sin cambios). 8+ = fallo real.
    if ($robocopyExit -ge 8) {
        throw "robocopy fallo con codigo $robocopyExit"
    }

    # Copiar el web.config si existe en el proyecto (sobreescribe siempre la version desplegada).
    if (Test-Path $WebConfigSource) {
        Copy-Item -Path $WebConfigSource -Destination (Join-Path $DestinationPath "web.config") -Force
        Write-Host "  web.config publicado en destino" -ForegroundColor $SuccessColor
    }
    else {
        Write-Host "  No hay web.config en el proyecto (se respeta el del destino, si existe)" -ForegroundColor $WarningColor
    }

    $FilesAfterCopy = @(Get-ChildItem -Path $DestinationPath -Recurse -File).Count
    Write-Host "  Copia completada: $FilesAfterCopy archivos (robocopy exit=$robocopyExit)" -ForegroundColor $SuccessColor
}
catch {
    Write-Host "Error durante la copia: $_" -ForegroundColor $ErrorColor
    exit 1
}

Write-Host ""

# Paso 4: Verificacion final
Write-Host "Paso 4: Verificacion final..." -ForegroundColor $InfoColor
Write-Host "----------------------------------------------------" -ForegroundColor $InfoColor

if (Test-Path (Join-Path $DestinationPath "index.html")) {
    Write-Host "  index.html encontrado" -ForegroundColor $SuccessColor
}
else {
    Write-Host "  [!] index.html no encontrado" -ForegroundColor $WarningColor
}

if (Test-Path (Join-Path $DestinationPath "web.config")) {
    Write-Host "  web.config presente en IIS" -ForegroundColor $SuccessColor
}
else {
    Write-Host "  [!] web.config NO presente: las rutas internas pueden dar 404 al refrescar" -ForegroundColor $WarningColor
}

Write-Host ""
Write-Host "========================================================" -ForegroundColor $SuccessColor
Write-Host "  [OK] Curso desplegado correctamente" -ForegroundColor $SuccessColor
Write-Host "  URL: https://preproddesa.campus.ua.es/curso-normalizacion/" -ForegroundColor $SuccessColor
Write-Host "========================================================" -ForegroundColor $SuccessColor

if ($Preview) {
    Write-Host ""
    Write-Host "Abriendo carpeta de destino..." -ForegroundColor $InfoColor
    explorer.exe $DestinationPath
}

exit 0
