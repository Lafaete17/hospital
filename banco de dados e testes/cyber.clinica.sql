/*********************************************************
************** SECURITY OBJECTS & PROGRAMMABILITY *********
**********************************************************/
-- 1. Derruba os gatilhos e visões primeiro (Eles dependem das tabelas)
DROP TRIGGER IF EXISTS tr_EnforceTimeAccessControl;
GO
DROP VIEW IF EXISTS vw_clinical_report;
GO

-- 2. Derrubando rotinas e funções de validação
DROP PROCEDURE IF EXISTS sp_AddMedicalRecord;
GO
DROP FUNCTION IF EXISTS fn_CheckUserAccessTime;
GO

/*********************************************************
************** TABLES (ORDEM DE DEPENDÊNCIA)**************
**********************************************************/
-- 3. Agora que as travas sumiram, derrubamos as tabelas (Filhas primeiro, Pais depois)
DROP TABLE IF EXISTS user_credentials;
DROP TABLE IF EXISTS user_schedules;
DROP TABLE IF EXISTS work_shift;
-- Ajustado para bater com o nome no singular
DROP TABLE IF EXISTS medical_record;
DROP TABLE IF EXISTS medication_room;
DROP TABLE IF EXISTS pharmacy;
DROP TABLE IF EXISTS xray_exams;
DROP TABLE IF EXISTS triage;
DROP TABLE IF EXISTS request_exams;
DROP TABLE IF EXISTS exams;
DROP TABLE IF EXISTS consultation;
DROP TABLE IF EXISTS receptionists;
DROP TABLE IF EXISTS nursing_staff;
DROP TABLE IF EXISTS doctors;
DROP TABLE IF EXISTS patients;
GO

/*********************************************************
********* DROP SECURITY OBJECTS (REEXECUÇÃO) *************
**********************************************************/

-- 4. Removendo os vínculos dos membros das Roles com segurança condicional
IF IS_ROLEMEMBER('db_receptionist_role', 'user_rebeca') = 1 ALTER ROLE db_receptionist_role DROP MEMBER user_rebeca;
IF IS_ROLEMEMBER('db_receptionist_role', 'user_lucas') = 1 ALTER ROLE db_receptionist_role DROP MEMBER user_lucas;
IF IS_ROLEMEMBER('db_doctor_role', 'user_lafaete') = 1 ALTER ROLE db_doctor_role DROP MEMBER user_lafaete;
IF IS_ROLEMEMBER('db_doctor_role', 'user_rosymeire') = 1 ALTER ROLE db_doctor_role DROP MEMBER user_rosymeire;
IF IS_ROLEMEMBER('db_nurse_role', 'user_maria_silva') = 1 ALTER ROLE db_nurse_role DROP MEMBER user_maria_silva;
IF IS_ROLEMEMBER('db_nurse_role', 'user_joao_carlos') = 1 ALTER ROLE db_nurse_role DROP MEMBER user_joao_carlos;
GO

-- 5. Derrubando as Roles customizadas
DROP ROLE IF EXISTS db_admin_role;
DROP ROLE IF EXISTS db_receptionist_role;
DROP ROLE IF EXISTS db_doctor_role;
DROP ROLE IF EXISTS db_nurse_role;
GO

-- 6. Derrubando os usuários vinculados ao banco PulseShield
DROP USER IF EXISTS user_rebeca;
DROP USER IF EXISTS user_lucas;
DROP USER IF EXISTS user_lafaete;
DROP USER IF EXISTS user_rosymeire;
DROP USER IF EXISTS user_maria_silva;
DROP USER IF EXISTS user_joao_carlos;
GO

-- 7. Derrubando os logins globais do servidor
DROP LOGIN login_rebeca;
DROP LOGIN login_lucas;
DROP LOGIN login_lafaete;
DROP LOGIN login_rosymeire;
DROP LOGIN login_maria_silva;
DROP LOGIN login_joao_carlos;
GO


