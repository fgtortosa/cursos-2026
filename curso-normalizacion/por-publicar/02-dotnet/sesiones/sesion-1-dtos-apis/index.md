---
title: "Sesión 4: Modelos y primer API"
description: Crear DTOs, controladores API REST y consumirlos desde Vue.js sin base de datos
outline: deep
---

# Sesión 4: Modelos y primer API (~45 min)

[[toc]]

## 1.1 ¿Qué es un DTO?

Un **DTO** (Data Transfer Object) es un objeto que transporta datos entre capas. No contiene lógica de negocio: solo propiedades.

| Concepto      | Propósito                                       | Ejemplo                              |
| ------------- | ----------------------------------------------- | ------------------------------------ |
| **DTO**       | Transportar datos entre capas (API ↔ cliente)   | `ClasePermiso`, `ClaseHerramientaIA` |
| **Entidad**   | Representar una fila de la BD con mapeo directo | Modelo de Entity Framework           |
| **ViewModel** | Preparar datos específicos para una vista MVC   | `HomeViewModel` (no aplica en APIs)  |

En nuestras aplicaciones UA, los DTOs son las clases que están en la carpeta `Models/` y se mapean directamente a las tablas Oracle.

### Ejemplo: DTO simple (modelo Permiso)

Un modelo sencillo con pocas propiedades, mapeado a una tabla Oracle:

```csharp
// Models/Permiso/ClasePermiso.cs
public class ClasePermiso
{
    public int CodPermiso { get; set; }      // COD_PERMISO
    public string Descripcion { get; set; }   // DESCRIPCION
    public bool Activo { get; set; }          // ACTIVO ('S'/'N' → bool)
}
```

### Ejemplo: DTO con multiidioma (modelo HerramientaIA)

Un modelo más complejo con propiedades multiidioma. La librería ClaseOracleBD3 resuelve automáticamente el sufijo `_ES`, `_CA` o `_EN` según el idioma:

```csharp
// Models/Herramienta/ClaseHerramientaIA.cs
public class ClaseHerramientaIA
{
    public int CodHerramienta { get; set; }   // COD_HERRAMIENTA
    public string Nombre { get; set; }         // NOMBRE_ES / NOMBRE_CA / NOMBRE_EN
    public string Descripcion { get; set; }    // DESCRIPCION_ES / DESCRIPCION_CA / DESCRIPCION_EN
    public string Url { get; set; }            // URL
    public bool Activo { get; set; }           // ACTIVO ('S'/'N' → bool)

    public string NombreConUrl => $"{Nombre} ({Url})";
}
```

::: tip BUENA PRÁCTICA
**Convenciones de nombres UA:**

- Propiedades en **PascalCase** en C# → se mapean automáticamente a **SNAKE_CASE** en Oracle
- `FechaNacimiento` → `FECHA_NACIMIENTO`
- `CodPermiso` → `COD_PERMISO`
- Usa `[Columna("NOMBRE_REAL")]` solo si la columna no sigue la convención SNAKE_CASE
  :::

## 1.2 Creando nuestra primera API

### Anatomía de un controlador API

Todos los controladores API en .NET Core 10 comparten esta estructura:

```csharp
[Route("api/[controller]")]  // Ruta base: /api/NombreControlador
[ApiController]               // Habilita validación automática del modelo
public class InfoController : ControllerBase  // Hereda de ControllerBase
{
    // Inyección de dependencias en el constructor
    private readonly ClaseTokens _tokens;

    public InfoController(ClaseTokens tokens)
    {
        _tokens = tokens;
    }

    // Acciones con atributos HTTP
    [HttpGet("Message")]
    public string GetBackendMessage()
    {
        return "Hola desde la API";
    }
}
```

### Ejemplo real: InfoController del proyecto Curso

Este es el controlador más sencillo del proyecto. Observamos cómo valida el token del usuario y devuelve información:

