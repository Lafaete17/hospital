-- =========================================================================
-- PROTOCOLO DE AUDITORIA E TESTE DE INVASÃO COMPLETO (PULSESHIELD)
-- OBJETIVO: Validar o isolamento de Roles e o Princípio do Menor Privilégio
-- =========================================================================

PRINT '=================================================================';
PRINT '--- INICIANDO FASE 1: AUDITORIA E RECONCILIAÇÃO DA RECEPÇÃO ---';
PRINT '=================================================================';

-- 1. Alterando contexto para o Recepcionista Lucas
EXECUTE AS USER = 'user_lucas';
GO

-- 1.1. Validação de Identidade Ativa
SELECT CURRENT_USER AS Funcionario_Ativo_Fase1;
GO

-- 1.2. [ACESSO LEGÍTIMO] Visualização de Pacientes (GRANT Ativo)
PRINT '--- Testando Acesso Permitido: Consulta de Pacientes ---';
BEGIN TRY
    SELECT *
FROM patients;
    PRINT '[SUCESSO] Recepção acessou a listagem de pacientes perfeitamente!';
END TRY
BEGIN CATCH
    PRINT '[ERRO CRÍTICO] Falha ao acessar tabela permitida: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 1.3. [ATAQUE SIMULADO] Tentativa de leitura direta no Prontuário Clínico (DENY Ativo)
PRINT '--- Testando Bloqueio Direto: Tentativa de Acesso ao Prontuário Clínico ---';
BEGIN TRY
    SELECT *
FROM medical_record;
    PRINT '[FALHA DE SEGURANÇA EXTREMA] O recepcionista conseguiu ler os prontuários brutos!';
END TRY
BEGIN CATCH
    PRINT '[SUCESSO] Ataque contido! O DENY explícito barrou o acesso na tabela bruta.';
    PRINT 'Mensagem de Bloqueio do Banco: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 1.4. [ATAQUE SIMULADO] Tentativa de bypass via View Clínica
PRINT '--- Testando Bloqueio Indireto: Tentativa de Leitura via View Clínica ---';
BEGIN TRY
    SELECT *
FROM vw_clinical_report;
    PRINT '[FALHA DE SEGURANÇA] O recepcionista quebrou o privilégio através da View!';
END TRY
BEGIN CATCH
    PRINT '[SUCESSO] View protegida! O usuário não possui privilégios nos objetos base.';
    PRINT 'Mensagem de Bloqueio do Banco: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 1.5. Restaurando contexto para o Administrador
REVERT;
GO
SELECT CURRENT_USER AS Contexto_Restaurado_Admin;
GO


PRINT '=================================================================';
PRINT '--- INICIANDO FASE 2: AUDITORIA DOS MÉDICOS (PLANTÃO SÉNIOR) ---';
PRINT '=================================================================';

-- 2. Alterando contexto para o Médico Lafaete
EXECUTE AS USER = 'user_lafaete';
GO

-- 2.1. Validação de Identidade Ativa
SELECT CURRENT_USER AS Medico_Ativo_Fase2;
GO

-- 2.2. [ACESSO LEGÍTIMO] Consulta ao Histórico de Pacientes
PRINT '--- Testando Acesso Médico: Consulta de Pacientes ---';
BEGIN TRY
    SELECT *
FROM patients;
    PRINT '[SUCESSO] Médico consultou dados cadastrais dos pacientes para o prontuário.';
END TRY
BEGIN CATCH
    PRINT '[ERRO DE INFRA] Médico foi bloqueado indevidamente em Patients: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 2.3. [ACESSO LEGÍTIMO] Leitura Direta do Prontuário Médico
PRINT '--- Testando Acesso Médico: Leitura de Prontuários ---';
BEGIN TRY
    SELECT *
FROM medical_record;
    PRINT '[SUCESSO] Médico visualizou o histórico clínico da tabela bruta.';
END TRY
BEGIN CATCH
    PRINT '[ERRO DE INFRA] Médico foi bloqueado na leitura de Prontuários: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 2.4. Restaurando contexto para o Administrador
REVERT;
GO
SELECT CURRENT_USER AS Contexto_Restaurado_Admin;
GO


PRINT '=================================================================';
PRINT '--- INICIANDO FASE 3: VALIDAÇÃO DE ESCRITA E OWNERSHIP CHAINING ---';
PRINT '=================================================================';

-- 3. Alterando contexto para a Médica Auditora Rosymeire
EXECUTE AS USER = 'user_rosymeire';
GO

-- 3.1. Validação de Identidade Ativa
SELECT CURRENT_USER AS Medico_Ativo_Fase3;
GO

-- 3.2. [ACESSO CONTROLADO] Cadastrando evolução via Stored Procedure (Protocolo Seguro)
PRINT '--- Testando Escrita Autorizada via Stored Procedure ---';
BEGIN TRY
    EXEC sp_AddMedicalRecord 
        @id_patient = 1, 
        @diagnosis = 'Crise Alérgica Aguda', 
        @symptoms = 'Paciente deu entrada com coriza intensa e congestão facial.', 
        @id_consultation = 2;
    PRINT '[SUCESSO] Dra. Rosymeire evoluiu o paciente via canal seguro (Ownership Chaining)!';
END TRY
BEGIN CATCH
    PRINT '[ERRO CRÍTICO] A Stored Procedure autorizada falhou: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 3.3. [CHEQUE-MATE] Validação da gravação e leitura dos dados atualizados
PRINT '--- Testando Leitura Pós-Gravação dos Dados Clínicos ---';
BEGIN TRY
    SELECT id_medical_record, diagnosis, symptoms
FROM medical_record;
    PRINT '[SUCESSO] Histórico atualizado exibido em tela com a nova evolução inclusa!';
END TRY
BEGIN CATCH
    PRINT '[ERRO DE INFRA] Falha na leitura dos prontuários atualizados: ' + ERROR_MESSAGE();
END CATCH;
GO

-- 3.4. Finalizando a simulação e retornando em definitivo para o Admin
REVERT;
GO
PRINT '=================================================================';
PRINT '--- FIM DO PROTOCOLO DE AUDITORIA: SISTEMA PULSESHIELD HOMOLOGADO ---';
PRINT '=================================================================';
SELECT CURRENT_USER AS Contexto_Seguro_Final;
GO


/*********************************************************
************** TEST SECURITY: TIME ACCESS TRIGGER *************
**********************************************************/

EXECUTE AS USER = 'user_lucas';
GO

-- Tentando inserir uma consulta na marra fora do horário
INSERT INTO consultation
    (consultation_date, consultation_time, fk_id_patient, fk_id_doctor)
VALUES
    ('2026-06-16', '16:00:00', 1, 1);
GO

REVERT;
GO