# Guiones de YouTube — Pulso Vital (15 minutos)

**Formato:** Video a dos voces (Alexander Arpushaina y Cristian Padilla)  
**Duración total:** 15:00 minutos  
**Objetivo:** Explicar la página web de **Pulso Vital**, el proceso completo de normalización (**0FN → 6FN**) y el código SQL + backend Node.js conectado a MySQL 8.0.

---

## Mapa de Tiempos (15:00 min)

| Bloque | Tiempo | Duración | Responsable | Qué se muestra en pantalla |
| :--- | :--- | :--- | :--- | :--- |
| 1. Intro y vista general de la página | `00:00 – 01:30` | 1:30 | **Alexander** | `http://127.0.0.1:3000/` (Hero y resumen) |
| 2. De 0FN a 1FN y 2FN | `01:30 – 04:00` | 2:30 | **Alexander** | `#recorrido` en la web + `sql/00_tabla_no_normalizada.sql` |
| 3. 3FN y dependencias transitivas | `04:00 – 05:30` | 1:30 | **Alexander** | `#recorrido` (3FN) + tablas `departamentos`, `ciudades`, `aseguradoras` |
| 4. FNBC (Boyce-Codd) y 4FN | `05:30 – 07:45` | 2:15 | **Cristian** | `consultorio_especialidad`, `paciente_telefono_hist`, `paciente_alergia_hist` |
| 5. 5FN y el salto a 6FN (Temporalidad) | `07:45 – 10:30` | 2:45 | **Cristian** | `#modelo` + `sql/01_esquema_6fn.sql` + `sql/02_datos_prueba.sql` |
| 6. Consultas SQL en MySQL (Reconstrucción 6FN) | `10:30 – 12:15` | 1:45 | **Alexander** | MySQL Workbench + `sql/03_consultas_ejemplo.sql` |
| 7. Backend Node.js y Gestión Clínica en vivo | `12:15 – 14:15` | 2:00 | **Cristian** | `server/index.js` + `http://127.0.0.1:3000/gestion.html` |
| 8. Cierre y repositorio | `14:15 – 15:00` | 0:45 | **Ambos** | `#recursos` en la web + repo en GitHub |

---

## Guion 1: Alexander Arpushaina (~7 min 30 s)

> **Enfoque de Alexander:** Introducción, recorrido visual de la página principal (`index.html`), las primeras formas normales (**0FN, 1FN, 2FN, 3FN**), las consultas de reconstrucción en MySQL Workbench y el cierre.

### Bloque 1 — Introducción y recorrido de la página (`00:00 – 01:30`)
> *[Pantalla: `http://127.0.0.1:3000/` en la sección `#inicio`]*

**Alexander:**  
"¡Hola a todos! Bienvenidos al canal. Hoy junto con mi compañero **Cristian Padilla** les vamos a presentar **Pulso Vital**, nuestro proyecto de Bases de Datos enfocado en el diseño y la normalización progresiva de una base de datos clínica en **MySQL 8.0**, llegando hasta la **Sexta Forma Normal (6FN)**.

Si miramos la página principal que construimos en `web/index.html`, no es solo un sitio informativo: está dividida en secciones que cuentan la historia del modelo. En el inicio vemos el propósito del sistema: organizar datos de pacientes, médicos, citas, diagnósticos y signos vitales sin redundancia ni anomalías.

Más abajo tenemos el recorrido interactivo por las **ocho etapas de normalización**, la vista del modelo relacional, los scripts SQL descargables y un enlace directo a nuestro módulo funcional de **Registro y Gestión Clínica** conectado a una API en Node.js. Yo arranco explicando cómo pasamos del caos inicial en **0FN** hasta la **3FN**, y luego Cristian toma la posta desde **Boyce-Codd** hasta **6FN** y el backend."

---

### Bloque 2 — 0FN, 1FN y 2FN (`01:30 – 04:00`)
> *[Pantalla: Sección `#recorrido` en `index.html`, luego cambiar a VS Code mostrando `sql/00_tabla_no_normalizada.sql`]*

**Alexander:**  
"Empecemos por el punto de partida: la **Forma No Normalizada (0FN)**, que pueden ver en nuestro archivo `sql/00_tabla_no_normalizada.sql`.

