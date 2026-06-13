/*********************************************************
********* TESTE 1: RECONCILIAÇÃO DE ACESSO (RECEPÇÃO) *****
**********************************************************/

-- 1. Recepcionista Lucas (Recepcionista)
EXECUTE AS USER = 'user_lucas';


-- 1.1. ELE DEVE CONSEGUIR VER OS PACIENTES (Permissão GRANT)
SELECT*
FROM patients;


-- 1.2. ELE DEVE SER BARRADO NA EVOLUÇÃO MÉDICA (Restrição DENY)
-- (Esse comando TEM QUE dar erro de permissão na tela!)
SELECT*
FROM medical_record;


-- 2. Voltando a ser o Administrador do Banco
REVERT;
GO

/*********************************************************
********* TESTE 2: AUDITORIA DE ACESSO (MÉDICO) **********
**********************************************************/

-- 1. Médico Lafaete (Médico)
EXECUTE AS USER = 'user_lafaete';


-- 1.1. ELE DEVE CONSEGUIR VER E INSERIR NO PRONTUÁRIO MÉDICO
SELECT*
FROM medical_record;


-- 1.2. ELE DEVE CONSEGUIR CONSULTAR O HISTÓRICO DE PACIENTES
SELECT*
FROM patients;

-- 2. Voltando a ser o Administrador do Banco
REVERT;
GO


