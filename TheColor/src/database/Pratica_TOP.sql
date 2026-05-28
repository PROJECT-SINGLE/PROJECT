CREATE DATABASE SP3_PRATICA;
USE SP3_PRATICA;

CREATE TABLE alunos (
    id_aluno INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100),
    email VARCHAR(100),
    data_nascimento DATE,
    data_matricula DATE
);

CREATE TABLE planos (
    id_plano INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(50),
    preco DECIMAL(10,2),
    duracao_dias INT
);

CREATE TABLE formas_pagamento (
    id_forma_pagamento INT PRIMARY KEY AUTO_INCREMENT,
    descricao VARCHAR(50)
);

CREATE TABLE matriculas (
    id_matricula INT PRIMARY KEY AUTO_INCREMENT,
    id_aluno INT,
    id_plano INT,
    data_matricula DATE,

    FOREIGN KEY (id_aluno)
        REFERENCES alunos(id_aluno),

    FOREIGN KEY (id_plano)
        REFERENCES planos(id_plano)
);

CREATE TABLE pagamentos (
    id_pagamento INT PRIMARY KEY AUTO_INCREMENT,
    id_matricula INT,
    id_forma_pagamento INT,
    valor DECIMAL(10,2),
    data_pagamento DATE,
    status VARCHAR(30),

    FOREIGN KEY (id_matricula)
        REFERENCES matriculas(id_matricula),

    FOREIGN KEY (id_forma_pagamento)
        REFERENCES formas_pagamento(id_forma_pagamento)
);

INSERT INTO planos (titulo, preco, duracao_dias)
VALUES
('Mensal', 120.00, 30),
('Trimestral', 300.00, 90),
('Anual', 1000.00, 365);

INSERT INTO formas_pagamento (descricao)
VALUES
('Cartão'),
('Pix'),
('Dinheiro');

INSERT INTO alunos (nome, email, data_nascimento, data_matricula)
VALUES
('João Silva', 'joao@email.com', '1998-05-10', '2024-01-10'),
('Maria Souza', 'maria@email.com', '1995-08-20', '2024-02-15'),
('Carlos Lima', 'carlos@email.com', '2000-03-12', '2024-03-01'),
('Ana Costa', 'ana@email.com', '1992-11-05', '2024-04-01'),
('Pedro Rocha', 'pedro@email.com', '1990-06-18', '2024-05-10');

INSERT INTO matriculas (id_aluno, id_plano, data_matricula)
VALUES
(1, 1, '2024-01-10'),
(2, 2, '2024-02-15'),
(3, 3, '2024-03-01'),
(4, 1, '2024-04-01'),
(5, 2, '2024-05-10');

INSERT INTO pagamentos
(id_matricula, id_forma_pagamento, valor, data_pagamento, status)
VALUES
(1, 1, 120.00, '2024-01-10', 'Pago'),
(2, 2, 150.00, '2024-02-15', 'Pago'),
(2, 2, 150.00, '2024-03-15', 'Pago'),
(3, 1, 500.00, '2024-03-01', 'Pago'),
(3, 1, 500.00, '2024-04-01', 'Pago'),
(4, 3, 120.00, '2024-04-01', 'Atrasado'),
(5, 2, 150.00, '2024-05-10', 'Pago'),
(5, 1, 150.00, '2024-06-10', 'Pago'),
(1, 2, 120.00, '2024-02-10', 'Pago'),
(4, 3, 120.00, '2024-05-01', 'Pago');


SELECT a.nome, p.titulo
FROM alunos a
JOIN matriculas m ON a.id_aluno = m.id_aluno
JOIN planos p ON m.id_plano = p.id_plano;


SELECT a.nome
FROM alunos a
JOIN matriculas m ON a.id_aluno = m.id_aluno
JOIN planos p ON m.id_plano = p.id_plano
WHERE p.titulo = 'Anual'
AND DATE_ADD(m.data_matricula, INTERVAL 365 DAY) >= CURDATE();

SELECT a.nome,
SUM(pg.valor) AS total_pago
FROM alunos a
JOIN matriculas m ON a.id_aluno = m.id_aluno
JOIN pagamentos pg ON m.id_matricula = pg.id_matricula
GROUP BY a.nome;

