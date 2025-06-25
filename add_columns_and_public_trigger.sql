ALTER TABLE Local
ADD COLUMN lotacao_maxima INTEGER NOT NULL;

ALTER TABLE Evento
ADD COLUMN publico_esperado INTEGER NOT NULL;

CREATE OR REPLACE FUNCTION validar_publico_evento()
RETURNS TRIGGER AS $$
DECLARE
    lotacao_local INTEGER;
BEGIN
    SELECT lotacao_maxima INTO lotacao_local
    FROM Local
    WHERE id = NEW.local_id;

    IF NEW.publico_esperado > lotacao_local THEN
        RAISE EXCEPTION 'Erro: público esperado (%), excede a lotação máxima do local (%)',
                        NEW.publico_esperado, lotacao_local;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validar_publico_evento
BEFORE INSERT OR UPDATE ON Evento
FOR EACH ROW
EXECUTE FUNCTION validar_publico_evento();

