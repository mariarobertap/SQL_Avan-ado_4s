/*Lista de Exerc�cios utilizando a base de dados COMERCIO: Procedimentos e Fun��es.

# Procedimentos

1) Crie um procedimento que apresente o volume e o montante total de vendas por regi�o e trimestre. */

GO
CREATE PROCEDURE Montante 
AS
BEGIN
	SELECT
		e.REGIAO, 
		FORMAT(SUM(nf.total), 'C', 'PT-BR') AS 'Montante Total',
		COUNT(distinct NF.IDNOTA) AS 'Volume de vendas',
		CASE DATEPART(QUARTER, nf.DATA) 
			 WHEN 1 THEN '1 Trimestre'   
			 WHEN 2 THEN '2 Trimestre' 
			 WHEN 3 THEN '3 Trimestre' 
		END as 'Trimestre'
	FROM
		nota_fiscal nf
		JOIN
			cliente c on nf.ID_CLIENTE = c.IDCLIENTE
		JOIN
			endereco e on e.ID_CLIENTE = c.IDCLIENTE
	WHERE 
		DATEPART(QUARTER, nf.DATA) != 4
	GROUP BY
		e.REGIAO,
		DATEPART(QUARTER, nf.DATA)
	ORDER BY 
		 4
END;

EXEC Montante

/*

2) Crie um procedimento que apresente os top 10 clientes em volume de compras.
*/
GO
CREATE PROCEDURE Top10EmVolume 
AS
BEGIN
	SELECT TOP 10
		ROW_NUMBER() OVER(ORDER BY COUNT(NF.IDNOTA)desc ) AS Rank,
		COUNT(NF.IDNOTA) AS 'Volume de compras',
		CONCAT(c.NOME, ' ', C.SOBRENOME) AS 'Nome completo'

	FROM
		nota_fiscal nf
		JOIN
			cliente c on nf.ID_CLIENTE = c.IDCLIENTE
	GROUP BY
		CONCAT(c.NOME, ' ', C.SOBRENOME)

end;
exec Top10EmVolume
drop procedure Top10EmVolume
/*
3) Crie um procedimento que mostre os clientes que n�o realizaram nenhuma compra.
*/
GO
CREATE PROCEDURE ClientesSemCompras 
AS
BEGIN
	SELECT 
		CONCAT(NOME, ' ', SOBRENOME) AS 'Nome completo'
	FROM
		CLIENTE
	WHERE IDCLIENTE NOT IN(
		SELECT 
			NF.ID_CLIENTE
		FROM
			NOTA_FISCAL NF
		JOIN
			CLIENTE C ON C.IDCLIENTE = NF.ID_CLIENTE)
end;
EXEC ClientesSemCompras
drop procedure ClientesSemCompras

/*
4) Crie um procedimento que apresente o faturamento e o faturamento acumulado por ano.
*/
GO
CREATE PROCEDURE FaturamentoPAno 
AS
BEGIN
	SELECT
		YEAR(n.DATA) as mes,
		FORMAT(SUM(n.total), 'C', 'PT-BR') AS 'Montante Total',
		vlrAcumulado = (
			SELECT 
				FORMAT(SUM(ns.total), 'C', 'PT-BR') AS 'Montante Total'
			FROM
				NOTA_FISCAL ns

			WHERE YEAR(ns.DATA) <= YEAR(N.DATA)
			)
		FROM 
			NOTA_FISCAL n
		GROUP BY
			YEAR(n.DATA)
END;

EXEC FaturamentoPAno


/*
5) Crie um procedimento que apresente os cinco produtos mais caros por categoria (par�metro de entrada) de produto.
*/

GO
CREATE PROCEDURE Top5ProdutosPCategoria (@NomeCategoria VARCHAR(30))
AS
BEGIN
	SELECT top 5
		ROW_NUMBER() OVER(ORDER BY max(valor) desc ) AS Rank,
		P.PRODUTO,
		C.NOME,
		FORMAT(max(valor), 'C', 'PT-BR') AS 'Valor'

	FROM
		PRODUTO P
	JOIN
		 CATEGORIA C ON C.IDCATEGORIA = P.ID_CATEGORIA
	WHERE C.NOME = @NomeCategoria
	GROUP BY P.PRODUTO, C.NOME