```csharp
// Curso/Controllers/Apis/InfoController.cs
[Route("api/[controller]")]
[ApiController]
public class InfoController : ControllerBase
{
    private readonly ClaseTokens _tokens;

    public InfoController(ClaseTokens tokens)
    {
        _tokens = tokens;
    }

    [HttpGet("MessageError")]
    public IActionResult GetErrorMessage()
    {
        return BadRequest("Error en la petición");
    }

    [HttpGet("Message")]
    public string GetBackendMessage()
    {
        var token = _tokens.GetTokenCookie(_tokens.APPTOKEN);
        var validacion = _tokens.ValidarJwt(token, false);

        if (validacion.TokenValido)
        {
            return "Eres " + validacion.CodPersona + " - "
                + validacion.NombrePersona + " - "
                + validacion.Idioma + " - "
                + validacion.Correo;
        }

        return "El token no es valido: " + validacion.TokenCaducado;
    }
}
```

### Verbos HTTP

| Verbo      | Atributo       | Uso                         | Ejemplo                          |
| ---------- | -------------- | --------------------------- | -------------------------------- |
| **GET**    | `[HttpGet]`    | Obtener datos               | Listar permisos, obtener usuario |
| **POST**   | `[HttpPost]`   | Crear recurso               | Crear una herramienta IA         |
| **PUT**    | `[HttpPut]`    | Actualizar recurso completo | Modificar un permiso             |
| **DELETE** | `[HttpDelete]` | Eliminar recurso            | Desactivar una herramienta       |

### Códigos de estado HTTP

| Código  | Método en .NET             | Significado                       |
| ------- | -------------------------- | --------------------------------- |
| **200** | `Ok(valor)`                | Operación exitosa con datos       |
| **204** | `NoContent()`              | Operación exitosa sin datos       |
| **400** | `BadRequest(mensaje)`      | Error en la solicitud del cliente |
| **401** | `Unauthorized()`           | No autenticado                    |
| **404** | `NotFound()`               | Recurso no encontrado             |
| **500** | `Problem(detail: mensaje)` | Error interno del servidor        |

::: code-group

```csharp [Controller básico]
[Route("api/[controller]")]
[ApiController]
public class ReservasController : ControllerBase
{
    [HttpGet]
    public IActionResult Listar()
    {
        return Ok(new[] { "Reserva 1", "Reserva 2" });
    }
}
```

```csharp [Controller con atributos]
[Route("api/[controller]")]
[ApiController]
[Produces("application/json")]
public class ReservasController : ControllerBase
{
    [HttpGet]
    [ProducesResponseType(typeof(List<ClaseReserva>), 200)]
    [ProducesResponseType(typeof(ProblemDetails), 500)]
    public IActionResult Listar()
    {
        return Ok(new[] { "Reserva 1", "Reserva 2" });
    }
}
```

:::

## 1.3 Probando la API sin base de datos

Antes de conectar con Oracle, es útil probar con datos hardcodeados. Así validamos que el controlador, las rutas y los códigos de estado funcionan correctamente.

```csharp
[Route("api/[controller]")]
[ApiController]
public class ReservasController : ControllerBase
{
    // Datos hardcodeados para pruebas
    private static readonly List<ClaseReserva> _reservas = new()
    {
        new ClaseReserva { CodReserva = 1, Descripcion = "Sala A - Reunión", Activo = true },
        new ClaseReserva { CodReserva = 2, Descripcion = "Sala B - Formación", Activo = true },
        new ClaseReserva { CodReserva = 3, Descripcion = "Sala C - Cancelada", Activo = false }
    };

    [HttpGet]
    public IActionResult Listar()
    {
        return Ok(_reservas.Where(r => r.Activo));
    }

    [HttpGet("{id}")]
    public IActionResult ObtenerPorId(int id)
    {
        var reserva = _reservas.FirstOrDefault(r => r.CodReserva == id);
        if (reserva == null)
            return NotFound();

        return Ok(reserva);
    }

    [HttpGet("error")]
    public IActionResult ProvocarError()
    {
        return Problem(detail: "Error simulado del servidor", statusCode: 500);
    }
}
```

::: warning IMPORTANTE
El atributo `[ApiController]` valida automáticamente el `ModelState`. Si un DTO tiene DataAnnotations y los datos no son válidos, .NET devuelve un `400 Bad Request` con un `ValidationProblemDetails` **sin que escribamos código de validación en la acción**.
:::

## 1.4 Viendo las respuestas en Vue

En el frontend, usamos `llamadaAxios` del paquete `vueua-useaxios` para consumir las APIs. Observamos el ejemplo real del proyecto Curso:

```vue
<!-- Curso/ClientApp/src/views/Home.vue -->
<script setup lang="ts">
import { onMounted, ref } from "vue";
import {
  gestionarError,
  llamadaAxios,
  verbosAxios,
} from "vueua-useaxios/services/useAxios";
import { avisarError } from "vueua-usetoast/services/useToast";

const info = ref<string>("");

// Llamada exitosa
const obtenerInfoUsuario = async () => {
  llamadaAxios("Info/Message", verbosAxios.GET)
    .then(({ data }) => {
      info.value = data.value;
    })
    .catch((error) => {
      gestionarError(
        error,
        "Error al obtener la información del usuario",
        "No se ha encontrado la información del usuario",
      );
    });
};

// Provocar un error
const obtenerError = () => {
  llamadaAxios("Info/MessageError", verbosAxios.GET)
    .then(() => {})
    .catch((error) => {
      avisarError(
        "Error al obtener la información",
        `Error ${error.response.status}: ${error.response.data}`,
      );
    });
};
</script>

<template>
  <button class="btn btn-primary" @click="obtenerInfoUsuario">
    Obtener información
  </button>
  <button class="btn btn-danger ms-2" @click="obtenerError">
    Provocar error
  </button>
  <p>{{ info }}</p>
</template>
```

::: code-group

```typescript [Llamada exitosa]
llamadaAxios("Reservas", verbosAxios.GET)
  .then(({ data }) => {
    reservas.value = data.value;
  })
  .catch((error) => {
    gestionarError(error, "Error al obtener reservas");
  });
```

```typescript [Llamada con error]
llamadaAxios("Reservas/999", verbosAxios.GET)
  .then(({ data }) => {
    reserva.value = data.value;
  })
  .catch((error) => {
    // error.response.status → 404
    // error.response.data → ProblemDetails JSON
    avisarError(
      "Reserva no encontrada",
      `Error ${error.response.status}: ${error.response.data.detail}`,
    );
  });
```

:::

## 1.5 Práctica guiada: Rojo-Verde-Refactor con validación

::: tip SESIÓN DE INTEGRACIÓN
Esta práctica introduce DataAnnotations como primer contacto con la validación. El tema se amplía en la **Sesión 12 — Validación en todas las capas**, donde se cubre FluentValidation, localización de mensajes y validación end-to-end con Vue.
:::

En esta sección practicamos el ciclo **Rojo-Verde-Refactor** usando el `EcoController`: un controlador que devuelve exactamente el mismo DTO que recibe. No necesita base de datos, así que podemos centrarnos en la validación.

### Paso 1: ROJO — Sin validación, todo pasa

Nuestro DTO inicial no tiene ninguna validación:

```csharp
// Models/Eco/ClaseEcoUnidad.cs
public class ClaseEcoUnidad
{
    public string? NombreEs { get; set; }
    public string? NombreCa { get; set; }
    public string? NombreEn { get; set; }
    public int Granularidad { get; set; }
    public string? EmailContacto { get; set; }
}
```

Y el controlador simplemente devuelve lo que recibe:

```csharp
// Controllers/Apis/EcoController.cs
[Route("api/[controller]")]
[ApiController]
public class EcoController : ControllerBase
{
    [HttpPost]
    public ActionResult<ClaseEcoUnidad> Eco([FromBody] ClaseEcoUnidad dto)
    {
        return Ok(dto);
    }

    [HttpPost("validar")]
    public ActionResult<ClaseEcoUnidad> Validar([FromBody] ClaseEcoUnidad dto)
    {
        return Ok(dto);
    }
}
```

**Probamos en Vue** enviando un DTO con campos vacíos al endpoint `/api/Eco/validar`:

```json
// Enviamos esto:
{
  "nombreEs": "",
  "nombreCa": "",
  "nombreEn": "",
  "granularidad": 0,
  "emailContacto": ""
}

// Recibimos 200 OK con el mismo DTO vacío:
{
  "nombreEs": "",
  "nombreCa": "",
  "nombreEn": "",
  "granularidad": 0,
  "emailContacto": ""
}
```

::: danger ESTO ES ROJO
La API acepta datos completamente vacíos. Un nombre vacío, una granularidad de 0 minutos y un email vacío no deberían ser válidos. Necesitamos **validación**.
:::

