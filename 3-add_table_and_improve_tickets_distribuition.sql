


CREATE TABLE Modelo_Distribuicao (
    id SERIAL PRIMARY KEY,
    evento_id INTEGER REFERENCES Evento(id) ON DELETE CASCADE,
    tipo VARCHAR(20) CHECK (tipo IN ('inteira', 'meia_solidaria', 'meia_idoso', 'meia_estudante', 'cortesia')),
    percentual NUMERIC(5,2) NOT NULL CHECK (percentual >= 0 AND percentual <= 100)
);


CREATE OR REPLACE FUNCTION validar_percentual_modelo_distribuicao()
RETURNS TRIGGER AS $$
BEGIN
    IF (
        SELECT COALESCE(SUM(percentual), 0)
        FROM Modelo_Distribuicao
        WHERE evento_id = NEW.evento_id
        AND id <> NEW.id
    ) + NEW.percentual > 100 THEN
        RAISE EXCEPTION 'Soma dos percentuais para o evento % excede 100%%', NEW.evento_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_valida_modelo_distribuicao
BEFORE INSERT OR UPDATE ON Modelo_Distribuicao
FOR EACH ROW EXECUTE FUNCTION validar_percentual_modelo_distribuicao();


ALTER TABLE Tipo_Ingresso
ADD COLUMN modelo_distribuicao_id INTEGER REFERENCES Modelo_Distribuicao(id);