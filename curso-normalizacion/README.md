# ✅ Checklist Rápido - Estado del Proyecto

## 🚀 Ejecutar VitePress tras clonar el repositorio

### Requisitos previos

- Tener instalado `Node.js`
- Tener disponible `pnpm`

Si `pnpm` no está instalado, puedes activarlo con Corepack:

```bash
corepack enable
corepack prepare pnpm@10.22.0 --activate
```

### Puesta en marcha

1. Clona el repositorio y entra en la carpeta del proyecto.
2. Instala las dependencias:

```bash
pnpm install
```

3. Arranca la documentación en local:

```bash
pnpm run docs:dev
```

Este comando regenera la sidebar automáticamente y lanza VitePress en modo desarrollo.

Abre en el navegador la URL que muestre la consola. Con la configuración actual normalmente será:

```text
http://localhost:5173/curso-normalizacion/
```

### Comandos útiles

```bash
pnpm run docs:dev
pnpm run docs:build
pnpm run docs:preview
```

- `docs:dev`: desarrollo local con recarga automática
- `docs:build`: genera la versión estática en `.vitepress/dist`
- `docs:preview`: sirve localmente la build generada

---

## 🎯 Tu Proyecto VitePress Está Listo

### ✨ Ya Funciona (Sin Instalar Nada Extra)

| Característica         | Cómo Usar                            | Estado         |
| ---------------------- | ------------------------------------ | -------------- |
| **Búsqueda**           | `Ctrl+K` en el navegador             | ✅ Funcionando |
| **Code Groups**        | `::: code-group` en Markdown         | ✅ Funcionando |
| **Sintaxis coloreada** | Automático con backticks             | ✅ Funcionando |
| **Números de línea**   | `:line-numbers` después del lenguaje | ✅ Funcionando |
| **Contenedores**       | `::: info`, `::: tip`, `::: warning` | ✅ Funcionando |
| **Tablas**             | `\| Columna \|` Markdown             | ✅ Funcionando |
| **Emoji**              | `:tada:` `:100:`                     | ✅ Funcionando |

---

## 🚀 Para Empezar Ahora Mismo

### 1. Desarrollo Local

```bash
pnpm run docs:dev
```

Abre `http://localhost:5173/curso-normalizacion/` en tu navegador

### 2. Publicar en P:\cursos-aplicaciones\curso-normalizacion

```bash
pnpm run docs:deploy
```

O con preview automático:

```bash
pnpm run docs:deploy-preview
```

El curso mantiene su base publica como `/curso-normalizacion/`. El destino usa una subcarpeta propia para poder publicar otros cursos junto a este dentro de `P:\cursos-aplicaciones`.

---

## 📝 Ejemplos Inmediatos

### Code Groups (Pestañas)

Usa esto ahora mismo en cualquier documento:

````markdown
::: code-group

```csharp [C#]
var result = await db.ExecuteAsync("SELECT * FROM usuarios");
```
````

```vue [Vue.js]
const usuarios = ref([])
```

```sql [SQL]
SELECT * FROM usuarios;
```

:::

````

### Contenedores

```markdown
::: tip
Este es un consejo útil
:::

::: warning
Esto es una advertencia
:::

::: details Click para expandir
Contenido oculto
:::
````

### Sintaxis Destacada

````markdown
```typescript{1,3-4}
const x = 1
const y = 2  // Esta línea está resaltada
const z = 3  // Esta también
```
````

```

---

## 📦 Archivos de Documentación

| Archivo | Propósito |
|---------|-----------|
| [PLUGINS.md](./PLUGINS.md) | Características de VitePress y qué instalar |
| [DEPLOY.md](./DEPLOY.md) | Cómo hacer build y publicar |
| [EJEMPLOS-MARKDOWN.md](./EJEMPLOS-MARKDOWN.md) | Ejemplos de código para documentar |

---

## 🎓 Estructura de Carpetas

```

proyecto/
├── index.md ✅ Home actualizado
├── PLUGINS.md ✅ Características
├── DEPLOY.md ✅ Build & Deploy
├── EJEMPLOS-MARKDOWN.md ✅ Ejemplos prácticos
├── package.json ✅ Scripts actualizados
├── deploy.ps1 ✅ Script PowerShell
├── deploy.bat ✅ Script Batch
├── .vitepress/
│ └── config.mts ✅ Configuración actualizada
├── cursos/ ✅ Estructura creada
│ ├── index.md
│ └── 2026/
│ ├── index.md
│ └── curso-normalizacion/
│ ├── index.md
│ └── vue/
│ └── index.md
└── herramientas/ ✅ Renombrado (era documentacion/)
├── index.md
├── nugets/
├── componentes-vue/
└── plantillas-ua/

````

---

## 🔧 Próximos Pasos (Opcionales)

Si quieres añadir más funcionalidades:

1. **Mermaid (Diagramas)**
   ```bash
   pnpm add -D markdown-it-mathjax3
````

Ver detalles en PLUGINS.md

2. **Matemáticas (Ecuaciones LaTeX)**

   ```bash
   pnpm add -D markdown-it-mathjax3
   ```

3. **Algolia Search (búsqueda avanzada en la nube)**
   - Solo si necesitas búsqueda en múltiples idiomas o análisis

---

## 🆘 Ayuda Rápida

### Mi sitio no abre en http://localhost:5173/curso-normalizacion/

```bash
# Instala dependencias
pnpm install

# Luego intenta de nuevo
pnpm run docs:dev
```

### El deploy no funciona

```bash
# Verifica permisos en P:\cursos-aplicaciones\curso-normalizacion
# O ejecuta como administrador:

pnpm run docs:deploy
```

### No veo cambios después de editar

- El navegador tiene caché: `Ctrl+Shift+R` (reload sin caché)
- El servidor se detuvo: Reinicia `pnpm run docs:dev`

---

## 🎉 ¡Listo Para Usar!

Tu documentación está configurada y lista:

✅ Estructura de carpetas organizada  
✅ Navegación jerárquica  
✅ Búsqueda integrada  
✅ Sintaxis destacada  
✅ Code groups para múltiples lenguajes  
✅ Scripts de build y deploy

**Ahora solo necesitas:**

1. 📝 Escribir contenido en Markdown
2. 🔍 Revisar con `pnpm run docs:dev`
3. 🚀 Publicar con `pnpm run docs:deploy`

---

## 📞 Contacto y Referencias

- [Documentación oficial VitePress](https://vitepress.dev/)
- [Guía de Markdown en VitePress](https://vitepress.dev/guide/markdown)
- [Referencia de Configuración](https://vitepress.dev/reference/site-config)
