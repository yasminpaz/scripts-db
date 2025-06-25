CREATE OR REPLACE VIEW vw_ingresso_cliente AS
SELECT
    i.id AS ingresso_id,
    i.evento_id,
    i.tipo_ingresso_id,
    i.valor,
    i.setor,
    v.id AS venda_id,
    v.cliente_id,
    c.nome AS cliente_nome,
    v.data AS data_venda,
    v.status_pagamento
FROM Ingresso i
JOIN ItemVenda iv ON i.id = iv.ingresso_id
JOIN Venda v ON iv.venda_id = v.id
JOIN Cliente c ON v.cliente_id = c.id;