Imaginemos una clínica pequeña que guarda todo en una sola tabla plana llamada `registro_clinico_bruto`. ¿Qué problema tiene? Miren este registro de ejemplo:
- En `paciente_telefonos` tenemos `'3001112233, 3104445566'` en una sola celda.
- En `medico_especialidades` dice `'Cardiología, Medicina Interna'`.
- En `medicamentos_recetados` y `signos_vitales` hay varios datos empaquetados en un mismo texto.

Esto provoca **anomalías graves**: no puedes registrar un médico si no tiene una cita, y si una aseguradora cambia de nombre, tendrías que actualizar cientos de filas repetidas.

Para pasar a **Primera Forma Normal (1FN)** aplicamos una regla simple pero estricta: **cada campo debe ser atómico** y no puede haber grupos repetidos.
- Separamos los signos vitales en columnas individuales: frecuencia cardíaca, presión sistólica, presión diastólica, temperatura y saturación de oxígeno.
- Dividimos el nombre en `nombres` y `apellidos`.
- Sacamos las listas de teléfonos, alergias y medicamentos a filas individuales, definiendo una clave primaria compuesta.

Pero al hacer eso aparece el problema que resuelve la **Segunda Forma Normal (2FN)**: las **dependencias parciales**. En 1FN, como la clave primaria es compuesta (por ejemplo, `id_cita` + `id_medicamento`), el nombre del paciente o el nombre del medicamento terminan dependiendo solo de *una parte* de la clave, no de toda la clave.

En **2FN**, separamos cada entidad en su propia tabla: `pacientes`, `medicos`, `citas`, `medicamentos` y `prescripciones`, de modo que cada atributo no clave dependa de la clave primaria completa."

---

### Bloque 3 — Tercera Forma Normal (3FN) (`04:00 – 05:30`)
> *[Pantalla: Sección `#recorrido` en 3FN y `sql/01_esquema_6fn.sql` mostrando `departamentos`, `ciudades`, `aseguradoras`, `sedes`]*

**Alexander:**  
"Ya estamos en 2FN, pero todavía quedan **dependencias transitivas**, y ahí entra la **Tercera Forma Normal (3FN)**.

Una dependencia transitiva ocurre cuando un atributo no clave depende de otro atributo no clave, en lugar de depender directamente de la clave primaria. Por ejemplo:
- En pacientes teníamos `id_paciente → ciudad → departamento`. Si cambia el nombre del departamento o si queremos listar departamentos sin pacientes, teníamos problemas.
- Lo mismo pasaba con `id_paciente → nit_aseguradora → nombre_aseguradora`, o en las citas con `id_consultorio → sede`.

En **3FN** cortamos esas cadenas transitivas creando tablas independientes: `departamentos`, `ciudades`, `aseguradoras`, `sedes`, `consultorios` y `diagnosticos`. Con esto la gran mayoría de sistemas tradicionales se detienen, pero nosotros fuimos más allá. Te doy paso, Cristian, para que expliques **Boyce-Codd, 4FN, 5FN y 6FN**."

---

### Bloque 6 — Consultas SQL en MySQL Workbench (`10:30 – 12:15`)
> *[Pantalla: MySQL Workbench con `sql/03_consultas_ejemplo.sql` y los resultados ejecutados]*

**Alexander:**  
"Gracias, Cristian. Ahora que vimos cómo **6FN** divide cada atributo temporal en su propia tabla —llegando a **39 tablas** en nuestro esquema `pulso_vital`—, la pregunta lógica es: *¿cómo consulto toda la información junta si está tan atomizada?*

