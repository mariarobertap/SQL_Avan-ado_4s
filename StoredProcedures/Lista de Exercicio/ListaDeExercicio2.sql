/*Lista de Exerc�cios utilizando a base de dados COMERCIO: Procedimentos e Fun��es.

# Procedimentos

1) Crie um procedimento que apresente o volume e o montante total de vendas por regi�o e trimestre. */


SELECT
	e.REGIAO, 
	FORMAT(SUM(nf.total), 'C', 'PT-BR') AS 'Montante Total',
	COUNT(distinct NF.IDNOTA) AS 'Volume de vendas',
	CASE DATEPART(QUARTER, nf.DATA) 
		 WHEN 1 THEN '1 Trimestre'   
		 WHEN 2 THEN '2 Trimestre' 
		 WHEN 3 THEN '3 Trimestre' 
	END 
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


/*

2) Crie um procedimento que apresente os top 10 clientes em volume de compras.
*/

	SELECT TOP 10
		ROW_NUMBER() OVER(ORDER BY COUNT(NF.IDNOTA)desc ) AS Rank,
		COUNT(NF.IDNOTA) AS 'Volume de compras',
		c.NOME
	FROM
		nota_fiscal nf
		JOIN
			cliente c on nf.ID_CLIENTE = c.IDCLIENTE
	GROUP BY
		c.NOME


/*
3) Crie um procedimento que mostre os clientes que n�o realizaram nenhuma compra.
*/

SELECT 
	NOME
FROM
	CLIENTE
WHERE IDCLIENTE NOT IN(
	SELECT 
		NF.ID_CLIENTE
	FROM
		NOTA_FISCAL NF
	JOIN
		CLIENTE C ON C.IDCLIENTE = NF.ID_CLIENTE)


/*
4) Crie um procedimento que apresente o faturamento e o faturamento acumulado por ano.
*/

	select * from NOTA_FISCAL




	
	select
		SUM(total)
	from 
		NOTA_FISCAL
	GROUP BY
		YEAR(DATA)


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



/*
5) Crie um procedimento que apresente os cinco produtos mais caros por categoria (par�metro de entrada) de produto.
*/


	SELECT top 5
		ROW_NUMBER() OVER(ORDER BY max(valor) desc ) AS Rank,
		P.PRODUTO, C.NOME, max(valor)
	FROM
		PRODUTO P
	JOIN
	 CATEGORIA C ON C.IDCATEGORIA = P.ID_CATEGORIA
	 group by P.PRODUTO, C.NOME

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
		
CREATE FUNCTION udfContacts()
    RETURNS TABLE   
AS
RETURN(

		SELECT 
		ROW_NUMBER() OVER(ORDER BY COUNT(NF.IDNOTA)desc ) AS Rank,
		C.IDCLIENTE AS 'Id cliente',
		CONCAT(c.NOME, ' ', C.SOBRENOME) AS 'Nome completo',
		c.NASCIMENTO,
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

SELECT * FROM udfContacts()

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
	
- Receita total  : R$ 20.000
- Custos         : R$ 13.000
- Lucro          : R$ 20.000 - R$ 13.000 = R$ 7.000
- Margem de Lucro: R$ 7.000 / R$ 20.000  = 0.35 x 100 = 35%

A fun��o dever� receber como par�metro de entrada o ano e a percentual da margem de lucro e dever� retornar somente os anos e trimestres (utilize a fun��o criada no exerc�cio 03) cuja a lucratividade tenha alcan�ado um resultado superior ou igual a margem de lucro informada.

5) Crie uma fun��o que informado duas datas (data inicial, data final) como par�metro retorne a diferen�a em dias.

6) Crie uma fun��o (multi-statement table-valued function) que informado o c�digo do cliente apresente a matriz RFM (Rec�ncia, Frequ�ncia e Valor Monet�rio) do mesmo.

Tempo para retorno (R) - dias desde a �ltima compra (utilize a fun��o criada no exerc�cio 05)
Frequ�ncia (F) - N�mero total de compras
Valor monet�rio (M) - quanto dinheiro total o cliente gastou.
*/