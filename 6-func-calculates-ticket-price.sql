

CREATE OR REPLACE FUNCTION calcular_valor_ingresso(
    p_evento_id INTEGER,
    p_tipo_ingresso_id INTEGER,
    p_preco_base NUMERIC
) RETURNS NUMERIC AS $$
DECLARE
    v_desconto NUMERIC;
    v_valor_final NUMERIC;
BEGIN
    SELECT percentual_desconto INTO v_desconto
    FROM Tipo_Ingresso
    WHERE id = p_tipo_ingresso_id;

    IF v_desconto IS NULL THEN
        v_desconto := 0;
    END IF;

    v_valor_final := p_preco_base * (1 - v_desconto / 100.0);

    RETURN ROUND(v_valor_final::NUMERIC, 2);
END;
$$ LANGUAGE plpgsql;