SELECT DISTINCT a.nome
FROM alunos a
JOIN matriculas m ON a.id_aluno = m.id_aluno
JOIN pagamentos pg ON m.id_matricula = pg.id_matricula
JOIN formas_pagamento fp
ON pg.id_forma_pagamento = fp.id_forma_pagamento
WHERE fp.descricao = 'Cartão';

SELECT a.nome
FROM alunos a
LEFT JOIN matriculas m ON a.id_aluno = m.id_aluno
LEFT JOIN pagamentos pg ON m.id_matricula = pg.id_matricula
WHERE pg.id_pagamento IS NULL;


SELECT ROUND(AVG(preco), 2) AS media_planos
FROM planos;


SELECT fp.descricao,
SUM(pg.valor) AS total
FROM pagamentos pg
JOIN formas_pagamento fp
ON pg.id_forma_pagamento = fp.id_forma_pagamento
GROUP BY fp.descricao;


SELECT p.titulo,
COUNT(m.id_aluno) AS quantidade
FROM planos p
JOIN matriculas m
ON p.id_plano = m.id_plano
GROUP BY p.titulo;

SELECT DATE_FORMAT(data_pagamento, '%Y-%m') AS mes,
SUM(valor) AS total
FROM pagamentos
GROUP BY mes
ORDER BY total DESC
LIMIT 1;


SELECT AVG(TIMESTAMPDIFF(YEAR, data_nascimento, CURDATE()))
AS idade_media
FROM alunos;


SELECT p.titulo,
SUM(pg.valor) AS total
FROM planos p
JOIN matriculas m ON p.id_plano = m.id_plano
JOIN pagamentos pg ON m.id_matricula = pg.id_matricula
GROUP BY p.titulo
HAVING total > 5000;


SELECT a.nome,
COUNT(m.id_matricula) AS qtd
FROM alunos a
JOIN matriculas m ON a.id_aluno = m.id_aluno
GROUP BY a.nome
HAVING qtd > 1;


SELECT fp.descricao,
COUNT(pg.id_pagamento) AS qtd
FROM formas_pagamento fp
JOIN pagamentos pg
ON fp.id_forma_pagamento = pg.id_forma_pagamento
GROUP BY fp.descricao
HAVING qtd < 3;




UPDATE planos
SET preco = preco * 1.10
WHERE titulo = 'Mensal';


UPDATE pagamentos
SET id_forma_pagamento =
(
    SELECT id_forma_pagamento
    FROM formas_pagamento
    WHERE descricao = 'Pix'
)
WHERE MONTH(data_pagamento) = MONTH(CURDATE() - INTERVAL 1 MONTH);


DELETE FROM pagamentos
WHERE id_forma_pagamento =
(
    SELECT id_forma_pagamento
    FROM formas_pagamento
    WHERE descricao = 'Dinheiro'
);


DELETE FROM alunos
WHERE id_aluno =
(
    SELECT id_aluno
    FROM
    (
        SELECT a.id_aluno,
        SUM(pg.valor) AS total
        FROM alunos a
        JOIN matriculas m
        ON a.id_aluno = m.id_aluno
        JOIN pagamentos pg
        ON m.id_matricula = pg.id_matricula
        GROUP BY a.id_aluno
        ORDER BY total ASC
        LIMIT 1
    ) AS sub
);


SELECT nome
FROM alunos
WHERE id_aluno IN
(
    SELECT m.id_aluno
    FROM matriculas m
    JOIN pagamentos pg
    ON m.id_matricula = pg.id_matricula
    GROUP BY m.id_aluno
    HAVING SUM(pg.valor) >
    (
        SELECT AVG(total_pago)
        FROM
        (
            SELECT SUM(pg.valor) AS total_pago
            FROM matriculas m
            JOIN pagamentos pg
            ON m.id_matricula = pg.id_matricula
            GROUP BY m.id_aluno
        ) AS media
    )
);


SELECT
a.nome,
(p.preco - media.media_planos) AS diferenca
FROM alunos a
JOIN matriculas m ON a.id_aluno = m.id_aluno
JOIN planos p ON m.id_plano = p.id_plano,
(
    SELECT AVG(preco) AS media_planos
    FROM planos
) AS media;