/*********************************************************
********* CREATION OF TABLES (ESTRUTURA) *****************
**********************************************************/

CREATE TABLE work_shift
(
    id_shift INT IDENTITY(1,1) PRIMARY KEY,
    shift_name VARCHAR(30) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL
);
GO

CREATE TABLE user_schedules
(
    id_schedules INT IDENTITY(1,1) PRIMARY KEY,
    db_username VARCHAR(128) NOT NULL,
    fk_id_shift INT NOT NULL,
    allowed_day_of_week INT NOT NULL CHECK(allowed_day_of_week BETWEEN 1 AND 7),

    CONSTRAINT fk_id_schedules FOREIGN KEY (fk_id_shift) REFERENCES work_shift(id_shift)
);
GO

CREATE TABLE receptionists
(
    id_receptionist INT IDENTITY(1,1) PRIMARY KEY,
    name_receptionist VARCHAR(60) NOT NULL,
    cpf_receptionist VARCHAR(14) UNIQUE NOT NULL,
    work_shift VARCHAR(20),
    /* Horário do expediente */
    status_receptionist BIT DEFAULT 1 NOT NULL
);

CREATE TABLE patients
(
    id_patient INT IDENTITY(1,1) PRIMARY KEY,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    name_patient VARCHAR(40) NOT NULL,
    phone_number VARCHAR(14),
    name_health_plan VARCHAR(20),
    type_health_plan VARCHAR(10)
);

CREATE INDEX idx_patients_cpf ON patients(cpf);

CREATE TABLE doctors
(
    id_doctor INT IDENTITY(1,1) PRIMARY KEY,
    crm INT UNIQUE NOT NULL,
    name_doctor VARCHAR(30) NOT NULL,
    specialty VARCHAR(20) NOT NULL
);

-- Tabela evoluída com foco exclusivo no corpo de enfermagem
CREATE TABLE nursing_staff
(
    id_nurse INT IDENTITY(1,1) PRIMARY KEY,
    name_nurse VARCHAR(60) NOT NULL,
    cpf_nurse VARCHAR(14) UNIQUE NOT NULL,
    coren VARCHAR(20) UNIQUE NOT NULL,
    /* Registro Profissional Obrigatório */
    status_nurse BIT DEFAULT 1 NOT NULL
);

/*********************************************************
********* ***** USER_CREDENTIALS  ************************
**********************************************************/

CREATE TABLE user_credentials
(
    id_credentials INT IDENTITY(1,1) PRIMARY KEY,
    fk_id_doctor INT NULL FOREIGN KEY REFERENCES doctors(id_doctor),
    fk_id_nurse INT NULL FOREIGN KEY REFERENCES nursing_staff(id_nurse),
    fk_id_receptionist INT NULL FOREIGN KEY REFERENCES receptionists(id_receptionist),
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    password_salt VARCHAR(255) NOT NULL,
    reset_token VARCHAR(100) NULL,
    -- <-- AJUSTADO PARA NULL!
    token_expires_at DATETIME NULL,
    is_active BIT DEFAULT 1 NOT NULL,
    last_login DATETIME NULL
);

CREATE TABLE exams
(
    code INT PRIMARY KEY,
    specification VARCHAR(50) NOT NULL,
    price MONEY NOT NULL
);

CREATE TABLE consultation
(
    id_consultation INT IDENTITY(1,1) PRIMARY KEY,
    consultation_date DATE NOT NULL,
    consultation_time TIME NOT NULL,
    fk_id_patient INT NOT NULL,
    fk_id_doctor INT NOT NULL,

    FOREIGN KEY (fk_id_patient) REFERENCES patients(id_patient),
    FOREIGN KEY (fk_id_doctor) REFERENCES doctors(id_doctor)
);

