# Proceso de normalización

## Alcance

El esquema físico de [`../database/schema.sql`](../database/schema.sql) lleva las relaciones del modelo hasta 6FN bajo las dependencias funcionales y reglas de negocio documentadas aquí. La 6FN implica las formas anteriores; no significa que exista una tabla separada por cada forma normal. El archivo temporal opcional [`../database/6fn_temporal_example.sql`](../database/6fn_temporal_example.sql) ilustra además cómo registrar cambios independientes a través del tiempo.

La normalización depende de las reglas reales del negocio. Si cambian las reglas de identidad, unicidad o asociación, se deben volver a verificar las claves y dependencias.

## Relación inicial sin normalizar

Una hoja de atención podría combinar en una fila la identidad del paciente, los datos del profesional, la cita y listas de especialidades, diagnósticos y mediciones. Esa estructura mezcla entidades y grupos repetidos, duplica descripciones y hace difícil actualizar la información sin anomalías.

La descomposición toma como referencia estas dependencias: cada identificador de paciente, profesional, cita o consulta determina su propia información; los códigos determinan los nombres de catálogos; y las asociaciones entre entidades se registran como hechos independientes.

## Primera forma normal (1FN)

**Regla:** cada atributo almacena un valor atómico para el dominio establecido y cada fila se identifica mediante una clave.

**Aplicación:** no se guardan listas de especialidades, diagnósticos ni mediciones en una celda. Las relaciones de asociación usan una fila por par relacionado. `document_identifier` se define como una sola representación atómica del identificador documental, según el formato elegido por el proyecto.

## Segunda forma normal (2FN)

**Regla:** estar en 1FN y que cada atributo no clave dependa de la clave completa, no de una parte de una clave compuesta.

**Aplicación:** las asociaciones con clave compuesta, como `professional_specialty(professional_id, specialty_id)` y `consultation_diagnosis(consultation_id, diagnosis_code)`, contienen solo las claves de la asociación. Los nombres, licencias y demás hechos se almacenan en relaciones cuya clave determina el atributo completo.

## Tercera forma normal (3FN)

**Regla:** estar en 2FN y no tener dependencias transitivas de atributos no clave respecto de una clave.

**Aplicación:** cada hecho descriptivo se separa de la entidad o asociación a la que pertenece. Por ejemplo, `appointment_current_status` guarda el código de estado, mientras que `appointment_status_name` contiene el nombre determinado por ese código. Los nombres de especialidades, diagnósticos y tipos de medición también se separan de sus códigos.

## Forma normal de Boyce-Codd (BCNF)

**Regla:** para cada dependencia funcional no trivial `X → Y`, `X` debe ser una superclave.

**Aplicación:** las relaciones de hechos usan claves primarias que determinan el único atributo no clave; las claves alternativas conocidas se refuerzan con restricciones `UNIQUE`. Por ejemplo, el identificador documental, la licencia profesional y los correos registrados son únicos según las reglas asumidas.

## Cuarta forma normal (4FN)

**Regla:** estar en BCNF y no combinar dependencias multivaluadas independientes en una misma relación.

**Aplicación:** las especialidades de un profesional se registran en `professional_specialty`, independientemente de otros posibles conjuntos multivaluados. Los diagnósticos de una consulta se almacenan en `consultation_diagnosis`. No se forma un producto entre especialidades, diagnósticos y mediciones.

## Quinta forma normal (5FN)

**Regla:** no debe existir una dependencia de reunión no trivial que permita dividir una relación y recomponerla con exactamente las asociaciones válidas.

**Aplicación:** las asociaciones muchos a muchos se representan en relaciones puente; no se descomponen en relaciones más pequeñas sin una regla de negocio que garantice que la reunión reconstruirá las asociaciones originales sin generar pares o ternas espurios. Se asume que cada fila de esas asociaciones representa una relación real.

## Sexta forma normal (6FN)

**Regla:** la relación no admite una descomposición no trivial sin pérdida. En diseños de hechos, esto se logra separando propiedades que pueden cambiar o existir independientemente.

**Aplicación en el esquema:** las tablas de identidad (`patient`, `professional`, `specialty`, `appointment_status`, `appointment`, `consultation`, `diagnosis`, `vital_type`) contienen solo claves. Las tablas de hechos como `patient_given_names`, `appointment_starts_at`, `consultation_clinical_notes`, `diagnosis_name` y `vital_type_unit` contienen su clave y un solo atributo no clave. Las tablas puente contienen únicamente las claves de la asociación.

Por ejemplo, una cita ancha con paciente, profesional, estado, hora, duración y motivo se descompone en `appointment` y en una relación separada para cada hecho: `appointment_patient`, `appointment_professional`, `appointment_current_status`, `appointment_starts_at`, `appointment_duration_minutes` y `appointment_reason`. Su reconstrucción requiere unir esas relaciones por `appointment_id`.

El ejemplo temporal opcional extiende esta idea: separa identidad, consulta, tipo, valor y nota, permitiendo que el valor y la nota tengan historiales de vigencia independientes. Usa intervalos con inicio y fin; el valor `9999-12-31 23:59:59` puede representar una vigencia abierta. En producción deben definirse reglas para evitar intervalos superpuestos y controlar cambios concurrentes.

## Resumen

| Forma normal | Cómo se aplica |
|---|---|
| 1FN | Valores atómicos y ausencia de listas repetidas en una columna. |
| 2FN | Cada atributo depende de la clave completa; las tablas puente no repiten atributos parciales. |
| 3FN | Los atributos descriptivos y catálogos se separan para evitar dependencias transitivas. |
| BCNF | Cada determinante funcional asumido es una superclave. |
| 4FN | Las asociaciones multivaluadas independientes se guardan por separado. |
| 5FN | Las asociaciones solo se descomponen si la regla de reunión conserva exactamente las filas válidas. |
| 6FN | Tablas de identidad con claves, hechos separados y asociaciones sin atributos descriptivos adicionales. |

## Consecuencias del diseño

- Se necesitan más uniones para reconstruir entidades lógicas.
- Las tablas de hechos opcionales se representan mediante ausencia de fila, no mediante `NULL`.
- La base de datos no puede garantizar con una restricción simple que todos los hechos requeridos de una entidad se hayan insertado; la aplicación debe insertarlos dentro de transacciones.
- La regla de no solapar citas requiere validación transaccional adicional.
- La 6FN aquí es una decisión académica de diseño; un sistema clínico real también requiere auditoría, permisos, protección de datos y revisión de las reglas locales.