CREATE VIEW V_RELATORIO_FINANCEIRO AS
SELECT
a.nome,
p.titulo,
p.preco,
SUM(pg.valor) AS total_pago
FROM alunos a
JOIN matriculas m ON a.id_aluno = m.id_aluno
JOIN planos p ON m.id_plano = p.id_plano
LEFT JOIN pagamentos pg
ON m.id_matricula = pg.id_matricula
GROUP BY a.nome, p.titulo, p.preco;


CREATE TABLE pesquisas (
    id_pesquisa INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(200),
    data_criacao DATE
);

CREATE TABLE perguntas (
    id_pergunta INT PRIMARY KEY AUTO_INCREMENT,
    texto VARCHAR(255),
    tipo VARCHAR(50)
);

CREATE TABLE pesquisa_pergunta (
    id_pesquisa INT,
    id_pergunta INT,

    PRIMARY KEY (id_pesquisa, id_pergunta),

    FOREIGN KEY (id_pesquisa)
        REFERENCES pesquisas(id_pesquisa),

    FOREIGN KEY (id_pergunta)
        REFERENCES perguntas(id_pergunta)
);

CREATE TABLE consumidores (
    id_consumidor INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100),
    idade INT,
    cidade VARCHAR(100)
);

CREATE TABLE sessoes_resposta (
    id_sessao INT PRIMARY KEY AUTO_INCREMENT,
    id_consumidor INT,
    id_pesquisa INT,
    data_resposta DATE,

    FOREIGN KEY (id_consumidor)
        REFERENCES consumidores(id_consumidor),

    FOREIGN KEY (id_pesquisa)
        REFERENCES pesquisas(id_pesquisa)
);

CREATE TABLE respostas (
    id_resposta INT PRIMARY KEY AUTO_INCREMENT,
    id_sessao INT,
    id_pergunta INT,
    resposta_nota INT,

    FOREIGN KEY (id_sessao)
        REFERENCES sessoes_resposta(id_sessao),

    FOREIGN KEY (id_pergunta)
        REFERENCES perguntas(id_pergunta)
);


INSERT INTO pesquisas (titulo, data_criacao)
VALUES
('Satisfação do Produto X', '2023-05-10'),
('Pesquisa de Atendimento', '2024-01-15');

INSERT INTO perguntas (texto, tipo)
VALUES
('Qual sua nota para o produto?', 'Nota'),
('O atendimento foi bom?', 'Nota'),
('Você recomendaria a empresa?', 'Multipla Escolha'),
('Qual a qualidade do produto?', 'Nota'),
('Voltaria a comprar?', 'Multipla Escolha');

INSERT INTO pesquisa_pergunta
(id_pesquisa, id_pergunta)
VALUES
(1,1),
(1,2),
(1,3),
(2,2),
(2,4),
(2,5);

INSERT INTO consumidores (nome, idade, cidade)
VALUES
('Lucas', 22, 'São Paulo'),
('Fernanda', 35, 'Rio de Janeiro'),
('Roberto', 45, 'Belo Horizonte'),
('Juliana', 29, 'Curitiba'),
('Marcos', 50, 'Rio de Janeiro');

INSERT INTO sessoes_resposta
(id_consumidor, id_pesquisa, data_resposta)
VALUES
(1,1,'2024-05-01'),
(2,1,'2024-05-02'),
(3,2,'2024-05-03'),
(4,2,'2024-05-04'),
(5,1,'2024-05-05');

INSERT INTO respostas
(id_sessao, id_pergunta, resposta_nota)
VALUES
(1,1,5),
(1,2,4),
(1,3,5),
(1,4,4),

(2,1,3),
(2,2,2),
(2,3,4),
(2,4,3),

(3,2,5),
(3,4,4),
(3,5,5),
(3,1,4),

(4,2,3),
(4,4,3),
(4,5,4),
(4,1,2),

(5,1,5),
(5,2,5),
(5,3,5),
(5,4,4);


SELECT c.nome, p.titulo
FROM consumidores c
JOIN sessoes_resposta s
ON c.id_consumidor = s.id_consumidor
JOIN pesquisas p
ON s.id_pesquisa = p.id_pesquisa;


SELECT titulo
FROM pesquisas
WHERE titulo LIKE '%Satisfação%';

SELECT DISTINCT c.nome
FROM consumidores c
JOIN sessoes_resposta s
ON c.id_consumidor = s.id_consumidor
JOIN pesquisas p
ON s.id_pesquisa = p.id_pesquisa
WHERE YEAR(p.data_criacao) < 2024;