CREATE TABLE request_exams
(
    request_number INT IDENTITY(1,1) PRIMARY KEY,
    result_exam VARCHAR(40),
    exam_date DATE NOT NULL,
    amount_payable MONEY NOT NULL,
    fk_id_consultation INT NOT NULL,
    fk_exam_code INT NOT NULL,

    FOREIGN KEY (fk_id_consultation) REFERENCES consultation(id_consultation),
    FOREIGN KEY (fk_exam_code) REFERENCES exams(code)
);

CREATE TABLE triage
(
    id_triage INT IDENTITY(1,1) PRIMARY KEY,
    id_patient INT NOT NULL,
    id_nurse INT NOT NULL,
    -- Atualizado para apontar para a enfermagem
    weight_patient DECIMAL(5,2),
    height_patient DECIMAL(3,2),
    blood_pressure VARCHAR(10),
    temperature_patient DECIMAL(3,1),
    symptoms_patient VARCHAR(255),
    classification_level VARCHAR(20),
    triage_date DATETIME DEFAULT GETDATE() NOT NULL,

    CONSTRAINT fk_triage_patient FOREIGN KEY (id_patient) REFERENCES patients(id_patient),
    CONSTRAINT fk_triage_nurse FOREIGN KEY (id_nurse) REFERENCES nursing_staff(id_nurse)
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
    name_of_the_medication VARCHAR(50) NOT NULL,
    dosage_medication VARCHAR(20) NOT NULL,
    Pharmaceutical_form VARCHAR(30) NOT NULL,
    Current_quantity_in_stock INT NOT NULL CHECK(Current_quantity_in_stock >= 0),
    Batch_of_medicine VARCHAR(20) NOT NULL,
    Expiration_date DATE NOT NULL
);

CREATE TABLE medication_room
(
    id_medication_room INT IDENTITY(1,1) PRIMARY KEY,
    id_medication INT NOT NULL,
    id_patient INT NOT NULL,
    id_doctor INT NOT NULL,
    id_nurse INT NOT NULL,
    -- Atualizado para apontar para a enfermagem
    applied_quantity INT NOT NULL CHECK(applied_quantity > 0),
    administration_route VARCHAR(30) NOT NULL,
    application_date DATETIME NOT NULL,

    CONSTRAINT fk_medication_patient FOREIGN KEY (id_patient) REFERENCES patients(id_patient),
    CONSTRAINT fk_medication_doctor FOREIGN KEY (id_doctor) REFERENCES doctors(id_doctor),
    CONSTRAINT fk_medication_nurse FOREIGN KEY (id_nurse) REFERENCES nursing_staff(id_nurse),
    CONSTRAINT fk_medication_pharmacy FOREIGN KEY (id_medication) REFERENCES pharmacy(id_medication)
);

CREATE TABLE medical_record
(
    id_medical_record INT IDENTITY(1,1) PRIMARY KEY,
    id_patient INT NOT NULL,
    diagnosis VARCHAR(150),
    symptoms TEXT NOT NULL,
    id_consultation INT NOT NULL,
    allergies VARCHAR(250),

    CONSTRAINT fk_medical_record FOREIGN KEY (id_patient) REFERENCES patients(id_patient),
    CONSTRAINT fk_record_consultation FOREIGN KEY (id_consultation) REFERENCES consultation(id_consultation)
);

/*********************************************************
********* INSERTS FOR TIME-BASED SECURITY ****************
**********************************************************/
INSERT INTO work_shift
    (shift_name, start_time, end_time)
VALUES
    ('Plantão Diurno Hospitalar', '07:00:00', '19:00:00'),
    ('Plantão Noturno Hospitalar', '19:00:00', '07:00:00');
GO

INSERT INTO user_schedules
    (db_username,fk_id_shift, allowed_day_of_week)
VALUES
    ('user_rebeca', 1, 3),
    ('user_lafaete', 1, 3);
GO

/*************************************
********* INSERTS PATIENTS ***********
***************************************/
INSERT INTO patients
    (cpf, name_patient, phone_number, name_health_plan, type_health_plan)
