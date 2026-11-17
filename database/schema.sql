CREATE DATABASE IF NOT EXISTS pulso_vital
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE pulso_vital;

-- Entity tables contain keys only. Each fact is stored in its own relation.
CREATE TABLE patient (
    patient_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (patient_id)
) ENGINE = InnoDB;

CREATE TABLE patient_document_identifier (
    patient_id BIGINT UNSIGNED NOT NULL,
    document_identifier VARCHAR(50) NOT NULL,
    PRIMARY KEY (patient_id),
    CONSTRAINT uq_patient_document_identifier UNIQUE (document_identifier),
    CONSTRAINT fk_patient_document_identifier_patient
        FOREIGN KEY (patient_id) REFERENCES patient (patient_id)
) ENGINE = InnoDB;

CREATE TABLE patient_given_names (
    patient_id BIGINT UNSIGNED NOT NULL,
    given_names VARCHAR(100) NOT NULL,
    PRIMARY KEY (patient_id),
    CONSTRAINT fk_patient_given_names_patient
        FOREIGN KEY (patient_id) REFERENCES patient (patient_id)
) ENGINE = InnoDB;

CREATE TABLE patient_family_names (
    patient_id BIGINT UNSIGNED NOT NULL,
    family_names VARCHAR(100) NOT NULL,
    PRIMARY KEY (patient_id),
    CONSTRAINT fk_patient_family_names_patient
        FOREIGN KEY (patient_id) REFERENCES patient (patient_id)
) ENGINE = InnoDB;

CREATE TABLE patient_birth_date (
    patient_id BIGINT UNSIGNED NOT NULL,
    birth_date DATE NOT NULL,
    PRIMARY KEY (patient_id),
    CONSTRAINT fk_patient_birth_date_patient
        FOREIGN KEY (patient_id) REFERENCES patient (patient_id)
) ENGINE = InnoDB;

CREATE TABLE patient_sex_at_birth (
    patient_id BIGINT UNSIGNED NOT NULL,
    sex_at_birth VARCHAR(20) NOT NULL,
    PRIMARY KEY (patient_id),
    CONSTRAINT chk_patient_sex_at_birth
        CHECK (sex_at_birth IN ('female', 'male', 'intersex', 'unspecified')),
    CONSTRAINT fk_patient_sex_at_birth_patient
        FOREIGN KEY (patient_id) REFERENCES patient (patient_id)
) ENGINE = InnoDB;

CREATE TABLE patient_email (
    patient_id BIGINT UNSIGNED NOT NULL,
    email VARCHAR(254) NOT NULL,
    PRIMARY KEY (patient_id),
    CONSTRAINT uq_patient_email UNIQUE (email),
    CONSTRAINT fk_patient_email_patient
        FOREIGN KEY (patient_id) REFERENCES patient (patient_id)
) ENGINE = InnoDB;

CREATE TABLE patient_phone (
    patient_id BIGINT UNSIGNED NOT NULL,
    phone VARCHAR(30) NOT NULL,
    PRIMARY KEY (patient_id),
    CONSTRAINT fk_patient_phone_patient
        FOREIGN KEY (patient_id) REFERENCES patient (patient_id)
) ENGINE = InnoDB;

CREATE TABLE professional (
    professional_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (professional_id)
) ENGINE = InnoDB;

CREATE TABLE professional_license (
    professional_id BIGINT UNSIGNED NOT NULL,
    license_number VARCHAR(40) NOT NULL,
    PRIMARY KEY (professional_id),
    CONSTRAINT uq_professional_license UNIQUE (license_number),
    CONSTRAINT fk_professional_license_professional
        FOREIGN KEY (professional_id) REFERENCES professional (professional_id)
) ENGINE = InnoDB;

CREATE TABLE professional_given_names (
    professional_id BIGINT UNSIGNED NOT NULL,
    given_names VARCHAR(100) NOT NULL,
    PRIMARY KEY (professional_id),
    CONSTRAINT fk_professional_given_names_professional
        FOREIGN KEY (professional_id) REFERENCES professional (professional_id)
) ENGINE = InnoDB;

