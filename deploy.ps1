# Deploy script para los cursos de aplicaciones
# Genera la documentación y la copia a P:\cursos-aplicaciones

param(
    [switch]$SkipBuild = $false,
    [string]$DestinationPath = "P:\cursos-aplicaciones",
    [switch]$Preview = $false
)

# Colores para output
$ErrorColor = "Red"
$SuccessColor = "Green"
$InfoColor = "Cyan"
$WarningColor = "Yellow"

# Asegurar salida en UTF-8 para que se vean bien acentos
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Assert-SafeDestination {
    param([Parameter(Mandatory = $true)][string]$PathValue)

    $fullPath = [System.IO.Path]::GetFullPath($PathValue)
    $rootPath = [System.IO.Path]::GetPathRoot($fullPath)

    if ($fullPath.TrimEnd('\', '/') -eq $rootPath.TrimEnd('\', '/')) {
        throw "No se permite limpiar la raiz de una unidad: $fullPath"
    }

    return $fullPath
}

Write-Host "========================================================" -ForegroundColor $InfoColor
Write-Host "  VitePress Courses Deploy Script" -ForegroundColor $InfoColor
Write-Host "========================================================" -ForegroundColor $InfoColor
Write-Host ""

# Obtener ruta del script (directorio del proyecto)
$ProjectPath = $PSScriptRoot
$DistPath = Join-Path $ProjectPath ".vitepress\dist"
$DestinationFullPath = Assert-SafeDestination -PathValue $DestinationPath

Write-Host "Configuración:" -ForegroundColor $InfoColor
Write-Host "Proyecto: $ProjectPath"
Write-Host "Output: $DistPath"
Write-Host "Destino: $DestinationFullPath"
Write-Host ""

# Verificar si la carpeta destino existe
if (-not (Test-Path -LiteralPath $DestinationFullPath)) {
    Write-Host "La carpeta destino no existe: $DestinationFullPath" -ForegroundColor $WarningColor
    Write-Host "Se intentará crear..." -ForegroundColor $InfoColor
    try {
        New-Item -ItemType Directory -Path $DestinationFullPath -Force | Out-Null
        Write-Host "Carpeta creada correctamente" -ForegroundColor $SuccessColor
    }
    catch {
        Write-Host "Error al crear la carpeta: $_" -ForegroundColor $ErrorColor
        exit 1
    }
}

# Step 1: Build (si no se salta)
if (-not $SkipBuild) {
    Write-Host "Paso 1: Generando documentación..." -ForegroundColor $InfoColor
    Write-Host "----------------------------------------------------" -ForegroundColor $InfoColor
    
    # Cambiar al directorio del proyecto
    Push-Location $ProjectPath
    
    try {
        # Intentar con pnpm primero (es lo que usa)
        if (Get-Command pnpm -ErrorAction SilentlyContinue) {
            Write-Host "Usando pnpm..." -ForegroundColor $InfoColor
            pnpm run docs:build
        }
        # Si no está pnpm, intentar con npm
        elseif (Get-Command npm -ErrorAction SilentlyContinue) {
            Write-Host "Usando npm..." -ForegroundColor $InfoColor
            npm run docs:build
        }
        else {
            Write-Host "No se encontró pnpm ni npm" -ForegroundColor $ErrorColor
            Pop-Location
            exit 1
        }
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Error durante el build" -ForegroundColor $ErrorColor
            Pop-Location
            exit 1
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
    Write-Host 'Paso 1: Saltando build (--SkipBuild)' -ForegroundColor $WarningColor
}

Write-Host ""

# Step 2: Verificar que existe la carpeta dist
Write-Host "Paso 2: Verificando archivos generados..." -ForegroundColor $InfoColor
Write-Host "----------------------------------------------------" -ForegroundColor $InfoColor

if (-not (Test-Path $DistPath)) {
    Write-Host " No se encontró la carpeta dist: $DistPath" -ForegroundColor $ErrorColor
    exit 1
}

$FileCount = @(Get-ChildItem -Path $DistPath -Recurse -File).Count
Write-Host "  Encontrados $FileCount archivos en dist/" -ForegroundColor $SuccessColor

Write-Host ""

# Step 3: Limpiar destino y copiar
Write-Host "Paso 3: Copiando archivos a carpeta compartida..." -ForegroundColor $InfoColor
Write-Host "----------------------------------------------------" -ForegroundColor $InfoColor

try {
    Write-Host "  Limpiando destino..." -ForegroundColor $InfoColor
    # Eliminar todo en el destino excepto carpetas del sistema
    Get-ChildItem -LiteralPath $DestinationFullPath -Force |
        Where-Object { -not ($_.Attributes -band [System.IO.FileAttributes]::System) } |
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-Host "  Copiando nuevos archivos..." -ForegroundColor $InfoColor
    Copy-Item -Path "$DistPath\*" -Destination $DestinationFullPath -Recurse -Force -ErrorAction Stop
    
    $FilesAfterCopy = @(Get-ChildItem -LiteralPath $DestinationFullPath -Recurse -File).Count
    Write-Host "  Copia completada: $FilesAfterCopy archivos" -ForegroundColor $SuccessColor
}
catch {
    Write-Host "Error durante la copia: $_" -ForegroundColor $ErrorColor
    exit 1
}

Write-Host ""

# Step 4: Verificación final
Write-Host "Paso 4: Verificación final..." -ForegroundColor $InfoColor
Write-Host "----------------------------------------------------" -ForegroundColor $InfoColor

if (Test-Path -LiteralPath (Join-Path $DestinationFullPath "index.html")) {
    Write-Host "  index.html encontrado" -ForegroundColor $SuccessColor
}
else {
    Write-Host "  [!] index.html no encontrado" -ForegroundColor $WarningColor
}

Write-Host ""
Write-Host "========================================================" -ForegroundColor $SuccessColor
Write-Host "  [OK] Deployado correctamente" -ForegroundColor $SuccessColor
Write-Host "========================================================" -ForegroundColor $SuccessColor

# Step 5: Vista previa opcional
if ($Preview) {
    Write-Host ""
    Write-Host 'Abriendo carpeta de destino...' -ForegroundColor $InfoColor
    explorer.exe $DestinationFullPath
}

exit 0