SELECT pe.texto, p.titulo
FROM perguntas pe
JOIN pesquisa_pergunta pp
ON pe.id_pergunta = pp.id_pergunta
JOIN pesquisas p
ON pp.id_pesquisa = p.id_pesquisa;


SELECT c.nome
FROM consumidores c
LEFT JOIN sessoes_resposta s
ON c.id_consumidor = s.id_consumidor
WHERE s.id_sessao IS NULL;


SELECT ROUND(AVG(idade),0) AS media_idade
FROM consumidores;

SELECT AVG(resposta_nota) AS media_notas
FROM respostas;

SELECT c.cidade,
COUNT(*) AS quantidade
FROM consumidores c
JOIN sessoes_resposta s
ON c.id_consumidor = s.id_consumidor
GROUP BY c.cidade;

SELECT p.titulo,
COUNT(r.id_resposta) AS total_respostas
FROM pesquisas p
JOIN sessoes_resposta s
ON p.id_pesquisa = s.id_pesquisa
JOIN respostas r
ON s.id_sessao = r.id_sessao
GROUP BY p.titulo;

SELECT
MAX(resposta_nota) AS nota_maxima,
MIN(resposta_nota) AS nota_minima
FROM respostas
WHERE id_pergunta = 1;


SELECT p.titulo,
AVG(r.resposta_nota) AS media
FROM pesquisas p
JOIN sessoes_resposta s
ON p.id_pesquisa = s.id_pesquisa
JOIN respostas r
ON s.id_sessao = r.id_sessao
GROUP BY p.titulo
HAVING media < 3.0;


SELECT c.nome,
COUNT(DISTINCT s.id_pesquisa) AS qtd
FROM consumidores c
JOIN sessoes_resposta s
ON c.id_consumidor = s.id_consumidor
GROUP BY c.nome
HAVING qtd > 1;


SELECT cidade,
COUNT(*) AS qtd
FROM consumidores
GROUP BY cidade
HAVING qtd > 2;


UPDATE consumidores
SET cidade = 'São Paulo'
WHERE idade > 40;


UPDATE perguntas
SET texto = 'Qual sua opinião sobre o atendimento?'
WHERE id_pergunta = 2;


DELETE r
FROM respostas r
JOIN sessoes_resposta s
ON r.id_sessao = s.id_sessao
JOIN consumidores c
ON s.id_consumidor = c.id_consumidor
WHERE c.cidade = 'Rio de Janeiro';

/* 17 */
DELETE FROM pesquisas
WHERE id_pesquisa =
(
    SELECT id_pesquisa
    FROM
    (
        SELECT p.id_pesquisa,
        COUNT(r.id_resposta) AS total
        FROM pesquisas p
        LEFT JOIN sessoes_resposta s
        ON p.id_pesquisa = s.id_pesquisa
        LEFT JOIN respostas r
        ON s.id_sessao = r.id_sessao
        GROUP BY p.id_pesquisa
        ORDER BY total ASC
        LIMIT 1
    ) AS sub
);

-- SUBQUERY
 
SELECT nome
FROM consumidores
WHERE idade >
(
    SELECT AVG(idade)
    FROM consumidores
);


SELECT
dados.titulo,
(dados.media_pesquisa - geral.media_geral) AS diferenca
FROM
(
    SELECT p.titulo,
    AVG(r.resposta_nota) AS media_pesquisa
    FROM pesquisas p
    JOIN sessoes_resposta s
    ON p.id_pesquisa = s.id_pesquisa
    JOIN respostas r
    ON s.id_sessao = r.id_sessao
    GROUP BY p.titulo
) AS dados,

(
    SELECT AVG(resposta_nota) AS media_geral
    FROM respostas
) AS geral;


CREATE VIEW V_ANALISE_RESPOSTAS AS
SELECT
p.titulo,
pe.texto,
AVG(r.resposta_nota) AS media_notas
FROM pesquisas p
JOIN sessoes_resposta s
ON p.id_pesquisa = s.id_pesquisa
JOIN respostas r
ON s.id_sessao = r.id_sessao
JOIN perguntas pe
ON r.id_pergunta = pe.id_pergunta
GROUP BY p.titulo, pe.texto;