-- Inserir local com lotação 500
INSERT INTO Local (nome, endereco, lotacao_maxima)
VALUES ('Arena Central', 'Rua Exemplo, 123', 500);

-- Vai funcionar (público esperado menor que a lotação)
INSERT INTO Evento (nome, tipo, data, local_id, classe, modelo_distribuicao, publico_esperado)
VALUES (
    'Show de Rock',
    'Show',
    '2025-09-10',
    (SELECT id FROM Local WHERE nome = 'Arena Central'),
    'A',
    '70% inteira, 30% meia',
    400
);

-- Vai falhar (público esperado maior que a lotação)
INSERT INTO Evento (nome, tipo, data, local_id, classe, modelo_distribuicao, publico_esperado)
VALUES (
    'Festival',
    'Festival',
    '2025-10-01',
    (SELECT id FROM Local WHERE nome = 'Arena Central'),
    'S',
    '60% inteira, 40% meia',
    600
);
