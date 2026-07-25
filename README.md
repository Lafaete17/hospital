PulseShield — Database Security & Hospital Information System
PulseShield é uma solução de arquitetura e segurança de banco de dados hospitalar projetada sob o paradigma de DevSecOps e Zero Trust (Confiança Zero). O projeto foca em Defense-in-Depth (Defesa em Profundidade), controle de acesso baseado em funções (RBAC), restrição temporal por turnos, auditoria e procedimentos seguros de autenticação.

📌 Escopo Atual & Stack Tecnológica
Atualmente, o repositório consolida a camada de Infraestrutura e Segurança de Dados do ecossistema hospitalar:

Engine de Banco de Dados: Microsoft SQL Server

Linguagem / Scripting: T-SQL (Transact-SQL)

Arquitetura de Segurança: Role-Based Access Control (RBAC), Time-Based Access Control (TBAC) e Gatilhos/Funções de Segurança

Procedimentos: Stored Procedures de Autenticação, Redefinição de Senha e Evolução Clínica

Auditoria: Views dedicadas para Relatórios Clínicos e Auditoria de Permissões

🔒 Mecanismos de Segurança Implementados
1. Modelo de Controle de Acesso Baseado em Funções (RBAC)
Implementação de regras estritas de privilégio mínimo (Least Privilege) separando os papéis do ecossistema hospitalar:

db_receptionist_role: Acesso restrito a pacientes, triagem e consultas (bloqueio total em prontuários e exames).

db_doctor_role: Acesso a exames de imagem, prontuários, triagem e execução de procedures clínicas.

db_nurse_role: Acesso e edição na triagem e aplicação de medicamentos, com bloqueio em prontuários clínicos.

db_admin_role: Gestão total do ambiente.

2. Controle de Acesso Temporal (Time-Based Access Control / Zero Trust)
Função fn_CheckUserAccessTime: Valida em tempo real se o usuário conectado possui um turno de trabalho (work_shift) ativo no exato dia da semana e horário da requisição.

Gatilho tr_EnforceTimeAccessControl: Intercepta operações na tabela de consultas (consultation), realizando o ROLLBACK automático da transação caso a tentativa de acesso ocorra fora do expediente do profissional.

3. Gestão de Credenciais e Autenticação Segura
Tabela user_credentials: Estruturada para armazenar hashes e salts de senhas, controle de status do usuário, último login e tokens de recuperação com validade temporária (token_expires_at).

Stored Procedures:

sp_RegisterUserCredentials: Cadastro seguro de acessos vinculados ao corpo médico, enfermagem ou recepção.

sp_GeneratePasswordResetToken: Geração de tokens de redefinição com expiração automática em 15 minutos.

sp_ValidatePasswordReset: Validação e redefinição segura de credenciais.

🗺️ Próximos Passos (Roadmap)
[x] Modelagem do Banco de Dados e Mapeamento de Entidades

[x] Implementação do RBAC e Regras de Segurança Temporal

[x] Stored Procedures para Autenticação e Gestão de Credenciais

[ ] Construção da Web API em .NET 8 (C#) com EF Core Migrations

[ ] Implementação do Hashing com Argon2id no Backend

[ ] Interface Frontend em Angular para os painéis clínicos

👨‍💻 Autor
Lafaete Vieira

Estudante de Análise e Desenvolvimento de Sistemas (ADS)

Focado em Cybersecurity, DevSecOps e Infraestrutura de Dados. 
