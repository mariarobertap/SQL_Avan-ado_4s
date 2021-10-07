/* Maria Roberta
   Banco: Locadora 
  */

/*Criar um cursor para selecionar o nome e valor do filme. Caso o valor do filme seja inferior a
R$ 12,00, mostrar o nome do filme, o valor atual e o valor com 10% de aumento. Se o valor 
do filme for superior a R$ 12,00 mostrar o nome do filme, o valor atual e valor com 15% de 
aumento.*/

SELECT * FROM FILME

SET NOCOUNT ON;

DECLARE cursor_exerc_01 CURSOR FOR

	SELECT 
		descricao as nome,
		valor
	FROM 
		filme

	DECLARE @nome VARCHAR(100)
	DECLARE @valor  DECIMAL(10,2)
	DECLARE @valorAux  DECIMAL(10,2)

	OPEN cursor_exerc_01

	FETCH NEXT FROM
		cursor_exerc_01
	INTO
		@nome,
		@valor



	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		IF(@valor > 12)
		begin
			set @valorAux = @valor + (@valor*10)/100
			SELECT CONCAT('Filme ', @nome, 'Valor: ', @valor, ' Valor + 10%: ', @valorAux)
		end
		ELSE IF(@valor < 12)
		begin
			set @valorAux = @valor + (@valor*15)/100
			SELECT CONCAT('Filme ', @nome, 'Valor: ', @valor, ' Valor + 15%: ', @valorAux)
		end
		--PRINT @mensagem

		FETCH NEXT FROM
			cursor_exerc_01
		INTO
			@nome,
			@valor
	END

CLOSE cursor_exerc_01
DEALLOCATE cursor_exerc_01

/*Criar um cursor para selecionar a data e o valor de loca��o. Caso o valor da loca��o seja 
superior a R$ 12,00, mostrar a data, valor da loca��o e valor com 10% de desconto. Se o 
valor da loca��o for inferior a R$ 12,00 mostrar todos os dados, mas com o valor de 
desconto de 8%.*/


/*Criar um cursor para atualizar os valores dos filmes, se o filme possuir 3 unidades ou menos
de fitas, aumentar em 5% no valor, se o filme tiver entre 4 e 5 unidades de fitas aumentar 
10%, se o filme contiver mais de 5 unidades de fitas aumentar 20% do valor.*/


/*Utilizando um cursor, apresente os clientes que precisam devolver filmes, se fazem 7 dias 
corridos da data de loca��o, acrescentar multa de 10% no valor, se tiver entre 8 e 15 dias 
acrescentar multa de 15% no valor, se fazem mais de 15 dias acrescentar multa de 30% do 
valor*/


/*DESAFIO: A locadora de filmes oferece um b�nus a seus clientes com base no n�mero de 
loca��es realizadas durante o ano no valor da m�dia de loca��es feitas no mesmo per�odo. 
O b�nus � aplicado para clientes que fizeram pelo menos 3 loca��es no ano. Contudo, o 
b�nus n�o � aplicado para clientes que tenham mais de 1 filme para devolu��o. Utilizando 
um cursor, crie um procedimento que passado o ano imprima o c�digo do cliente, o seu 
nome e o valor do seu respectivo b�nus*/