La vista Vue para probar el eco está en `/eco` y muestra tanto la respuesta exitosa (en verde) como los errores de validación (en rojo) cuando los añadamos:

```vue
<!-- Fragmento de Eco.vue — Gestión de errores de validación -->
<script setup lang="ts">
const enviarValidar = () => {
  respuesta.value = null;
  errores.value = null;

  llamadaAxios("Eco/validar", verbosAxios.POST, formulario)
    .then(({ data }) => {
      respuesta.value = data.value; // 200 OK → mostramos la respuesta
    })
    .catch((error) => {
      if (error.response?.status === 400 && error.response?.data?.errors) {
        errores.value = error.response.data.errors; // Errores campo a campo
      } else {
        gestionarError(error, "Error al validar");
      }
    });
};
</script>

<!-- Mostramos errores por campo con Bootstrap is-invalid -->
<input
  v-model="formulario.nombreEs"
  type="text"
  class="form-control"
  :class="{ 'is-invalid': errores?.NombreEs }"
/>
<div class="invalid-feedback" v-if="errores?.NombreEs">
  {{ errores.NombreEs.join(", ") }}
</div>
```

### Paso 2: VERDE — Añadimos [Required] y .NET rechaza datos vacíos

Añadimos `[Required]` a los tres campos de nombre:

```csharp
// Models/Eco/ClaseEcoUnidad.cs — Fase VERDE
using System.ComponentModel.DataAnnotations;

public class ClaseEcoUnidad
{
    [Required(ErrorMessage = "El nombre en español es obligatorio")]
    public string? NombreEs { get; set; }

    [Required(ErrorMessage = "El nombre en valenciano es obligatorio")]
    public string? NombreCa { get; set; }

    [Required(ErrorMessage = "El nombre en inglés es obligatorio")]
    public string? NombreEn { get; set; }

    public int Granularidad { get; set; }
    public string? EmailContacto { get; set; }
}
```

**Enviamos el mismo DTO vacío** y ahora la API devuelve `400 Bad Request` con un `ValidationProblemDetails`:

```json
// POST /api/Eco/validar con campos vacíos
// Respuesta: 400 Bad Request
{
  "type": "https://tools.ietf.org/html/rfc9110#section-15.5.1",
  "title": "One or more validation errors occurred.",
  "status": 400,
  "errors": {
    "NombreEs": ["El nombre en español es obligatorio"],
    "NombreCa": ["El nombre en valenciano es obligatorio"],
    "NombreEn": ["El nombre en inglés es obligatorio"]
  }
}
```

::: tip ESTO ES VERDE
Ahora la API rechaza datos vacíos con mensajes claros por cada campo. El `[ApiController]` se encarga de validar automáticamente el `ModelState` y devolver el `ValidationProblemDetails` estándar (RFC 7807). **No hemos escrito ni una línea de código de validación en el controlador**.
:::

En **Vue**, los errores aparecen campo a campo gracias a `error.response.data.errors`:

```vue
<!-- El campo muestra el borde rojo y el mensaje de error -->
<input
  v-model="formulario.nombreEs"
  type="text"
  class="form-control"
  :class="{ 'is-invalid': errores?.NombreEs }"
/>
<div class="invalid-feedback" v-if="errores?.NombreEs">
  {{ errores.NombreEs.join(", ") }}
</div>
```

### Paso 3: REFACTOR — Validaciones más específicas

Ahora mejoramos las validaciones añadiendo restricciones de longitud, rango numérico y expresión regular para el email:

```csharp
// Models/Eco/ClaseEcoUnidad.cs — Fase REFACTOR
public class ClaseEcoUnidad
{
    [Required(ErrorMessage = "El nombre en español es obligatorio")]
    [StringLength(200, MinimumLength = 3,
        ErrorMessage = "El nombre en español debe tener entre 3 y 200 caracteres")]
    public string? NombreEs { get; set; }

    [Required(ErrorMessage = "El nombre en valenciano es obligatorio")]
    [StringLength(200, MinimumLength = 3,
        ErrorMessage = "El nombre en valenciano debe tener entre 3 y 200 caracteres")]
    public string? NombreCa { get; set; }

    [Required(ErrorMessage = "El nombre en inglés es obligatorio")]
    [StringLength(200, MinimumLength = 3,
        ErrorMessage = "El nombre en inglés debe tener entre 3 y 200 caracteres")]
    public string? NombreEn { get; set; }

    [Range(5, 120, ErrorMessage = "La granularidad debe estar entre 5 y 120 minutos")]
    public int Granularidad { get; set; }

    [EmailAddress(ErrorMessage = "El formato del email no es válido")]
    [RegularExpression(@"^[^@]+@(ua\.es|alu\.ua\.es)$",
        ErrorMessage = "El email debe ser de @ua.es o @alu.ua.es")]
    public string? EmailContacto { get; set; }
}
```

