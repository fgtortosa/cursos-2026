---
title: Configuración del entorno de desarrollo en Windows
description: Guía de configuración de Git, SSH, npm, NuGet y herramientas para desarrolladores del Servicio de Informática de la UA.
outline: deep
---

# Configuración del entorno de desarrollo en Windows

Esta guía cubre todos los ficheros de configuración y herramientas necesarias para empezar a trabajar con los repositorios, paquetes npm y paquetes NuGet del Servicio de Informática de la Universidad de Alicante.

::: info CONTEXTO
El servidor de control de versiones de la UA es una instancia **Azure DevOps Server (TFS) autoalojada** en `servidortfs.campus.ua.es`. Todos los repositorios Git, feeds de paquetes npm y feeds NuGet están alojados en esa instancia.
:::

---

## Herramientas necesarias {#herramientas}

Instala estas herramientas antes de continuar con el resto de la guía.

| Herramienta                                               | Versión recomendada      | Notas                                      |
| --------------------------------------------------------- | ------------------------ | ------------------------------------------ |
| [Git for Windows](https://git-scm.com/download/win)       | Última estable           | Incluye Git Credential Manager y OpenSSH   |
| [Node.js](https://nodejs.org/)                            | LTS                      | Instala también `npm`                      |
| [.NET SDK](https://dotnet.microsoft.com/download)         | 10                       | SDK, no solo Runtime                       |
| [Visual Studio 2022](https://visualstudio.microsoft.com/) | Community / Professional | Carga de trabajo ASP.NET y desarrollo web  |
| [Visual Studio Code](https://code.visualstudio.com/)      | Última estable (2026)    | Editor principal para Vue y tareas ligeras |

::: warning IMPORTANTE
Instala **Git for Windows** antes de configurar SSH. El instalador incluye OpenSSH y Git Credential Manager, que son necesarios para los pasos posteriores.
:::

---

## Configuración de Git {#git-config}

El fichero `~/.gitconfig` (`%USERPROFILE%\.gitconfig`) es la configuración global de Git para tu usuario de Windows.

### Configuración mínima obligatoria

Ejecuta estos comandos en Git Bash o PowerShell para establecer tu identidad:

```powershell
git config --global user.name "Nombre Apellido"
git config --global user.email "TU_USUARIO@ua.es"
```

### Configuración recomendada

```powershell
# Evitar conversión automática de saltos de línea al hacer commit en Windows
git config --global core.autocrlf true

# Editor por defecto (Visual Studio Code)
git config --global core.editor "code --wait"

# Usar el OpenSSH de Windows (evita conflictos con PuTTY)
git config --global core.sshCommand "C:/Windows/System32/OpenSSH/ssh.exe"

# Rama por defecto en repositorios nuevos
git config --global init.defaultBranch main

# Permitir autenticación NTLM para el servidor TFS
git config --global http.https://servidortfs.campus.ua.es.allowNTLMAuth true
git config --global credential.https://servidortfs.campus.ua.es.useHttpPath true
```

#### Qué resuelve

- `allowNTLMAuth = true` permite a Git negociar autenticación integrada de Windows contra ese host.
- `useHttpPath = true` separa credenciales por ruta HTTP y reduce conflictos cuando el mismo servidor expone varios repositorios, colecciones o feeds.

::: tip BUENA PRACTICA
Aplicamos esta configuración a nivel de usuario, no dentro de cada repositorio. Así afecta a todos los clones que apunten a `servidortfs.campus.ua.es`.
:::

::: tip BUENA PRACTICA
Usa `core.autocrlf true` en Windows. Esto convierte los `CRLF` de Windows a `LF` al hacer commit, y los revierte al hacer checkout. Evita conflictos de fin de línea con compañeros que trabajen en Linux/Mac.
:::

::: details Ver el .gitconfig resultante completo

```ini
[user]
    name = Nombre Apellido
    email = TU_USUARIO@ua.es

[core]
    autocrlf = true
    editor = code --wait
    sshCommand = C:/Windows/System32/OpenSSH/ssh.exe

[init]
    defaultBranch = main

[http "https://servidortfs.campus.ua.es"]
    allowNTLMAuth = true

[credential "https://servidortfs.campus.ua.es"]
    useHttpPath = true
```

:::

---

## Clave SSH {#ssh}

SSH es el método preferido para autenticarse con el servidor TFS. Es más seguro que HTTPS y no requiere introducir la contraseña en cada operación.

### Generar la clave RSA

Abre PowerShell o Git Bash y ejecuta:

```bash
ssh-keygen -t rsa -b 4096 -C "TU_USUARIO@ua.es"
```

El asistente te pedirá:

1. **Ruta del fichero** — pulsa Enter para aceptar la ruta por defecto (`%USERPROFILE%\.ssh\id_rsa`)
2. **Passphrase** — establece una contraseña para proteger la clave privada (recomendado)

Esto genera dos ficheros en `%USERPROFILE%\.ssh\`:

| Fichero      | Descripción                                             |
| ------------ | ------------------------------------------------------- |
| `id_rsa`     | **Clave privada.** Nunca la compartas.                  |
| `id_rsa.pub` | **Clave pública.** Esta es la que se copia al servidor. |

::: danger ZONA PELIGROSA
Nunca compartas ni subas al repositorio el fichero `id_rsa` (clave privada). Solo la clave `.pub` se proporciona al servidor.
:::

### Fichero ~/.ssh/config {#ssh-config}

Crea o edita el fichero `%USERPROFILE%\.ssh\config` para indicar qué clave usar al conectar con el servidor TFS:

```
Host servidortfs.campus.ua.es
    HostName servidortfs.campus.ua.es
    User git
    IdentityFile ~/.ssh/id_rsa
    IdentitiesOnly yes
```

Esto hace que cualquier conexión SSH al servidor TFS use automáticamente tu clave `id_rsa`, sin necesidad de especificarla en cada comando `git clone` o `git push`.

---

## Añadir la clave SSH en Azure DevOps Server (TFS) {#ssh-tfs}

Una vez generada la clave, debes registrar la clave **pública** en tu perfil del servidor TFS.

### Pasos

1. Abre el servidor TFS en el navegador: `http://servidortfs.campus.ua.es/tfs/`
2. Haz clic en tu **avatar** (esquina superior derecha) y selecciona **"Security"** (Seguridad)
3. En el menú lateral, selecciona **"SSH public keys"**
4. Haz clic en **"Add"**
5. Asigna un nombre descriptivo (ej: `Windows-NombreEquipo`)
6. Pega el contenido de tu clave pública

Para obtener el contenido de la clave pública, ejecuta:

```powershell
type %USERPROFILE%\.ssh\id_rsa.pub
```

O

```powershell
Get-Content "$env:USERPROFILE\.ssh\id_rsa.pub"
```

Copia la línea completa (empieza por `ssh-rsa ...`) y pégala en el campo del formulario TFS.

::: tip BUENA PRACTICA
Pon un nombre descriptivo a la clave SSH en TFS (ej: `Portatil-UA-2025`). Si alguna vez pierdes el equipo, podrás identificarla y revocarla fácilmente.
:::

### Verificar la conexión SSH {#ssh-verificar}

Antes de clonar ningún repositorio, comprueba que la clave está correctamente cargada y que el servidor la acepta.

**1. Verificar que la clave está cargada en el agente SSH:**

```bash
ssh-add -l
```

Debe mostrar tu clave `id_rsa`. Si devuelve `The agent has no identities`, ejecuta `ssh-add ~/.ssh/id_rsa`.

**2. Probar la conexión con el servidor TFS:**

```bash
ssh -T git@servidortfs.campus.ua.es
```

La respuesta correcta cuando la autenticación ha funcionado es:

```
remote: Shell access is not supported.
shell request failed on channel 0
```

::: info CONTEXTO
Este mensaje **no es un error**. Azure DevOps Server acepta la clave SSH para operaciones Git pero rechaza las sesiones shell interactivas, que no son necesarias. Si ves este mensaje, la autenticación SSH está correctamente configurada y puedes clonar repositorios con normalidad.

Si en cambio ves `Permission denied (publickey)`, revisa que la clave pública está registrada en tu perfil TFS y que `ssh-add -l` muestra la clave.
:::

---

## Autenticación HTTPS con TFS {#https-auth}

Si prefieres o necesitas usar HTTPS en lugar de SSH, Git Credential Manager (incluido en Git for Windows) gestiona las credenciales automáticamente.

### Credenciales de dominio UA

::: warning IMPORTANTE
El nombre de usuario para autenticación HTTP con el TFS es **solo la parte local del correo**, es decir, la dirección antes de la `@`.

| Correo completo    | Usuario correcto | Usuario incorrecto |
| ------------------ | ---------------- | ------------------ |
| `TU_USUARIO@ua.es` | `TU_USUARIO`     | `TU_USUARIO@ua.es` |

La contraseña es tu **contraseña de Windows/dominio** de la UA.
:::

### Git Credential Manager

Git Credential Manager (GCM) se instala automáticamente con Git for Windows y almacena las credenciales en el Administrador de credenciales de Windows (`%APPDATA%\Microsoft\Credentials`), de forma que no tendrás que introducirlas en cada operación.

La primera vez que hagas `git clone` o `git push` con HTTPS, aparecerá un diálogo para introducir las credenciales. Tras autenticarte correctamente, GCM las guarda para las siguientes sesiones.

Para verificar que GCM está activo:

```bash
git config --global credential.helper
# Debe devolver: manager
```

::: details Eliminar credenciales guardadas si necesitas cambiarlas
Abre el **Administrador de credenciales de Windows** (`Control Panel > Credential Manager > Windows Credentials`) y busca entradas que contengan `servidortfs.campus.ua.es`. Elimínalas para que GCM solicite de nuevo las credenciales.
:::

---

## Configuración de npm — registro privado {#npmrc}

Para poder instalar paquetes del feed npm privado del TFS, debes configurar el fichero `%USERPROFILE%\.npmrc` con tus credenciales.

### Estructura del fichero

Crea o edita `%USERPROFILE%\.npmrc` con el siguiente contenido:

```ini
; Credenciales para Azure DevOps / TFS - ServidorNPM
//servidortfs.campus.ua.es/tfs/Desarrollo/ComponentesVue/_packaging/ServidorNPM/npm/registry/:username=TU_USUARIO
//servidortfs.campus.ua.es/tfs/Desarrollo/ComponentesVue/_packaging/ServidorNPM/npm/registry/:_password=TOKEN_EN_BASE64
//servidortfs.campus.ua.es/tfs/Desarrollo/ComponentesVue/_packaging/ServidorNPM/npm/registry/:email=TU_USUARIO@ua.es
//servidortfs.campus.ua.es/tfs/Desarrollo/ComponentesVue/_packaging/ServidorNPM/npm/:username=TU_USUARIO
//servidortfs.campus.ua.es/tfs/Desarrollo/ComponentesVue/_packaging/ServidorNPM/npm/:_password=TOKEN_EN_BASE64
//servidortfs.campus.ua.es/tfs/Desarrollo/ComponentesVue/_packaging/ServidorNPM/npm/:email=TU_USUARIO@ua.es
```

::: info CONTEXTO
El campo `_password` no es tu contraseña de Windows. Es un **Personal Access Token (PAT)** generado en TFS y codificado en **Base64**. Los dos bloques de líneas (con `/registry/` y sin él) son necesarios para compatibilidad con todas las versiones del cliente npm.
:::

### Cómo obtener el token (PAT)

1. Entra en `http://servidortfs.campus.ua.es/tfs/`
2. Haz clic en tu **avatar** > **"Security"**
3. Selecciona **"Personal access tokens"** > **"Add"**
4. Asigna nombre, fecha de expiración y selecciona el scope **"Packaging (read)"**
5. Copia el token generado (solo se muestra una vez)

### Codificar el token en Base64

Tienes que codificar el PAT en Base64 antes de pegarlo en `_password`. Puedes hacerlo en PowerShell:

```powershell
$pat = "PEGA_AQUI_TU_PAT"
[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($pat))
```

Copia el resultado y úsalo como valor de `_password` en el `.npmrc`.

::: warning IMPORTANTE
El fichero `.npmrc` contiene credenciales sensibles. No lo subas nunca a un repositorio Git. Comprueba que tu `.gitignore` global incluya `.npmrc` si trabajas en proyectos donde pudiera colarse por error.
:::

### Verificar la configuración

```powershell
npm ping --registry https://servidortfs.campus.ua.es/tfs/Desarrollo/ComponentesVue/_packaging/ServidorNPM/npm/registry/
```

---

## Configuración de NuGet {#nuget}

::: info CONTEXTO — dos sistemas de paquetes
Una aplicación UA moderna tiene **dos sistemas de paquetes independientes**:

| Lado     | Gestor       | Fichero de configuración                                  | Qué descarga                                  |
| -------- | ------------ | --------------------------------------------------------- | --------------------------------------------- |
| **.NET** | NuGet        | `%APPDATA%\NuGet\NuGet.Config` (global por usuario)       | `PlantillaMVCCore`, `ClaseOracleBD3`, etc.    |
| **Vue**  | npm / pnpm   | `%USERPROFILE%\.npmrc` (global por usuario)               | `@vueua/...`, `vue`, `axios`, `pinia`, etc.   |

Cada uno tiene su propio fichero **en tu equipo**, con su propio formato y sus propias credenciales. Si los feeds no están bien configurados, no compilarás ni un "Hola mundo". Esta sección cubre el lado **.NET**; la siguiente (`Configuración de npm`) cubre el lado JavaScript.
:::

El fichero `%APPDATA%\NuGet\NuGet.Config` define las fuentes de paquetes NuGet disponibles en Visual Studio y en la CLI de `dotnet`.

### Editar el fichero en tu equipo

Abre el fichero global con el bloc de notas desde PowerShell (cárgalo en tu carpeta de usuario):

```powershell
notepad.exe $env:APPDATA\NuGet\NuGet.Config
```

Si no existe la carpeta o el fichero, créalos:

```powershell
New-Item -ItemType Directory -Force -Path "$env:APPDATA\NuGet" | Out-Null
New-Item -ItemType File -Force -Path "$env:APPDATA\NuGet\NuGet.Config" | Out-Null
notepad.exe $env:APPDATA\NuGet\NuGet.Config
```

### Contenido para el curso

Pega **exactamente** este contenido. Es el que se usa durante todo el curso:

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
   <auditSources>
      <clear />
      <add key="nuget.org" value="https://api.nuget.org/v3/index.json" />
    </auditSources>
  <packageSources>
    <clear />
    <add key="nuget.org" value="https://api.nuget.org/v3/index.json" protocolVersion="3" />
    <add key="Microsoft Visual Studio Offline Packages" value="C:\Program Files (x86)\Microsoft SDKs\NuGetPackages\" />
    <add key="PaquetesNugets" value="https://servidortfs.campus.ua.es/tfs/Desarrollo/4ae97c7f-a3b4-4000-b8e4-b307b5c301f9/_packaging/PaquetesNugets/nuget/v3/index.json" />
    <add key="NUGET UA" value="https://preproddesa.campus.ua.es:443/NugetUA/nuget" />
  </packageSources>
  <activePackageSource>
    <add key="PaquetesNugets" value="true" />
    <add key="NUGET UA" value="true" />
  </activePackageSource>
  <disabledPackageSources>
    <add key="Microsoft Visual Studio Offline Packages" value="true" />
  </disabledPackageSources>
  <packageRestore>
    <add key="enabled" value="True" />
    <add key="automatic" value="True" />
  </packageRestore>
  <bindingRedirects>
    <add key="skip" value="False" />
  </bindingRedirects>
  <packageManagement>
    <add key="disabled" value="False" />
    <add key="format" value="0" />
  </packageManagement>
</configuration>
```

::: warning IMPORTANTE
- **El orden de `packageSources` importa**: NuGet consulta los feeds en el orden en que aparecen. Si un mismo paquete existe en varios, gana el primero que lo tenga.
- **Los feeds privados de la UA requieren estar dentro de la red campus** o tener un VPN activo. Si trabajas desde casa sin VPN, el restore fallará.
- **Nunca pongas credenciales en `NuGet.Config`.** Para los feeds privados UA, Visual Studio autentica con tu usuario Windows / Azure DevOps.
:::

### Comandos útiles

```powershell
# Ver feeds configurados
dotnet nuget list source

# Restaurar paquetes de la solución (descarga lo que falte)
dotnet restore

# Buscar paquetes en los feeds activos
dotnet package search ClaseOracle

# Forzar limpieza de cachés si el restore se atasca
dotnet nuget locals all --clear
```

### Añadir credenciales para el feed TFS en Visual Studio

Cuando Visual Studio intente restaurar paquetes del feed TFS por primera vez, aparecerá un diálogo de autenticación. Usa las mismas credenciales que para HTTPS Git:

- **Usuario**: parte local del correo (`TU_USUARIO`, sin `@ua.es`)
- **Contraseña**: contraseña de Windows/dominio

Visual Studio almacena las credenciales en el Administrador de credenciales de Windows para las siguientes sesiones.

También puedes añadirlas por línea de comandos:

```bash
dotnet nuget add source "https://servidortfs.campus.ua.es/tfs/Desarrollo/{ID}/_packaging/PaquetesNugets/nuget/v3/index.json" \
  --name "Preprod" \
  --username "TU_USUARIO" \
  --password "TU_CONTRASEÑA" \
  --store-password-in-clear-text
```

::: warning IMPORTANTE
`--store-password-in-clear-text` es necesario en Windows cuando se usan credenciales básicas con feeds TFS. Las credenciales quedan almacenadas en `NuGet.Config`, por lo que no compartas ese fichero si contiene contraseñas reales.
:::

---

## El servidor TFS de la UA {#tfs}

### Estructura de URLs

El servidor TFS organiza los proyectos en **colecciones**. La URL base es:

```
http://servidortfs.campus.ua.es/tfs/{COLECCION}/{PROYECTO}
```

| Segmento                        | Descripción                                |
| ------------------------------- | ------------------------------------------ |
| `servidortfs.campus.ua.es/tfs/` | Raíz del servidor TFS                      |
| `{COLECCION}`                   | Agrupación de proyectos (ej: `Desarrollo`) |
| `{PROYECTO}`                    | Proyecto individual dentro de la colección |

### Colecciones principales

- **`Desarrollo`** — Colección principal con los proyectos de aplicaciones de la UA

### Navegación por la interfaz web

Desde `http://servidortfs.campus.ua.es/tfs/` puedes:

- Ver los proyectos a los que tienes acceso
- Navegar por el historial de commits y ramas desde **Repos > Commits**
- Gestionar work items desde **Boards**
- Consultar y descargar artefactos de builds desde **Pipelines**
- Administrar feeds de paquetes desde **Artifacts**

::: info CONTEXTO
Azure DevOps Server (antes llamado TFS — Team Foundation Server) es la plataforma autoalojada equivalente a Azure DevOps de Microsoft. La interfaz web y los comandos Git son idénticos a los de la versión en la nube, con la diferencia de que el servidor está dentro de la red de la UA.
:::

---

## Clonar un repositorio {#clonar}

### Obtener la URL desde la interfaz TFS

1. Navega al proyecto en `http://servidortfs.campus.ua.es/tfs/`
2. Ve a **Repos** (o **Code** en versiones antiguas)
3. Haz clic en el botón **"Clone"**
4. Selecciona la pestaña **SSH** o **HTTPS** para obtener la URL correspondiente

### Clonar con SSH (recomendado)

```bash
git clone ssh://servidortfs.campus.ua.es:22/tfs/Desarrollo/NombreProyecto/_git/NombreRepositorio
```

::: tip BUENA PRACTICA
Usa SSH siempre que sea posible. No requiere introducir credenciales, funciona con `ssh-agent` en segundo plano y es más robusto en conexiones largas o con muchos objetos.
:::

### Clonar con HTTPS (alternativa)

```bash
git clone http://servidortfs.campus.ua.es/tfs/Desarrollo/NombreProyecto/_git/NombreRepositorio
```

La primera vez te pedirá usuario y contraseña. Git Credential Manager las guardará automáticamente.

::: info CONTEXTO
Las URLs SSH del TFS siguen el formato `ssh://HOST:PUERTO/tfs/COLECCION/PROYECTO/_git/REPOSITORIO`. El puerto por defecto suele ser el `22` estándar de SSH, aunque puede variar según la configuración del servidor.
:::

---

## Extensiones recomendadas de VS Code {#vscode-extensiones}

Instala estas extensiones para trabajar con los proyectos de la UA:

| Extensión             | ID                                  | Para qué sirve                                                 |
| --------------------- | ----------------------------------- | -------------------------------------------------------------- |
| .NET Extension Pack   | `ms-dotnettools.vscode-dotnet-pack` | Pack completo para desarrollo .NET (incluye C# y herramientas) |
| C#                    | `ms-dotnettools.csharp`             | Soporte base de C#: sintaxis, navegación y depuración          |
| C# Dev Kit            | `ms-dotnettools.csdevkit`           | IntelliSense avanzado, tests y gestión de soluciones           |
| i18n Ally             | `lokalise.i18n-ally`                | Gestión de traducciones y literales i18n en Vue                |
| Oracle SQL Developer  | `Oracle.sql-developer`              | Conexión y edición SQL contra bases de datos Oracle            |
| Playwright            | `ms-playwright.playwright`          | Ejecución y depuración de tests E2E con Playwright             |
| Vue - Official        | `Vue.volar`                         | Soporte Vue 3 con TypeScript (sustituye a Vetur)               |
| Vue.js Extension Pack | `mubaidr.vuejs-extension-pack`      | Pack de extensiones complementarias para Vue                   |

Puedes instalarlas todas desde la terminal:

```bash
code --install-extension ms-dotnettools.vscode-dotnet-pack
code --install-extension ms-dotnettools.csharp
code --install-extension ms-dotnettools.csdevkit
code --install-extension lokalise.i18n-ally
code --install-extension Oracle.sql-developer
code --install-extension ms-playwright.playwright
code --install-extension Vue.volar
code --install-extension mubaidr.vuejs-extension-pack
```

::: tip BUENA PRACTICA
Desactiva la extensión **Vetur** si la tenías instalada previamente. Es incompatible con **Vue - Official (Volar)** y puede causar conflictos de IntelliSense en proyectos Vue 3.
:::

---

## Verificación final {#verificacion}

Comprueba que todo está correctamente configurado antes de empezar a trabajar:

```bash
# Git: identidad configurada
git config --global user.name
git config --global user.email

# SSH: conectividad con el servidor TFS
ssh -T git@servidortfs.campus.ua.es

# npm: acceso al registro privado
npm ping --registry https://servidortfs.campus.ua.es/tfs/Desarrollo/ComponentesVue/_packaging/ServidorNPM/npm/registry/

# .NET SDK instalado
dotnet --version

# Node.js y npm instalados
node --version
npm --version
```

::: details Salida esperada del test SSH
Si la clave SSH está bien configurada, el comando `ssh -T git@servidortfs.campus.ua.es` devuelve:

```
remote: Shell access is not supported.
shell request failed on channel 0
```

Este mensaje **es la respuesta correcta**. Azure DevOps Server acepta la clave para operaciones Git pero no permite sesiones shell interactivas.

Si devuelve `Permission denied (publickey)`, revisa que:

1. La clave pública está añadida en el perfil TFS
2. El fichero `~/.ssh/config` apunta al fichero de clave correcto (`id_rsa`)
3. `ssh-agent` está corriendo y tiene cargada la clave: `ssh-add -l`
   :::

---

## Referencias {#referencias}

- [Documentación oficial de Git](https://git-scm.com/doc)
- [Generación de claves SSH — GitHub Docs](https://docs.github.com/es/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
- [Git Credential Manager](https://github.com/git-ecosystem/git-credential-manager)
- [Autenticación npm con Azure Artifacts](https://learn.microsoft.com/es-es/azure/devops/artifacts/npm/npmrc)
- [NuGet.Config — referencia](https://learn.microsoft.com/es-es/nuget/reference/nuget-config-file)
- [Servidor TFS de la UA](http://servidortfs.campus.ua.es/tfs/)
