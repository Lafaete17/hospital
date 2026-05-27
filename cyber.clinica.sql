
DROP TABLE IF EXISTS request_exams;
DROP TABLE IF EXISTS exams;
DROP TABLE IF EXISTS consultation;
DROP TABLE IF EXISTS doctors;
DROP TABLE IF EXISTS patients;

CREATE TABLE patients
(
    id_patient INT IDENTITY(1,1) PRIMARY KEY,
    --chave primária
    cpf VARCHAR(14) UNIQUE NOT NULL,
    --cpf unico e protegido
    name_patient VARCHAR(40) NOT NULL,
    phone_number VARCHAR(14),
    name_health_plan VARCHAR(20),
    type_health_plan VARCHAR (10)

);

CREATE INDEX idx_patients_cpf ON patients(cpf);

CREATE TABLE doctors
(
    id_doctor INT IDENTITY(1,1) PRIMARY KEY,
    --chave primária
    crm INT UNIQUE NOT NULL,
    name_doctor VARCHAR(30) NOT NULL,
    specialty VARCHAR(20)NOT NULL
);

CREATE TABLE consultation
(
    id_consultation INT IDENTITY (1,1) PRIMARY KEY,
    consultation_date DATE NOT NULL,
    consultation_time TIME NOT NULL,
    fk_id_patient INT NOT NULL,
    fk_id_doctor INT NOT NULL,

    FOREIGN KEY (fk_id_patient) REFERENCES patients(id_patient),
    FOREIGN KEY (fk_id_doctor) REFERENCES doctors(id_doctor)
);

CREATE TABLE exams
(
    code INT PRIMARY KEY,
    specification VARCHAR(50)NOT NULL,
    price money NOT NULL
);

CREATE TABLE request_exams
(
    request_number INT IDENTITY (1,1) PRIMARY KEY,
    result_exam VARCHAR(40),
    exam_date DATE NOT NULL,
    amount_payable money NOT NULL,
    fk_id_consultation INT NOT NULL,
    fk_exam_code INT NOT NULL,

    FOREIGN KEY (fk_id_consultation)
     REFERENCES consultation(id_consultation),

    FOREIGN KEY(fk_exam_code)
    REFERENCES exams(code)
);

CREATE TABLE employees
(
    id_employee INT IDENTITY(1,1) PRIMARY KEY,
    name_employee VARCHAR(60) NOT NULL,
    cpf_employee VARCHAR(14) UNIQUE NOT NULL,
    role_employee VARCHAR(40),
    department VARCHAR(40),
    status_employee BIT DEFAULT 1 NOT NULL

);

CREATE TABLE triage
(
    id_triage INT IDENTITY(1,1) PRIMARY KEY,
    id_patient INT NOT NULL,
    id_employee INT NOT NULL,
    weight_patient DECIMAL (5,2),
    height_patient DECIMAL (3,2),
    blood_pressure VARCHAR (10),
    temperature_patient DECIMAL(3,1),
    symptoms_patient VARCHAR(255),
    classification_level VARCHAR(20),
    triage_date DATETIME DEFAULT GETDATE() NOT NULL,

    CONSTRAINT fk_triage_patient FOREIGN KEY (id_patient) REFERENCES patients(id_patient),
    CONSTRAINT fk_triage_employee FOREIGN KEY (id_employee) REFERENCES employees(id_employee)

);

/*************************************
*********INSERTS PATIENTS*************
***************************************/


INSERT into patients
    (cpf,name_patient, phone_number, name_health_plan, type_health_plan)
VALUES(
        '123.456.789-00',
        'Mauricio Aragão',
        '(86) 977559910',
        'unimed',
        'premium'
);

INSERT into patients
    (cpf,name_patient, phone_number, name_health_plan, type_health_plan)
VALUES(
        '132.605.892-90',
        'Matheus Rodrigues',
        '(61) 987559911',
        'bradesco',
        'silver'
);

INSERT into patients
    (cpf,name_patient, phone_number, name_health_plan, type_health_plan)
VALUES(
        '100.406.789-20',
        'Francisco Aragão',
        '(86)947579901',
        'cassi',
        'gold'
);

