/*
	lista
	Banco LOCADORA.bak
*/

/*(1) Exiba a quantidade total de loca��es de um determinado filme. (Exibir o id, nome do filme
e quantidade de loca��es)
*/

GO
CREATE PROCEDURE QuantidadeLocacao (@idFilme INT)
AS
	SELECT DISTINCT
		fi.id,
		fi.descricao,
		COUNT(l.fitaId) 'Qtd Loca��es'
	FROM
		locacao l
	JOIn
		fita fit ON fit.id = l.fitaId
	JOIN 
		filme fi ON fi.id = fit.filmeId
	WHERE 
		fi.id = @idFilme
	GROUP BY
		fi.descricao, fi.id

drop procedure QuantidadeLocacao
EXEC QuantidadeLocacao 2

select * from filme

/*(02) Exiba todas as loca��es efetuadas por um determinando cliente. (Exibir o id, nome do
cliente e quantidade de loca��es)
*/
GO
CREATE PROCEDURE LocacaoPCliente (@idCliente INT)
AS
	
	SELECT DISTINCT 
		c.id,
		c.nome,
		COUNT(l.fitaId) as 'Loca��es'
	FROM
		locacao l
	JOIN
		cliente c ON c.id = l.clienteId
	WHERE 
		c.id = @idCliente
	GROUP BY
		c.id, c.nome

EXEC LocacaoPCliente 3

/*
(03) Calcule o valor total de loca��es para as categorias de filme com base nas loca��es do
m�s/ano (m�s e ano ser�o par�metros IN)
*/
GO
CREATE PROCEDURE LocacaoPanoEmes (@mes INT, @ano INT)
AS
BEGIN
	IF((@mes <= 12 AND @mes >= 1) AND (@ANO <= 9999 AND @ANO >= 1000))
		 begin
	 			SELECT DISTINCT 
				cat.descricao,
				SUM(fi.valor) AS 'Total',
				COUNT(fit.filmeId) 'Loca��es'
			FROM
				locacao l
				JOIN 
					fita fit ON fit.id = l.fitaId
				JOIN 
					filme fi ON fi.id = fit.filmeId
				JOIN 
					categoria cat ON cat.id = fi.categoriaId
			where
				month(l.dataLocacao) = @mes and year(l.dataLocacao) = @ano
			GROUP BY
				cat.descricao
		 end
	 ELSE
		 select 'Data invalida'
END;

DROP procedure LocacaoPanoEmes
select * from locacao
EXEC LocacaoPanoEmes 11, 2019




/*
(04) Listar quais clientes precisam devolver filmes.
*/
GO
CREATE PROCEDURE ClientesDevolucao
AS
BEGIN
	SELECT DISTINCT 
		l.clienteId,
		c.nome,
		count(l.fitaId) 'Filmes a devolver'
	from 
		locacao l
		join cliente c on c.id = l.clienteId
	where 
		l.dataDevolucao IS NULL
	group by
		l.clienteId, c.nome
END;
DROP PROCEDURE ClientesDevolucao

EXEC ClientesDevolucao 

	
/*
(5) Listar quais filmes nunca foram locados.
*/
GO
CREATE PROCEDURE FilmesNuncaLocados
AS

	SELECT DISTINCT
		fi.id,
		fi.descricao
	FROM
		filme fi
	where 
		fi.id NOT IN (	SELECT 
							fi.id
						FROM
							fita fit
						JOIN 
							filme fi ON fi.id = fit.filmeId
						JOIN 
							locacao l ON l.fitaId = fit.id
					  )
DROP procedure FilmesNuncaLocados

EXEC FilmesNuncaLocados 
		
/*
(06) Listar quais clientes nunca efetuaram uma loca��o.
*/
GO
CREATE PROCEDURE NuncaLocou
AS

	select 
		* 
	from 
		cliente c 
	where 
		c.id NOT IN (SELECT clienteId FROM locacao)


EXEC NuncaLocou 


