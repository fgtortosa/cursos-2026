---
title: Guía de organización del repositorio
description: Flujo de ramas y trabajo interno para el profesorado del curso
outline: [2, 2]
search: false
---

# Guía de organización del repositorio

## Índice

1. [Modelo de Ramas](#1-modelo-de-ramas)
2. [Guía Git para Estudiantes](#2-guía-git-para-estudiantes)
3. [Flujo de Trabajo para Profesores](#3-flujo-de-trabajo-para-profesores)
4. [Estructura de Carpetas](#4-estructura-de-carpetas)
5. [Resolución de Problemas](#5-resolución-de-problemas)

---

## 1. Modelo de Ramas

### 1.1 Visión General

```
                    ┌─────────────────────────────────────────────────────┐
                    │                      master                         │
                    │              (base estable del proyecto)            │
                    └─────────────────────────┬───────────────────────────┘
                                              │
              ┌───────────────────────────────┼───────────────────────────────┐
              │                               │                               │
              ▼                               ▼                               ▼
    ┌─────────────────┐             ┌─────────────────┐             ┌─────────────────┐
    │ contenido/oracle│             │ contenido/dotnet│             │  contenido/vue  │
    │   (Prof. Oracle)│             │  (Prof. .NET)   │             │   (Prof. Vue)   │
    └────────┬────────┘             └────────┬────────┘             └────────┬────────┘
             │                               │                               │
             └───────────────────────────────┼───────────────────────────────┘
                                             │
                                             ▼
    ┌─────────────────────────────────────────────────────────────────────────────────┐
    │                            curso/semana-X                                        │
    │                    (integración de contenido por semana)                         │
    └─────────────────────────────────────────────────────────────────────────────────┘
                                             │
                                             ▼
    ┌─────────────────────────────────────────────────────────────────────────────────┐
    │                              🎯 COMPLETA                                         │
    │                     (rama que usan los estudiantes)                              │
    └─────────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Descripción de Ramas

| Rama                     | Propósito                                               | Quién la usa             |
| ------------------------ | ------------------------------------------------------- | ------------------------ |
| `master`                 | Base estable con estructura y scripts                   | Todos (heredan de aquí)  |
| `contenido/oracle`       | Scripts SQL y ejercicios Oracle                         | Profesor de Oracle       |
| `contenido/dotnet`       | Controladores, Modelos y APIs                           | Profesor de .NET         |
| `contenido/vue`          | Componentes Vue, vistas, ejercicios                     | Profesor de Vue          |
| `contenido/herramientas` | Utilidades, herramientas de programacion, configuracion | Profesor de herramientas |
| `curso/semana-X`         | Contenido integrado de la semana X                      | Coordinador del curso    |
| `COMPLETA`               | Todo el contenido acumulado                             | **Estudiantes**          |

---

## 2. Guía Git para Estudiantes

### 2.1 Configuración Inicial

```bash
# Clonar el repositorio (solo la primera vez)
git clone ssh://servidortfs.campus.ua.es:22/tfs/Desarrollo/Curso%20de%20Oracle%20-%20.NET%20-%20Vue.js%20-%20Accesibilidad%20-%20IA/_git/CursoNormalizacionApps

# Entrar en la carpeta
cd CursoNormalizacionApps

# Cambiar a la rama COMPLETA
git checkout COMPLETA
```

### 2.2 Actualizar tu Copia

```bash
# Antes de cada clase, actualiza tu código
git pull origin COMPLETA
```

### 2.3 Guardar Cambios Temporalmente (Stash)

El **stash** es como una caja donde guardas tus cambios temporalmente:

```bash
# Guardar tus cambios en la caja
git stash

# Ver qué hay en la caja
git stash list

# Recuperar los cambios de la caja
git stash pop

# Recuperar sin eliminar de la caja
git stash apply
```

**📌 Caso de uso típico:**

```bash
# 1. Estás trabajando en algo y necesitas actualizar
git stash                    # Guarda tus cambios

# 2. Actualizas
git pull origin COMPLETA     # Trae lo nuevo

# 3. Recuperas tu trabajo
git stash pop                # Devuelve tus cambios
```

### 2.4 Hacer Commits

Un **commit** es una foto de tu código en un momento dado:

```bash
# Ver qué archivos has cambiado
git status

# Añadir archivos específicos
git add archivo.ts

# Añadir todos los archivos
git add -A

# Crear el commit con un mensaje
git commit -m "Añadir validación al formulario"
```

**📌 Buenos mensajes de commit:**

- ✅ `"Añadir validación email en formulario contacto"`
- ✅ `"Corregir error en cálculo de totales"`
- ❌ `"Cambios"`
- ❌ `"asdfasdf"`

### 2.5 Deshacer Cambios (Restore)

```bash
# Descartar cambios en UN archivo (volver a como estaba)
git restore archivo.ts

# Descartar TODOS los cambios locales
git restore .

# Quitar un archivo del staging (después de git add)
git restore --staged archivo.ts
```

### 2.6 Resumen Visual

```
┌─────────────────┐    git add     ┌─────────────────┐   git commit   ┌─────────────────┐
│  Working Dir    │ ────────────▶  │    Staging      │ ────────────▶  │   Repository    │
│  (tus cambios)  │                │    (preparado)  │                │   (guardado)    │
└─────────────────┘                └─────────────────┘                └─────────────────┘
        │                                  │
        │◀──────── git restore ────────────┘
        │◀──────── git restore --staged ───┘
```

---

## 3. Flujo de Trabajo para Profesores

### 3.1 Trabajar en Contenido

```bash
# 1. Cambiar a tu rama de contenido
git checkout contenido/vue      # o contenido/oracle, contenido/dotnet

# 2. Actualizar desde master (por si hay cambios)
git merge master

# 3. Hacer tus cambios...

# 4. Commit y push
git add -A
git commit -m "Añadir ejercicio día 5: componentes reactivos"
git push origin contenido/vue
```

### 3.2 Integrar en Semana

```bash
# 1. Cambiar a la rama de semana
git checkout curso/semana-3

# 2. Traer contenido de las ramas necesarias
git merge contenido/vue
git merge contenido/dotnet

# 3. Resolver conflictos si los hay

# 4. Push
git push origin curso/semana-3
```

### 3.3 Actualizar COMPLETA

Usar el script proporcionado:

```powershell
.\scripts\incorporar-a-completa.ps1 -Semana 3 -Push
```

---

## 4. Estructura de Carpetas

### 4.1 Estructura General

```
📦 curso-normalizacion-aplicaciones
│
├── 📁 Oracle/                      # Scripts SQL
│   ├── 📁 Semana_1/
│   │   ├── 📁 Dia_1/
│   │   │   ├── 📁 ejercicios/
│   │   │   └── 📁 soluciones/
│   │   └── 📁 Dia_2/
│   └── 📁 Semana_2/
│
├── 📁 Documentacion/               # Documentación teórica
│   ├── 📁 Semana_1_Fundamentos/
│   │   ├── 📁 Dia_1_Intro/
│   │   │   ├── Dia_1_Intro.md
│   │   │   ├── 📁 ejercicios/
│   │   │   └── 📁 soluciones/
│   │   └── 📁 Dia_2_Oracle/
│   └── 📁 Semana_3_Vue_Intro/
│
├── 📁 ClientApp/                   # Aplicación Vue
│   └── 📁 src/
│       ├── 📁 views/
│       │   ├── 📁 semana-3/
│       │   ├── 📁 semana-4/
│       │   └── ...
│       ├── 📁 components/
│       └── 📁 composables/
│
├── 📁 Controllers/                 # APIs .NET
│   └── 📁 Apis/
│
├── 📁 Models/                      # Modelos de datos
│
└── 📁 scripts/                     # Scripts de gestión
```

### 4.2 Convenciones de Nombres

| Tipo                  | Patrón                       | Ejemplo                      |
| --------------------- | ---------------------------- | ---------------------------- |
| Carpeta semana (Docs) | `Semana_X_NombreDescriptivo` | `Semana_3_Vue_Intro`         |
| Carpeta día (Docs)    | `Dia_X_NombreDescriptivo`    | `Dia_5_Intro_Vue_TypeScript` |
| Carpeta semana (Vue)  | `semana-X`                   | `semana-3`                   |
| Script Oracle         | `XX_nombre_descriptivo.sql`  | `01_crear_tablas.sql`        |

---

## 5. Resolución de Problemas

### 5.1 "Tengo cambios y no me deja cambiar de rama"

```bash
# Opción 1: Guardar cambios temporalmente
git stash
git checkout otra-rama
git stash pop          # cuando vuelvas

# Opción 2: Hacer commit de los cambios
git add -A
git commit -m "WIP: trabajo en progreso"
git checkout otra-rama
```

### 5.2 "He hecho cambios que quiero descartar"

```bash
# Solo algunos archivos
git restore archivo1.ts archivo2.vue

# Todo
git restore .
```

### 5.3 "Me he equivocado en el último commit"

```bash
# Cambiar el mensaje
git commit --amend -m "Mensaje corregido"

# Añadir archivos olvidados
git add archivo-olvidado.ts
git commit --amend --no-edit
```

### 5.4 "Tengo conflictos al hacer merge"

1. Abre los archivos con conflictos (marcados con `<<<<<<<`)
2. Elige qué código mantener
3. Elimina las marcas de conflicto
4. Guarda y haz commit:

```bash
git add .
git commit -m "Resolver conflictos de merge"
```

### 5.5 "Quiero volver a un commit anterior"

```bash
# Ver historial
git log --oneline -10

# Volver temporalmente (solo ver)
git checkout abc123

# Volver a la rama actual
git checkout nombre-rama
```

---

## 📞 Contacto

Si tienes problemas con Git, contacta con el coordinador del curso antes de intentar comandos destructivos.

---

_Última actualización: Enero 2026_
