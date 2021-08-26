Considere uma tabela de sal�rios em um banco de dados, toda vez que o campo sal�rio for alterado na tabela de sal�rios, � preciso manter um log de auditoria em uma tabela que armazena os dados do sal�rio antes e depois da altera��o, al�m de manter os dados do usu�rio (SYSTEM_USER) e a data da altera��o. 

a) Teste o trigger atualizando o sal�rio da matr�cula 1 para R$ 2.000,00.
b) Teste o trigger atualizando o sal�rio da matr�cula 2 para R$ 1.500,00.
c) Teste o trigger atualizando o sal�rio da matr�cula 3 para R$ 2.000,00.
d) Teste o trigger atualizando o sal�rio da matr�cula 4 para R$ 2.500,00.
e) Teste o trigger atualizando todos sal�rios com um aumento de 10%.

# DDL com os artefatos necess�rios para o lab

USE GATILHO;

CREATE TABLE salario(
	matricula INT NOT NULL,
	salario DECIMAL(10, 2) NOT NULL
)

INSERT INTO salario VALUES (1, 1000)
INSERT INTO salario VALUES (2, 1500)
INSERT INTO salario VALUES (3, 2000)
INSERT INTO salario VALUES (4, 2500)

SELECT * FROM salario

CREATE TABLE auditoria_salario(
	matricula INT NOT NULL,
	sal_antes DECIMAL(10, 2) NOT NULL,
	sal_depois DECIMAL(10, 2) NOT NULL,
	usuario VARCHAR(50) NOT NULL,
	data_atualizacao DATETIME NOT NULL
)

SELECT * FROM auditoria_salario