VALUES
    ('123.456.789-00', 'Mauricio Aragão', '(86) 977559910', 'unimed', 'premium'),
    ('132.605.892-90', 'Matheus Rodrigues', '(61) 987559911', 'bradesco', 'silver'),
    ('100.406.789-20', 'Francisco Aragão', '(86)947579901', 'cassi', 'gold'),
    ('133.906.889-30', 'Rosy Vieira', '(86)947579901', 'cassi', 'gold');

/*****************************************
*********** INSERTS DOCTORS **************
******************************************/
INSERT INTO doctors
    (crm, name_doctor, specialty)
VALUES
    (54189, 'Dr Leandro Almeida', 'Ortopedista'),
    (96835, 'Dra Rosy Vieira', 'Neurologista'),
    (78214, 'Dr Lafaete Vieira', 'Clinica Médica');

/*****************************************
********* INSERTS RECEPTIONISTS **********
******************************************/
INSERT INTO receptionists
    (name_receptionist, cpf_receptionist, work_shift)
VALUES
    ('Bruna Santos', '111.222.333-44', 'Manhã'),
    ('Lucas Oliveira', '555.666.777-88', 'Tarde');

/*****************************************
********* INSERTS NURSING STAFF **********
******************************************/
INSERT INTO nursing_staff
    (name_nurse, cpf_nurse, coren)
VALUES
    ('Enfermeira Maria Silva', '987.654.321-11', 'COREN-SP 12345'),
    ('Enfermeiro João Carlos', '907.654.421-51', 'COREN-SP 67890'),
    ('Enfermeiro Carlos Antonio', '807.554.121-21', 'COREN-SP 54321');

/*****************************************
********* INSERTS CONSULTATION ***********
******************************************/
INSERT INTO consultation
    (consultation_date, consultation_time, fk_id_patient, fk_id_doctor)
VALUES
    ('2026-05-11', '12:50', 3, 2),
    ('2026-05-13', '12:50', 4, 1),
    ('2026-05-10', '12:50', 2, 3);

/*****************************************
************* INSERTS EXAMS **************
******************************************/
INSERT INTO exams
    (code, specification, price)
VALUES
    (1, 'blood_count', 120.00),
    (2, 'x-ray', 75.00),
    (3, 'resonance', 1775.00);

/*****************************************
************* INSERTS TRIAGE *************
******************************************/
INSERT INTO triage
    (id_patient, id_nurse, weight_patient, height_patient, blood_pressure, temperature_patient, symptoms_patient, classification_level)
VALUES
    (1, 1, 75.50, 1.75, '12/8', 36.5, 'Rinite alergica e sinusite', 'Verde'),
    (2, 2, 80.50, 1.75, '14/8', 38.5, 'pressão alta', 'amarelo'),
    (3, 2, 80.50, 1.75, '14/8', 38.5, 'rinite alergica', 'Verde'),
    (4, 3, 80.50, 1.75, '13/8', 38.5, 'rinite alergica', 'Verde');

/*****************************************
*********** INSERT REQUEST_EXAMS *********
******************************************/
INSERT INTO request_exams
    (result_exam, exam_date, amount_payable, fk_id_consultation, fk_exam_code)
VALUES
    ('normal', '2026-05-11', 120.00, 1, 1),
    ('fracture', '2026-05-13', 75.00, 2, 2),
    ('no changes', '2026-05-13', 1775.00, 3, 3);

/*****************************************
*********** INSERTS XRAY EXAMS ***********
******************************************/
INSERT INTO xray_exams
    (id_patient, id_doctor, fk_request_number, scan_area, xray_view, radiological_findings, image_path)
VALUES
    (3, 2, 1, 'torax', 'AP (Anteroposterior)', 'Pulmoes limpos, sem sinais de fratura nas costelas ou alteracoes cardiacas.', '/images/xray/2026/req_001.png'),
    (4, 1, 3, 'Perna esquerda', 'AP (Anteroposterior) e perfil', 'Fratura de tíbia', '/images/xray/2026/req_003.png'),
    (4, 2, 1, 'Perna esquerda', 'AP (Anteroposterior) e perfil', 'Fratura de fêmur ', '/images/xray/2026/req_001.png');

