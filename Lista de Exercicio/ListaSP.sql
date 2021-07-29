--Utilizando o BD LOCADORA crie os seguintes Stored Procedures:

/*(1) Exiba a quantidade total de loca��es de um determinado filme. (Exibir o id, nome do filme
e quantidade de loca��es)*/SELECT DISTINCT	fi.id, fi.descricao, COUNT(fit.filmeId) 'Loca��es'FROM	locacao lJOIn	fita fit ON fit.id = l.fitaIdJOIN 	filme fi ON fi.id = fit.filmeIdGROUP BYfi.descricao, fi.id/*(02) Exiba todas as loca��es efetuadas por um determinando cliente. (Exibir o id, nome do
cliente e quantidade de loca��es)*/SELECT DISTINCT c.id, c.nome, COUNT(l.fitaId) as 'Loca��es'FROM	locacao lJOIN	cliente c ON c.id = l.clienteIdGROUP BY	c.id, c.nome/*
(03) Calcule o valor total de loca��es para as categorias de filme com base nas loca��es do
m�s/ano (m�s e ano ser�o par�metros IN)*/SELECT DISTINCT 	cat.descricao, SUM(fi.valor), COUNT(fit.filmeId) 'Loca��es'FROM	locacao lJOIN 	fita fit ON fit.id = l.fitaIdJOIN 	filme fi ON fi.id = fit.filmeIdJOIN 	categoria cat ON cat.id = fi.categoriaIdGROUP BY	cat.descricao/*
(04) Listar quais clientes precisam devolver filmes.*/select distinct	l.clienteId, c.nome, count(l.fitaId) 'Filmes a devolver'from 	locacao ljoin cliente c on c.id = l.clienteIdwhere l.dataDevolucao IS NULLgroup by l.clienteId, c.nome /*
(05) Listar quais filmes nunca foram locados.*/