INSERT into patients
    (cpf,name_patient, phone_number, name_health_plan, type_health_plan)
VALUES(
        '133.906.889-30',
        'Rosy Vieira',
        '(86)947579901',
        'cassi',
        'gold'
);

/*****************************************
***********NSERTS DOCTORS************
******************************************/

INSERT into doctors
    (crm, name_doctor, specialty)
VALUES(
        54189,
        'Dr Leandro Almeida',
        'Ortopedista'
);

INSERT into doctors
    (crm, name_doctor, specialty)
VALUES(
        96835,
        'Dra Rosy Vieira',
        'Neurologista'
);

INSERT into doctors
    (crm, name_doctor, specialty)
VALUES(
        78214,
        'Dr Lafaete Vieira',
        'Clinica Médica'
);

/*****************************************
*********NSERTS CONSULTATION*************
******************************************/

INSERT into consultation
    (consultation_date,consultation_time, fk_id_patient, fk_id_doctor)
VALUES(
        '2026-05-11',
        '12:50',
        3,
        2
);

INSERT into consultation
    (consultation_date,consultation_time, fk_id_patient, fk_id_doctor)
VALUES(
        '2026-05-13',
        '12:50',
        4,
        1
);

INSERT into consultation
    (consultation_date,consultation_time, fk_id_patient, fk_id_doctor)
VALUES(
        '2026-05-10',
        '12:50',
        2,
        3
);

/*****************************************
*************NSERTS EXAMS*****************
******************************************/

INSERT into exams
VALUES(
        1,
        'blood_count',
        120.00
);

INSERT into exams
VALUES(
        2,
        'x-ray',
        75.00
);

INSERT into exams
VALUES(
        3,
        'resonance',
        1775.00
);

/*****************************************
***********INSERT REQUEST_EXAMS***********
******************************************/

INSERT into request_exams
    (result_exam, exam_date, amount_payable, fk_id_consultation, fk_exam_code)
values(
        'normal',
        '2026-05-11',
        120.00,
        1,
        1
);

INSERT into request_exams
    (result_exam, exam_date, amount_payable, fk_id_consultation, fk_exam_code)
values(
        'fracture',
        '2026-05-13',
        75.00,
        2,
        2
);

INSERT into request_exams
    (result_exam, exam_date, amount_payable, fk_id_consultation, fk_exam_code)
values(
        'no changes',
        '2026-05-13',
        1775.00,
        3,
        3
);

/*****************************************
***********UPDATES E DELETES**************
******************************************/

UPDATE patients
SET type_health_plan = 'special'
WHERE cpf = '123.456.789-00';

UPDATE patients
SET type_health_plan = 'standard'
WHERE cpf = '100.406.789-20';

UPDATE patients
SET type_health_plan = 'basic'
WHERE cpf = '133.906.889-30';

UPDATE patients
SET type_health_plan = 'standard'
WHERE cpf = '132.605.892-90';

UPDATE patients
SET phone_number = '(61)99999-0000'
WHERE cpf = '123.456.789-00';

UPDATE patients
SET phone_number = '(86)947579901'
WHERE cpf = '100.406.789-20';

UPDATE patients
SET phone_number = '(86)947579901'
WHERE cpf = '133.906.889-30';


DELETE FROM patients
WHERE cpf = '222.222.222.32';

DELETE FROM patients
WHERE cpf = '888.888.888.00';
DELETE FROM patients
WHERE cpf = '999.999.999-99';

/*****************************************
************SELECTS***********************
******************************************/


SELECT
    patients.name_patient,
    doctors.name_doctor,
    consultation.consultation_date
FROM consultation
    INNER JOIN patients
    ON consultation.fk_id_patient = patients.id_patient
    INNER JOIN doctors
    ON consultation.fk_id_doctor = doctors.id_doctor;

/*****************************************
******************************************
******************************************/

SELECT *
FROM patients;

SELECT *
FROM doctors;

SELECT *
FROM consultation;

SELECT *
FROM exams;

SELECT *
FROM request_exams;

