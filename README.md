# Pulso Vital

## Descripción

Pulso Vital es un proyecto académico enfocado en el diseño y la normalización de una base de datos. Su propósito es organizar la información de forma coherente, reducir la redundancia y mantener la integridad de los datos mediante la aplicación progresiva de las formas normales hasta la sexta forma normal (6FN).

## Objetivos

- Diseñar una estructura de datos clara y consistente.
- Identificar y reducir duplicidades y dependencias problemáticas.
- Aplicar las formas normales para mejorar la integridad y facilitar el mantenimiento de la base de datos.
- Documentar el proceso de normalización y las decisiones de diseño.

## Formas normales consideradas

- **Primera forma normal (1FN):** cada campo contiene un valor atómico y no hay grupos repetidos.
- **Segunda forma normal (2FN):** se cumple 1FN y cada atributo no clave depende de la clave completa, no solo de una parte de una clave compuesta.
- **Tercera forma normal (3FN):** se cumple 2FN y se eliminan dependencias transitivas entre atributos no clave.
- **Forma normal de Boyce-Codd (FNBC):** todo determinante de una dependencia funcional es una clave candidata.
- **Cuarta forma normal (4FN):** se eliminan dependencias multivaluadas no triviales que no estén determinadas por una clave.
- **Quinta forma normal (5FN):** se eliminan dependencias de reunión no triviales que puedan descomponerse sin pérdida de información.
- **Sexta forma normal (6FN):** las relaciones se descomponen hasta no admitir descomposiciones adicionales sin pérdida; se utiliza especialmente en diseños que necesitan representar cambios temporales de manera precisa.

## Beneficios de la normalización

La normalización ayuda a evitar anomalías al insertar, actualizar o eliminar información. También permite definir con mayor precisión las relaciones entre los datos y aplicar restricciones que favorezcan su consistencia.

## Estado del proyecto

Este repositorio presenta el proyecto y su enfoque de diseño. El esquema, los ejemplos y los archivos de implementación pueden incorporarse conforme avance el desarrollo.
