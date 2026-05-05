---
title: "Sesión 12: Validación en todas las capas"
description: Pipeline de validación Oracle → .NET → Vue con DataAnnotations, FluentValidation, ValidationProblemDetails y useGestionFormularios v2
outline: deep
---

# Sesión 12: Validación en todas las capas

[[toc]]

::: info CONTEXTO
La validación no es un problema de una capa: es un contrato entre Oracle, el servidor .NET y el formulario Vue. En esta sesión construimos ese contrato de punta a punta, con un formato de error único que todas las capas entienden y que el frontend puede pintar sin lógica extra.
:::

## Objetivos

Al finalizar esta sesión, el alumno será capaz de:

- Entender qué valida cada capa y por qué no se puede confiar en una sola
- Aplicar DataAnnotations para reglas de campo simples
- Crear validaciones cruzadas con FluentValidation
- Configurar el formato estándar de respuesta (`ValidationProblemDetails`)
- Heredar de `ApiControllerUA` y usar `ProblemaValidacion()` para errores manuales y de Oracle
- Pintar errores de campo y errores globales en el formulario Vue con `useGestionFormularios` v2

---

## 12.1 El pipeline de validación {#pipeline}

Cada capa tiene su responsabilidad. Ninguna reemplaza a las otras.

```
Oracle (constraints + RAISE_APPLICATION_ERROR)
    │
    ▼
.NET — DataAnnotations + FluentValidation           → 400 ValidationProblemDetails
.NET — BDException.Usuario capturado en controlador → 400 ValidationProblemDetails (error global)
.NET — BDException.Sistema → ErrorHandlerMiddleware → 500 + correo al desarrollador
    │
    ▼
Vue — useGestionFormularios v2
    adaptarProblemDetails() → modelState (errores por campo)
                            → erroresGlobales (validaciones cruzadas, errores Oracle de usuario)
```

### Qué valida cada capa

| Capa | Qué valida | Cómo |
|------|-----------|------|
| Oracle | Integridad estructural: NOT NULL, UNIQUE, CHECK, FK | Constraints de tabla |
| Oracle | Reglas de negocio que solo la BD conoce | `RAISE_APPLICATION_ERROR` |
| .NET DTO | Formato y presencia de campo: required, longitud, email, rango | DataAnnotations |
| .NET Validator | Reglas cruzadas y async: fecha fin > inicio, email único | FluentValidation |
| Vue | Feedback inmediato al usuario (UX) | HTML5 + `useGestionFormularios` |

::: warning POR QUÉ VALIDAR EN MÚLTIPLES CAPAS
Un usuario puede manipular el navegador y saltarse las validaciones de Vue. Un atacante puede hacer peticiones HTTP directas y saltarse el frontend por completo. Las validaciones de .NET son las que protegen de verdad los datos; las de Vue son para mejorar la experiencia del usuario.
:::

### El formato de error único

Todas las respuestas de validación del servidor usan el mismo formato `ValidationProblemDetails` (RFC 7807):

```json
{
  "title": "Error de validación",
  "detail": "Revise los campos del formulario",
  "status": 400,
  "errors": {
    "NombreEs": ["El nombre en español es obligatorio"],
    "Granularidad": ["La granularidad no puede superar la duración máxima"],
    "": ["El expediente ya está cerrado y no puede modificarse"]
  }
}
```

La clave `""` (vacía) recoge errores que no pertenecen a un campo concreto — validaciones cruzadas o mensajes de Oracle de tipo usuario.

---

## 12.2 DataAnnotations: validación de campos {#data-annotations}

Las DataAnnotations son atributos que añadimos directamente en las propiedades del DTO. `[ApiController]` las valida automáticamente **antes** de ejecutar la acción — si el DTO falla, el controlador no llega a ejecutarse y se devuelve un `400` directamente.

```csharp
// Models/Unidad/ClaseGuardarUnidad.cs
public class ClaseGuardarUnidad
{
    [Required(ErrorMessage = "El nombre en español es obligatorio")]
    [StringLength(200, MinimumLength = 2,
        ErrorMessage = "El nombre debe tener entre 2 y 200 caracteres")]
    public string NombreEs { get; set; } = "";

    [Required(ErrorMessage = "El nombre en valenciano es obligatorio")]
    [StringLength(200)]
    public string NombreCa { get; set; } = "";

    [Range(5, 120, ErrorMessage = "La granularidad debe estar entre 5 y 120 minutos")]
    public int Granularidad { get; set; }

    [Range(1, 50, ErrorMessage = "Las citas simultáneas deben estar entre 1 y 50")]
    public int NumCitasSimultaneas { get; set; }

    [EmailAddress(ErrorMessage = "El email de contacto no tiene el formato correcto")]
    public string? EmailContacto { get; set; }
}
```

| Atributo | Uso | Ejemplo |
|----------|-----|---------|
| `[Required]` | Campo obligatorio | NombreEs |
| `[StringLength(max, MinimumLength)]` | Longitud de texto | Entre 2 y 200 caracteres |
| `[Range(min, max)]` | Rango numérico | Granularidad entre 5 y 120 |
| `[EmailAddress]` | Formato email | EmailContacto |
| `[RegularExpression]` | Patrón regex | NIF, código postal |

### Configurar el título y detalle en español

Por defecto, cuando `[ApiController]` devuelve el `400`, el campo `title` viene en inglés: `"One or more validation errors occurred."`. Para que llegue en español al formulario Vue, registramos `AddValidacionUA()` en `Program.cs`:

```csharp
// Program.cs
using ua.Models.Plantilla.Errores;

// Debe ir ANTES de AddControllersWithViews()
builder.Services.AddValidacionUA();
builder.Services.AddControllersWithViews();
```

Con esto, cualquier `400` automático de `[ApiController]` devuelve:

```json
{
  "title": "Error de validación",
  "detail": "Revise los campos del formulario",
  "status": 400,
  "errors": { ... }
}
```

Ese `title` y ese `detail` son los que `useGestionFormularios` mostrará en el toast automático.

---

## 12.3 FluentValidation: reglas cruzadas y dependientes {#fluent-validation}

DataAnnotations valida cada campo por separado. Cuando necesitamos comparar campos entre sí, validar con una consulta a la base de datos, o expresar reglas de negocio complejas, usamos FluentValidation.

::: tip REGLA PRÁCTICA
**DataAnnotations** para todo lo que sea de un campo solo: `required`, `length`, `email`, `range`.  
**FluentValidation** cuando la regla involucre más de un campo, sea asíncrona, o sea demasiado compleja para un atributo.  
Ambos pueden convivir en el mismo DTO sin problema.
:::

### Instalación

```bash
dotnet add package FluentValidation.AspNetCore
```

### Registro en Program.cs

```csharp
using FluentValidation;
using FluentValidation.AspNetCore;

// Registra automáticamente todos los validators del ensamblado
builder.Services.AddFluentValidationAutoValidation();
builder.Services.AddValidatorsFromAssemblyContaining<Program>();
```

Con `AddFluentValidationAutoValidation()`, el validator se ejecuta igual que DataAnnotations: antes de que el controlador llegue a ejecutarse. Si el DTO no valida, devuelve `400` automáticamente.

### Validator básico: reglas de campo

```csharp
// Validators/ClaseGuardarUnidadValidator.cs
public sealed class ClaseGuardarUnidadValidator : AbstractValidator<ClaseGuardarUnidad>
{
    public ClaseGuardarUnidadValidator()
    {
        RuleFor(x => x.NombreEs)
            .NotEmpty().WithMessage("El nombre en español es obligatorio")
            .MaximumLength(200).WithMessage("El nombre no puede superar 200 caracteres");

        RuleFor(x => x.Granularidad)
            .InclusiveBetween(5, 120)
            .WithMessage("La granularidad debe estar entre 5 y 120 minutos");
    }
}
```

### Validator con regla cruzada: error asignado a un campo

El error se muestra bajo el campo `DuracionMax` en el formulario:

```csharp
// La granularidad no puede superar la duración máxima
// Error asignado al campo Granularidad → aparece bajo ese input en Vue
RuleFor(x => x.Granularidad)
    .Must((unidad, granularidad) =>
        !unidad.DuracionMax.HasValue || granularidad <= unidad.DuracionMax.Value)
    .WithMessage("La granularidad no puede superar la duración máxima");
```

### Validator con error global: sin campo asociado

Cuando la regla afecta al objeto completo y no tiene un campo claro como responsable, el error va a la clave `""` y Vue lo muestra como error global (encima del formulario, no bajo ningún input):

```csharp
// Error global: no pertenece a ningún campo concreto
// Clave "" en errors → erroresGlobales en Vue
RuleFor(x => x).Custom((unidad, ctx) =>
{
    if (unidad.FechaFin.HasValue && unidad.FechaInicio.HasValue
        && unidad.FechaFin <= unidad.FechaInicio)
    {
        ctx.AddFailure("", "La fecha de fin debe ser posterior a la fecha de inicio");
    }
});
```

### Validator con validación asíncrona (consulta a BD)

Cuando necesitamos verificar algo contra la base de datos, como si un nombre ya existe:

```csharp
public sealed class ClaseGuardarUnidadValidator : AbstractValidator<ClaseGuardarUnidad>
{
    private readonly IUnidadesRepositorio _repo;

    public ClaseGuardarUnidadValidator(IUnidadesRepositorio repo)
    {
        _repo = repo;

        RuleFor(x => x.NombreEs)
            .NotEmpty().WithMessage("El nombre en español es obligatorio")
            .MustAsync(async (nombre, ct) =>
                !await _repo.ExisteNombreAsync(nombre))
            .WithMessage("Ya existe una unidad con ese nombre en español");
    }
}
```

---

## 12.4 ApiControllerUA: respuesta estándar y errores de Oracle {#api-controller-ua}

Cuando la validación es automática (DataAnnotations + FluentValidation con `AddFluentValidationAutoValidation()`), el controlador no necesita hacer nada — el `400` sale solo.

Pero hay dos casos en los que necesitamos devolver el error manualmente:

1. **Validación adicional en el propio controlador** (rara, pero ocurre)
2. **`BDException.Usuario`**: Oracle ha rechazado la operación con un mensaje para el usuario

Para estos casos, el controlador hereda de `ApiControllerUA` en lugar de `ControllerBase`:

```csharp
using ua.Plantilla;       // ApiControllerUA
using ua.Models;          // BDException, EnumBDException
using ua.Models.Plantilla.Errores; // AppException

[Route("api/unidades")]
public class UnidadesController : ApiControllerUA   // ← hereda de ApiControllerUA
{
    private readonly IUnidades _unidades;

    public UnidadesController(IUnidades unidades) => _unidades = unidades;

    [HttpPost]
    public async Task<IActionResult> Guardar([FromBody] ClaseGuardarUnidad input)
    {
        // [ApiController] + AddValidacionUA() ya validaron DataAnnotations y FluentValidation.
        // Si hubo errores de formato o reglas cruzadas, nunca llegamos aquí.

        try
        {
            var id = await _unidades.GuardarAsync(input);
            return CreatedAtAction(nameof(ObtenerPorId), new { id }, id);
        }
        catch (BDException bdex) when (bdex.TipoExcepcion == EnumBDException.Usuario)
        {
            // Oracle rechazó la operación con un mensaje para el usuario
            // (RAISE_APPLICATION_ERROR con # en el PL/SQL)
            // Lo convertimos en error global de validación → erroresGlobales en Vue
            ModelState.AddModelError("", bdex.Message);
            return ProblemaValidacion("El servidor ha rechazado la operación");
        }
        // BDException.Sistema, MantenimientoException y otras → ErrorHandlerMiddleware
        // → correo al desarrollador + mensaje genérico al usuario
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Actualizar(int id, [FromBody] ClaseGuardarUnidad input)
    {
        try
        {
            await _unidades.ActualizarAsync(id, input);
            return Ok();
        }
        catch (BDException bdex) when (bdex.TipoExcepcion == EnumBDException.Usuario)
        {
            ModelState.AddModelError("", bdex.Message);
            return ProblemaValidacion();
        }
    }
}
```

### Qué devuelve ProblemaValidacion()

`ProblemaValidacion()` construye un `ValidationProblemDetails` con el `ModelState` actual:

```json
{
  "title": "Error de validación",
  "detail": "El servidor ha rechazado la operación",
  "status": 400,
  "errors": {
    "": ["La unidad ya está bloqueada y no puede modificarse"]
  }
}
```

Ese `errors[""]` viaja al frontend y `adaptarProblemDetails()` lo mete en `erroresGlobales`.

---

## 12.5 Vue: pintar errores con useGestionFormularios v2 {#gestion-formularios}

`useGestionFormularios` v2 (de `@vueua/components`) gestiona en un solo composable la validación de cliente y los errores del servidor. No requiere TanStack Form ni Pinia.

### Importación y estado disponible

```typescript
import { useGestionFormularios } from '@vueua/components/composables/use-gestion-formularios';

const {
  modelState,          // errores por campo (array de mensajes)
  erroresGlobales,     // errores sin campo (key "" del servidor, refine() de Zod sin path)
  hayErrores,          // resultado de la última validación de cliente
  hayErroresServidor,  // true si hay algo en modelState o erroresGlobales

  errorDeCampo,        // (campo) => string | undefined — primer error del campo
  erroresDeCampo,      // (campo) => string[] — todos los errores del campo

  validarFormulario,   // (ref) => boolean — HTML5 + Bootstrap
  validarConEsquema,   // (ZodSchema, datos) => boolean — Zod (opt-in)

  adaptarProblemDetails, // (pd, ref, prefijo?) — carga errores del servidor
  inicializarMensajeError, // () — limpia todo antes del submit
} = useGestionFormularios({ aislado: true }); // siempre aislado: true
```

::: warning SIEMPRE `{ aislado: true }`
Sin esta opción, el estado es compartido entre todos los componentes de la pantalla. Si hay dos formularios activos (un modal sobre una lista, dos tabs), se interfieren. Con `{ aislado: true }`, cada instancia tiene su propio estado.
:::

### Flujo de submit

```typescript
const formRef = ref<HTMLFormElement | null>(null);
const cargando = ref(false);
const datos = ref({ nombreEs: '', nombreCa: '', granularidad: 15, numCitasSimultaneas: 1 });

async function guardar() {
  // 1. Limpiar errores del envío anterior
  inicializarMensajeError();

  // 2. Validación de cliente (HTML5 + Bootstrap)
  if (!validarFormulario(formRef)) return;

  // 3. Petición al servidor
  cargando.value = true;
  try {
    await peticion('/unidades', verbosAxios.POST, datos.value);
    avisar('Guardado', 'La unidad se ha creado correctamente');
  } catch (error: any) {
    if (error.response?.status === 400) {
      // 4. Errores de validación → distribuir a campos y erroresGlobales
      //    Prefijo 'nuevo_' debe coincidir con los id del template
      adaptarProblemDetails(error.response.data, formRef, 'nuevo_');
    } else {
      // 5. Error de sistema → toast genérico
      gestionarError(error, 'Error', 'No se pudo crear la unidad');
    }
  } finally {
    cargando.value = false;
  }
}
```

### Template: errores globales

Colocar **encima del formulario**, antes del `<form>`:

```html
<div
  v-if="erroresGlobales.length"
  class="alert alert-danger"
  role="alert"
  aria-live="assertive"
>
  <strong>No se pudo guardar:</strong>
  <ul class="mb-0 mt-1">
    <li v-for="err in erroresGlobales" :key="err">{{ err }}</li>
  </ul>
</div>
```

Aquí aparecen:
- Los errores de validaciones cruzadas de FluentValidation (clave `""`)
- Los mensajes de Oracle con `#` capturados como `BDException.Usuario`

### Template: campo con errores de servidor

El prefijo `nuevo_` del template debe coincidir con el que se pasa a `adaptarProblemDetails`:

```html
<div class="mb-3">
  <label for="nuevo_NombreEs" class="form-label">
    Nombre (español) <span class="text-danger" aria-hidden="true">*</span>
  </label>
  <input
    id="nuevo_NombreEs"
    v-model="datos.nombreEs"
    type="text"
    class="form-control"
    :class="{ 'is-invalid': errorDeCampo('nuevo_NombreEs') }"
    required
    maxlength="200"
  />
  <!-- Mensaje HTML5 (sin error de servidor activo) -->
  <div class="invalid-feedback">El nombre en español es obligatorio</div>
  <!-- Mensajes del servidor sobre este campo (puede ser más de uno) -->
  <div
    v-if="erroresDeCampo('nuevo_NombreEs').length"
    class="invalid-feedback d-block"
    role="alert"
  >
    <span
      v-for="err in erroresDeCampo('nuevo_NombreEs')"
      :key="err"
      class="d-block"
    >{{ err }}</span>
  </div>
</div>
```

::: tip POR QUÉ `erroresDeCampo` Y NO `errorDeCampo`
FluentValidation puede devolver **varios errores por campo** si no se configura `CascadeMode.Stop`. Por ejemplo, un campo `Password` puede fallar por longitud, por mayúsculas y por números a la vez. Usar `erroresDeCampo()` muestra todos; `errorDeCampo()` solo muestra el primero.
:::

### Ejemplo completo del componente

```vue
<template>
  <!-- Errores globales: encima del formulario -->
  <div
    v-if="erroresGlobales.length"
    class="alert alert-danger"
    role="alert"
    aria-live="assertive"
  >
    <strong>No se pudo guardar:</strong>
    <ul class="mb-0 mt-1">
      <li v-for="err in erroresGlobales" :key="err">{{ err }}</li>
    </ul>
  </div>

  <form ref="formRef" novalidate @submit.prevent="guardar">
    <!-- Nombre en español -->
    <div class="mb-3">
      <label for="nuevo_NombreEs" class="form-label">
        Nombre (español) <span class="text-danger" aria-hidden="true">*</span>
      </label>
      <input
        id="nuevo_NombreEs"
        v-model="datos.nombreEs"
        type="text"
        class="form-control"
        :class="{ 'is-invalid': errorDeCampo('nuevo_NombreEs') }"
        required
        maxlength="200"
      />
      <div class="invalid-feedback">El nombre en español es obligatorio</div>
      <div v-if="erroresDeCampo('nuevo_NombreEs').length" class="invalid-feedback d-block">
        <span v-for="err in erroresDeCampo('nuevo_NombreEs')" :key="err" class="d-block">
          {{ err }}
        </span>
      </div>
    </div>

    <!-- Granularidad -->
    <div class="mb-3">
      <label for="nuevo_Granularidad" class="form-label">Granularidad (minutos)</label>
      <input
        id="nuevo_Granularidad"
        v-model.number="datos.granularidad"
        type="number"
        class="form-control"
        :class="{ 'is-invalid': errorDeCampo('nuevo_Granularidad') }"
        min="5"
        max="120"
        required
      />
      <div class="invalid-feedback">Debe estar entre 5 y 120 minutos</div>
      <div v-if="erroresDeCampo('nuevo_Granularidad').length" class="invalid-feedback d-block">
        <span v-for="err in erroresDeCampo('nuevo_Granularidad')" :key="err" class="d-block">
          {{ err }}
        </span>
      </div>
    </div>

    <button type="submit" class="btn btn-primary" :disabled="cargando">
      {{ cargando ? 'Guardando...' : 'Guardar' }}
    </button>
  </form>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useGestionFormularios } from '@vueua/components/composables/use-gestion-formularios';
import { peticion, verbosAxios, gestionarError } from '@vueua/components/composables/use-axios';
import { avisar } from '@vueua/components/composables/use-toast';

const formRef = ref<HTMLFormElement | null>(null);
const cargando = ref(false);
const datos = ref({ nombreEs: '', nombreCa: '', granularidad: 15, numCitasSimultaneas: 1 });

const {
  erroresGlobales,
  errorDeCampo,
  erroresDeCampo,
  inicializarMensajeError,
  validarFormulario,
  adaptarProblemDetails,
} = useGestionFormularios({ aislado: true });

async function guardar() {
  inicializarMensajeError();
  if (!validarFormulario(formRef)) return;

  cargando.value = true;
  try {
    await peticion('/unidades', verbosAxios.POST, datos.value);
    avisar('Guardado', 'La unidad se ha creado correctamente');
  } catch (error: any) {
    if (error.response?.status === 400) {
      adaptarProblemDetails(error.response.data, formRef, 'nuevo_');
    } else {
      gestionarError(error, 'Error', 'No se pudo crear la unidad');
    }
  } finally {
    cargando.value = false;
  }
}
</script>
```

### El prefijo y por qué existe

El servidor devuelve los errores con el nombre de la propiedad del DTO: `"NombreEs"`, `"Granularidad"`. En el template, los inputs tienen `id="nuevo_NombreEs"`, `id="nuevo_Granularidad"`. El prefijo `'nuevo_'` que pasamos a `adaptarProblemDetails` hace que el composable construya `modelState["nuevo_NombreEs"]` en lugar de `modelState["NombreEs"]`.

Esto es necesario cuando en la misma pantalla hay dos formularios (alta y edición), ya que así sus errores no colisionan aunque tengan los mismos campos:

```typescript
// Formulario de alta
adaptarProblemDetails(pd, formAltaRef, 'nuevo_');   // → modelState["nuevo_NombreEs"]

// Formulario de edición en modal
adaptarProblemDetails(pd, formEditRef, 'editar_');  // → modelState["editar_NombreEs"]
```

---

## 12.6 Tabla resumen: de Oracle a Vue {#resumen}

| Origen del error | Formato servidor | Clave en `errors` | Dónde aparece en Vue |
|-----------------|-----------------|-------------------|----------------------|
| DataAnnotation `[Required]` en `NombreEs` | ValidationProblemDetails (automático) | `"NombreEs"` | `errorDeCampo('nuevo_NombreEs')` |
| FluentValidation regla de campo | ValidationProblemDetails (automático) | `"Granularidad"` | `errorDeCampo('nuevo_Granularidad')` |
| FluentValidation `AddFailure("")` (cruzada) | ValidationProblemDetails (automático) | `""` | `erroresGlobales` |
| `BDException.Usuario` + `AddModelError("")` | `ProblemaValidacion()` | `""` | `erroresGlobales` |
| `BDException.Sistema` | ErrorHandlerMiddleware → 500 | — | Mensaje genérico del middleware |

---

## 12.7 Ejercicio guiado {#ejercicio}

Vamos a aplicar lo visto al formulario de Unidades de nuestra aplicación.

### Paso 1: DataAnnotations en el DTO

Abre `Models/Unidad/ClaseGuardarUnidad.cs` y añade validaciones a todos los campos obligatorios.

### Paso 2: Configurar AddValidacionUA

En `Program.cs`, añade `builder.Services.AddValidacionUA()` antes de `AddControllersWithViews()`.

### Paso 3: Hereda de ApiControllerUA

Cambia la herencia del controlador de `ControllerBase` a `ApiControllerUA`. Añade el `catch` para `BDException.Usuario`.

### Paso 4: Validator para la regla cruzada

Crea `Validators/ClaseGuardarUnidadValidator.cs` con la regla: granularidad no puede superar la duración máxima.

Verifica que al enviar datos inválidos recibes un `400` con `errors` por campo. Verifica que al enviar granularidad > duración, el error aparece en el campo `Granularidad`.

### Paso 5: Vue con useGestionFormularios

En el componente Vue del formulario de alta:
1. Importa `useGestionFormularios` con `{ aislado: true }`.
2. Añade el bloque de errores globales encima del `<form>`.
3. Añade `:class="{ 'is-invalid': errorDeCampo('nuevo_...') }"` a cada input.
4. Añade `erroresDeCampo()` para mostrar los mensajes del servidor bajo cada input.
5. En el `catch`, llama a `adaptarProblemDetails(error.response.data, formRef, 'nuevo_')`.

Prueba enviando datos que el validador de FluentValidation rechace (granularidad > duración). Verifica que el error aparece bajo el campo `Granularidad` en el formulario.