CREATE TABLE professional_family_names (
    professional_id BIGINT UNSIGNED NOT NULL,
    family_names VARCHAR(100) NOT NULL,
    PRIMARY KEY (professional_id),
    CONSTRAINT fk_professional_family_names_professional
        FOREIGN KEY (professional_id) REFERENCES professional (professional_id)
) ENGINE = InnoDB;

CREATE TABLE professional_email (
    professional_id BIGINT UNSIGNED NOT NULL,
    email VARCHAR(254) NOT NULL,
    PRIMARY KEY (professional_id),
    CONSTRAINT uq_professional_email UNIQUE (email),
    CONSTRAINT fk_professional_email_professional
        FOREIGN KEY (professional_id) REFERENCES professional (professional_id)
) ENGINE = InnoDB;

CREATE TABLE professional_phone (
    professional_id BIGINT UNSIGNED NOT NULL,
    phone VARCHAR(30) NOT NULL,
    PRIMARY KEY (professional_id),
    CONSTRAINT fk_professional_phone_professional
        FOREIGN KEY (professional_id) REFERENCES professional (professional_id)
) ENGINE = InnoDB;

CREATE TABLE professional_is_active (
    professional_id BIGINT UNSIGNED NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (professional_id),
    CONSTRAINT fk_professional_is_active_professional
        FOREIGN KEY (professional_id) REFERENCES professional (professional_id)
) ENGINE = InnoDB;

CREATE TABLE specialty (
    specialty_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (specialty_id)
) ENGINE = InnoDB;

CREATE TABLE specialty_name (
    specialty_id BIGINT UNSIGNED NOT NULL,
    specialty_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (specialty_id),
    CONSTRAINT uq_specialty_name UNIQUE (specialty_name),
    CONSTRAINT fk_specialty_name_specialty
        FOREIGN KEY (specialty_id) REFERENCES specialty (specialty_id)
) ENGINE = InnoDB;

CREATE TABLE professional_specialty (
    professional_id BIGINT UNSIGNED NOT NULL,
    specialty_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (professional_id, specialty_id),
    CONSTRAINT fk_professional_specialty_professional
        FOREIGN KEY (professional_id) REFERENCES professional (professional_id),
    CONSTRAINT fk_professional_specialty_specialty
        FOREIGN KEY (specialty_id) REFERENCES specialty (specialty_id)
) ENGINE = InnoDB;

CREATE TABLE appointment_status (
    status_code VARCHAR(20) NOT NULL,
    PRIMARY KEY (status_code)
) ENGINE = InnoDB;

CREATE TABLE appointment_status_name (
    status_code VARCHAR(20) NOT NULL,
    status_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (status_code),
    CONSTRAINT uq_appointment_status_name UNIQUE (status_name),
    CONSTRAINT fk_appointment_status_name_status
        FOREIGN KEY (status_code) REFERENCES appointment_status (status_code)
) ENGINE = InnoDB;

INSERT INTO appointment_status (status_code) VALUES
    ('scheduled'),
    ('confirmed'),
    ('completed'),
    ('cancelled'),
    ('no_show');

INSERT INTO appointment_status_name (status_code, status_name) VALUES
    ('scheduled', 'Programada'),
    ('confirmed', 'Confirmada'),
    ('completed', 'Completada'),
    ('cancelled', 'Cancelada'),
    ('no_show', 'No asistió');

CREATE TABLE appointment (
    appointment_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (appointment_id)
) ENGINE = InnoDB;

CREATE TABLE appointment_patient (
    appointment_id BIGINT UNSIGNED NOT NULL,
    patient_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (appointment_id),
    CONSTRAINT fk_appointment_patient_appointment
        FOREIGN KEY (appointment_id) REFERENCES appointment (appointment_id),
    CONSTRAINT fk_appointment_patient_patient
        FOREIGN KEY (patient_id) REFERENCES patient (patient_id)
) ENGINE = InnoDB;

CREATE TABLE appointment_professional (
    appointment_id BIGINT UNSIGNED NOT NULL,
    professional_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (appointment_id),
    CONSTRAINT fk_appointment_professional_appointment
        FOREIGN KEY (appointment_id) REFERENCES appointment (appointment_id),
    CONSTRAINT fk_appointment_professional_professional
        FOREIGN KEY (professional_id) REFERENCES professional (professional_id)
) ENGINE = InnoDB;

