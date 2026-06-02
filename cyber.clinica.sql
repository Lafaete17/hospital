
DROP TABLE IF EXISTS medication_room;
DROP TABLE IF EXISTS pharmacy;
DROP TABLE IF EXISTS xray_exams;
DROP TABLE IF EXISTS triage;
DROP TABLE IF EXISTS request_exams;
DROP TABLE IF EXISTS exams;
DROP TABLE IF EXISTS consultation;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS doctors;
DROP TABLE IF EXISTS patients;

CREATE TABLE patients
(
    id_patient INT IDENTITY(1,1) PRIMARY KEY,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    name_patient VARCHAR(40) NOT NULL,
    phone_number VARCHAR(14),
    name_health_plan VARCHAR(20),
    type_health_plan VARCHAR (10)
);

CREATE INDEX idx_patients_cpf ON patients(cpf);

CREATE TABLE doctors
(
    id_doctor INT IDENTITY(1,1) PRIMARY KEY,
    crm INT UNIQUE NOT NULL,
    name_doctor VARCHAR(30) NOT NULL,
    specialty VARCHAR(20) NOT NULL
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

CREATE TABLE exams
(
    code INT PRIMARY KEY,
    specification VARCHAR(50) NOT NULL,
    price money NOT NULL
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

CREATE TABLE request_exams
(
    request_number INT IDENTITY (1,1) PRIMARY KEY,
    result_exam VARCHAR(40),
    exam_date DATE NOT NULL,
    amount_payable money NOT NULL,
    fk_id_consultation INT NOT NULL,
    fk_exam_code INT NOT NULL,

    FOREIGN KEY (fk_id_consultation) REFERENCES consultation(id_consultation),
    FOREIGN KEY(fk_exam_code) REFERENCES exams(code)
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

CREATE TABLE xray_exams
(
    id_xray INT IDENTITY(1,1) PRIMARY KEY,
    id_patient INT NOT NULL,
    id_doctor INT NOT NULL,
    fk_request_number INT NOT NULL,
    scan_area VARCHAR(50) NOT NULL,
    xray_view VARCHAR(30),
    radiological_findings VARCHAR(MAX),
    image_path VARCHAR(255),

    CONSTRAINT fk_xray_patient FOREIGN KEY (id_patient) REFERENCES patients(id_patient),
    CONSTRAINT fk_xray_doctor FOREIGN KEY (id_doctor) REFERENCES doctors(id_doctor),
    CONSTRAINT fk_xray_request FOREIGN KEY (fk_request_number) REFERENCES request_exams(request_number)
);

CREATE TABLE pharmacy
(
    id_medication INT IDENTITY(1,1) PRIMARY KEY,
    name_of_the_medication VARCHAR(50)NOT NULL,
    dosage_medication VARCHAR (20) NOT NULL,
    Pharmaceutical_form VARCHAR(30)NOT NULL,
    Current_quantity_in_stock INT NOT NULL CHECK(Current_quantity_in_stock >= 0),
    Batch_of_medicine varchar (20) NOT NULL,
    Expiration_date DATE NOT NULL
);

CREATE TABLE medication_room
(
    id_medication_room INT IDENTITY(1,1) PRIMARY KEY,
    id_medication INT NOT NULL,
    id_patient INT NOT NULL,
    id_doctor INT NOT NULL,
    id_employee INT NOT NULL,
    applied_quantity INT NOT NULL CHECK(applied_quantity > 0),
    administration_route VARCHAR(30) NOT NULL,
    application_date DATETIME NOT NULL

        CONSTRAINT fk_medication_patient FOREIGN KEY (id_patient) REFERENCES patients(id_patient),
    CONSTRAINT fk_medication_doctor FOREIGN KEY (id_doctor) REFERENCES doctors(id_doctor),
    CONSTRAINT fk_medication_employee FOREIGN KEY (id_employee) REFERENCES EMPLOYEES(id_employee),
    CONSTRAINT fk_medication_pharmacy FOREIGN KEY (id_medication) REFERENCES pharmacy(id_medication)
);


/*************************************
*********INSERTS PATIENTS*************
***************************************/
INSERT into patients
    (cpf,name_patient, phone_number, name_health_plan, type_health_plan)
VALUES
    ('123.456.789-00', 'Mauricio Aragão', '(86) 977559910', 'unimed', 'premium');

INSERT into patients
    (cpf,name_patient, phone_number, name_health_plan, type_health_plan)
VALUES
    ('132.605.892-90', 'Matheus Rodrigues', '(61) 987559911', 'bradesco', 'silver');

INSERT into patients
    (cpf,name_patient, phone_number, name_health_plan, type_health_plan)
VALUES
    ('100.406.789-20', 'Francisco Aragão', '(86)947579901', 'cassi', 'gold');

INSERT into patients
    (cpf,name_patient, phone_number, name_health_plan, type_health_plan)
VALUES
    ('133.906.889-30', 'Rosy Vieira', '(86)947579901', 'cassi', 'gold');

/*****************************************
***********INSERTS DOCTORS************
******************************************/
INSERT into doctors
    (crm, name_doctor, specialty)
VALUES
    (54189, 'Dr Leandro Almeida', 'Ortopedista');

INSERT into doctors
    (crm, name_doctor, specialty)
VALUES
    (96835, 'Dra Rosy Vieira', 'Neurologista');

INSERT into doctors
    (crm, name_doctor, specialty)
VALUES
    (78214, 'Dr Lafaete Vieira', 'Clinica Médica');

/*****************************************
*************INSERTS EMPLOYEES************
******************************************/
INSERT INTO employees
    (name_employee, cpf_employee, role_employee, department)
VALUES
    ('Enfermeira Maria Silva', '987.654.321-11', 'Enfermeira Triagem', 'Pronto Socorro');

INSERT INTO employees
    (name_employee, cpf_employee, role_employee, department)
VALUES
    ('Enfermeiro João Carlos', '907.654.421-51', 'Enfermeiro Triagem', 'Pronto Socorro');

INSERT INTO employees
    (name_employee, cpf_employee, role_employee, department)
VALUES
    ('Enfermeiro  Carlos Antonio', '807.554.121-21', 'Enfermeiro Triagem', 'Pronto Socorro');

/*****************************************
*********INSERTS CONSULTATION*************
******************************************/
INSERT into consultation
    (consultation_date,consultation_time, fk_id_patient, fk_id_doctor)
VALUES
    ('2026-05-11', '12:50', 3, 2);

INSERT into consultation
    (consultation_date,consultation_time, fk_id_patient, fk_id_doctor)
VALUES
    ('2026-05-13', '12:50', 4, 1);

INSERT into consultation
    (consultation_date,consultation_time, fk_id_patient, fk_id_doctor)
VALUES
    ('2026-05-10', '12:50', 2, 3);

/*****************************************
*************INSERTS EXAMS*****************
******************************************/
INSERT into exams
VALUES
    (1, 'blood_count', 120.00);
INSERT into exams
VALUES
    (2, 'x-ray', 75.00);
INSERT into exams
VALUES
    (3, 'resonance', 1775.00);

/*****************************************
*************INSERTS TRIAGE*****************
******************************************/
INSERT INTO triage
    (id_patient, id_employee, weight_patient, height_patient, blood_pressure, temperature_patient, symptoms_patient, classification_level)
VALUES
    (1, 1, 75.50, 1.75, '12/8', 36.5, 'Rinite alergica e sinusite', 'Verde');

INSERT INTO triage
    (id_patient, id_employee, weight_patient, height_patient, blood_pressure, temperature_patient, symptoms_patient, classification_level)
VALUES
    (2, 2, 80.50, 1.75, '14/8', 38.5, 'pressão alta', 'amarelo');

INSERT INTO triage
    (id_patient, id_employee, weight_patient, height_patient, blood_pressure, temperature_patient, symptoms_patient, classification_level)
VALUES
    (3, 2, 80.50, 1.75, '14/8', 38.5, 'rinite alergica', 'Verde');

INSERT INTO triage
    (id_patient, id_employee, weight_patient, height_patient, blood_pressure, temperature_patient, symptoms_patient, classification_level)
VALUES
    (4, 3, 80.50, 1.75, '13/8', 38.5, 'rinite alergica', 'Verde');

/*****************************************
***********INSERT REQUEST_EXAMS***********
******************************************/
INSERT into request_exams
    (result_exam, exam_date, amount_payable, fk_id_consultation, fk_exam_code)
VALUES
    ('normal', '2026-05-11', 120.00, 1, 1);

INSERT into request_exams
    (result_exam, exam_date, amount_payable, fk_id_consultation, fk_exam_code)
VALUES
    ('fracture', '2026-05-13', 75.00, 2, 2);

INSERT into request_exams
    (result_exam, exam_date, amount_payable, fk_id_consultation, fk_exam_code)
VALUES
    ('no changes', '2026-05-13', 1775.00, 3, 3);

/*****************************************
***********INSERTS XRAY EXAMS**************
******************************************/
INSERT INTO xray_exams
    (id_patient,id_doctor,fk_request_number,scan_area,xray_view,radiological_findings,image_path)
VALUES
    (3, 2, 1, 'torax', 'AP (Anteroposterior)', 'Pulmoes limpos, sem sinais de fratura nas costelas ou alteracoes cardiacas.', '/images/xray/2026/req_001.png');

INSERT INTO xray_exams
    (id_patient,id_doctor,fk_request_number,scan_area,xray_view,radiological_findings,image_path)
VALUES
    (4, 1, 3, 'Perna esquerda', 'AP (Anteroposterior) e perfil', 'Fratura de tíbia', '/images/xray/2026/req_003.png');

INSERT INTO xray_exams
    (id_patient,id_doctor,fk_request_number,scan_area,xray_view,radiological_findings,image_path)
VALUES
    (4, 2, 1, 'Perna esquerda', 'AP (Anteroposterior) e perfil', 'Fratura de fêmur ', '/images/xray/2026/req_001.png');

/*****************************************
***********INSERTS PHARMACY**************
******************************************/

INSERT INTO pharmacy
    (name_of_the_medication, dosage_medication, Pharmaceutical_form,Current_quantity_in_stock,Batch_of_medicine,Expiration_date)
VALUES(
        'dipirona',
        '500 mg',
        'comprimido',
        100,
        'D-260601-001',
        '2030-05-10'
);

INSERT INTO pharmacy
    (name_of_the_medication, dosage_medication, Pharmaceutical_form,Current_quantity_in_stock,Batch_of_medicine,Expiration_date)
VALUES(
        'buscopan',
        '10mg',
        'gotas',
        100,
        'b-260601-001',
        '2038-06-10'
);

INSERT INTO pharmacy
    (name_of_the_medication, dosage_medication, Pharmaceutical_form,Current_quantity_in_stock,Batch_of_medicine,Expiration_date)
VALUES(
        'tramal',
        '500 mg',
        'injetável',
        60,
        'Tr-260601-001',
        '2027-05-10'
);

/*****************************************
***********INSERTS medication_room********
******************************************/

/*id_medication,id_patient,id_doctor,id_employee,applied_quantity,administration_route,application_date*/

INSERT INTO medication_room
    (id_medication,id_patient,id_doctor,id_employee,applied_quantity,administration_route,application_date)
VALUES(
        2,
        4,
        3,
        1,
        2,
        'oral',
        '2026-06-02 10:00'

);

/*****************************************
***********UPDATES E DELETES**************
******************************************/
UPDATE patients SET type_health_plan = 'special' WHERE cpf = '123.456.789-00';
UPDATE patients SET type_health_plan = 'standard' WHERE cpf = '100.406.789-20';
UPDATE patients SET type_health_plan = 'basic' WHERE cpf = '133.906.889-30';
UPDATE patients SET type_health_plan = 'standard' WHERE cpf = '132.605.892-90';
UPDATE patients SET phone_number = '(61)99999-0000' WHERE cpf = '123.456.789-00';
UPDATE patients SET phone_number = '(86)947579901' WHERE cpf = '100.406.789-20';
UPDATE patients SET phone_number = '(86)947579901' WHERE cpf = '133.906.889-30';

DELETE FROM patients WHERE cpf = '222.222.222.32';
DELETE FROM patients WHERE cpf = '888.888.888.00';
DELETE FROM patients WHERE cpf = '999.999.999-99';


/*****************************************
************SELECTS***********************
******************************************/

SELECT
    p.name_patient AS 'Paciente',
    d.name_doctor AS 'Médico',
    x.fk_request_number AS 'Nº Pedido',
    x.scan_area AS 'Região',
    x.radiological_findings AS 'Laudo Radiológico'
FROM xray_exams x
    INNER JOIN patients p ON x.id_patient = p.id_patient
    INNER JOIN doctors d ON x.id_doctor = d.id_doctor;


SELECT
    t.id_triage AS 'Nº Triagem',
    p.id_patient AS 'ID Paciente',
    p.name_patient AS 'Paciente',
    t.weight_patient AS 'Peso',
    t.height_patient AS 'Altura',
    t.blood_pressure AS 'P.A.',
    t.temperature_patient AS 'Temp',
    t.symptoms_patient AS 'sintomas',
    t.classification_level AS 'Classificação',
    e.id_employee AS 'ID Funcionário',
    e.name_employee AS 'Profissional',
    t.triage_date AS 'Data/Hora'
FROM triage t
    INNER JOIN patients p ON t.id_patient = p.id_patient
    INNER JOIN employees e ON t.id_employee = e.id_employee



SELECT
    patients.name_patient,
    doctors.name_doctor,
    consultation.consultation_date

FROM consultation
    INNER JOIN patients
    ON consultation.fk_id_patient = patients.id_patient
    INNER JOIN doctors
    ON consultation.fk_id_doctor = doctors.id_doctor;


SELECT
    mr.id_medication_room AS 'Cód.Registro',
    p.name_of_the_medication AS 'Medicamento',
    pat.name_patient AS 'Paciente',
    doc.name_doctor AS 'Médico Prescritor',
    emp.name_employee AS 'Profissional',
    mr.applied_quantity AS 'quantidade',
    mr.administration_route AS 'Via',
    mr.application_date AS 'Data/Hora'
FROM medication_room mr
    INNER JOIN pharmacy p ON mr.id_medication = p.id_medication
    INNER JOIN patients pat ON mr.id_patient = pat.id_patient
    INNER JOIN doctors doc ON mr.id_doctor = doc.id_doctor
    INNER JOIN employees emp ON mr.id_employee = emp.id_employee;



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

SELECT*
FROM xray_exams;

SELECT*
FROM pharmacy;

SELECT*
FROM medication_room;
