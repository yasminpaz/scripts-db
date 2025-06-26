CREATE OR REPLACE FUNCTION validar_venda_com_itens()
RETURNS TRIGGER AS $$
DECLARE
    total_itens INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_itens FROM ItemVenda WHERE venda_id = OLD.venda_id;

    IF total_itens = 0 THEN
        RAISE EXCEPTION 'Venda % deve conter ao menos um ingresso (ItemVenda).', OLD.venda_id;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validar_venda_itens ON ItemVenda;