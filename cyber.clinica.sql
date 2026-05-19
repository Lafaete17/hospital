

CREATE TABLE patients(
    cpf VARCHAR(14) PRIMARY KEY,
    name_patient VARCHAR(40),
    phone_number VARCHAR(14),
    name_health_plan VARCHAR(20),
    type_health_plan VARCHAR (10)

);

CREATE TABLE doctors(
    crm INT PRIMARY KEY,
    name_doctor VARCHAR(30),
    specialty VARCHAR(20)
);

CREATE TABLE consultation(
    consultation_number INT IDENTITY (1,1) PRIMARY KEY,
    consultation_date DATE,
    consultation_time TIME,
    fk_patient_cpf VARCHAR(14),
    fk_doctors_crm INT,

    FOREIGN KEY (fk_patient_cpf)
    REFERENCES patients(cpf),

    FOREIGN KEY (fk_doctors_crm)
    REFERENCES doctors (crm)

);

CREATE TABLE exams(
    code INT PRIMARY KEY,
    specification VARCHAR(20),
    price money
);

CREATE TABLE request_exams(
    request_number INT IDENTITY (1,1) PRIMARY KEY,
    result_exam VARCHAR(40),
    exam_date DATE,
    amount_payable money,
    fk_consultation_number INT,
    fk_exam_code INT,

    FOREIGN KEY (fk_consultation_number)
    REFERENCES consultation(consultation_number),

    FOREIGN KEY(fk_exam_code)
    REFERENCES exams(code)
);
/*************************************
*********INSERTS PATIENTS*************
***************************************/


INSERT into patients
VALUES(
    '123.456.789-00',
    'Mauricio Aragão',
    '(86) 977559910',
    'unimed',
    'premium'
);

INSERT into patients
VALUES(
    '132.605.892-90',
    'Matheus Rodrigues',
    '(61) 987559911',
    'bradesco',
    'silver'
);

INSERT into patients
VALUES(
    '100.406.789-20',
    'Francisco Aragão',
    '(86)947579901',
    'cassi',
    'gold'
);

INSERT into patients
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
VALUES(
    54189,
    'Dr Leandro Almeida',
    'Ortopedista'
);

INSERT into doctors
VALUES(
    96835,
    'Dra Rosy Vieira',
    'Neurologista'
);

INSERT into doctors
VALUES(
    78214,
    'Dr Lafaete Vieira',
    'Clinica Médica'
);

/*****************************************
*********NSERTS CONSULTATION*************
******************************************/

INSERT into consultation
VALUES(
    '2026-05-11',
    '12:50',
    '100.406.789-20',
    96835
);

INSERT into consultation
VALUES(
    '2026-05-13',
    '12:50',
    '133.906.889-30',
    54189
);

INSERT into consultation
VALUES(
    '2026-05-10',
    '12:50',
    '132.605.892-90',
    78214
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
values(
    'normal',
    '2026-05-11',
    120.00,
    7,
    1
);

INSERT into request_exams
values(
    'fracture',
    '2026-05-13',
    75.00,
    8,
    2
);

INSERT into request_exams
values(
    'no changes',
    '2026-05-13',
    1775.00,
    9,
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
ON consultation.fk_patient_cpf = patients.cpf
INNER JOIN doctors
ON consultation.fk_doctors_crm = doctors.crm; 

/*****************************************
******************************************
******************************************/

SELECT * FROM patients;

SELECT * FROM doctors;

SELECT * FROM consultation;

SELECT * FROM exams;

SELECT * FROM request_exams;

