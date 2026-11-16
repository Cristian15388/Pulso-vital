

CREATE DATABASE IF NOT EXISTS pulso_vital
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE pulso_vital;

-- -----------------------------------------------------------------------------
-- 1. TABLAS ANCLA (Identidades y catálogos inmutables)
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS departamentos (
    id_departamento     INT AUTO_INCREMENT PRIMARY KEY,
    codigo_dane         VARCHAR(10) NOT NULL UNIQUE,
    nombre              VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS ciudades (
    id_ciudad           INT AUTO_INCREMENT PRIMARY KEY,
    id_departamento     INT NOT NULL,
    codigo_dane         VARCHAR(10) NOT NULL UNIQUE,
    nombre              VARCHAR(100) NOT NULL,
    UNIQUE KEY uq_ciudad_depto (id_departamento, nombre),
    CONSTRAINT fk_ciudad_departamento
        FOREIGN KEY (id_departamento) REFERENCES departamentos(id_departamento)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS aseguradoras (
    id_aseguradora      INT AUTO_INCREMENT PRIMARY KEY,
    nit                 VARCHAR(20) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS sedes (
    id_sede             INT AUTO_INCREMENT PRIMARY KEY,
    codigo_sede         VARCHAR(20) NOT NULL UNIQUE,
    id_ciudad           INT NOT NULL,
    CONSTRAINT fk_sede_ciudad
        FOREIGN KEY (id_ciudad) REFERENCES ciudades(id_ciudad)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS consultorios (
    id_consultorio      INT AUTO_INCREMENT PRIMARY KEY,
    id_sede             INT NOT NULL,
    codigo_consultorio  VARCHAR(20) NOT NULL,
    piso                SMALLINT NOT NULL,
    UNIQUE KEY uq_sede_consultorio (id_sede, codigo_consultorio),
    CONSTRAINT chk_consultorio_piso CHECK (piso >= 0),
    CONSTRAINT fk_consultorio_sede
        FOREIGN KEY (id_sede) REFERENCES sedes(id_sede)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS especialidades (
    id_especialidad     INT AUTO_INCREMENT PRIMARY KEY,
    codigo_especialidad VARCHAR(20) NOT NULL UNIQUE,
    nombre              VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS diagnosticos (
    id_diagnostico      INT AUTO_INCREMENT PRIMARY KEY,
    codigo_cie10        VARCHAR(10) NOT NULL UNIQUE,
    descripcion         TEXT NOT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS medicamentos (
    id_medicamento      INT AUTO_INCREMENT PRIMARY KEY,
    codigo_atc          VARCHAR(15) NOT NULL UNIQUE,
    nombre_generico     VARCHAR(150) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS alergias (
    id_alergia          INT AUTO_INCREMENT PRIMARY KEY,
    codigo_alergia      VARCHAR(20) NOT NULL UNIQUE,
    nombre              VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS pacientes (
    id_paciente         INT AUTO_INCREMENT PRIMARY KEY,
    tipo_documento      VARCHAR(10) NOT NULL,
    numero_documento    VARCHAR(30) NOT NULL,
    fecha_nacimiento    DATE NOT NULL,
    creado_en           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_paciente_doc (tipo_documento, numero_documento),
    CONSTRAINT chk_paciente_tipo_doc CHECK (tipo_documento IN ('CC', 'TI', 'CE', 'PA', 'RC'))
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS medicos (
    id_medico           INT AUTO_INCREMENT PRIMARY KEY,
    numero_licencia     VARCHAR(30) NOT NULL UNIQUE,
    creado_en           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS citas (
    id_cita                 INT AUTO_INCREMENT PRIMARY KEY,
    fecha_hora_programada   DATETIME NOT NULL,
    creado_en               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 2. TABLAS IRREDUCIBLES 6FN - ENTIDADES Y ATRIBUTOS TEMPORALES
--    Cada tabla contiene la clave de entidad, intervalo [valido_desde, valido_hasta)
--    y un único atributo no clave.
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS aseguradora_nombre_hist (
    id_aseguradora      INT NOT NULL,
    valido_desde        DATETIME NOT NULL,
    valido_hasta        DATETIME NULL,
    nombre              VARCHAR(150) NOT NULL,
    PRIMARY KEY (id_aseguradora, valido_desde),
    CONSTRAINT fk_aseg_nom_aseg FOREIGN KEY (id_aseguradora) REFERENCES aseguradoras(id_aseguradora),
    CONSTRAINT chk_aseg_nom_fechas CHECK (valido_hasta IS NULL OR valido_hasta > valido_desde)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS sede_nombre_hist (
    id_sede             INT NOT NULL,
    valido_desde        DATETIME NOT NULL,
    valido_hasta        DATETIME NULL,
    nombre              VARCHAR(150) NOT NULL,
    PRIMARY KEY (id_sede, valido_desde),
    CONSTRAINT fk_sede_nom_sede FOREIGN KEY (id_sede) REFERENCES sedes(id_sede),
    CONSTRAINT chk_sede_nom_fechas CHECK (valido_hasta IS NULL OR valido_hasta > valido_desde)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS paciente_nombres_hist (
    id_paciente         INT NOT NULL,
    valido_desde        DATETIME NOT NULL,
    valido_hasta        DATETIME NULL,
    nombres             VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_paciente, valido_desde),
    CONSTRAINT fk_pac_nom_pac FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente),
    CONSTRAINT chk_pac_nom_fechas CHECK (valido_hasta IS NULL OR valido_hasta > valido_desde)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS paciente_apellidos_hist (
    id_paciente         INT NOT NULL,
    valido_desde        DATETIME NOT NULL,
    valido_hasta        DATETIME NULL,
    apellidos           VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_paciente, valido_desde),
    CONSTRAINT fk_pac_ape_pac FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente),
    CONSTRAINT chk_pac_ape_fechas CHECK (valido_hasta IS NULL OR valido_hasta > valido_desde)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS paciente_direccion_hist (
    id_paciente         INT NOT NULL,
    valido_desde        DATETIME NOT NULL,
    valido_hasta        DATETIME NULL,
    direccion           VARCHAR(200) NOT NULL,
    PRIMARY KEY (id_paciente, valido_desde),
    CONSTRAINT fk_pac_dir_pac FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente),
    CONSTRAINT chk_pac_dir_fechas CHECK (valido_hasta IS NULL OR valido_hasta > valido_desde)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS paciente_ciudad_hist (
    id_paciente         INT NOT NULL,
    valido_desde        DATETIME NOT NULL,
    valido_hasta        DATETIME NULL,
    id_ciudad           INT NOT NULL,
    PRIMARY KEY (id_paciente, valido_desde),
    CONSTRAINT fk_pac_ciu_pac FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente),
    CONSTRAINT fk_pac_ciu_ciu FOREIGN KEY (id_ciudad) REFERENCES ciudades(id_ciudad),
    CONSTRAINT chk_pac_ciu_fechas CHECK (valido_hasta IS NULL OR valido_hasta > valido_desde)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS paciente_aseguradora_hist (
    id_paciente         INT NOT NULL,
    valido_desde        DATETIME NOT NULL,
    valido_hasta        DATETIME NULL,
    id_aseguradora      INT NOT NULL,
    PRIMARY KEY (id_paciente, valido_desde),
    CONSTRAINT fk_pac_aseg_pac FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente),
    CONSTRAINT fk_pac_aseg_aseg FOREIGN KEY (id_aseguradora) REFERENCES aseguradoras(id_aseguradora),
    CONSTRAINT chk_pac_aseg_fechas CHECK (valido_hasta IS NULL OR valido_hasta > valido_desde)
) ENGINE=InnoDB;

-- Paciente: teléfonos (4FN + 6FN)
CREATE TABLE IF NOT EXISTS paciente_telefono_hist (
    id_paciente         INT NOT NULL,
    telefono            VARCHAR(20) NOT NULL,
    valido_desde        DATETIME NOT NULL,
    valido_hasta        DATETIME NULL,
    tipo_telefono       VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_paciente, telefono, valido_desde),
    CONSTRAINT fk_pac_tel_pac FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente),
    CONSTRAINT chk_pac_tel_tipo CHECK (tipo_telefono IN ('MOVIL', 'FIJO', 'EMERGENCIA')),
    CONSTRAINT chk_pac_tel_fechas CHECK (valido_hasta IS NULL OR valido_hasta > valido_desde)
) ENGINE=InnoDB;

-- Paciente: alergias (4FN + 6FN)
CREATE TABLE IF NOT EXISTS paciente_alergia_hist (
    id_paciente         INT NOT NULL,
    id_alergia          INT NOT NULL,
    valido_desde        DATETIME NOT NULL,
    valido_hasta        DATETIME NULL,
    severidad           VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_paciente, id_alergia, valido_desde),
    CONSTRAINT fk_pac_alg_pac FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente),
    CONSTRAINT fk_pac_alg_alg FOREIGN KEY (id_alergia) REFERENCES alergias(id_alergia),
    CONSTRAINT chk_pac_alg_sev CHECK (severidad IN ('LEVE', 'MODERADA', 'SEVERA')),
    CONSTRAINT chk_pac_alg_fechas CHECK (valido_hasta IS NULL OR valido_hasta > valido_desde)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS medico_nombre_hist (
    id_medico           INT NOT NULL,
    valido_desde        DATETIME NOT NULL,
    valido_hasta        DATETIME NULL,
    nombre_completo     VARCHAR(150) NOT NULL,
    PRIMARY KEY (id_medico, valido_desde),
    CONSTRAINT fk_med_nom_med FOREIGN KEY (id_medico) REFERENCES medicos(id_medico),
    CONSTRAINT chk_med_nom_fechas CHECK (valido_hasta IS NULL OR valido_hasta > valido_desde)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 3. FNBC + 6FN: CONSULTORIOS, ESPECIALIDADES Y ASIGNACIÓN DE MÉDICOS
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS consultorio_especialidad (
    id_consultorio      INT PRIMARY KEY,
    id_especialidad     INT NOT NULL,
    CONSTRAINT fk_cons_esp_cons FOREIGN KEY (id_consultorio) REFERENCES consultorios(id_consultorio),
    CONSTRAINT fk_cons_esp_esp FOREIGN KEY (id_especialidad) REFERENCES especialidades(id_especialidad)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS medico_consultorio_hist (
    id_medico           INT NOT NULL,
    id_consultorio      INT NOT NULL,
    valido_desde        DATETIME NOT NULL,
    valido_hasta        DATETIME NULL,
    PRIMARY KEY (id_medico, id_consultorio, valido_desde),
    CONSTRAINT fk_med_cons_med FOREIGN KEY (id_medico) REFERENCES medicos(id_medico),
    CONSTRAINT fk_med_cons_cons FOREIGN KEY (id_consultorio) REFERENCES consultorios(id_consultorio),
    CONSTRAINT chk_med_cons_fechas CHECK (valido_hasta IS NULL OR valido_hasta > valido_desde)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 4. SERIES TEMPORALES DE SIGNOS VITALES (6FN)
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS signo_frecuencia_cardiaca (
    id_paciente         INT NOT NULL,
    registrado_en       DATETIME NOT NULL,
    valor_lpm           SMALLINT NOT NULL,
    PRIMARY KEY (id_paciente, registrado_en),
    CONSTRAINT fk_fc_pac FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente),
    CONSTRAINT chk_fc_rango CHECK (valor_lpm BETWEEN 20 AND 260)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS signo_presion_sistolica (
    id_paciente         INT NOT NULL,
    registrado_en       DATETIME NOT NULL,
    valor_mmhg          SMALLINT NOT NULL,
    PRIMARY KEY (id_paciente, registrado_en),
    CONSTRAINT fk_ps_pac FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente),
    CONSTRAINT chk_ps_rango CHECK (valor_mmhg BETWEEN 40 AND 300)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS signo_presion_diastolica (
    id_paciente         INT NOT NULL,
    registrado_en       DATETIME NOT NULL,
    valor_mmhg          SMALLINT NOT NULL,
    PRIMARY KEY (id_paciente, registrado_en),
    CONSTRAINT fk_pd_pac FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente),
    CONSTRAINT chk_pd_rango CHECK (valor_mmhg BETWEEN 20 AND 200)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS signo_temperatura (
    id_paciente         INT NOT NULL,
    registrado_en       DATETIME NOT NULL,
    valor_celsius       DECIMAL(4, 2) NOT NULL,
    PRIMARY KEY (id_paciente, registrado_en),
    CONSTRAINT fk_temp_pac FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente),
    CONSTRAINT chk_temp_rango CHECK (valor_celsius BETWEEN 30.00 AND 45.00)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS signo_saturacion_o2 (
    id_paciente         INT NOT NULL,
    registrado_en       DATETIME NOT NULL,
    porcentaje_spo2     SMALLINT NOT NULL,
    PRIMARY KEY (id_paciente, registrado_en),
    CONSTRAINT fk_spo2_pac FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente),
    CONSTRAINT chk_spo2_rango CHECK (porcentaje_spo2 BETWEEN 50 AND 100)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 5. CITAS, DIAGNÓSTICOS Y PRESCRIPCIONES (6FN)
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS cita_paciente (
    id_cita             INT PRIMARY KEY,
    id_paciente         INT NOT NULL,
    CONSTRAINT fk_cp_cita FOREIGN KEY (id_cita) REFERENCES citas(id_cita),
    CONSTRAINT fk_cp_pac FOREIGN KEY (id_paciente) REFERENCES pacientes(id_paciente)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS cita_medico (
    id_cita             INT PRIMARY KEY,
    id_medico           INT NOT NULL,
    CONSTRAINT fk_cm_cita FOREIGN KEY (id_cita) REFERENCES citas(id_cita),
    CONSTRAINT fk_cm_med FOREIGN KEY (id_medico) REFERENCES medicos(id_medico)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS cita_consultorio (
    id_cita             INT PRIMARY KEY,
    id_consultorio      INT NOT NULL,
    CONSTRAINT fk_cc_cita FOREIGN KEY (id_cita) REFERENCES citas(id_cita),
    CONSTRAINT fk_cc_cons FOREIGN KEY (id_consultorio) REFERENCES consultorios(id_consultorio)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS cita_estado_hist (
    id_cita             INT NOT NULL,
    valido_desde        DATETIME NOT NULL,
    valido_hasta        DATETIME NULL,
    estado              VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_cita, valido_desde),
    CONSTRAINT fk_ce_cita FOREIGN KEY (id_cita) REFERENCES citas(id_cita),
    CONSTRAINT chk_ce_estado CHECK (estado IN ('PROGRAMADA', 'EN_CURSO', 'COMPLETADA', 'CANCELADA')),
    CONSTRAINT chk_ce_fechas CHECK (valido_hasta IS NULL OR valido_hasta > valido_desde)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS cita_diagnostico (
    id_cita             INT NOT NULL,
    id_diagnostico      INT NOT NULL,
    registrado_en       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_cita, id_diagnostico),
    CONSTRAINT fk_cd_cita FOREIGN KEY (id_cita) REFERENCES citas(id_cita),
    CONSTRAINT fk_cd_diag FOREIGN KEY (id_diagnostico) REFERENCES diagnosticos(id_diagnostico)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS prescripcion_dosis_hist (
    id_cita             INT NOT NULL,
    id_medicamento      INT NOT NULL,
    valido_desde        DATETIME NOT NULL,
    valido_hasta        DATETIME NULL,
    dosis               VARCHAR(50) NOT NULL,
    PRIMARY KEY (id_cita, id_medicamento, valido_desde),
    CONSTRAINT fk_pdosis_cita FOREIGN KEY (id_cita) REFERENCES citas(id_cita),
    CONSTRAINT fk_pdosis_med FOREIGN KEY (id_medicamento) REFERENCES medicamentos(id_medicamento),
    CONSTRAINT chk_pdosis_fechas CHECK (valido_hasta IS NULL OR valido_hasta > valido_desde)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS prescripcion_frecuencia_hist (
    id_cita             INT NOT NULL,
    id_medicamento      INT NOT NULL,
    valido_desde        DATETIME NOT NULL,
    valido_hasta        DATETIME NULL,
    frecuencia_horas    SMALLINT NOT NULL,
    PRIMARY KEY (id_cita, id_medicamento, valido_desde),
    CONSTRAINT fk_pfrec_cita FOREIGN KEY (id_cita) REFERENCES citas(id_cita),
    CONSTRAINT fk_pfrec_med FOREIGN KEY (id_medicamento) REFERENCES medicamentos(id_medicamento),
    CONSTRAINT chk_pfrec_horas CHECK (frecuencia_horas > 0),
    CONSTRAINT chk_pfrec_fechas CHECK (valido_hasta IS NULL OR valido_hasta > valido_desde)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 6. REGLAS DE COBERTURA CLÍNICA (5FN)
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS aseguradora_especialidades (
    id_aseguradora      INT NOT NULL,
    id_especialidad     INT NOT NULL,
    PRIMARY KEY (id_aseguradora, id_especialidad),
    CONSTRAINT fk_ae_aseg FOREIGN KEY (id_aseguradora) REFERENCES aseguradoras(id_aseguradora),
    CONSTRAINT fk_ae_esp FOREIGN KEY (id_especialidad) REFERENCES especialidades(id_especialidad)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS especialidad_medicamentos (
    id_especialidad     INT NOT NULL,
    id_medicamento      INT NOT NULL,
    PRIMARY KEY (id_especialidad, id_medicamento),
    CONSTRAINT fk_em_esp FOREIGN KEY (id_especialidad) REFERENCES especialidades(id_especialidad),
    CONSTRAINT fk_em_med FOREIGN KEY (id_medicamento) REFERENCES medicamentos(id_medicamento)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS aseguradora_medicamentos (
    id_aseguradora      INT NOT NULL,
    id_medicamento      INT NOT NULL,
    PRIMARY KEY (id_aseguradora, id_medicamento),
    CONSTRAINT fk_am_aseg FOREIGN KEY (id_aseguradora) REFERENCES aseguradoras(id_aseguradora),
    CONSTRAINT fk_am_med FOREIGN KEY (id_medicamento) REFERENCES medicamentos(id_medicamento)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 7. ÍNDICES DE APOYO PARA CONSULTAS TEMPORALES VIGENTES
-- -----------------------------------------------------------------------------

CREATE INDEX idx_pac_dir_vigente
    ON paciente_direccion_hist (id_paciente, valido_hasta);

CREATE INDEX idx_pac_aseg_vigente
    ON paciente_aseguradora_hist (id_paciente, valido_hasta);

CREATE INDEX idx_cita_estado_vigente
    ON cita_estado_hist (id_cita, valido_hasta);

CREATE INDEX idx_fc_paciente_fecha
    ON signo_frecuencia_cardiaca (id_paciente, registrado_en);
