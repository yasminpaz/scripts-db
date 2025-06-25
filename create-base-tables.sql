-- Tabela Artista
CREATE TABLE Artista (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    classe CHAR(1) CHECK (classe IN ('S', 'A', 'B', 'C')),
    genero VARCHAR(50),
    nacionalidade VARCHAR(50)
);

-- Tabela Local
CREATE TABLE Local (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    endereco VARCHAR(200)
);

-- Tabela Evento
CREATE TABLE Evento (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo VARCHAR(50),
    data DATE NOT NULL,
    local_id INTEGER NOT NULL,
    classe CHAR(1) CHECK (classe IN ('S', 'A', 'B', 'C')),
    modelo_distribuicao VARCHAR(100),
    CONSTRAINT fk_evento_local FOREIGN KEY (local_id) REFERENCES Local(id)
);

CREATE INDEX idx_evento_local_id ON Evento(local_id);

-- Tabela Cliente
CREATE TABLE Cliente (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    data_nasc DATE,
    email VARCHAR(100),
    telefone VARCHAR(20)
);

CREATE INDEX idx_cliente_cpf ON Cliente(cpf);

-- Tabela Tipo_Ingresso
CREATE TABLE Tipo_Ingresso (
    id SERIAL PRIMARY KEY,
    descricao VARCHAR(100) NOT NULL,
    percentual_desconto DECIMAL(5,2)
);

-- Tabela Ingresso
CREATE TABLE Ingresso (
    id SERIAL PRIMARY KEY,
    evento_id INTEGER NOT NULL,
    tipo_ingresso_id INTEGER NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    setor VARCHAR(100),
    CONSTRAINT fk_ingresso_evento FOREIGN KEY (evento_id) REFERENCES Evento(id),
    CONSTRAINT fk_ingresso_tipo FOREIGN KEY (tipo_ingresso_id) REFERENCES Tipo_Ingresso(id)
);

CREATE INDEX idx_ingresso_evento_id ON Ingresso(evento_id);
CREATE INDEX idx_ingresso_tipo_id ON Ingresso(tipo_ingresso_id);

-- Tabela Venda
CREATE TABLE Venda (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    data TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2) NOT NULL,
    status_pagamento VARCHAR(50),
    CONSTRAINT fk_venda_cliente FOREIGN KEY (cliente_id) REFERENCES Cliente(id)
);

CREATE INDEX idx_venda_cliente_id ON Venda(cliente_id);

-- Tabela ItemVenda
CREATE TABLE ItemVenda (
    id SERIAL PRIMARY KEY,
    venda_id INTEGER NOT NULL,
    ingresso_id INTEGER NOT NULL,
    CONSTRAINT fk_itemvenda_venda FOREIGN KEY (venda_id) REFERENCES Venda(id),
    CONSTRAINT fk_itemvenda_ingresso FOREIGN KEY (ingresso_id) REFERENCES Ingresso(id)
);

CREATE INDEX idx_itemvenda_venda_id ON ItemVenda(venda_id);
CREATE INDEX idx_itemvenda_ingresso_id ON ItemVenda(ingresso_id);

-- Tabela Setor
CREATE TABLE Setor (
    id SERIAL PRIMARY KEY,
    local_id INTEGER NOT NULL,
    nome VARCHAR(100),
    capacidade INTEGER,
    CONSTRAINT fk_setor_local FOREIGN KEY (local_id) REFERENCES Local(id)
);

CREATE INDEX idx_setor_local_id ON Setor(local_id);

-- Tabela Pagamento
CREATE TABLE Pagamento (
    id SERIAL PRIMARY KEY,
    venda_id INTEGER NOT NULL,
    tipo VARCHAR(50),
    status VARCHAR(50),
    valor DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_pagamento_venda FOREIGN KEY (venda_id) REFERENCES Venda(id)
);

CREATE INDEX idx_pagamento_venda_id ON Pagamento(venda_id);