/*****************************************
*********** INSERTS PHARMACY **************
******************************************/
INSERT INTO pharmacy
    (name_of_the_medication, dosage_medication, Pharmaceutical_form, Current_quantity_in_stock, Batch_of_medicine, Expiration_date)
VALUES
    ('dipirona', '500 mg', 'comprimido', 100, 'D-260601-001', '2030-05-10'),
    ('buscopan', '10mg', 'gotas', 100, 'b-260601-001', '2038-06-10'),
    ('tramal', '500 mg', 'injetável', 60, 'Tr-260601-001', '2027-05-10');

/*****************************************
*********** INSERTS MEDICATION_ROOM *******
******************************************/
INSERT INTO medication_room
    (id_medication, id_patient, id_doctor, id_nurse, applied_quantity, administration_route, application_date)
VALUES
    (2, 4, 3, 1, 2, 'oral', '2026-06-02 10:00');

/*************************************
********* INSERTS MEDICAL RECORD *******
***************************************/
INSERT INTO medical_record
    (id_patient, id_consultation, diagnosis, symptoms, allergies)
VALUES
    (2, 2, 'suspeita de gripe', 'paciente apresenta corisa, fraqueza,febre e dor de cabeça', 'sem alergias conhecidas'),
    (3, 3, 'suspeita de dengue', 'Paciente apresenta febre alta, dor de cabeça e mialgia há 2 dias.', 'sem alergias conhecidas');

/*****************************************
*********** UPDATES E DELETES ************
******************************************/
UPDATE patients SET type_health_plan = 'special' WHERE cpf = '123.456.789-00';
UPDATE patients SET type_health_plan = 'standard' WHERE cpf = '100.406.789-20';
UPDATE patients SET type_health_plan = 'basic' WHERE cpf = '133.906.889-30';
UPDATE patients SET type_health_plan = 'standard' WHERE cpf = '132.605.892-90';
UPDATE patients SET phone_number = '(61)99999-0000' WHERE cpf = '123.456.789-00';
UPDATE patients SET phone_number = '(86)947579901' WHERE cpf = '100.406.789-20';
UPDATE patients SET phone_number = '(86)947579901' WHERE cpf = '133.906.889-30';

/*****************************************
************ VIEWS ***********************
******************************************/
GO
CREATE VIEW vw_clinical_report
AS
    SELECT
        mr.id_medical_record,
        p.name_patient AS name_patient,
        mr.diagnosis,
        mr.symptoms,
        d.name_doctor AS name_doctor,
        c.consultation_date
    FROM medical_record mr
        INNER JOIN patients p ON mr.id_patient = p.id_patient
        INNER JOIN consultation c ON mr.id_consultation = c.id_consultation
        INNER JOIN doctors d ON c.fk_id_doctor = d.id_doctor;
GO

/*********************************************************
************** STORED PROCEDURE***************************
**********************************************************/
GO
CREATE PROCEDURE sp_AddMedicalRecord
    @id_patient INT,
    @diagnosis VARCHAR(150),
    @symptoms VARCHAR(255),
    @id_consultation INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO medical_record
        (id_patient, id_consultation, diagnosis, symptoms)
    VALUES
        (@id_patient, @id_consultation, @diagnosis, @symptoms);
    PRINT 'Evolução clínica cadastrada com sucesso via Protocolo Seguro!';

END;
GO

