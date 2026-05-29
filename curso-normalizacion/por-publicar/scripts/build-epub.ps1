# =============================================================================
#  build-epub.ps1
#  Genera un fichero EPUB a partir del contenido VitePress del curso.
#
#  Uso:
#    pwsh ./scripts/build-epub.ps1                     # parámetros por defecto
#    pwsh ./scripts/build-epub.ps1 -NoMermaid          # sin pre-renderizar diagramas
#    pwsh ./scripts/build-epub.ps1 -KeepTemp           # conservar carpeta intermedia
#    pwsh ./scripts/build-epub.ps1 -OutputFile out.epub
#
#  Requisitos:
#    - pandoc            https://pandoc.org/installing.html
#    - mmdc (opcional)   pnpm add -g @mermaid-js/mermaid-cli
# =============================================================================

[CmdletBinding()]
param(
    [string]$OutputFile = "curso-normalizacion-2026.epub",
    [string]$Title = "Curso de Normalización de Aplicaciones 2026",
    [string]$Author = "Paco García Tortosa",
    [string]$Lang = "es",
    [switch]$NoMermaid,
    [switch]$KeepTemp
)

$ErrorActionPreference = 'Stop'

# --- Resolver raíz del proyecto -------------------------------------------------
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Write-Host "[build-epub] Proyecto: $ProjectRoot" -ForegroundColor Cyan

# --- Comprobar prerequisitos ---------------------------------------------------
if (-not (Get-Command pandoc -ErrorAction SilentlyContinue)) {
    Write-Error "pandoc no está instalado. Descárgalo de https://pandoc.org/installing.html y vuelve a ejecutar."
}

$script:HasMmdc = $false
if (-not $NoMermaid) {
    if (Get-Command mmdc -ErrorAction SilentlyContinue) {
        $script:HasMmdc = $true
        Write-Host "[build-epub] mmdc detectado — los diagramas mermaid se renderizarán a SVG" -ForegroundColor Cyan
    }
    else {
        Write-Warning "mmdc no encontrado. Los diagramas mermaid quedarán como bloque de código."
        Write-Warning "Para renderizarlos como imagen: pnpm add -g @mermaid-js/mermaid-cli"
    }
}

# --- Orden de los bloques ------------------------------------------------------
$Blocks = @(
    '00-preparacion',
    '01-oracle',
    '02-dotnet',
    '03-vue',
    '04-integracion',
    '05-avanzadas',
    '06-proyecto-final'
)

# Carpetas a IGNORAR (no se incluyen en el ePub)
$ExcludePatterns = @('node_modules', '.vitepress', '.tmp', 'public', 'test')

# --- Preparar carpeta intermedia ----------------------------------------------
$TmpDir = Join-Path $ProjectRoot '.tmp-epub'
if (Test-Path $TmpDir) { Remove-Item $TmpDir -Recurse -Force }
New-Item -ItemType Directory -Path $TmpDir | Out-Null
$AssetsDir = Join-Path $TmpDir 'assets'
New-Item -ItemType Directory -Path $AssetsDir | Out-Null
$script:AssetsDir = $AssetsDir

# --- Mapas para los bloques ::: tip / info / warning / danger / details -------
$AdmonitionLabels = @{
    'tip'     = "💡 Consejo"
    'info'    = "ℹ Información"
    'warning' = "⚠ Atención"
    'danger'  = "🚫 Peligro"
    'details' = "▸ Detalle"
    'note'    = "📝 Nota"
}

# =============================================================================
#  Funciones de transformación
# =============================================================================

