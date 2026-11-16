-- =============================================================================
-- Pulso Vital - Paso 0: Tabla Universal No Normalizada (0FN)
-- Motor: MySQL 8.0+ (MySQL Workbench)
-- Propósito: Ilustrar las anomalías y problemas de diseño antes de normalizar.
-- =============================================================================

CREATE DATABASE IF NOT EXISTS pulso_vital_0fn
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE pulso_vital_0fn;

CREATE TABLE IF NOT EXISTS registro_clinico_bruto (
    id_cita                 INT,
    fecha_cita              VARCHAR(30),
    paciente_documento      VARCHAR(40),
    paciente_nombre         VARCHAR(150),
    paciente_fecha_nac      VARCHAR(20),
    paciente_telefonos      TEXT,   -- No atómico: lista separada por comas
    paciente_direccion      VARCHAR(200),
    paciente_ciudad         VARCHAR(100),
    paciente_departamento   VARCHAR(100),
    aseguradora_nit         VARCHAR(30),
    aseguradora_nombre      VARCHAR(150),
    medico_licencia         VARCHAR(40),
    medico_nombre           VARCHAR(150),
    medico_especialidades   TEXT,   -- No atómico: lista separada por comas
    consultorio_codigo      VARCHAR(20),
    consultorio_piso        VARCHAR(20),
    sede_nombre             VARCHAR(150),
    diagnostico_codigo      VARCHAR(20),
    diagnostico_desc        TEXT,
    medicamentos_recetados  TEXT,   -- Grupo repetido en una sola celda
    signos_vitales          TEXT,   -- Valores compuestos en una sola celda
    alergias                TEXT    -- Lista separada por comas
) ENGINE=InnoDB;

INSERT INTO registro_clinico_bruto VALUES
(
    1001,
    '2026-10-15 09:00',
    'CC-1045789123',
    'María Fernanda Gómez López',
    '1988-04-12',
    '3001112233, 3104445566',
    'Cra 45 # 72-18',
    'Barranquilla',
    'Atlántico',
    '900123456-1',
    'Salud Integral EPS',
    'MED-77889',
    'Dr. Carlos Andrés Mendoza',
    'Cardiología, Medicina Interna',
    'C-204',
    'Piso 2',
    'Sede Norte',
    'I10',
    'Hipertensión esencial (primaria)',
    'Losartán 50mg (cada 12h), Ácido Acetilsalicílico 100mg (cada 24h)',
    'FC: 82 lpm; PA: 142/92 mmHg; Temp: 36.7 C; SpO2: 98%',
    'Penicilina, Polen'
);
