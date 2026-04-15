#CREATE SCHEMA lab3;
USE lab3;

CREATE TABLE CLIENTE (
	Cpf CHAR(11) PRIMARY KEY,
    Nome VARCHAR(150),
    Endereco VARCHAR(250)
);

CREATE TABLE telefones_cliente (
    Cpf CHAR(11),
    Numero CHAR(11),
    PRIMARY KEY (Cpf, Numero),
    FOREIGN KEY (Cpf) REFERENCES CLIENTE(Cpf)
);

CREATE TABLE CORRETOR (
	Nome VARCHAR(150),
    Cpf CHAR(11) PRIMARY KEY,
    Numero_SUSEP VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE SEGURO (
	Numero_Apolice CHAR(24) PRIMARY KEY,
    Periodo_Cobertura INT,
    Data_Inicio DATE,
    Franquia REAL
);

CREATE TABLE SINISTRO (
	Numero_Sinistro CHAR(70),
    Valor_Sinistro REAL,
    Descricao_Sinistro VARCHAR(200),
    Numero_Apolice CHAR(24),
    FOREIGN KEY (Numero_Apolice) REFERENCES SEGURO(Numero_Apolice),
    PRIMARY KEY (Numero_Sinistro, Numero_Apolice)
);

CREATE TABLE PERITO (
	Cpf CHAR(11) PRIMARY KEY,
    Nome VARCHAR(150),
    Especialidade VARCHAR(150)
);

CREATE TABLE BEM (
	Codigo_Bem VARCHAR(70) PRIMARY KEY,
    Valor_Bem REAL
);

CREATE TABLE AUTOMOVEL (
	Modelo VARCHAR(100),
    Codigo_Bem VARCHAR(70) PRIMARY KEY,
    FOREIGN KEY (Codigo_Bem) REFERENCES BEM(Codigo_Bem)
);

CREATE TABLE IMOVEL (
	Localizacao VARCHAR(250),
    Codigo_Bem VARCHAR(70) PRIMARY KEY,
    FOREIGN KEY (Codigo_Bem) REFERENCES BEM(Codigo_Bem)
);

CREATE TABLE ADQUIRE (
	Data_Assinatura Date,
    Cpf_cliente CHAR(11) NOT NULL,
    Cpf_corretor CHAR(11) NOT NULL,
    Numero_Apolice CHAR(24),
    FOREIGN KEY (Cpf_cliente) REFERENCES CLIENTE(Cpf),
    FOREIGN KEY (Cpf_corretor) REFERENCES CORRETOR(Cpf),
    FOREIGN KEY (Numero_Apolice) REFERENCES SEGURO(Numero_Apolice),
    PRIMARY KEY (Numero_Apolice)
);

CREATE TABLE PROTEGE (
    Numero_Apolice CHAR(24),
    Codigo_Bem VARCHAR(70) NOT NULL,
    PRIMARY KEY (Numero_Apolice),
    FOREIGN KEY (Numero_Apolice) REFERENCES SEGURO (Numero_Apolice),
    FOREIGN KEY (Codigo_Bem) REFERENCES BEM (Codigo_Bem)
);

CREATE TABLE AVALIA (
	Observacao VARCHAR(250),
    Data_Vistoria Date,
    Cpf_perito CHAR(11),
    Numero_Sinistro CHAR(70),
    Numero_Apolice CHAR(24),
    FOREIGN KEY (Numero_Apolice) REFERENCES SEGURO(Numero_Apolice),
    FOREIGN KEY (Numero_Sinistro) REFERENCES SINISTRO(Numero_Sinistro),
    FOREIGN KEY (Cpf_perito) REFERENCES PERITO(Cpf),
    PRIMARY KEY (Cpf_perito, Numero_Apolice, Numero_Sinistro)
);