/*
(07) Listar a data da �ltima loca��o de um determinado cliente.
*/
GO
CREATE PROCEDURE UltimaLocacao
@idCliente INT 
AS
	SELECT
		 c.id,
		 c.nome,
		 MAX(l.dataLocacao)
	FROM 
		cliente c 
	join
		locacao l on l.clienteId = c.id
	WHERE 
		@idCliente = c.id
	group by
		c.nome

EXEC UltimaLocacao 2

/*
(08) Calcule o valor total de loca��es e o valor total de loca��es acumulado por m�s (ano ser� 
par�metro IN)
*/


		SELECT
			ISNULL([Janeiro], 0) AS Janeiro,
			ISNULL([Fevereiro], 0) AS Fevereiro,
			ISNULL([Mar�o], 0) AS MAR�O,
			ISNULL([Abril],0) AS ABRIL,
			ISNULL([Maio], 0) AS MAIO,
			ISNULL([Junho], 0) AS JUNHO,
			ISNULL([Julho], 0) AS JULHO,
			ISNULL([Agosto], 0) AS AGOSTO,
			ISNULL([Setembro],0) AS SETEMBRO,
			ISNULL([Outubro], 0) AS OUTUBRO,
			ISNULL([Novembro], 0) AS NOVEMBRO,
			ISNULL([Dezembro], 0) AS DEZEMBRO
		
	FROM (
		select 
			f.valor, DATENAME(month,lo.dataLocacao) as [Month]
		from
			locacao lo
		join
			fita fi on fi.id = lo.fitaId
		join
			filme f on f.id = fi.filmeId
	) AS SOURCE
	PIVOT(
		sum(valor)
		FOR [Month] in ([Janeiro], [Fevereiro], [Mar�o], [Abril], [Maio], [Junho], [Julho], [Agosto], [Setembro], [Outubro], [Novembro], [Dezembro] )
	) AS PVT


	SELECT
		MONTH(l.dataLocacao) as mes,
		SUM(f.valor) as vlrTotal,
		vlrAcumulado = (
			SELECT 
				sum(fs.valor)
			FROM
				locacao ls
			JOIN 
				fita fts on fts.id = ls.fitaId
			JOIN
				filme fs on fs.id = fts.filmeId

			WHERE MONTH(ls.dataLocacao) <= MONTH(l.dataLocacao)
			)
		FROM 
			locacao l
		JOIN
			fita ft on ft.id = l.fitaId
		JOIN
			filme f on f.id = ft.filmeId
		WHERE
			YEAR(l.dataLocacao) = 2019
		GROUP BY
			MONTH(l.dataLocacao)


/*09) Listar a quantidade de loca��es por categoria de filme. Exibir cada categoria de filme sendo 
uma coluna. (Conceito Pivot Table)
*/

	SELECT
		[A��o],
		[Terror],
		[Com�dia],
		[Drama],
		[Fic��o Cient�fica]
		
	FROM (
		SELECT DISTINCT 
			cat.descricao,
			fit.filmeId
		FROM
			locacao l
		JOIN 
			fita fit ON fit.id = l.fitaId
		JOIN 
			filme fi ON fi.id = fit.filmeId
		JOIN 
			categoria cat ON cat.id = fi.categoriaId
	) AS SOURCE
	PIVOT(
		COUNT(filmeId)
		FOR descricao in ([A��o], [Terror], [Com�dia], [Drama], [Fic��o Cient�fica])
	) AS PVT
	

/*10) DESAFIO: Listar o ranking de filmes mais locados. (Conceito de Rank
*/

	SELECT 
		FI.descricao,
		COUNT(LO.fitaId) AS 'Locacoes',
		ROW_NUMBER() OVER(ORDER BY COUNT(LO.fitaId)desc ) AS Rank
	FROM 
		filme fi 
	JOIN
		fita ft ON ft.filmeId = fi.id
	JOIN 
		locacao lo ON lo.fitaId = ft.id
	GROUP BY
		fi.descricao

--https://www.sqlshack.com/overview-of-sql-rank-functions/

-------------------------------------------------------------------