/*********************************************************
**********STORED PROCEDURE Register User Credentials******
**********************************************************/
CREATE PROCEDURE sp_RegisterUserCredentials
    -- <-- CORRIGIDO O NOME COM 1 "D"!
    @username VARCHAR(50),
    @fk_id_doctor INT = NULL,
    @fk_id_nurse INT = NULL,
    @fk_id_receptionist INT = NULL,
    @password_hash VARCHAR(255),
    @password_salt VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO user_credentials
        (username, fk_id_doctor, fk_id_nurse, fk_id_receptionist, password_hash, password_salt)
    VALUES
        (@username, @fk_id_doctor, @fk_id_nurse, @fk_id_receptionist, @password_hash, @password_salt);
    PRINT 'Credenciais de acesso registradas com sucesso no PulseShield!';
END;
GO


/*********************************************************
********STORED PROCEDURE Generate Password Reset Token***
**********************************************************/
CREATE PROCEDURE sp_GeneratePasswordResetToken
    @username VARCHAR(50),
    @reset_token VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE user_credentials
    SET reset_token = @reset_token,
        token_expires_at = DATEADD(MINUTE, 15, GETDATE())
    WHERE username = @username;
    -- <-- CORRIGIDO PARA O NOME EXATO DA COLUNA!
    PRINT 'Token de redefinição gerado com sucesso!';
END;
GO

/*********************************************************
********STORED PROCEDURE Validate Password Reset***
**********************************************************/
CREATE PROCEDURE sp_ValidatePasswordReset
    @username VARCHAR(50),
    @reset_token VARCHAR(100),
    @new_password_hash VARCHAR(255),
    @new_password_salt VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE user_credentials
    SET password_hash = @new_password_hash,
        password_salt = @new_password_salt,
        reset_token = NULL,
        token_expires_at = NULL
    WHERE username = @username
        AND reset_token = @reset_token
        AND token_expires_at >= GETDATE();

    PRINT 'Senha redefinida com sucesso';
END;   
GO



/*********************************************************
********* SECURITY: ROLES AND PERMISSIONS (admin role) *
**********************************************************/
GO

CREATE ROLE db_admin_role;
GO

GRANT CONTROL TO db_admin_role;
GO

/*********************************************************
********* SECURITY: ROLES AND PERMISSIONS (RECEPTIONIST) *
**********************************************************/

CREATE ROLE db_receptionist_role;
GO

GRANT SELECT, INSERT, UPDATE ON patients to db_receptionist_role;
GO

GRANT SELECT, INSERT ON triage to db_receptionist_role;
GO

GRANT SELECT, INSERT, UPDATE ON consultation TO db_receptionist_role;
GO

DENY SELECT, INSERT, UPDATE, DELETE ON medical_record TO db_receptionist_role;
GO

DENY SELECT, INSERT,UPDATE,DELETE ON xray_exams TO db_receptionist_role;
GO

/*********************************************************
********* SECURITY: ROLES AND PERMISSIONS (DOCTOR)********
**********************************************************/

CREATE ROLE db_doctor_role;
GO

GRANT SELECT, UPDATE ON medical_record TO db_doctor_role;
GO

GRANT EXECUTE ON sp_AddMedicalRecord TO db_doctor_role;

GRANT SELECT, INSERT, UPDATE ON xray_exams TO db_doctor_role;
GO

GRANT SELECT ON patients TO db_doctor_role;
GO

GRANT SELECT ON triage TO db_doctor_role;
GO

GRANT SELECT ON consultation TO db_doctor_role;
GO

/*********************************************************
********* SECURITY: ROLES AND PERMISSIONS (NURSE ROLE)****
**********************************************************/

CREATE ROLE db_nurse_role
GO

GRANT SELECT,INSERT,UPDATE ON triage TO db_nurse_role;
GO

GRANT SELECT ON patients TO db_nurse_role;
GO

GRANT SELECT ON consultation TO db_nurse_role;
GO

DENY SELECT,INSERT,UPDATE,DELETE ON medical_record TO db_nurse_role;
GO

DENY SELECT, INSERT, UPDATE, DELETE ON xray_exams TO db_nurse_role;
GO

/*********************************************************
** CREATING LOGINS AND ASSIGNING TO ROLES (RECEPTIONISTS)*
**********************************************************/

