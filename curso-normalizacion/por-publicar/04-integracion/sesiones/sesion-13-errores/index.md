---
title: "Sesión 13: Gestión de errores de extremo a extremo"
description: Flujo de error desde Oracle hasta Vue — Result<T>, ProblemDetails, IExceptionHandler, toasts y modales
outline: deep
---

# Sesión 13: Gestión de errores de extremo a extremo

[[toc]]

::: info CONTEXTO
Un error puede originarse en Oracle (constraint violation), en el servicio .NET (regla de negocio) o en Vue (validación local). Esta sesión cubre cómo se propaga cada tipo de error a través de todas las capas y cómo se presenta al usuario de forma coherente.
:::

## Objetivos

Al finalizar esta sesión, el alumno será capaz de:
- Entender cómo se propaga un error desde Oracle hasta el usuario
- Devolver errores de negocio sin lanzar excepciones (Result\<T\>)
- Traducir el resultado del servicio a un código HTTP adecuado
- Configurar `IExceptionHandler` para excepciones no controladas
- Aplicar el estándar ProblemDetails (RFC 7807) con convenciones UA
- Notificar al usuario con toasts de confirmación, error e información
- Usar modales de confirmación antes de operaciones destructivas

## 13.1 Cómo se propaga un error {#propagacion}

::: warning IMPORTANTE
El contenido detallado de esta sesión está pendiente de publicación.
:::

Pendiente de publicación.

Material de referencia: [Validación y errores (.NET)](../../parte-dotnet/sesiones/sesion-3-validacion-errores/)

## 13.2 Result\<T\> y errores de negocio {#result-errores}

Pendiente de publicación.

## 13.3 IExceptionHandler y ProblemDetails {#exception-handler}

Pendiente de publicación.

## 13.4 Toasts y modales en Vue {#toasts-modales}

Pendiente de publicación.