Aquí en **MySQL Workbench** les muestro `sql/03_consultas_ejemplo.sql`:
1. **Primera consulta (Vista actual del paciente):** Hacemos `JOIN` entre `pacientes` y las tablas históricas filtrando por `valido_hasta IS NULL`. Con eso obtenemos el dato vigente hoy de nombres, apellidos, dirección, ciudad y aseguradora.
2. **Segunda consulta (*Point-in-Time* o consulta en el tiempo):** Si queremos saber cómo estaba la base de datos el `2025-06-01`, filtramos con `valido_desde <= '2025-06-01 12:00:00'` y `(valido_hasta IS NULL OR valido_hasta > '2025-06-01 12:00:00')`. Miren el resultado: nos devuelve la dirección anterior de María Fernanda y la aseguradora anterior de Jorge Luis, sin haber perdido ni un solo dato histórico.
3. **Tercera consulta:** Reconstruimos la línea de tiempo de signos vitales (`signo_frecuencia_cardiaca`, `signo_presion_sistolica`, `signo_presion_diastolica`).
4. **Cuarta consulta:** Reunimos las tres tablas de **5FN** (`aseguradora_especialidades`, `especialidad_medicamentos`, `aseguradora_medicamentos`) para reconstruir exactamente qué medicamentos cubre cada aseguradora por especialidad.

Ahora Cristian les muestra cómo conectamos todo esto a nuestra aplicación web."

---

### Bloque 8 — Cierre (`14:15 – 15:00`)
> *[Pantalla: `#recursos` en `http://127.0.0.1:3000/`]*

**Alexander:**  
"Y así cerramos el recorrido completo de **Pulso Vital**: desde una tabla plana llena de anomalías en **0FN**, hasta un modelo **6FN** con trazabilidad temporal completa corriendo en **MySQL 8.0** y conectado a una interfaz web real."

**Cristian:**  
"Todo el código, la documentación paso a paso en `docs/normalizacion.md`, el modelo relacional y los scripts SQL están disponibles en nuestro repositorio de GitHub que dejamos en la descripción y en la sección de recursos de la página."

**Alexander:**  
"Si les sirvió este video para entender las formas normales aplicadas a un proyecto real, déjennos un like, suscríbanse y cuéntennos en los comentarios qué otra forma normal o consulta les gustaría ver. ¡Nos vemos en el próximo video!"

---

## Guion 2: Cristian Padilla (~7 min 30 s)

> **Enfoque de Cristian:** Formas normales avanzadas (**FNBC, 4FN, 5FN y 6FN**), demostración del código del servidor en Node.js (`server/index.js`, `server/validation.js`) y demo en vivo de la página de gestión (`web/gestion.html`).

### Bloque 4 — FNBC (Boyce-Codd) y 4FN (`05:30 – 07:45`)
> *[Pantalla: `docs/normalizacion.md` (secciones 6 y 7) y `sql/01_esquema_6fn.sql`]*

**Cristian:**  
"¡Gracias, Alexander! A partir de **3FN**, la base de datos ya parece ordenada, pero todavía existen casos sutiles que rompen la integridad.

El primero es la **Forma Normal de Boyce-Codd (FNBC)**, que exige que **todo determinante de una dependencia funcional sea una clave candidata**.
Veamos nuestro caso clínico real:
- Cada `consultorio` está equipado para una única `especialidad` (`id_consultorio → id_especialidad`).
- Un médico en una especialidad atiende en un consultorio asignado.
Si juntamos `(id_medico, id_especialidad, id_consultorio)` en una sola tabla, todas las columnas forman parte de alguna clave candidata, así que cumple 3FN. **Pero viola FNBC**, porque `id_consultorio` determina a `id_especialidad` sin ser clave candidata.
¿Cómo lo resolvemos en `sql/01_esquema_6fn.sql`? Lo dividimos en dos tablas: `consultorio_especialidad` y `medico_consultorio_hist`.

Luego pasamos a la **Cuarta Forma Normal (4FN)**, donde eliminamos las **dependencias multivaluadas** independientes.
Un paciente puede tener varios teléfonos y varias alergias, y ambos hechos no tienen relación entre sí. Si los guardáramos en la misma tabla, cada teléfono tendría que repetirse por cada alergia (un producto cartesiano innecesario).
Por eso en 4FN los separamos en `paciente_telefono_hist` y `paciente_alergia_hist`."

---

### Bloque 5 — 5FN y Sexta Forma Normal (6FN) (`07:45 – 10:30`)
> *[Pantalla: `#modelo` en `index.html`, luego `sql/01_esquema_6fn.sql` y `sql/02_datos_prueba.sql`]*