--Utilizando o BD LOCADORA crie as seguintes Functions:
/*
01) Crie uma fun��o que informado um valor retorne uma string informando se o n�mero �
par ou �mpar.
*/
CREATE FUNCTION FN_EXERCICIO_01(@valor INT)
RETURNS VARCHAR(10)
AS
BEGIN
	RETURN IIF(@valor % 2 > 0, 'Impar', 'Par')
END;

SELECT dbo.FN_EXERCICIO_01(1)
SELECT dbo.FN_EXERCICIO_01(2)
/*
02) Crie uma fun��o que retorne o n�mero mais o nome do m�s em portugu�s (1 - Janeiro) de
acordo com o par�metro informado que deve ser uma data. Para testar, crie uma consulta que
retorne o cliente e m�s de loca��o (n�mero e nome do m�s).
*/
CREATE FUNCTION FN_EXERCICIO_02(@data DATETIME)
RETURNS VARCHAR(20)
AS
BEGIN
	RETURN CONCAT(MONTH(@data), ' - ', UPPER(DATENAME(MONTH, @data)))
END;

SET LANGUAGE Portuguese;
SELECT dbo.FN_EXERCICIO_02(GETDATE())

SELECT
	l.clienteId,
	c.nome as cliente,
	l.dataLocacao,
	dbo.FN_EXERCICIO_02(l.dataLocacao) as mes
FROM
	locacao l
	join cliente c
		on c.id = l.clienteId

/*
03) Crie uma fun��o que retorne o n�mero mais o nome do dia da semana em portugu�s (1 -
Domingo), como par�metro de entrada receba uma data. Para testar, crie uma consulta que
retorne o c�digo do cliente, o nome do cliente e dia da semana da loca��o utilizando a fun��o
criada.
*/
CREATE FUNCTION FN_EXERCICIO_03(@data DATETIME)
RETURNS VARCHAR(20)
AS
BEGIN
	RETURN CONCAT(DATEPART(WEEKDAY, @data), ' - ', DATENAME(WEEKDAY, @data))
END

SELECT dbo.FN_EXERCICIO_03(GETDATE())

SELECT
	l.clienteId,
	c.nome as cliente,
	l.dataLocacao,
	dbo.FN_EXERCICIO_03(l.dataLocacao) as diaSemana
FROM
	locacao l
	join cliente c
		on c.id = l.clienteId

SELECT
	dbo.FN_EXERCICIO_03(l.dataLocacao) as diaSemana,
	COUNT(*) as qtde
FROM
	locacao l
GROUP BY
	dbo.FN_EXERCICIO_03(l.dataLocacao)
ORDER BY
	1

/*
04) Crie uma fun��o para retornar o gent�lico dos clientes de acordo com o estado onde
moram (ga�cho, catarinense ou paranaense), o par�metro de entrada deve ser a sigla do
estado. Para testar a fun��o crie uma consulta que liste o nome do cliente e gent�lico
utilizando a fun��o criada.
*/
CREATE FUNCTION FN_EXERCICIO_04(@uf CHAR(2))
RETURNS VARCHAR(20)
AS
BEGIN
	DECLARE @gentilico VARCHAR(20)
	
	SET @gentilico = 
	CASE @uf
		WHEN 'PR' THEN 'paranaense'
		WHEN 'SC' THEN 'catarinese'
		WHEN 'RS' THEN 'ga�cho'
		ELSE 'n�o informado'
	END
		
	RETURN @gentilico
END

SELECT dbo.FN_EXERCICIO_04('RS')

UPDATE cliente SET estado = 'SC' WHERE id not in(1, 2)

SELECT 
	nome as cliente,
	dbo.FN_EXERCICIO_04(estado) as gentilico
FROM 
	cliente

/*
05) Crie uma fun��o que retorne o CPF do cliente no formato ###.###.###-##. Para testar a
fun��o criada exiba os dados do cliente com o CPF formatado corretamente utilizando a
fun��o criada.
*/
CREATE FUNCTION FN_EXERCICIO_05(@cpf VARCHAR(11))
RETURNS VARCHAR(14)
AS
BEGIN
	RETURN CONCAT(
		LEFT(@cpf, 3), 
		'.', 
		SUBSTRING(@cpf, 4, 3), 
		'.', 
		SUBSTRING(@cpf, 7, 3), 
		'-', 
		RIGHT(@cpf, 2)
	)
