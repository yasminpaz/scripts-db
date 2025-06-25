--Etapas para validar o trigger
-- 1) Um Local com lotação e setores.
-- 2) Um Evento nesse local.
-- 3) Um Modelo de Distribuição com percentual limitado.
-- 4) Um Tipo de Ingresso vinculado ao modelo.
-- 5) Vendas confirmadas até o limite.
-- 6) Uma tentativa de venda que exceda o limite — aqui o trigger deve bloquear.

CREATE OR REPLACE FUNCTION validar_limite_ingresso()
RETURNS TRIGGER AS $$
DECLARE
    v_evento_id INTEGER;
    v_modelo_id INTEGER;
    v_percentual NUMERIC;
    v_capacidade_evento INTEGER;
    v_total_vendidos INTEGER;
BEGIN
    -- Buscar evento e modelo do ingresso
    SELECT i.evento_id, ti.modelo_distribuicao_id
    INTO v_evento_id, v_modelo_id
    FROM Ingresso i
    JOIN Tipo_Ingresso ti ON i.tipo_ingresso_id = ti.id
    WHERE i.id = NEW.ingresso_id;

    -- Buscar percentual do modelo
    SELECT md.percentual INTO v_percentual
    FROM Modelo_Distribuicao md
    WHERE md.id = v_modelo_id;

    -- Calcular capacidade total do evento (com segurança)
    SELECT COALESCE(SUM(s.capacidade), 0)
    INTO v_capacidade_evento
    FROM Setor s
    JOIN Evento e ON s.local_id = e.local_id
    WHERE e.id = v_evento_id;

    -- Contar ingressos já vendidos e pagos
    SELECT COUNT(*) INTO v_total_vendidos
    FROM ItemVenda iv
    JOIN Venda v ON iv.venda_id = v.id
    JOIN Ingresso i2 ON iv.ingresso_id = i2.id
    JOIN Tipo_Ingresso ti2 ON i2.tipo_ingresso_id = ti2.id
    WHERE v.status_pagamento = 'Confirmado'
      AND i2.evento_id = v_evento_id
      AND ti2.modelo_distribuicao_id = v_modelo_id;

    -- Verificar se ultrapassou o limite
    IF v_total_vendidos >= (v_percentual / 100.0) * v_capacidade_evento THEN
        RAISE EXCEPTION 
        'Limite de ingressos para o modelo de distribuição (%.2f%%) atingido: vendidos % de no máximo %.0f.', 
        v_percentual, v_total_vendidos, (v_percentual / 100.0) * v_capacidade_evento;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;