# Pulso Vital

Proyecto académico de diseño de una base de datos relacional para una clínica. Organiza información de pacientes, profesionales, especialidades, citas, consultas, diagnósticos y mediciones clínicas.

El esquema principal está descompuesto hasta 6FN: cada tabla de hechos almacena una sola propiedad no clave, mientras que las tablas de identidad y asociación conservan las claves necesarias para reconstruir las relaciones. Esto reduce redundancias, pero requiere más uniones para consultar la información.

## Contenido

- [`database/schema.sql`](database/schema.sql): crea el esquema principal descompuesto en 6FN para MySQL 8.0.16 o posterior.
- [`database/6fn_temporal_example.sql`](database/6fn_temporal_example.sql): ejemplo opcional de historial temporal de mediciones y notas.
- [`docs/modelo-relacional.md`](docs/modelo-relacional.md): entidades, relaciones, cardinalidades y reglas del modelo.
- [`docs/normalizacion.md`](docs/normalizacion.md): explicación del proceso de normalización hasta 6FN.

## Requisitos

- MySQL 8.0.16 o posterior (para aplicar las restricciones `CHECK`).
- Un cliente de MySQL, por ejemplo MySQL Workbench o el cliente de línea de comandos.

## Instalación

1. Abre una conexión a un servidor MySQL 8.0.16 o posterior.
2. Ejecuta `database/schema.sql` una sola vez en una instalación limpia.
3. Para consultar el esquema, usa la base de datos `pulso_vital`.

El script crea la base de datos si no existe. No es un script de migración ni está diseñado para ejecutarse sobre tablas ya creadas. No agrega pacientes ni datos clínicos de ejemplo.

El ejemplo temporal es opcional: ejecútalo solo después de crear el esquema principal. Crea tablas adicionales con el prefijo `ejemplo_6fn_` dentro de `pulso_vital`.

## Módulos incluidos

- **Pacientes:** datos de identificación y contacto.
- **Profesionales y especialidades:** catálogo de profesionales y relación muchos a muchos con sus especialidades.
- **Citas:** paciente, profesional, horario y estado.
- **Consultas:** registro clínico asociado a una cita.
- **Diagnósticos:** catálogo y relación muchos a muchos con las consultas.
- **Mediciones:** catálogo de tipos de medición y valores registrados durante una consulta.

## Diseño en 6FN

Las entidades tienen tablas de identidad y sus atributos se guardan en relaciones separadas. Por ejemplo, los datos de paciente se distribuyen entre `patient`, `patient_given_names`, `patient_family_names` y otras tablas de hechos. Las relaciones de muchos a muchos contienen las claves de la asociación y no repiten atributos descriptivos.

Esta descomposición prioriza el ejercicio académico de normalización por encima de la sencillez de consulta. El detalle de la reconstrucción y las dependencias asumidas está en [`docs/normalizacion.md`](docs/normalizacion.md).

## Alcance

Este es un modelo académico inicial, no un sistema clínico listo para producción. No contiene autenticación, control de acceso, auditoría, facturación, recetas ni requisitos legales específicos. Antes de usarlo con datos reales de salud, se requiere una revisión profesional de seguridad, privacidad y normativa aplicable.