END;

SELECT dbo.FN_EXERCICIO_05('71026854083')

SELECT 
	nome as cliente,
	dbo.FN_EXERCICIO_05(cpf) as cpf
FROM 
	cliente

/*
06) Crie uma fun��o que fa�a a compara��o entre dois n�meros inteiros. Caso os dois n�meros
sejam iguais a sa�da dever� ser �x � igual a y�, no qual x � o primeiro par�metro e y o segundo
par�metro. Se x for maior, dever� ser exibido �x � maior que y�. Se x for menor, dever� ser
exibido �x � menor que y�.
*/
CREATE FUNCTION FN_EXERCICIO_06(@x INT, @y INT)
RETURNS VARCHAR(20)
AS
BEGIN
	DECLARE @res VARCHAR(20)

	IF (@x = @y)
		SET @res = 'x � igual a y'
	ELSE IF (@x > @y)
			SET @res = 'x � maior que y'
		ELSE
			SET @res = 'x � menor que y'

	RETURN @res
END

SELECT dbo.FN_EXERCICIO_06(15, 10)
SELECT dbo.FN_EXERCICIO_06(10, 10)
SELECT dbo.FN_EXERCICIO_06(5, 10)

/*
07) Crie uma fun��o que calcule a f�rmula de Bhaskara. Como par�metro de entrada devem
ser recebidos 3 valores (a, b e c). Ao final a fun��o deve retornar �Os resultados calculados s�o
x e y�, no qual x e y s�o os valores calculados.
*/
CREATE FUNCTION FN_EXERCICIO_07(@a INT, @b INT, @c INT)
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @x INT;
	DECLARE @y INT;
	DECLARE @delta FLOAT;

	SET @delta = (@b * @b) - (4 * @a * @c)

	SET @x = (-@b + SQRT(@delta)) / (2 * @a);
	SET @y = (-@b - SQRT(@delta)) / (2 * @a);

	RETURN CONCAT('Os resultados calculados s�o x e y: ', @x, ', ', @y) 
END;

SELECT dbo.FN_EXERCICIO_07(1, 5, 4)

/*
08) Crie uma fun��o que informado a data de nascimento como par�metro retorne a idade da
pessoa em anos.
*/
CREATE FUNCTION FN_EXERCICIO_08(@data DATE)
RETURNS INT
AS
BEGIN
	RETURN FLOOR(DATEDIFF(DAY, @data, GETDATE()) / 365.25)
END

SELECT dbo.FN_EXERCICIO_08('1986-05-22')

/*
09) Fa�a uma fun��o que retorna o c�digo do cliente com a maior quantidade de loca��es por 
ano/m�s. Observe que a fun��o dever� receber como par�metros um ano e um m�s. Deve ser 
exibido a seguinte express�o: �O cliente XXXXXXX (c�d) � XXXXXXX (nome) foi o cliente que fez 
a maior quantidade de loca��es no ano XXXX m�s XX com um total de XXX loca��es�. 
*/
CREATE FUNCTION FN_EXERCICIO_09(@ano INT, @mes INT)
RETURNS VARCHAR(200)
AS
BEGIN
	DECLARE @id INT
	DECLARE @nome VARCHAR(100)
	DECLARE @qtdeLocacoes INT

	SELECT TOP 1
		@id = c.id,
		@nome = c.nome,
		@qtdeLocacoes = COUNT(*)
	FROM
		locacao l
		join cliente c
			on c.id = l.clienteId
	WHERE
		YEAR(dataLocacao) = @ano
		AND MONTH(dataLocacao) = @mes
	GROUP BY
		c.id,
		c.nome
	ORDER BY
		3 DESC

	RETURN CONCAT(
		'O cliente ', @id ,' � ', @nome, 
		' foi o cliente que fez a maior quantidade de loca��es no ano ', @ano, ' no m�s ', @mes, 
		' com um total de ', @qtdeLocacoes, ' loca��es.')

END

SELECT dbo.FN_EXERCICIO_09(2019, 11)
