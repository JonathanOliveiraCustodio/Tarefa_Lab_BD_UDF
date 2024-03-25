USE master
CREATE DATABASE aulafunction
GO

USE aulafunction 

GO
CREATE TABLE funcionario ( 
codigo			INT			 NOT NULL, 
nome			VARCHAR(50)  NOT NULL,
salario			DECIMAL(7,2) NOT NULL
PRIMARY KEY (codigo)
)
GO

CREATE TABLE dependendente(
codigoDependente		INT			 NOT NULL, 
codigoFuncionario		INT			 NOT NULL, 
nomDependente			VARCHAR(50)  NOT NULL, 
salarioDependente		DECIMAL(7,2) NOT NULL
PRIMARY KEY (codigoDependente)
FOREIGN KEY (codigoFuncionario) REFERENCES funcionario(codigo) 
)
GO

-- Inserir 10 registros na tabela funcionario
INSERT INTO funcionario (codigo, nome, salario)
VALUES
    (1, 'João Silva', 5000.00),
    (2, 'Maria Oliveira', 5500.00),
    (3, 'Carlos Santos', 4800.00),
    (4, 'Ana Pereira', 5200.00),
    (5, 'Paulo Oliveira', 5300.00),
    (6, 'Juliana Martins', 5100.00),
    (7, 'Lucas Silva', 4900.00),
    (8, 'Mariana Santos', 5400.00),
    (9, 'Pedro Oliveira', 4700.00),
    (10, 'Camila Martins', 5600.00);

-- Inserir 10 registros na tabela dependente
INSERT INTO dependendente (codigoDependente, codigoFuncionario, nomDependente, salarioDependente)
VALUES
    (1, 1, 'Filho1', 1.50),
    (2, 1, 'Filho2', 99.00),
    (3, 2, 'Filha1', 97.50),
    (4, 2, 'Filho3', 200.03),
    (5, 3, 'Filho4', 5.00),
    (6, 4, 'Filha2', 400.60),
    (7, 5, 'Filho5', 9.50),
    (8, 6, 'Filho6', 8.60),
    (9, 7, 'Filha3', 1.20),
    (10, 8,'Filho7', 10.20);

--1. Criar uma database, criar as tabelas abaixo, definindo o tipo de dados e a relação PK/FK e popular com alguma massa de dados de teste (Suficiente para testar UDFs)
--Funcionário (Código, Nome, Salário)
--Dependendente (Código_Dep, Código_Funcionário, Nome_Dependente, Salário_Dependente)
--a) Código no Github ou Pastebin de uma Function que Retorne uma tabela:
--(Nome_Funcionário, Nome_Dependente, Salário_Funcionário, Salário_Dependente)


CREATE FUNCTION fn_funcionarios_dependentes()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        f.nome AS Nome_Funcionário,
        d.nomDependente AS Nome_Dependente,
        f.salario AS Salário_Funcionário,
        d.salarioDependente AS Salário_Dependente
    FROM 
        funcionario f
    INNER JOIN 
        dependendente d ON f.codigo = d.codigoFuncionario
);

SELECT * FROM fn_funcionarios_dependentes()

--b) Código no Github ou Pastebin de uma Scalar Function que Retorne a soma dos Salários dos dependentes, mais a do funcionário. 

CREATE FUNCTION fn_soma_salario (@codigoFuncionario INT)
RETURNS DECIMAL(7,2)
AS
BEGIN
    DECLARE @totalSalario DECIMAL(7,2);

    SELECT @totalSalario = ISNULL(SUM(d.salarioDependente), 0) + ISNULL(f.salario, 0)
    FROM funcionario f
    LEFT JOIN dependendente d ON f.codigo = d.codigoFuncionario
    WHERE f.codigo = @codigoFuncionario
    GROUP BY f.salario;

    RETURN @totalSalario;
END;

SELECT dbo.fn_soma_salario(4) AS "Soma Salarios"

CREATE TABLE produto(
codigo					INT			NOT NULL, 
nome					VARCHAR(30) NOT NULL,
valorUnitario			DECIMAL(7,2)NOT NULL,
qtdEstoque				INT			NOT NULL
PRIMARY KEY (codigo)
)
GO

-- Inserir 10 registros na tabela produto
INSERT INTO produto (codigo, nome, valorUnitario, qtdEstoque)
VALUES
    (1, 'Produto 1', 10.50, 100),
    (2, 'Produto 2', 15.75, 150),
    (3, 'Produto 3', 20.25, 200),
    (4, 'Produto 4', 12.99, 120),
    (5, 'Produto 5', 8.50, 80),
    (6, 'Produto 6', 18.75, 180),
    (7, 'Produto 7', 22.00, 220),
    (8, 'Produto 8', 9.99, 90),
    (9, 'Produto 9', 16.50, 160),
    (10, 'Produto 10', 25.00, 250);

--a) a partir da tabela Produtos (codigo, nome, valor unitário e qtd estoque), quantos produtos estão com estoque abaixo de um valor de entrada
CREATE FUNCTION fn_quantidadeEstoque (@valorMinimo INT)
RETURNS INT
AS
BEGIN
    DECLARE @qtdEstoqueAbaixo INT;

    SELECT @qtdEstoqueAbaixo = COUNT(*)
    FROM produto
    WHERE qtdEstoque < @valorMinimo;

    RETURN @qtdEstoqueAbaixo;
END;

SELECT dbo.fn_quantidadeEstoque(120) AS "Quantidade Estoque"

--b) Uma tabela com o código, o nome e a quantidade dos produtos que estão com o estoque abaixo de um valor de entrada

CREATE FUNCTION fn_produtosEstoque (@valor INT)
RETURNS TABLE
AS
RETURN (
    SELECT codigo, nome, qtdEstoque
    FROM produto
    WHERE qtdEstoque < @valor
);

SELECT * FROM dbo.fn_produtosEstoque(120)

--3. Criar, uma UDF, que baseada nas tabelas abaixo, retorne
--Nome do Cliente, Nome do Produto, Quantidade e Valor Total, Data de hoje
--Tabelas iniciais:
--Cliente (Codigo, nome)
--Produto (Codigo, nome, valor)

-- Criação das tabelas
CREATE TABLE cliente (
    codigo INT,
    nome VARCHAR(50)
	PRIMARY KEY (codigo)
)
GO

CREATE TABLE produto1 (
    codigo INT ,
    nome VARCHAR(50),
    valor DECIMAL(7,2)
	
)
GO

CREATE TABLE venda (
    cliente INT,
    produto INT,
    qtd INT,
    dataCompra DATE,
    FOREIGN KEY (cliente) REFERENCES cliente(Codigo),
    FOREIGN KEY (produto) REFERENCES produto(Codigo)
)
GO

CREATE FUNCTION fn_calculo()
RETURNS @tabela TABLE (
Nome_cliente VARCHAR(100),
Nome_produto VARCHAR(100),
qtd_p INT,
valot_tot DECIMAL(10, 2),
data_hoje DATE
) 
BEGIN
 
    INSERT INTO @tabela(Nome_cliente, Nome_produto, qtd_p, valot_tot, data_hoje )
	     SELECT C.nome, P.Nome, COUNT(P.Codigo) AS qtd_p, SUM(p.valorUnitario) AS valor_tot, GETDATE() as data_hoje
		 FROM Cliente C
		 INNER JOIN produto p ON p.codigo = c.codigo
		 GROUP BY c.nome, p.nome;
		 RETURN
END
 
SELECT * FROM fn_calculo()




