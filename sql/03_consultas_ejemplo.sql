USE pulso_vital;

-- 1. Vista actual consolidada de pacientes (reconstruyendo desde tablas 6FN)
SELECT
    p.id_paciente,
    p.tipo_documento,
    p.numero_documento,
    pn.nombres,
    pa.apellidos,
    pd.direccion,
    c.nombre AS ciudad,
    d.nombre AS departamento,
    an.nombre AS aseguradora_actual
FROM pacientes p
JOIN paciente_nombres_hist pn
    ON pn.id_paciente = p.id_paciente AND pn.valido_hasta IS NULL
JOIN paciente_apellidos_hist pa
    ON pa.id_paciente = p.id_paciente AND pa.valido_hasta IS NULL
JOIN paciente_direccion_hist pd
    ON pd.id_paciente = p.id_paciente AND pd.valido_hasta IS NULL
JOIN paciente_ciudad_hist pc
    ON pc.id_paciente = p.id_paciente AND pc.valido_hasta IS NULL
JOIN ciudades c
    ON c.id_ciudad = pc.id_ciudad
JOIN departamentos d
    ON d.id_departamento = c.id_departamento
JOIN paciente_aseguradora_hist paseg
    ON paseg.id_paciente = p.id_paciente AND paseg.valido_hasta IS NULL
JOIN aseguradora_nombre_hist an
    ON an.id_aseguradora = paseg.id_aseguradora AND an.valido_hasta IS NULL;

-- 2. Consulta temporal (Point-in-Time): ¿Cuál era la dirección y aseguradora de los pacientes el 2025-06-01?
SELECT
    p.numero_documento,
    CONCAT(pn.nombres, ' ', pa.apellidos) AS paciente,
    pd.direccion AS direccion_en_fecha,
    an.nombre AS aseguradora_en_fecha
FROM pacientes p
JOIN paciente_nombres_hist pn
    ON pn.id_paciente = p.id_paciente
   AND pn.valido_desde <= '2025-06-01 12:00:00'
   AND (pn.valido_hasta IS NULL OR pn.valido_hasta > '2025-06-01 12:00:00')
JOIN paciente_apellidos_hist pa
    ON pa.id_paciente = p.id_paciente
   AND pa.valido_desde <= '2025-06-01 12:00:00'
   AND (pa.valido_hasta IS NULL OR pa.valido_hasta > '2025-06-01 12:00:00')
JOIN paciente_direccion_hist pd
    ON pd.id_paciente = p.id_paciente
   AND pd.valido_desde <= '2025-06-01 12:00:00'
   AND (pd.valido_hasta IS NULL OR pd.valido_hasta > '2025-06-01 12:00:00')
JOIN paciente_aseguradora_hist paseg
    ON paseg.id_paciente = p.id_paciente
   AND paseg.valido_desde <= '2025-06-01 12:00:00'
   AND (paseg.valido_hasta IS NULL OR paseg.valido_hasta > '2025-06-01 12:00:00')
JOIN aseguradora_nombre_hist an
    ON an.id_aseguradora = paseg.id_aseguradora
   AND an.valido_desde <= '2025-06-01 12:00:00'
   AND (an.valido_hasta IS NULL OR an.valido_hasta > '2025-06-01 12:00:00');

-- 3. Evolución de signos vitales de un paciente
SELECT
    fc.registrado_en,
    fc.valor_lpm AS frecuencia_cardiaca_lpm,
    ps.valor_mmhg AS presion_sistolica_mmhg,
    pd.valor_mmhg AS presion_diastolica_mmhg
FROM signo_frecuencia_cardiaca fc
LEFT JOIN signo_presion_sistolica ps
    ON ps.id_paciente = fc.id_paciente AND ps.registrado_en = fc.registrado_en
LEFT JOIN signo_presion_diastolica pd
    ON pd.id_paciente = fc.id_paciente AND pd.registrado_en = fc.registrado_en
WHERE fc.id_paciente = 1
ORDER BY fc.registrado_en DESC;

-- 4. Reconstrucción de cobertura clínica desde tablas 5FN
SELECT
    an.nombre AS aseguradora,
    e.nombre AS especialidad,
    m.nombre_generico AS medicamento
FROM aseguradora_especialidades ae
JOIN especialidad_medicamentos em
    ON em.id_especialidad = ae.id_especialidad
JOIN aseguradora_medicamentos am
    ON am.id_aseguradora = ae.id_aseguradora
   AND am.id_medicamento = em.id_medicamento
JOIN aseguradora_nombre_hist an
    ON an.id_aseguradora = ae.id_aseguradora AND an.valido_hasta IS NULL
JOIN especialidades e
    ON e.id_especialidad = ae.id_especialidad
JOIN medicamentos m
    ON m.id_medicamento = em.id_medicamento
ORDER BY aseguradora, especialidad, medicamento;
