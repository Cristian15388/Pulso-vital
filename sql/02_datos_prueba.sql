

USE pulso_vital;

-- 1. Catálogos base
INSERT INTO departamentos (id_departamento, codigo_dane, nombre) VALUES
(1, '08', 'Atlántico'),
(2, '11', 'Bogotá D.C.');

INSERT INTO ciudades (id_ciudad, id_departamento, codigo_dane, nombre) VALUES
(1, 1, '08001', 'Barranquilla'),
(2, 2, '11001', 'Bogotá');

INSERT INTO aseguradoras (id_aseguradora, nit) VALUES
(1, '900123456-1'),
(2, '800987654-3');

INSERT INTO aseguradora_nombre_hist (id_aseguradora, valido_desde, valido_hasta, nombre) VALUES
(1, '2020-01-01 00:00:00', NULL, 'Salud Integral EPS'),
(2, '2020-01-01 00:00:00', NULL, 'Vida Plena EPS');

INSERT INTO sedes (id_sede, codigo_sede, id_ciudad) VALUES
(1, 'SED-BAQ-N', 1),
(2, 'SED-BOG-C', 2);

INSERT INTO sede_nombre_hist (id_sede, valido_desde, valido_hasta, nombre) VALUES
(1, '2022-01-01 00:00:00', NULL, 'Sede Norte Barranquilla'),
(2, '2022-01-01 00:00:00', NULL, 'Sede Central Bogotá');

INSERT INTO consultorios (id_consultorio, id_sede, codigo_consultorio, piso) VALUES
(1, 1, 'C-204', 2),
(2, 1, 'C-102', 1);

INSERT INTO especialidades (id_especialidad, codigo_especialidad, nombre) VALUES
(1, 'CARD', 'Cardiología'),
(2, 'MEDINT', 'Medicina Interna');

INSERT INTO consultorio_especialidad (id_consultorio, id_especialidad) VALUES
(1, 1),
(2, 2);

INSERT INTO diagnosticos (id_diagnostico, codigo_cie10, descripcion) VALUES
(1, 'I10', 'Hipertensión esencial (primaria)'),
(2, 'E11', 'Diabetes mellitus tipo 2');

INSERT INTO medicamentos (id_medicamento, codigo_atc, nombre_generico) VALUES
(1, 'C09CA01', 'Losartán 50mg'),
(2, 'B01AC06', 'Ácido Acetilsalicílico 100mg'),
(3, 'A10BA02', 'Metformina 850mg');

INSERT INTO alergias (id_alergia, codigo_alergia, nombre) VALUES
(1, 'ALG-PEN', 'Penicilina'),
(2, 'ALG-POL', 'Polen');

-- 2. Cobertura 5FN
INSERT INTO aseguradora_especialidades (id_aseguradora, id_especialidad) VALUES
(1, 1), (1, 2), (2, 1);

INSERT INTO especialidad_medicamentos (id_especialidad, id_medicamento) VALUES
(1, 1), (1, 2), (2, 3);

INSERT INTO aseguradora_medicamentos (id_aseguradora, id_medicamento) VALUES
(1, 1), (1, 2), (1, 3), (2, 1);

-- 3. Pacientes y atributos temporales 6FN
INSERT INTO pacientes (id_paciente, tipo_documento, numero_documento, fecha_nacimiento) VALUES
(1, 'CC', '1045789123', '1988-04-12'),
(2, 'CC', '72345678', '1975-11-03');

INSERT INTO paciente_nombres_hist (id_paciente, valido_desde, valido_hasta, nombres) VALUES
(1, '2024-01-10 08:00:00', NULL, 'María Fernanda'),
(2, '2024-02-01 09:00:00', NULL, 'Jorge Luis');

INSERT INTO paciente_apellidos_hist (id_paciente, valido_desde, valido_hasta, apellidos) VALUES
(1, '2024-01-10 08:00:00', NULL, 'Gómez López'),
(2, '2024-02-01 09:00:00', NULL, 'Martínez Ruiz');

-- Cambio temporal independiente de dirección en 6FN (sin duplicar nombre ni aseguradora)
INSERT INTO paciente_direccion_hist (id_paciente, valido_desde, valido_hasta, direccion) VALUES
(1, '2024-01-10 08:00:00', '2026-05-01 00:00:00', 'Cra 45 # 72-18'),
(1, '2026-05-01 00:00:00', NULL, 'Calle 84 # 51B-20'),
(2, '2024-02-01 09:00:00', NULL, 'Cra 38 # 64-12');

INSERT INTO paciente_ciudad_hist (id_paciente, valido_desde, valido_hasta, id_ciudad) VALUES
(1, '2024-01-10 08:00:00', NULL, 1),
(2, '2024-02-01 09:00:00', NULL, 1);

