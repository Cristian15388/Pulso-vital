# Pulso Vital

Proyecto académico de diseño y normalización de una base de datos para un sistema de salud. Documenta el proceso desde una tabla inicial sin normalizar hasta 6FN e incluye scripts MySQL, datos de prueba y consultas.

## Presentación en YouTube

[Ver la presentación del proyecto Pulso Vital](https://youtu.be/t9gsdHv6IN4)

## Archivos principales

- [`web/index.html`](web/index.html): presentación web interactiva del proyecto.
- [`web/styles.css`](web/styles.css): estilos responsive de la página.
- [`web/gestion.html`](web/gestion.html): pantalla local para registrar pacientes y personal de la clínica.
- [`server/index.js`](server/index.js): API local que valida y guarda registros en MySQL.
- [`docs/normalizacion.md`](docs/normalizacion.md): explicación del proceso 0FN, 1FN, 2FN, 3FN, BCNF, 4FN, 5FN y 6FN.
- [`sql/00_tabla_no_normalizada.sql`](sql/00_tabla_no_normalizada.sql): ejemplo inicial 0FN.
- [`sql/01_esquema_6fn.sql`](sql/01_esquema_6fn.sql): esquema clínico extendido con historial temporal.
- [`sql/02_datos_prueba.sql`](sql/02_datos_prueba.sql): datos de prueba.
- [`sql/03_consultas_ejemplo.sql`](sql/03_consultas_ejemplo.sql): consultas para reconstruir y analizar los datos.
- [`sql/04_registro_app.sql`](sql/04_registro_app.sql): tablas normalizadas del personal y catálogo de cargos clínicos, administrativos y de apoyo.

## Ver la página web

Abre `web/index.html` directamente en un navegador. La página es estática, no requiere instalar dependencias y permite explorar las etapas, el modelo lógico y los archivos del proyecto.

## Ejecutar el registro de pacientes y personal

La pantalla de registro necesita Node.js 18 o posterior, un backend y MySQL; no guarda datos cuando se abre como archivo ni cuando se sirve solo desde GitHub Pages.

1. Inicia el servicio local MySQL.
2. En MySQL Workbench, ejecuta `sql/01_esquema_6fn.sql` para crear `pulso_vital`.
3. Opcionalmente, ejecuta `sql/02_datos_prueba.sql` para cargar pacientes ficticios de ejemplo.
4. Ejecuta `sql/04_registro_app.sql` para agregar el catálogo de cargos y las relaciones normalizadas del personal.
5. Copia `.env.example` a `.env` (en PowerShell: `Copy-Item .env.example .env`) y configura la contraseña de MySQL y el puerto de tu servidor. No subas `.env` a GitHub.
6. Desde la carpeta del proyecto, ejecuta `npm install` y luego `npm start`.
7. Abre `http://127.0.0.1:3000/gestion.html`.

En el primer inicio sin personal se generan cinco registros ficticios con cargos aleatorios del catálogo. La aplicación incluye puestos clínicos, administrativos y de apoyo, como médicos, enfermería, recepción, limpieza, laboratorio y farmacia. Si ya tenías instalada la aplicación, vuelve a ejecutar `sql/04_registro_app.sql` para agregar los nuevos cargos. La página permite agregar personal y pacientes; los registros se guardan en MySQL y se pueden buscar, actualizar y exportar a CSV.

El servidor escucha solo en `127.0.0.1`; no lo expongas a internet ni ingreses datos reales de pacientes en esta aplicación académica sin controles de privacidad y seguridad.

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
