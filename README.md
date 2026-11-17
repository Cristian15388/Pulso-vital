# Pulso Vital

Proyecto académico de diseño y normalización de una base de datos para un sistema de salud. Documenta el proceso desde una tabla inicial sin normalizar hasta 6FN e incluye scripts MySQL, datos de prueba y consultas.

## Archivos principales

- [`web/index.html`](web/index.html): presentación web interactiva del proyecto.
- [`web/styles.css`](web/styles.css): estilos responsive de la página.
- [`docs/normalizacion.md`](docs/normalizacion.md): explicación del proceso 0FN, 1FN, 2FN, 3FN, BCNF, 4FN, 5FN y 6FN.
- [`sql/00_tabla_no_normalizada.sql`](sql/00_tabla_no_normalizada.sql): ejemplo inicial 0FN.
- [`sql/01_esquema_6fn.sql`](sql/01_esquema_6fn.sql): esquema clínico extendido con historial temporal.
- [`sql/02_datos_prueba.sql`](sql/02_datos_prueba.sql): datos de prueba.
- [`sql/03_consultas_ejemplo.sql`](sql/03_consultas_ejemplo.sql): consultas para reconstruir y analizar los datos.

## Ver la página web

Abre `web/index.html` directamente en un navegador. La página es estática, no requiere instalar dependencias y permite explorar las etapas, el modelo lógico y los archivos del proyecto.

## Ejecución del esquema extendido

Requisitos: MySQL 8.0 o posterior y un cliente como MySQL Workbench.

1. Ejecuta `sql/01_esquema_6fn.sql`.
2. Ejecuta `sql/02_datos_prueba.sql`.
3. Ejecuta `sql/03_consultas_ejemplo.sql` para probar las consultas.
4. Opcionalmente, ejecuta `sql/00_tabla_no_normalizada.sql` para revisar la tabla de partida 0FN en la base separada `pulso_vital_0fn`.

Ejecuta los scripts de creación en una base de datos limpia. El script 0FN es independiente del esquema principal.

## Modelo compacto complementario

El directorio [`database/`](database/) contiene otra versión compacta del modelo, descompuesta en relaciones de hechos de 6FN:

- [`database/schema.sql`](database/schema.sql): crea `pulso_vital_6fn_basico`.
- [`database/6fn_temporal_example.sql`](database/6fn_temporal_example.sql): agrega un ejemplo de historial temporal a ese esquema.
- [`docs/modelo-relacional.md`](docs/modelo-relacional.md): describe las entidades y relaciones de esta versión compacta.

Las versiones crean bases de datos distintas (`pulso_vital` y `pulso_vital_6fn_basico`), por lo que pueden coexistir. Para cada versión, ejecuta sus scripts sobre una base limpia.

## Alcance

El proyecto es académico y no está listo para manejar información clínica real. Antes de un uso real se requieren controles de acceso, auditoría, privacidad, seguridad y revisión de la normativa aplicable.
