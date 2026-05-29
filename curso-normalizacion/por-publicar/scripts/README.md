# Generación del ePub del curso

Convierte el contenido VitePress (`.md`) en un único fichero `.epub` para leer en tablet o e-reader.

## Requisitos

| Herramienta              | Para qué                                | Cómo instalar                                                |
| ------------------------ | --------------------------------------- | ------------------------------------------------------------ |
| **pandoc** (obligatorio) | Convierte el Markdown final a ePub      | <https://pandoc.org/installing.html> · `winget install JohnMacFarlane.Pandoc` |
| **mmdc** (opcional)      | Pre-renderiza los diagramas mermaid SVG | `pnpm add -g @mermaid-js/mermaid-cli`                        |

Sin `mmdc` los diagramas mermaid se incluyen como bloque de código (legibles pero no visuales). Con él se incrustan como SVG.

## Uso básico

Desde la raíz `por-publicar/`:

```powershell
pwsh ./scripts/build-epub.ps1
```

Genera `curso-normalizacion-2026.epub` en el directorio actual.

## Opciones

```powershell
pwsh ./scripts/build-epub.ps1 `
    -OutputFile  "curso-2026.epub" `         # nombre de salida
    -Title       "Mi título" `
    -Author      "Mi nombre" `
    -NoMermaid `                              # saltar pre-renderizado (más rápido)
    -KeepTemp                                 # conservar .tmp-epub/ para inspección
```

## Qué hace el script

1. **Recorre los bloques** `00-preparacion` → `06-proyecto-final` en orden, en cada uno coge todos los `.md` ordenados alfabéticamente (los nombres `sesion-09…sesion-25` ya están bien numerados). Excluye `test/`, `node_modules/`, `.vitepress/`, `public/`.
2. **Limpia cada `.md`** quitando frontmatter YAML, `<!-- [[toc]] -->`, bloques `<!-- NAV:START/END -->`, anclas `{#id}` de cabeceras y `<code v-pre>…</code>`.
3. **Renderiza los `mermaid`** a SVG con `mmdc`. Cachea por hash SHA1 del contenido, así reejecutar es rápido.
4. **Convierte los bloques de VitePress** (`::: tip`, `::: info`, `::: warning`, `::: danger`, `::: details`, `::: code`) a blockquotes Markdown con icono + título en negrita. Los lee bien cualquier reader sin CSS extra.
5. **Llama a pandoc** con `--toc --toc-depth=3 --split-level=1` y produce `epub3`.

## Inspección y depuración

- Carpeta intermedia: `.tmp-epub/` en la raíz del proyecto (eliminada al terminar, salvo `-KeepTemp`).
- Si un diagrama mermaid no se renderiza, el script avisa con `WARNING: No se pudo renderizar un mermaid (hash …)` y deja ese bloque como código. Mira el `.mmd` correspondiente en `.tmp-epub/assets/` para diagnosticarlo.
- Para ver el ePub: Calibre, Kindle (envío por correo), Apple Books, KOReader (e-ink), o cualquier lector ePub en móvil.

## Limitaciones conocidas

- **Imágenes locales** (por ejemplo `lola.jpg` en `public/`) no se incrustan en esta versión: pandoc solo encuentra los SVG de `mmd-…` en la carpeta de assets. Si las necesitas, copia el contenido de `public/` a `.tmp-epub/assets/` antes de pandoc.
- **Diagramas `svgbob`** (4 en todo el curso) se incluyen tal cual como bloque de código. Renderiza con la web `https://svgbob.com/` y sustituye manualmente si quieres mejorarlos.
- **Enlaces internos** entre páginas (`../../03-vue/sesiones/…`) no funcionan en el ePub porque el split es por capítulos. Los textos se ven, pero no son navegables.
- **Detalles colapsables** (`::: details`) se renderizan como blockquote normal (todo visible). El comportamiento desplegable no existe en el formato ePub.