CREATE TABLE appointment_current_status (
    appointment_id BIGINT UNSIGNED NOT NULL,
    status_code VARCHAR(20) NOT NULL,
    PRIMARY KEY (appointment_id),
    CONSTRAINT fk_appointment_current_status_appointment
        FOREIGN KEY (appointment_id) REFERENCES appointment (appointment_id),
    CONSTRAINT fk_appointment_current_status_status
        FOREIGN KEY (status_code) REFERENCES appointment_status (status_code)
) ENGINE = InnoDB;

CREATE TABLE appointment_starts_at (
    appointment_id BIGINT UNSIGNED NOT NULL,
    starts_at DATETIME NOT NULL,
    PRIMARY KEY (appointment_id),
    CONSTRAINT fk_appointment_starts_at_appointment
        FOREIGN KEY (appointment_id) REFERENCES appointment (appointment_id)
) ENGINE = InnoDB;

CREATE TABLE appointment_duration_minutes (
    appointment_id BIGINT UNSIGNED NOT NULL,
    duration_minutes SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY (appointment_id),
    CONSTRAINT chk_appointment_duration CHECK (duration_minutes > 0),
    CONSTRAINT fk_appointment_duration_appointment
        FOREIGN KEY (appointment_id) REFERENCES appointment (appointment_id)
) ENGINE = InnoDB;

CREATE TABLE appointment_reason (
    appointment_id BIGINT UNSIGNED NOT NULL,
    reason VARCHAR(500) NOT NULL,
    PRIMARY KEY (appointment_id),
    CONSTRAINT fk_appointment_reason_appointment
        FOREIGN KEY (appointment_id) REFERENCES appointment (appointment_id)
) ENGINE = InnoDB;

CREATE TABLE consultation (
    consultation_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    PRIMARY KEY (consultation_id)
) ENGINE = InnoDB;

CREATE TABLE consultation_appointment (
    consultation_id BIGINT UNSIGNED NOT NULL,
    appointment_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (consultation_id),
    CONSTRAINT uq_consultation_appointment UNIQUE (appointment_id),
    CONSTRAINT fk_consultation_appointment_consultation
        FOREIGN KEY (consultation_id) REFERENCES consultation (consultation_id),
    CONSTRAINT fk_consultation_appointment_appointment
        FOREIGN KEY (appointment_id) REFERENCES appointment (appointment_id)
) ENGINE = InnoDB;

CREATE TABLE consultation_consulted_at (
    consultation_id BIGINT UNSIGNED NOT NULL,
    consulted_at DATETIME NOT NULL,
    PRIMARY KEY (consultation_id),
    CONSTRAINT fk_consultation_consulted_at_consultation
        FOREIGN KEY (consultation_id) REFERENCES consultation (consultation_id)
) ENGINE = InnoDB;

CREATE TABLE consultation_clinical_notes (
    consultation_id BIGINT UNSIGNED NOT NULL,
    clinical_notes TEXT NOT NULL,
    PRIMARY KEY (consultation_id),
    CONSTRAINT fk_consultation_clinical_notes_consultation
        FOREIGN KEY (consultation_id) REFERENCES consultation (consultation_id)
) ENGINE = InnoDB;

CREATE TABLE diagnosis (
    diagnosis_code VARCHAR(20) NOT NULL,
    PRIMARY KEY (diagnosis_code)
) ENGINE = InnoDB;

CREATE TABLE diagnosis_name (
    diagnosis_code VARCHAR(20) NOT NULL,
    diagnosis_name VARCHAR(255) NOT NULL,
    PRIMARY KEY (diagnosis_code),
    CONSTRAINT uq_diagnosis_name UNIQUE (diagnosis_name),
    CONSTRAINT fk_diagnosis_name_diagnosis
        FOREIGN KEY (diagnosis_code) REFERENCES diagnosis (diagnosis_code)
) ENGINE = InnoDB;

