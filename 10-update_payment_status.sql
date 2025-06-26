CREATE OR REPLACE FUNCTION atualizar_status_venda_pagamento()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'Confirmado' AND (OLD.status IS NULL OR OLD.status != 'Confirmado') THEN
        UPDATE Venda 
        SET status_pagamento = 'Confirmado' 
        WHERE id = NEW.venda_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_atualizar_status_venda
AFTER UPDATE ON Pagamento
FOR EACH ROW
EXECUTE FUNCTION atualizar_status_venda_pagamento();