**Probamos con datos inválidos:**

```json
// POST /api/Eco/validar
{
  "nombreEs": "AB",
  "nombreCa": "Unitat de prova",
  "nombreEn": "Test unit",
  "granularidad": 3,
  "emailContacto": "usuario@gmail.com"
}

// Respuesta: 400 Bad Request
{
  "type": "https://tools.ietf.org/html/rfc9110#section-15.5.1",
  "title": "One or more validation errors occurred.",
  "status": 400,
  "errors": {
    "NombreEs": ["El nombre en español debe tener entre 3 y 200 caracteres"],
    "Granularidad": ["La granularidad debe estar entre 5 y 120 minutos"],
    "EmailContacto": ["El email debe ser de @ua.es o @alu.ua.es"]
  }
}
```

::: tip ESTO ES REFACTOR
Cada atributo de validación añade una capa más de seguridad. Observa cómo se acumulan los errores: un mismo campo puede tener varios mensajes (por ejemplo, `EmailContacto` primero valida formato y luego dominio). Los atributos más comunes son:

| Atributo                                   | Propósito            | Ejemplo                  |
| ------------------------------------------ | -------------------- | ------------------------ |
| `[Required]`                               | Campo obligatorio    | Nombres, códigos         |
| `[StringLength(max, MinimumLength = min)]` | Longitud de texto    | Entre 3 y 200 caracteres |
| `[Range(min, max)]`                        | Rango numérico       | Granularidad 5-120 min   |
| `[EmailAddress]`                           | Formato de email     | Validación RFC estándar  |
| `[RegularExpression(pattern)]`             | Patrón personalizado | Solo emails @ua.es       |

:::

## Ejercicio Sesión 1

**Objetivo:** Crear una API de reservas sin base de datos y consumirla desde Vue.

1. Crear el DTO `ClaseReserva` con propiedades: `CodReserva`, `Descripcion`, `FechaInicio`, `FechaFin`, `Activo`
2. Crear `ReservasController` con:
   - `GET /api/Reservas` → Lista de reservas hardcodeadas
   - `GET /api/Reservas/{id}` → Buscar por ID (devolver `404` si no existe)
   - `GET /api/Reservas/error` → Devolver un `Problem` con código 500
3. En Vue, crear una vista que:
   - Llame a la API y muestre las reservas
   - Tenga un botón para provocar el error y mostrarlo con `avisarError`

::: details Solución

**DTO:**

```csharp
// Models/Reserva/ClaseReserva.cs
public class ClaseReserva
{
    public int CodReserva { get; set; }
    public string Descripcion { get; set; }
    public DateTime FechaInicio { get; set; }
    public DateTime FechaFin { get; set; }
    public bool Activo { get; set; }
}
```

**Controlador:**

```csharp
// Controllers/Apis/ReservasController.cs
[Route("api/[controller]")]
[ApiController]
public class ReservasController : ControllerBase
{
    private static readonly List<ClaseReserva> _reservas = new()
    {
        new ClaseReserva
        {
            CodReserva = 1,
            Descripcion = "Sala de reuniones A",
            FechaInicio = new DateTime(2026, 3, 1, 10, 0, 0),
            FechaFin = new DateTime(2026, 3, 1, 11, 0, 0),
            Activo = true
        },
        new ClaseReserva
        {
            CodReserva = 2,
            Descripcion = "Aula de formación B",
            FechaInicio = new DateTime(2026, 3, 2, 9, 0, 0),
            FechaFin = new DateTime(2026, 3, 2, 12, 0, 0),
            Activo = true
        }
    };

    [HttpGet]
    public IActionResult Listar()
    {
        return Ok(_reservas.Where(r => r.Activo));
    }

    [HttpGet("{id}")]
    public IActionResult ObtenerPorId(int id)
    {
        var reserva = _reservas.FirstOrDefault(r => r.CodReserva == id);
        return reserva != null ? Ok(reserva) : NotFound();
    }

    [HttpGet("error")]
    public IActionResult ProvocarError()
    {
        return Problem(detail: "Error simulado del servidor", statusCode: 500);
    }
}
```

