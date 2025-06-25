CREATE OR REPLACE FUNCTION criar_venda(
    p_cliente_id INTEGER,
    p_ingresso_ids INTEGER[]
) RETURNS INTEGER AS $$
DECLARE
    v_venda_id INTEGER;
    v_total NUMERIC := 0;
    v_ingresso_id INTEGER;
    v_valor_ingresso NUMERIC;
    v_pagamento_id INTEGER;
BEGIN
    IF array_length(p_ingresso_ids, 1) IS NULL OR array_length(p_ingresso_ids, 1) = 0 THEN
        RAISE EXCEPTION 'Nenhum ingresso especificado para a venda';
    END IF;

    INSERT INTO Venda (cliente_id, total, status_pagamento)
    VALUES (p_cliente_id, 0, 'Pendente')
    RETURNING id INTO v_venda_id;

    FOREACH v_ingresso_id IN ARRAY p_ingresso_ids LOOP
        IF NOT EXISTS (SELECT 1 FROM Ingresso WHERE id = v_ingresso_id) THEN
            RAISE EXCEPTION 'Ingresso com ID % não existe', v_ingresso_id;
        END IF;

        IF EXISTS (
            SELECT 1 FROM ItemVenda iv
            JOIN Venda v ON iv.venda_id = v.id
            WHERE iv.ingresso_id = v_ingresso_id
            AND v.status_pagamento = 'Confirmado'
        ) THEN
            RAISE EXCEPTION 'Ingresso com ID % já foi vendido', v_ingresso_id;
        END IF;

        INSERT INTO ItemVenda (venda_id, ingresso_id)
        VALUES (v_venda_id, v_ingresso_id);

        SELECT valor INTO v_valor_ingresso FROM Ingresso WHERE id = v_ingresso_id;
        v_total := v_total + v_valor_ingresso;
    END LOOP;

    UPDATE Venda SET total = v_total WHERE id = v_venda_id;

    INSERT INTO Pagamento (venda_id, tipo, status, valor)
    VALUES (v_venda_id, 'A definir', 'Pendente', v_total)
    RETURNING id INTO v_pagamento_id;

    RETURN v_venda_id;
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
$$ LANGUAGE plpgsql;


SELECT criar_venda(1, ARRAY[2]);