**Cristian:**  
"Ahora llegamos a la **Quinta Forma Normal (5FN)**, que elimina dependencias de reunión cíclicas.
En nuestro dominio clínico tenemos tres conceptos relacionados: **Aseguradoras**, **Especialidades** y **Medicamentos**. Si una aseguradora cubre una especialidad, esa especialidad prescribe un medicamento, y la aseguradora aprueba ese medicamento en su vademécum, guardar la terna completa genera redundancia al insertar o eliminar reglas.
En 5FN lo descomponemos sin pérdida en tres tablas binarias:
- `aseguradora_especialidades`
- `especialidad_medicamentos`
- `aseguradora_medicamentos`

Y finalmente, la protagonista del proyecto: la **Sexta Forma Normal (6FN)**.
Una tabla está en 6FN cuando es **irreducible**: contiene únicamente la clave primaria de la entidad, su intervalo de validez temporal (`valido_desde`, `valido_hasta`) y **a lo sumo un atributo** que cambia en el tiempo.

¿Por qué es tan útil en salud? Porque los datos clínicos cambian de forma asíncrona. Miren `sql/02_datos_prueba.sql`:
- La paciente María Fernanda se muda de dirección el 1 de mayo de 2026. Solo cerramos el intervalo en `paciente_direccion_hist` y abrimos uno nuevo, **sin duplicar** sus nombres, apellidos ni su aseguradora.
- Lo mismo pasa con las series temporales de signos vitales: `signo_frecuencia_cardiaca`, `signo_presion_sistolica`, `signo_presion_diastolica`, `signo_temperatura` y `signo_saturacion_o2` se registran por separado en su propio instante exacto.
- Incluso en las prescripciones, podemos ajustar la dosis en `prescripcion_dosis_hist` sin tocar la frecuencia en `prescripcion_frecuencia_hist`.

Alexander, muéstranos ahora cómo se consultan estos datos en MySQL Workbench."

---

### Bloque 7 — Código del Backend y Gestión Clínica en vivo (`12:15 – 14:15`)
> *[Pantalla: VS Code mostrando `server/index.js` y `server/validation.js`, luego navegador en `http://127.0.0.1:3000/gestion.html`]*

**Cristian:**  
"Para que este modelo 6FN no se quede solo en scripts SQL, construimos un backend en **Node.js con Express y `mysql2`** en `server/index.js`, acompañado de validaciones en `server/validation.js` y pruebas unitarias con `node --test`.

Si vemos el código de `server/index.js`:
- Tenemos endpoints como `GET /api/health`, `GET /api/patients`, `POST /api/patients`, `GET /api/administrators`, `GET /api/roles` y `POST /api/administrators`.
- Cuando registramos un paciente desde `POST /api/patients`, el servidor abre una **transacción en MySQL**, inserta la identidad inmutable en `pacientes` y reparte los atributos vigentes en `paciente_nombres_hist`, `paciente_apellidos_hist` y `paciente_telefono_hist` con `valido_desde = NOW()`.

Ahora veámoslo funcionando en `http://127.0.0.1:3000/gestion.html`:
- Arriba a la derecha vemos el indicador **`Conectado · pulso_vital`**, confirmado por `/api/health`.
- Tenemos dos pestañas: **Pacientes** y **Personal de la clínica**, con buscador en tiempo real y exportación.
- Si hacemos clic en **Registrar paciente**, se abre el formulario modal donde validamos tipo de documento, fecha de nacimiento y teléfono; al guardar, el registro aparece inmediatamente en la tabla y queda persistido siguiendo la estructura **6FN** en MySQL."

*(Pasa el cierre final a Alexander para despedir el video en el Bloque 8).*

---

## Notas de producción para la grabación
- **Resolución recomendada:** 1920×1080 (1080p) con zoom al 125% en VS Code y MySQL Workbench para que el SQL y el código JS se lean bien en YouTube.
- **Antes de grabar:** ejecutar `npm start` dentro de `Pulso-vital` y tener abiertas 3 ventanas listas:
  1. Navegador en `http://127.0.0.1:3000/` (y otra pestaña en `gestion.html`).
  2. MySQL Workbench con `sql/03_consultas_ejemplo.sql` cargado.
  3. VS Code con `sql/00_tabla_no_normalizada.sql`, `sql/01_esquema_6fn.sql` y `server/index.js`.