**Vista Vue:**

```vue
<script setup lang="ts">
import { ref } from "vue";
import {
  gestionarError,
  llamadaAxios,
  verbosAxios,
} from "vueua-useaxios/services/useAxios";
import { avisarError } from "vueua-usetoast/services/useToast";

interface Reserva {
  codReserva: number;
  descripcion: string;
  fechaInicio: string;
  fechaFin: string;
  activo: boolean;
}

const reservas = ref<Reserva[]>([]);

const cargarReservas = () => {
  llamadaAxios("Reservas", verbosAxios.GET)
    .then(({ data }) => {
      reservas.value = data.value;
    })
    .catch((error) => {
      gestionarError(error, "Error al obtener reservas");
    });
};

const provocarError = () => {
  llamadaAxios("Reservas/error", verbosAxios.GET)
    .then(() => {})
    .catch((error) => {
      avisarError(
        "Error del servidor",
        `Error ${error.response.status}: ${error.response.data.detail}`,
      );
    });
};
</script>

<template>
  <h1>Reservas</h1>
  <button class="btn btn-primary" @click="cargarReservas">Cargar</button>
  <button class="btn btn-danger ms-2" @click="provocarError">Error</button>

  <ul class="mt-3">
    <li v-for="r in reservas" :key="r.codReserva">
      {{ r.descripcion }} ({{ r.fechaInicio }})
    </li>
  </ul>
</template>
```

:::

::: details Código con fallos para Copilot (Controlador)
Copia este código en tu proyecto. Tiene **5 errores intencionados**. Usa Copilot para identificarlos y corregirlos:

```csharp
// ⚠️ CÓDIGO CON FALLOS - Usa Copilot para arreglarlo
[Route("api/controller")]          // 🐛 Falta [controller] entre corchetes
[ApiController]
public class ReservasController    // 🐛 No hereda de ControllerBase
{
    private static readonly List<ClaseReserva> _reservas = new()
    {
        new ClaseReserva { CodReserva = 1, Descripcion = "Sala A" }
    };

    [HttpGet]
    public IActionResult Listar()
    {
        return _reservas;           // 🐛 Falta Ok() para devolver IActionResult
    }

    [HttpGet("{id}")]
    public IActionResult ObtenerPorId(string id)  // 🐛 id debería ser int
    {
        var reserva = _reservas.FirstOrDefault(r => r.CodReserva == id);
        return Ok(reserva);         // 🐛 No comprueba si es null → debería devolver NotFound
    }
}
```

:::

::: details Código con fallos para Copilot (Validación DTO + Vue)
Este DTO tiene **4 errores** en las DataAnnotations y el código Vue tiene **3 errores** en la gestión de errores:

```csharp
// ⚠️ CÓDIGO CON FALLOS - DTO con validaciones incorrectas
public class ClaseEcoUnidad
{
    [Required]                          // 🐛 Sin ErrorMessage → mensaje genérico en inglés
    [StringLength(200)]                 // 🐛 Falta MinimumLength → acepta strings de 1 carácter
    public string? NombreEs { get; set; }

    public string? NombreCa { get; set; }   // 🐛 Falta [Required] → acepta vacío

    [Range(0, 999)]                     // 🐛 Rango incorrecto: acepta 0 min y 999 min
    public int Granularidad { get; set; }

    [RegularExpression(@"@ua.es")]      // 🐛 Regex mal: no ancla, no escapa el punto,
    public string? EmailContacto { get; set; }  //     no contempla @alu.ua.es
}
```

```vue
<!-- ⚠️ CÓDIGO CON FALLOS - Vue con errores en gestión de validación -->
<script setup lang="ts">
const enviarValidar = () => {
  // 🐛 No limpia errores anteriores → se acumulan errores viejos
  llamadaAxios("Eco/validar", verbosAxios.GET, formulario) // 🐛 Debería ser POST
    .then(({ data }) => {
      respuesta.value = data.value;
    })
    .catch((error) => {
      // 🐛 No distingue 400 (validación) de otros errores
      errores.value = error.response.data; // 🐛 Debería ser error.response.data.errors
    });
};
</script>
```

:::

## Preguntas de test

::: details 1. ¿Qué es un DTO?
**a)** Un objeto que contiene lógica de negocio y accede a la base de datos
**b)** Un objeto que transporta datos entre capas sin lógica de negocio ✅
**c)** Un componente de Vue que muestra datos al usuario
**d)** Un middleware de autenticación en .NET Core
:::

::: details 2. ¿Qué hace el atributo [ApiController] en un controlador?
**a)** Registra el controlador en el contenedor de inyección de dependencias
**b)** Habilita la autenticación JWT automáticamente
**c)** Valida automáticamente el ModelState y devuelve 400 si no es válido ✅
**d)** Genera documentación Swagger para todas las acciones
:::

::: details 3. ¿Qué código HTTP devuelve NotFound()?
**a)** 400 Bad Request
**b)** 401 Unauthorized
**c)** 404 Not Found ✅
**d)** 500 Internal Server Error
:::

::: details 4. ¿Cuál es la ruta generada para un controlador llamado UnidadesController con [Route("api/[controller]")]?
**a)** `/api/UnidadesController`
**b)** `/api/Unidades` ✅
**c)** `/Unidades`
**d)** `/api/controller/Unidades`
:::

::: details 5. ¿Qué verbo HTTP se usa para crear un recurso nuevo?
**a)** GET
**b)** PUT
**c)** POST ✅
**d)** DELETE
:::

::: details 6. ¿Qué función de Vue UA usamos para gestionar errores HTTP genéricos?
**a)** `avisarError` — muestra un toast con título y mensaje personalizados
**b)** `gestionarError` — gestiona el error de forma centralizada con toast automático ✅
**c)** `llamadaAxios` — hace la llamada y gestiona el error internamente
**d)** `verbosAxios.ERROR` — verbo especial para errores
:::

::: details 7. Si un controlador API devuelve Problem(detail: "Error", statusCode: 500), ¿qué formato tiene la respuesta?
**a)** Un string plano con el mensaje de error
**b)** Un JSON con formato ProblemDetails (RFC 7807) ✅
**c)** Un HTML con la página de error del servidor
**d)** Un código de estado sin cuerpo de respuesta
:::

::: details 8. En el proyecto UA, ¿de qué clase hereda un controlador API básico?
**a)** `Controller`
**b)** `ControllerBase` ✅
**c)** `ApiController`
**d)** `BaseApiController`
:::

::: details 9. Si un DTO tiene [Required] en una propiedad string y enviamos ese campo vacío, ¿qué ocurre con [ApiController]?
**a)** La acción del controlador recibe el string vacío y debe validarlo manualmente
**b)** .NET devuelve automáticamente un 400 Bad Request con ValidationProblemDetails ✅
**c)** .NET lanza una excepción NullReferenceException
**d)** El campo se rellena con un valor por defecto
:::

::: details 10. ¿Qué expresión regular valida que un email sea de @ua.es o @alu.ua.es?
**a)** `@".*@ua\.es$"` — solo valida @ua.es, no @alu.ua.es
**b)** `@"^[^@]+@(ua\.es|alu\.ua\.es)$"` ✅
**c)** `@"@ua.es|@alu.ua.es"` — no ancla el patrón, acepta texto extra
**d)** `@"^.+@ua\.es$"` — solo valida @ua.es
:::

---

## Tests y práctica IA

- [Ver tests y práctica de la sesión](../../test/sesion-1/)
- [Autoevaluación sesión 1](../../test/sesion-1/autoevaluacion.md)
- [Preguntas de test sesión 1](../../test/sesion-1/preguntas.md)
- [Respuestas del test sesión 1](../../test/sesion-1/respuestas.md)
- [Práctica IA-fix sesión 1](../../test/sesion-1/practica-ia-fix.md)

---

**Siguiente:** [Sesión 2: Servicios, Oracle y ClaseOracleBD3](../sesion-2-servicios-oracle/)