function Remove-VitePressArtifacts {
    param([string]$Text)

    # Frontmatter YAML
    $Text = [regex]::Replace(
        $Text,
        '\A---\r?\n.*?\r?\n---\r?\n',
        '',
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    # <!-- [[toc]] -->
    $Text = [regex]::Replace($Text, '(?m)^<!--\s*\[\[toc\]\]\s*-->\s*$', '')

    # <!-- NAV:START -->...<!-- NAV:END -->
    $Text = [regex]::Replace(
        $Text,
        '<!-- NAV:START -->.*?<!-- NAV:END -->',
        '',
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    # <!-- diagram id="…" caption: "…" -->
    $Text = [regex]::Replace($Text, '(?m)^<!--\s*diagram\s+id=.*?-->\s*$', '')

    # Anclas {#mi-id} al final de las cabeceras → eliminar (epub no las necesita)
    $Text = [regex]::Replace($Text, '(?m)^(#{1,6}\s+.+?)\s+\{#[^}]+\}\s*$', '$1')

    # <code v-pre>X</code> → `X`
    $Text = [regex]::Replace(
        $Text,
        '<code v-pre>(.*?)</code>',
        { '`' + $args[0].Groups[1].Value + '`' },
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    return $Text
}

function Convert-Admonitions {
    # Convierte los bloques `::: tipo TÍTULO ... :::` de VitePress en
    # blockquotes Markdown estándar para que pandoc los renderice en epub
    # con un formato consistente (icono + título en negrita).
    param([string]$Text)

    $lines = $Text -split "`r?`n"
    $output = New-Object System.Collections.Generic.List[string]
    $inBlock = $false
    $skipBlock = $false

    foreach ($line in $lines) {
        if (-not $inBlock -and $line -match '^:::\s*([a-zA-Z]+)(?:\s+(.+?))?\s*$') {
            $kind = $matches[1].ToLowerInvariant()
            $userTitle = if ($matches.Count -gt 2) { $matches[2] } else { $null }

            # ::: code (CodeGroup de VitePress) — desenvuelvo, no genero blockquote
            if ($kind -eq 'code') {
                $skipBlock = $true
                $inBlock = $true
                continue
            }

            $defaultLabel = $AdmonitionLabels[$kind]
            if (-not $defaultLabel) { $defaultLabel = "▸ $kind" }

            $title = if ($userTitle) { "$defaultLabel — $userTitle" } else { $defaultLabel }

            $output.Add("")
            $output.Add("> **$title**")
            $output.Add(">")
            $inBlock = $true
            $skipBlock = $false
            continue
        }

        if ($inBlock -and $line -match '^:::\s*$') {
            $inBlock = $false
            if (-not $skipBlock) { $output.Add("") }
            $skipBlock = $false
            continue
        }

        if ($inBlock -and -not $skipBlock) {
            if ($line.Trim() -eq '') {
                $output.Add(">")
            }
            else {
                $output.Add("> $line")
            }
            continue
        }

        $output.Add($line)
    }

    return ($output -join "`n")
}

function Convert-Mermaid {
    # Encuentra cada bloque ```mermaid…``` y lo renderiza a SVG con mmdc.
    # Cacheado por hash SHA1 del contenido → re-ejecuciones rápidas.
    param([string]$Text)

    if (-not $script:HasMmdc) { return $Text }

    $pattern = '(?ms)^```mermaid\r?\n(.*?)\r?\n```\s*$'
    return [regex]::Replace($Text, $pattern, {
            param($m)
            $body = $m.Groups[1].Value
            $sha = [System.Security.Cryptography.SHA1]::Create()
            try {
                $hashBytes = $sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($body))
                $hash = ([System.BitConverter]::ToString($hashBytes) -replace '-', '').Substring(0, 10).ToLowerInvariant()
            }
            finally { $sha.Dispose() }

            $svgName = "mmd-$hash.svg"
            $svgPath = Join-Path $script:AssetsDir $svgName

            if (-not (Test-Path $svgPath)) {
                $mmdPath = Join-Path $script:AssetsDir "mmd-$hash.mmd"
                Set-Content -Path $mmdPath -Value $body -Encoding utf8
                # mmdc imprime mucha cosa en stderr aunque haya éxito; descartar stdout/stderr
                & mmdc -i $mmdPath -o $svgPath -b transparent *>$null
                Remove-Item $mmdPath -ErrorAction SilentlyContinue
            }

            if (Test-Path $svgPath) {
                return "`n![Diagrama]($svgName)`n"
            }
            else {
                # El renderizado falló — dejar el bloque como código
                Write-Warning "  No se pudo renderizar un mermaid (hash $hash); se incluye como código"
                return $m.Value
            }
        })
}

# =============================================================================
#  Descubrir ficheros .md a procesar
# =============================================================================

function Get-MarkdownFiles {
    $files = @()

    # index.md raíz (portada)
    $rootIndex = Join-Path $ProjectRoot 'index.md'
    if (Test-Path $rootIndex) { $files += $rootIndex }

    foreach ($block in $Blocks) {
        $blockPath = Join-Path $ProjectRoot $block
        if (-not (Test-Path $blockPath)) { continue }

        $blockFiles = Get-ChildItem -Path $blockPath -Recurse -Filter '*.md' | Where-Object {
            $relPath = $_.FullName.Substring($ProjectRoot.Length + 1).Replace('\', '/')
            $excluded = $false
            foreach ($pat in $ExcludePatterns) {
                if ($relPath -match "(^|/)$([regex]::Escape($pat))(/|$)") {
                    $excluded = $true
                    break
                }
            }
            -not $excluded
        } | Sort-Object FullName

        $files += $blockFiles.FullName
    }
    return $files
}

# =============================================================================
#  Pipeline principal
# =============================================================================

$allMd = Get-MarkdownFiles
if ($allMd.Count -eq 0) {
    Write-Error "No se encontró ningún fichero .md."
}
Write-Host "[build-epub] $($allMd.Count) ficheros markdown a procesar" -ForegroundColor Cyan

$processedFiles = New-Object System.Collections.Generic.List[string]
$idx = 0
foreach ($mdPath in $allMd) {
    $idx++
    $rel = $mdPath.Substring($ProjectRoot.Length + 1)
    Write-Host ("  [{0,3}/{1,3}] {2}" -f $idx, $allMd.Count, $rel)

    $content = Get-Content $mdPath -Raw -Encoding utf8
    $content = Remove-VitePressArtifacts $content
    $content = Convert-Mermaid $content
    $content = Convert-Admonitions $content

    # Nombre plano único por fichero → coloca todos los .md en la raíz de tmp
    $flat = $rel.Replace('\', '_').Replace('/', '_')
    $outPath = Join-Path $TmpDir $flat
    Set-Content -Path $outPath -Value $content -Encoding utf8
    $processedFiles.Add($outPath)
}

# =============================================================================
#  Llamar a pandoc
# =============================================================================

$pandocArgs = @(
    '--from', 'gfm+fenced_divs+pipe_tables+attributes+task_lists',
    '--to', 'epub3',
    '--toc',
    '--toc-depth=3',
    '--split-level=1',
    '--metadata', "title=$Title",
    '--metadata', "author=$Author",
    '--metadata', "lang=$Lang",
    '--resource-path', $AssetsDir,
    '-o', $OutputFile
)
$pandocArgs += $processedFiles

Write-Host "[build-epub] Llamando a pandoc..." -ForegroundColor Cyan
& pandoc @pandocArgs
if ($LASTEXITCODE -ne 0) {
    Write-Error "pandoc terminó con código $LASTEXITCODE"
}

# =============================================================================
#  Limpieza
# =============================================================================

if (-not $KeepTemp) {
    Remove-Item $TmpDir -Recurse -Force
}
else {
    Write-Host "[build-epub] Carpeta intermedia preservada: $TmpDir" -ForegroundColor Yellow
}

$outFull = (Resolve-Path $OutputFile).Path
Write-Host ""
Write-Host "✓ ePub generado: $outFull" -ForegroundColor Green
$size = [math]::Round((Get-Item $outFull).Length / 1MB, 2)
Write-Host "  Tamaño: $size MB" -ForegroundColor DarkGray
