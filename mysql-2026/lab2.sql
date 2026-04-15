USE bd;

-- LIMPEZA
DROP TABLE IF EXISTS MODELOS_MAIS_LUCRATIVOS;
DROP TABLE IF EXISTS VENDA;
DROP TABLE IF EXISTS ITEM;
DROP TABLE IF EXISTS AVALIACAO;
DROP TABLE IF EXISTS CLIENTE;
DROP TABLE IF EXISTS MODELO;
DROP TRIGGER IF EXISTS tg_verifica_valor_venda;
--

-- TABELAS
CREATE TABLE CLIENTE (
    Cpf CHAR(11) PRIMARY KEY,
    Nome VARCHAR(150) NOT NULL,
    Data_Nascimento DATE NULL,
    Genero ENUM('F', 'M') NULL
);

CREATE TABLE MODELO (
    Identificacao_Modelo INT PRIMARY KEY,
    Nome_produto VARCHAR(150) NOT NULL UNIQUE,
    Descricao VARCHAR(250) NULL
);

CREATE TABLE ITEM (
    Numero_Serie INT PRIMARY KEY,
    Valor_Aquisicao DECIMAL(10,2) NOT NULL CHECK (Valor_Aquisicao >= 0),
    Identificacao_Modelo INT NOT NULL,
    FOREIGN KEY (Identificacao_Modelo) REFERENCES MODELO (Identificacao_Modelo)
);

CREATE TABLE VENDA (
    Numero_Serie INT PRIMARY KEY,
    Valor_Venda DECIMAL(10,2) NOT NULL CHECK (Valor_Venda >= 0),
    Data_Hora TIMESTAMP NOT NULL,
    Cliente_Cpf CHAR(11) NOT NULL,
    FOREIGN KEY (Numero_Serie) REFERENCES ITEM (Numero_Serie),
    FOREIGN KEY (Cliente_Cpf) REFERENCES CLIENTE (Cpf)
);

CREATE TABLE AVALIACAO (
    Cliente_Cpf CHAR(11) NOT NULL,
    Identificacao_Modelo INT NOT NULL,
    Nota FLOAT NOT NULL CHECK (Nota BETWEEN 0 AND 5),
    PRIMARY KEY (Cliente_Cpf, Identificacao_Modelo),
    FOREIGN KEY (Cliente_Cpf) REFERENCES CLIENTE (Cpf),
    FOREIGN KEY (Identificacao_Modelo) REFERENCES MODELO (Identificacao_Modelo)
);
--

-- INSERTS
INSERT INTO MODELO VALUES
(1, 'Notebook Pro 14', 'Notebook profissional com alto desempenho'),
(2, 'Smartphone X', 'Smartphone intermediário com câmera avançada'),
(3, 'Tablet Plus', 'Tablet para uso educacional e multimídia'),
(4, 'TV Smart', 'Televisão inteligente'),
(5, 'Headset Gamer', 'Headset com fio, cancelamento de ruído e microfone incluso');

INSERT INTO ITEM VALUES
(1001, 3500.00, 1),
(1002, 3600.00, 1),
(1003, 3400.00, 1),
(2001, 1800.00, 2),
(2002, 1750.00, 2),
(2003, 1850.00, 2),
(2004, 1700.00, 2),
(3001, 2200.00, 3),
(3002, 2150.00, 3),
(3003, 2250.00, 3),
(4004, 1200.00, 4),
(5005, 700.00, 5);

INSERT INTO CLIENTE VALUES
('12345678901', 'Ana Silva', '1995-04-12', 'F'),
('23456789012', 'Bruno Costa', '1988-09-30', 'M'),
('34567890123', 'Carla Souza', '2000-01-20', 'F'),
('45678901234', 'Diego Pereira', '1992-07-05', 'M');

INSERT INTO VENDA VALUES
(1001, 4500.00, '2025-01-10 10:30:00', '12345678901'),
(1002, 4700.00, '2025-01-11 14:15:00', '23456789012'),
(3001, 2300.00, '2025-01-12 09:45:00', '34567890123'),
(2002, 2100.00, '2025-01-13 16:20:00', '12345678901'),
(3003, 2400.00, '2025-01-14 11:00:00', '45678901234'),
(5005, 950.00, '2025-01-14 11:00:00', '12345678901');

INSERT INTO AVALIACAO VALUES
('12345678901', 1, 5),
('23456789012', 1, 4),
('34567890123', 1, 5),
('45678901234', 1, 4),
('12345678901', 2, 4),
('23456789012', 2, 3),
('34567890123', 2, 4),
('45678901234', 2, 5),
('12345678901', 3, 5),
('23456789012', 3, 4),
('34567890123', 3, 4),
('45678901234', 3, 5),
('12345678901', 5, 5),
('45678901234', 5, 5);
--

-- CONSULTAS
-- SELECT * FROM CLIENTE;
-- SELECT * FROM MODELO;
-- SELECT * FROM ITEM;
-- SELECT * FROM VENDA;
-- SELECT * FROM AVALIACAO;
--

-- Média das avaliações por modelo
SELECT 
    Identificacao_Modelo,
    AVG(Nota) AS Media_Nota
FROM AVALIACAO
GROUP BY Identificacao_Modelo;
--

-- VIEW MATERIALIZADA
CREATE TABLE MODELOS_MAIS_LUCRATIVOS AS
SELECT 
    m.Nome_produto,
    SUM(
        CASE 
            WHEN v.Numero_Serie IS NOT NULL
            THEN (v.Valor_Venda - i.Valor_Aquisicao)
            ELSE 0
        END
    ) AS Lucro_Total
FROM MODELO m
LEFT JOIN ITEM i ON i.Identificacao_Modelo = m.Identificacao_Modelo
LEFT JOIN VENDA v ON v.Numero_Serie = i.Numero_Serie
GROUP BY m.Nome_produto
ORDER BY Lucro_Total DESC;

SELECT * FROM MODELOS_MAIS_LUCRATIVOS;
--

-- TRIGGER
DROP TRIGGER IF EXISTS tg_verifica_valor_venda;
DELIMITER $$

CREATE TRIGGER tg_verifica_valor_venda
BEFORE INSERT ON VENDA
FOR EACH ROW
BEGIN
    DECLARE valor_aquisicao DECIMAL(10,2);

    SELECT Valor_Aquisicao
    INTO valor_aquisicao
    FROM ITEM
    WHERE Numero_Serie = NEW.Numero_Serie;
	
    IF valor_aquisicao IS NULL 
       OR NEW.Valor_Venda < valor_aquisicao * 1.3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 
        'Erro: O valor de venda deve ser pelo menos 30% maior que o valor de aquisição.';
    END IF;
END$$

DELIMITER ;
--

-- TESTE DA TRIGGER -> Teste de falha
INSERT INTO VENDA VALUES
(4004, 1000.00, '2025-01-16 10:00:00', '12345678901');
