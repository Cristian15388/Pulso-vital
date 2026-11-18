USE pulso_vital;

CREATE TABLE IF NOT EXISTS cargos_administrativos (
    id_cargo INT NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(30) NOT NULL,
    nombre VARCHAR(80) NOT NULL,
    PRIMARY KEY (id_cargo),
    CONSTRAINT uq_cargo_administrativo_codigo UNIQUE (codigo),
    CONSTRAINT uq_cargo_administrativo_nombre UNIQUE (nombre)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS administrativos (
    id_administrativo INT NOT NULL AUTO_INCREMENT,
    tipo_documento VARCHAR(10) NOT NULL,
    numero_documento VARCHAR(30) NOT NULL,
    creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_administrativo),
    CONSTRAINT uq_administrativo_documento UNIQUE (tipo_documento, numero_documento),
    CONSTRAINT chk_administrativo_tipo_documento
        CHECK (tipo_documento IN ('CC', 'TI', 'CE', 'PA', 'RC'))
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS administrativo_nombres_hist (
    id_administrativo INT NOT NULL,
    valido_desde DATETIME NOT NULL,
    valido_hasta DATETIME NULL,
    nombres VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_administrativo, valido_desde),
    CONSTRAINT fk_administrativo_nombres
        FOREIGN KEY (id_administrativo) REFERENCES administrativos (id_administrativo),
    CONSTRAINT chk_administrativo_nombres_fechas
        CHECK (valido_hasta IS NULL OR valido_hasta > valido_desde)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS administrativo_apellidos_hist (
    id_administrativo INT NOT NULL,
    valido_desde DATETIME NOT NULL,
    valido_hasta DATETIME NULL,
    apellidos VARCHAR(100) NOT NULL,
    PRIMARY KEY (id_administrativo, valido_desde),
    CONSTRAINT fk_administrativo_apellidos
        FOREIGN KEY (id_administrativo) REFERENCES administrativos (id_administrativo),
    CONSTRAINT chk_administrativo_apellidos_fechas
        CHECK (valido_hasta IS NULL OR valido_hasta > valido_desde)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS administrativo_cargo_hist (
    id_administrativo INT NOT NULL,
    valido_desde DATETIME NOT NULL,
    valido_hasta DATETIME NULL,
    id_cargo INT NOT NULL,
    PRIMARY KEY (id_administrativo, valido_desde),
    INDEX ix_administrativo_cargo_vigente (id_administrativo, valido_hasta),
    CONSTRAINT fk_administrativo_cargo_administrativo
        FOREIGN KEY (id_administrativo) REFERENCES administrativos (id_administrativo),
    CONSTRAINT fk_administrativo_cargo_catalogo
        FOREIGN KEY (id_cargo) REFERENCES cargos_administrativos (id_cargo),
    CONSTRAINT chk_administrativo_cargo_fechas
        CHECK (valido_hasta IS NULL OR valido_hasta > valido_desde)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS administrativo_telefono_hist (
    id_administrativo INT NOT NULL,
    valido_desde DATETIME NOT NULL,
    valido_hasta DATETIME NULL,
    telefono VARCHAR(30) NOT NULL,
    PRIMARY KEY (id_administrativo, valido_desde),
    CONSTRAINT fk_administrativo_telefono
        FOREIGN KEY (id_administrativo) REFERENCES administrativos (id_administrativo),
    CONSTRAINT chk_administrativo_telefono_fechas
        CHECK (valido_hasta IS NULL OR valido_hasta > valido_desde)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS administrativo_correo_hist (
    id_administrativo INT NOT NULL,
    valido_desde DATETIME NOT NULL,
    valido_hasta DATETIME NULL,
    correo VARCHAR(254) NOT NULL,
    correo_vigente VARCHAR(254)
        GENERATED ALWAYS AS (IF(valido_hasta IS NULL, correo, NULL)) STORED,
    PRIMARY KEY (id_administrativo, valido_desde),
    CONSTRAINT uq_administrativo_correo_vigente UNIQUE (correo_vigente),
    CONSTRAINT fk_administrativo_correo
        FOREIGN KEY (id_administrativo) REFERENCES administrativos (id_administrativo),
    CONSTRAINT chk_administrativo_correo_fechas
        CHECK (valido_hasta IS NULL OR valido_hasta > valido_desde)
) ENGINE = InnoDB;

INSERT IGNORE INTO cargos_administrativos (codigo, nombre) VALUES
    ('recepcion', 'Recepción'),
    ('archivo', 'Archivo clínico'),
    ('facturacion', 'Facturación'),
    ('coordinacion', 'Coordinación'),
    ('admisiones', 'Admisiones'),
    ('cajero', 'Cajero/a'),
    ('asistente_administrativo', 'Asistente administrativo'),
    ('gerente_clinica', 'Gerente de clínica'),
    ('recursos_humanos', 'Recursos humanos'),
    ('servicio_usuario', 'Atención al usuario'),
    ('auditor_medico', 'Auditor médico'),
    ('auditor_calidad', 'Auditor de calidad'),
    ('cartera', 'Cartera y recaudo'),
    ('compras', 'Compras'),
    ('almacen', 'Almacén'),
    ('asesor_juridico', 'Asesor jurídico'),
    ('medico_general', 'Médico general'),
    ('medico_familiar', 'Médico familiar'),
    ('medico_internista', 'Médico internista'),
    ('pediatra', 'Pediatra'),
    ('ginecologo_obstetra', 'Ginecólogo/a obstetra'),
    ('cirujano_general', 'Cirujano/a general'),
    ('cirujano_pediatrico', 'Cirujano/a pediátrico/a'),
    ('anestesiologo', 'Anestesiólogo/a'),
    ('cardiologo', 'Cardiólogo/a'),
    ('dermatologo', 'Dermatólogo/a'),
    ('endocrinologo', 'Endocrinólogo/a'),
    ('gastroenterologo', 'Gastroenterólogo/a'),
    ('neurologo', 'Neurólogo/a'),
    ('oftalmologo', 'Oftalmólogo/a'),
    ('ortopedista', 'Ortopedista'),
    ('otorrinolaringologo', 'Otorrinolaringólogo/a'),
    ('psiquiatra', 'Psiquiatra'),
    ('radiologo', 'Radiólogo/a'),
    ('urologo', 'Urólogo/a'),
    ('urgenciologo', 'Médico/a de urgencias'),
    ('intensivista', 'Médico/a intensivista'),
    ('odontologo', 'Odontólogo/a'),
    ('jefe_enfermeria', 'Jefe/a de enfermería'),
    ('enfermero_profesional', 'Enfermero/a profesional'),
    ('auxiliar_enfermeria', 'Auxiliar de enfermería'),
    ('instrumentador_quirurgico', 'Instrumentador/a quirúrgico/a'),
    ('fisioterapeuta', 'Fisioterapeuta'),
    ('terapeuta_respiratorio', 'Terapeuta respiratorio/a'),
    ('terapeuta_ocupacional', 'Terapeuta ocupacional'),
    ('nutricionista', 'Nutricionista'),
    ('psicologo', 'Psicólogo/a'),
    ('trabajador_social', 'Trabajador/a social'),
    ('fonoaudiologo', 'Fonoaudiólogo/a'),
    ('optometrista', 'Optómetra'),
    ('bacteriologo', 'Bacteriólogo/a'),
    ('auxiliar_laboratorio', 'Auxiliar de laboratorio'),
    ('tecnico_imagenologia', 'Técnico/a de imagenología'),
    ('tecnico_radiologia', 'Técnico/a de radiología'),
    ('quimico_farmaceutico', 'Químico/a farmacéutico/a'),
    ('auxiliar_farmacia', 'Auxiliar de farmacia'),
    ('aseo_limpieza', 'Aseo y limpieza'),
    ('servicios_generales', 'Servicios generales'),
    ('mantenimiento', 'Mantenimiento'),
    ('vigilancia', 'Seguridad y vigilancia'),
    ('camillero', 'Camillero/a'),
    ('conductor_ambulancia', 'Conductor/a de ambulancia'),
    ('esterilizacion', 'Auxiliar de esterilización'),
    ('cocina', 'Cocina y alimentación'),
    ('lavanderia', 'Lavandería'),
    ('mensajero', 'Mensajero/a');