END;
exec Top5ProdutosPCategoria 'LIVROS'
SELECT MAX(VALOR) FROM PRODUTO
SELECT * FROM CATEGORIA
/*


# Fun��es

1) Crie uma fun��o que informado o sexo (M, F) como par�metro retorne a sua descri��o (Masculino, Feminino).
*/


CREATE FUNCTION FN_EXERCICIO_01(@sexo CHAR)
RETURNS VARCHAR(10)
AS
BEGIN
	RETURN IIF(@sexo  = 'F', 'Feminino', 'Masculino')
END;

SELECT dbo.FN_EXERCICIO_01('F')



/*
2) Crie uma fun��o (multi-statement table-valued function) que apresente o volume e o montante total de compras com as informa��es do cliente (par�metro de entrada, c�digo do cliente), sendo:

- c�digo;
- nome completo;
- data de nascimento (no formato PT_BR (DD/MM/YYYY);
- sexo (categoriza��o -> M=Masculino; F=Feminino) utilize a fun��o criada no exerc�cio 01;
- cidade;
- estado; e
- regi�o.

SELE
*/
		
CREATE FUNCTION udfContacts(@IDCliente int)
    RETURNS TABLE   
AS
RETURN(

		SELECT 
		ROW_NUMBER() OVER(ORDER BY COUNT(NF.IDNOTA)desc ) AS Rank,
		C.IDCLIENTE AS 'Id cliente',
		CONCAT(c.NOME, ' ', C.SOBRENOME) AS 'Nome completo',
		CONVERT(VARCHAR, c.NASCIMENTO, 103) AS 'Nascimento',
		(SELECT dbo.FN_EXERCICIO_01(C.SEXO)) AS 'Sexo',
		e.CIDADE,
		e.ESTADO,
		e.REGIAO,
		COUNT(NF.IDNOTA) AS 'Volume de compras',
		FORMAT(SUM(nf.total), 'C', 'PT-BR') AS 'Montante Total'
	FROM
		nota_fiscal nf
		JOIN
			cliente c on nf.ID_CLIENTE = c.IDCLIENTE
		JOIN
			ENDERECO e on e.ID_CLIENTE = c.IDCLIENTE
	WHERE
		C.IDCLIENTE = @IDCliente
	GROUP BY
		CONCAT(c.NOME, ' ', C.SOBRENOME),
		C.IDCLIENTE,
		C.SEXO,
		C.IDCLIENTE,
		c.NASCIMENTO,
		e.CIDADE,
		e.ESTADO,
		e.REGIAO
)

SELECT * FROM udfContacts(2)

DROP FUNCTION udfContacts

/*
3) Crie uma fun��o que informado uma data como par�metro retorne o seu trimestre (1� TRI, 2� TRI, 3� TRI e 4� TRI).

*/

CREATE FUNCTION FN_EXERCICIO_03 (@DATA DATETIME)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @res VARCHAR(50)
	IF (DATEPART(QUARTER, @DATA) = 1)	
		SET @res ='Primeiro trimestre';
	ELSE IF DATEPART(QUARTER, @DATA) = 2	
		SET @res ='Primeiro trimestre';
	ELSE IF DATEPART(QUARTER, @DATA) = 3	
		SET @res ='Terceiro trimestre';

	RETURN @res
END;

SELECT dbo.FN_EXERCICIO_03(getdate())
DROP FUNCTION FN_EXERCICIO_03