CREATE TABLE diagnosis_description (
    diagnosis_code VARCHAR(20) NOT NULL,
    description TEXT NOT NULL,
    PRIMARY KEY (diagnosis_code),
    CONSTRAINT fk_diagnosis_description_diagnosis
        FOREIGN KEY (diagnosis_code) REFERENCES diagnosis (diagnosis_code)
) ENGINE = InnoDB;

CREATE TABLE consultation_diagnosis (
    consultation_id BIGINT UNSIGNED NOT NULL,
    diagnosis_code VARCHAR(20) NOT NULL,
    PRIMARY KEY (consultation_id, diagnosis_code),
    CONSTRAINT fk_consultation_diagnosis_consultation
        FOREIGN KEY (consultation_id) REFERENCES consultation (consultation_id),
    CONSTRAINT fk_consultation_diagnosis_diagnosis
        FOREIGN KEY (diagnosis_code) REFERENCES diagnosis (diagnosis_code)
) ENGINE = InnoDB;

CREATE TABLE vital_type (
    vital_type_code VARCHAR(30) NOT NULL,
    PRIMARY KEY (vital_type_code)
) ENGINE = InnoDB;

CREATE TABLE vital_type_name (
    vital_type_code VARCHAR(30) NOT NULL,
    vital_type_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (vital_type_code),
    CONSTRAINT uq_vital_type_name UNIQUE (vital_type_name),
    CONSTRAINT fk_vital_type_name_type
        FOREIGN KEY (vital_type_code) REFERENCES vital_type (vital_type_code)
) ENGINE = InnoDB;

CREATE TABLE vital_type_unit (
    vital_type_code VARCHAR(30) NOT NULL,
    unit_of_measure VARCHAR(30) NOT NULL,
    PRIMARY KEY (vital_type_code),
    CONSTRAINT fk_vital_type_unit_type
        FOREIGN KEY (vital_type_code) REFERENCES vital_type (vital_type_code)
) ENGINE = InnoDB;

INSERT INTO vital_type (vital_type_code) VALUES
    ('heart_rate'),
    ('systolic_bp'),
    ('diastolic_bp'),
    ('temperature'),
    ('weight'),
    ('height'),
    ('oxygen_saturation');

INSERT INTO vital_type_name (vital_type_code, vital_type_name) VALUES
    ('heart_rate', 'Frecuencia cardiaca'),
    ('systolic_bp', 'Presión arterial sistólica'),
    ('diastolic_bp', 'Presión arterial diastólica'),
    ('temperature', 'Temperatura corporal'),
    ('weight', 'Peso'),
    ('height', 'Estatura'),
    ('oxygen_saturation', 'Saturación de oxígeno');

INSERT INTO vital_type_unit (vital_type_code, unit_of_measure) VALUES
    ('heart_rate', 'latidos/min'),
    ('systolic_bp', 'mmHg'),
    ('diastolic_bp', 'mmHg'),
    ('temperature', '°C'),
    ('weight', 'kg'),
    ('height', 'cm'),
    ('oxygen_saturation', '%');

CREATE TABLE vital_measurement (
    consultation_id BIGINT UNSIGNED NOT NULL,
    vital_type_code VARCHAR(30) NOT NULL,
    measured_at DATETIME NOT NULL,
    PRIMARY KEY (consultation_id, vital_type_code, measured_at),
    CONSTRAINT fk_vital_measurement_consultation
        FOREIGN KEY (consultation_id) REFERENCES consultation (consultation_id),
    CONSTRAINT fk_vital_measurement_type
        FOREIGN KEY (vital_type_code) REFERENCES vital_type (vital_type_code)
) ENGINE = InnoDB;

CREATE TABLE vital_measurement_value (
    consultation_id BIGINT UNSIGNED NOT NULL,
    vital_type_code VARCHAR(30) NOT NULL,
    measured_at DATETIME NOT NULL,
    numeric_value DECIMAL(10, 3) NOT NULL,
    PRIMARY KEY (consultation_id, vital_type_code, measured_at),
    CONSTRAINT chk_vital_measurement_value CHECK (numeric_value >= 0),
    CONSTRAINT fk_vital_measurement_value_measurement
        FOREIGN KEY (consultation_id, vital_type_code, measured_at)
        REFERENCES vital_measurement (consultation_id, vital_type_code, measured_at)
) ENGINE = InnoDB;