INSERT INTO paciente_aseguradora_hist (id_paciente, valido_desde, valido_hasta, id_aseguradora) VALUES
(1, '2024-01-10 08:00:00', NULL, 1),
(2, '2024-02-01 09:00:00', '2025-12-31 23:59:59', 2),
(2, '2026-01-01 00:00:00', NULL, 1);

INSERT INTO paciente_telefono_hist (id_paciente, telefono, valido_desde, valido_hasta, tipo_telefono) VALUES
(1, '3001112233', '2024-01-10 08:00:00', NULL, 'MOVIL'),
(1, '3104445566', '2024-01-10 08:00:00', NULL, 'EMERGENCIA'),
(2, '3157778899', '2024-02-01 09:00:00', NULL, 'MOVIL');

INSERT INTO paciente_alergia_hist (id_paciente, id_alergia, valido_desde, valido_hasta, severidad) VALUES
(1, 1, '2024-01-10 08:00:00', NULL, 'SEVERA'),
(1, 2, '2024-01-10 08:00:00', NULL, 'LEVE');

-- 4. Médicos
INSERT INTO medicos (id_medico, numero_licencia) VALUES
(1, 'MED-77889'),
(2, 'MED-88990');

INSERT INTO medico_nombre_hist (id_medico, valido_desde, valido_hasta, nombre_completo) VALUES
(1, '2022-01-01 00:00:00', NULL, 'Dr. Carlos Andrés Mendoza'),
(2, '2023-03-15 00:00:00', NULL, 'Dra. Laura Sofía Herrera');

INSERT INTO medico_consultorio_hist (id_medico, id_consultorio, valido_desde, valido_hasta) VALUES
(1, 1, '2025-01-01 00:00:00', NULL),
(2, 2, '2025-01-01 00:00:00', NULL);

-- 5. Citas y prescripciones
INSERT INTO citas (id_cita, fecha_hora_programada) VALUES
(1001, '2026-10-15 09:00:00'),
(1002, '2026-11-10 10:30:00');

INSERT INTO cita_paciente (id_cita, id_paciente) VALUES (1001, 1), (1002, 2);
INSERT INTO cita_medico (id_cita, id_medico) VALUES (1001, 1), (1002, 2);
INSERT INTO cita_consultorio (id_cita, id_consultorio) VALUES (1001, 1), (1002, 2);

INSERT INTO cita_estado_hist (id_cita, valido_desde, valido_hasta, estado) VALUES
(1001, '2026-10-01 10:00:00', '2026-10-15 09:00:00', 'PROGRAMADA'),
(1001, '2026-10-15 09:00:00', '2026-10-15 09:35:00', 'EN_CURSO'),
(1001, '2026-10-15 09:35:00', NULL, 'COMPLETADA'),
(1002, '2026-11-01 14:00:00', NULL, 'PROGRAMADA');

INSERT INTO cita_diagnostico (id_cita, id_diagnostico, registrado_en) VALUES
(1001, 1, '2026-10-15 09:30:00');

INSERT INTO prescripcion_dosis_hist (id_cita, id_medicamento, valido_desde, valido_hasta, dosis) VALUES
(1001, 1, '2026-10-15 09:32:00', '2026-11-01 08:00:00', '50mg'),
(1001, 1, '2026-11-01 08:00:00', NULL, '100mg'),
(1001, 2, '2026-10-15 09:32:00', NULL, '100mg');

INSERT INTO prescripcion_frecuencia_hist (id_cita, id_medicamento, valido_desde, valido_hasta, frecuencia_horas) VALUES
(1001, 1, '2026-10-15 09:32:00', NULL, 12),
(1001, 2, '2026-10-15 09:32:00', NULL, 24);

-- 6. Series temporales de signos vitales
INSERT INTO signo_frecuencia_cardiaca (id_paciente, registrado_en, valor_lpm) VALUES
(1, '2026-10-15 09:05:00', 82),
(1, '2026-11-01 08:15:00', 74);

INSERT INTO signo_presion_sistolica (id_paciente, registrado_en, valor_mmhg) VALUES
(1, '2026-10-15 09:05:00', 142),
(1, '2026-11-01 08:15:00', 124);

INSERT INTO signo_presion_diastolica (id_paciente, registrado_en, valor_mmhg) VALUES
(1, '2026-10-15 09:05:00', 92),
(1, '2026-11-01 08:15:00', 80);

INSERT INTO signo_temperatura (id_paciente, registrado_en, valor_celsius) VALUES
(1, '2026-10-15 09:05:00', 36.70);

INSERT INTO signo_saturacion_o2 (id_paciente, registrado_en, porcentaje_spo2) VALUES
(1, '2026-10-15 09:05:00', 98);
