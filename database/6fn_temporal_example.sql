USE pulso_vital;

CREATE TABLE ejemplo_6fn_vital_observation (
    observation_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (observation_id)
) ENGINE = InnoDB;

CREATE TABLE ejemplo_6fn_observation_consultation (
    observation_id BIGINT UNSIGNED NOT NULL,
    consultation_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (observation_id),
    CONSTRAINT fk_ejemplo_6fn_observation_consultation
        FOREIGN KEY (observation_id)
        REFERENCES ejemplo_6fn_vital_observation (observation_id),
    CONSTRAINT fk_ejemplo_6fn_consultation
        FOREIGN KEY (consultation_id) REFERENCES consultation (consultation_id)
) ENGINE = InnoDB;

CREATE TABLE ejemplo_6fn_observation_type (
    observation_id BIGINT UNSIGNED NOT NULL,
    vital_type_code VARCHAR(30) NOT NULL,
    PRIMARY KEY (observation_id),
    CONSTRAINT fk_ejemplo_6fn_observation_type_observation
        FOREIGN KEY (observation_id)
        REFERENCES ejemplo_6fn_vital_observation (observation_id),
    CONSTRAINT fk_ejemplo_6fn_observation_type
        FOREIGN KEY (vital_type_code) REFERENCES vital_type (vital_type_code)
) ENGINE = InnoDB;

CREATE TABLE ejemplo_6fn_vital_value (
    observation_id BIGINT UNSIGNED NOT NULL,
    valid_from DATETIME NOT NULL,
    valid_to DATETIME NOT NULL,
    numeric_value DECIMAL(10, 3) NOT NULL,
    PRIMARY KEY (observation_id, valid_from, valid_to),
    CONSTRAINT chk_ejemplo_6fn_value_period CHECK (valid_to > valid_from),
    CONSTRAINT chk_ejemplo_6fn_numeric_value CHECK (numeric_value >= 0),
    CONSTRAINT fk_ejemplo_6fn_value_observation
        FOREIGN KEY (observation_id)
        REFERENCES ejemplo_6fn_vital_observation (observation_id)
) ENGINE = InnoDB;

CREATE TABLE ejemplo_6fn_vital_note (
    observation_id BIGINT UNSIGNED NOT NULL,
    valid_from DATETIME NOT NULL,
    valid_to DATETIME NOT NULL,
    note TEXT NOT NULL,
    PRIMARY KEY (observation_id, valid_from, valid_to),
    CONSTRAINT chk_ejemplo_6fn_note_period CHECK (valid_to > valid_from),
    CONSTRAINT fk_ejemplo_6fn_note_observation
        FOREIGN KEY (observation_id)
        REFERENCES ejemplo_6fn_vital_observation (observation_id)
) ENGINE = InnoDB;