/*
4) Crie uma fun��o (multi-statement table-valued function) que gere um relat�rio que apresente o ano e o trimestre, seguido das seguintes m�tricas:
- receita total;
- custo total;
- lucro total; e
- margem de lucro (bruta).

F�rmula = (Lucro / Receita total) * 100
	
Exemplo: 
(LUCRO = RECEITA_TOTAL - CUSTOS)
F�rmula = (Lucro / Receita total) * 100

- Receita total  : R$ 20.000
- Custos         : R$ 13.000
- Lucro          : R$ 20.000 - R$ 13.000 = R$ 7.000
- Margem de Lucro: R$ 7.000 / R$ 20.000  = 0.35 x 100 = 35%
*/
CREATE FUNCTION Relatorio()
RETURNS TABLE
AS
RETURN(
		SELECT
			CASE DATEPART(QUARTER, nf.DATA) 
				 WHEN 1 THEN '1 Trimestre'   
				 WHEN 2 THEN '2 Trimestre' 
				 WHEN 3 THEN '3 Trimestre' 
			END AS TRI,
			FORMAT(SUM((ITN.TOTAL)), 'C', 'PT-BR') AS 'Receita total',
			FORMAT(sum((P.CUSTO_MEDIO * ITN.QUANTIDADE)), 'C', 'PT-BR') AS CUSTO,
			FORMAT(SUM((itN.TOTAL)) - sum((P.CUSTO_MEDIO * ITN.QUANTIDADE)), 'C', 'PT-BR') AS LUCRO,
			(((SUM((ITN.TOTAL)) - sum((P.CUSTO_MEDIO * ITN.QUANTIDADE))) / SUM((ITN.TOTAL))) * 100) AS MARGEM
		FROM 
			NOTA_FISCAL nF
		JOIN
			ITEM_NOTA ITN ON ITN.ID_NOTA_FISCAL = NF.IDNOTA
		JOIN
			PRODUTO P ON P.IDPRODUTO = ITN.ID_PRODUTO
		WHERE 
			DATEPART(QUARTER, nf.DATA) != 4 		
		GROUP BY
			DATEPART(QUARTER, nf.DATA)
	
			)
DROP FUNCTION Relatorio
SELECT * FROM Relatorio()
/*
A fun��o dever� receber como par�metro de entrada o ano e a percentual da margem de lucro e dever� retornar somente os anos e trimestres (utilize a fun��o criada no exerc�cio 03) cuja a lucratividade tenha alcan�ado um resultado superior ou igual a margem de lucro informada.

5) Crie uma fun��o que informado duas datas (data inicial, data final) como par�metro retorne a diferen�a em dias.
*/
CREATE FUNCTION TESTE( @InicialDate DATETIME, @FinalDate DATETIME)
RETURNS int
AS
BEGIN
	RETURN DATEDIFF(DAY,  @InicialDate, @FinalDate)
END

DROP FUNCTION TESTE

SELECT dbo.TESTE ( '28-07-2021 19:00:00.000', GETDATE())


/*
6) Crie uma fun��o (multi-statement table-valued function) que informado o c�digo do cliente apresente a matriz RFM (Rec�ncia, Frequ�ncia e Valor Monet�rio) do mesmo.

Tempo para retorno (R) - dias desde a �ltima compra (utilize a fun��o criada no exerc�cio 05)
Frequ�ncia (F) - N�mero total de compras
Valor monet�rio (M) - quanto dinheiro total o cliente gastou.
*/

CREATE FUNCTION RFMPcliente(@IDCliente INT)
RETURNS TABLE
AS
RETURN(
	SELECT 
		 CONCAT(c.NOME, ' ', C.SOBRENOME) AS 'Nome completo',
		 dbo.TESTE(MAX(NF.DATA), GETDATE()) AS 'Tempo para retorno',
		 COUNT(NF.IDNOTA) 'Frequencia',
		 FORMAT(SUM((nf.TOTAL)), 'C', 'PT-BR') AS 'Total gasto'
	FROM 
		NOTA_FISCAL NF 
	JOIN 
		CLIENTE C ON C.IDCLIENTE = NF.ID_CLIENTE
	WHERE 
		C.IDCLIENTE = @IDCliente
	GROUP BY
		CONCAT(c.NOME, ' ', C.SOBRENOME)
)



DROP FUNCTION dbo.COSTUMER_RFM
select  * from dbo.RFMPcliente(1)

