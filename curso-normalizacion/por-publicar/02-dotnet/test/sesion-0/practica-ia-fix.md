# Práctica IA-fix — Sesión 0

## Objetivo

Pedir a Copilot/ChatGPT que corrija el siguiente `Program.cs` con **5 errores** de inyección de dependencias y pipeline.

```csharp
var builder = WebApplication.CreateBuilder(args);

// 🐛 1: Singleton para un servicio que usa conexión BD
builder.Services.AddSingleton<IClaseUnidades, ClaseUnidades>();

// 🐛 2: Falta registrar los controladores
builder.Services.AddOpenApi();

var app = builder.Build();

// 🐛 3: UseAuthorization ANTES de UseRouting
app.UseAuthorization();
app.UseRouting();

// 🐛 4: UseAuthentication DESPUÉS de UseAuthorization
app.UseAuthentication();

// 🐛 5: Falta MapControllers
app.Run();
```

## Qué debe arreglar la IA

1. **Ciclo de vida** — Cambiar `AddSingleton` a `AddScoped` para servicios con conexión a BD.
2. **Registro de controladores** — Añadir `AddControllersWithViews()` (o `AddControllers()`).
3. **Orden del pipeline** — `UseRouting()` → `UseAuthentication()` → `UseAuthorization()`.
4. **Mapeo de endpoints** — Añadir `app.MapControllers()` antes de `app.Run()`.

## Solución esperada

```csharp
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllersWithViews();
builder.Services.AddScoped<IClaseUnidades, ClaseUnidades>();
builder.Services.AddOpenApi();

var app = builder.Build();

app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run();
```
