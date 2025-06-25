CREATE OR REPLACE FUNCTION realizar_pagamento(
    p_venda_id INTEGER,
    p_tipo_pagamento VARCHAR(50),
    p_valor DECIMAL(10,2)
) RETURNS VOID AS $$
DECLARE
    v_total_venda DECIMAL(10,2);
    v_pagamento_id INTEGER;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Venda WHERE id = p_venda_id) THEN
        RAISE EXCEPTION 'Venda com ID % não encontrada', p_venda_id;
    END IF;
    
    SELECT total INTO v_total_venda FROM Venda WHERE id = p_venda_id;
    
    IF p_valor != v_total_venda THEN
        RAISE EXCEPTION 'Valor do pagamento (R$ %) não corresponde ao total da venda (R$ %)', 
                        p_valor, v_total_venda;
    END IF;
    
    SELECT id INTO v_pagamento_id 
    FROM Pagamento 
    WHERE venda_id = p_venda_id AND status = 'Pendente'
    LIMIT 1;
    
    IF v_pagamento_id IS NULL THEN
        RAISE EXCEPTION 'Nenhum pagamento pendente encontrado para a venda %', p_venda_id;
    END IF;
    
    UPDATE Pagamento 
    SET 
        tipo = p_tipo_pagamento,
        status = 'Confirmado',
        valor = p_valor
    WHERE id = v_pagamento_id;
    
    UPDATE Venda 
    SET status_pagamento = 'Confirmado' 
    WHERE id = p_venda_id;
END;
$$ LANGUAGE plpgsql;