CREATE LOGIN login_rebeca WITH PASSWORD = 'SecurePassword123!';
GO

CREATE USER user_rebeca FOR LOGIN login_rebeca;
GO

ALTER ROLE db_receptionist_role ADD MEMBER user_rebeca;
GO


CREATE LOGIN login_lucas WITH PASSWORD = 'SecurePassword1234!';
GO

CREATE USER user_lucas FOR LOGIN login_lucas;
GO

ALTER ROLE db_receptionist_role ADD MEMBER user_lucas;
GO

/*********************************************************
******CREATING LOGINS AND ASSIGNING TO ROLES (DOCTORS)****
**********************************************************/
CREATE LOGIN login_lafaete WITH PASSWORD = 'SecureMed123!';
GO

CREATE USER user_lafaete FOR LOGIN login_lafaete;
GO

ALTER ROLE db_doctor_role ADD MEMBER user_lafaete;
GO

CREATE LOGIN login_rosymeire WITH PASSWORD = 'SecureMed123!';
GO

CREATE USER user_rosymeire FOR LOGIN login_rosymeire;
GO

ALTER ROLE db_doctor_role ADD MEMBER user_rosymeire;
GO

/*********************************************************
** CREATING LOGINS AND ASSIGNING TO ROLES (NURSE)*********
**********************************************************/

CREATE LOGIN login_maria_silva WITH PASSWORD = 'SecureNurse123!';
GO

CREATE USER user_maria_silva FOR LOGIN login_maria_silva;
GO

ALTER ROLE db_nurse_role ADD MEMBER user_maria_silva;
GO

CREATE LOGIN login_joao_carlos WITH PASSWORD = 'SecureNurse1234!';
GO

CREATE USER user_joao_carlos FOR LOGIN login_joao_carlos;
GO

ALTER ROLE db_nurse_role ADD MEMBER user_joao_carlos;
GO

/*********************************************************
************** SECURITY: TIME ACCESS FUNCTION ************
**********************************************************/
GO
CREATE FUNCTION fn_CheckUserAccessTime (@username VARCHAR(128))
RETURNS BIT
AS
BEGIN
    DECLARE @is_allowed BIT = 0;
    DECLARE @current_time TIME = CONVERT(TIME, GETDATE());
    DECLARE @current_day INT = DATEPART(WEEKDAY, GETDATE());

    -- Verifica se existe uma escala ativa para o usuário neste exato momento
    IF EXISTS (
        SELECT 1
    FROM user_schedules us
        INNER JOIN work_shift ws ON us.fk_id_shift = ws.id_shift
    WHERE us.db_username = @username
        AND us.allowed_day_of_week = @current_day
        AND (
                -- Caso 1: Turno padrão que não vira o dia (Ex: 07:00 às 19:00)
                (ws.start_time <= ws.end_time AND @current_time BETWEEN ws.start_time AND ws.end_time)
        OR
        -- Caso 2: Turno noturno que vira o dia (Ex: 19:00 às 07:00 do dia seguinte)
        (ws.start_time > ws.end_time AND (@current_time >= ws.start_time OR @current_time <= ws.end_time))
          )
    )
    BEGIN
        SET @is_allowed = 1;
    END;

    RETURN @is_allowed;
END;
GO

/*********************************************************
************** SECURITY: TIME ACCESS TRIGGER *************
**********************************************************/
CREATE TRIGGER tr_EnforceTimeAccessControl
ON consultation
FOR INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Captura o usuário do sistema que disparou o comando atual
    DECLARE @current_user VARCHAR(128) = SYSTEM_USER;

    -- Se o usuário NÃO tiver um plantão ativo neste exato momento, barra ele!
    IF dbo.fn_CheckUserAccessTime(@current_user) = 0
    BEGIN
        RAISERROR ('[PulseShield Security] Acesso bloqueado! Seu usuário não possui um plantão ativo para este horário ou dia da semana.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO


