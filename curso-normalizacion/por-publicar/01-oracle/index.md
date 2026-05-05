---
title: Parte Oracle — Sesiones 1 y 2
description: Bloque de base de datos Oracle del curso de normalización (sesiones 1-2). Arquitectura ADM/WEB, convenciones, tipos, diseño de tablas, vistas orientadas a WEB y paquetes CRUD completos.
outline: deep
---

# Parte Oracle

Esta sección cubre las **sesiones 1 y 2** del curso, dedicadas a Oracle. Es el punto de entrada antes de continuar con [.NET](../parte-dotnet/) y [Vue](../parte-vue/).

## Objetivos del módulo

::: info CONTEXTO
Al finalizar este bloque serás capaz de:

- Diseñar un esquema Oracle completo para un nuevo proyecto: tablas, restricciones, índices y tablespaces
- Crear vistas orientadas al usuario WEB con alias que facilitan el automapeo .NET
- Escribir un package CRUD normalizado con validación, gestión de errores y protección de integridad funcional
- Aplicar el flujo completo `TABLA → VISTA → DTO .NET → API → Vue` sobre un caso real
  :::

## Sesiones

| Sesión                                                       | Título                                                                                    |
| ------------------------------------------------------------ | ----------------------------------------------------------------------------------------- |
| [Sesión 1](./sesiones/1-fundamentos-oracle/)                 | Fundamentos de oracle                                                                     |
| [Ejercicio sesión 1](./sesiones/2-ejercicio-fundamentos/)    | Inspección del schema y diseño de un catálogo                                             |
| [Sesión 2](./sesiones/3-tablas-vistas/)                      | Tablas, vistas y paquetes                                                                 |
| [Ejercicio sesión 2A](./sesiones/4-ejercicio-tablas-vistas/) | Diseño de vistas (`VRES_FRANJA_HORARIO`, `VRES_HORARIO_DIA`)                              |
| [Ejercicio sesión 2B](./sesiones/5-paquetes/)                | Procedimientos en paquetes (`ACTUALIZAR_BLOQUEADO`, `CREAR_HORARIO_DIA`, `CREAR_RESERVA`) |
