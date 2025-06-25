
CREATE OR REPLACE FUNCTION validar_ocupacao_setor()
RETURNS TRIGGER AS $$
DECLARE
    setor_nome VARCHAR;
    evento_id INTEGER;
    local_id INTEGER;
    setor_capacidade INTEGER;
    total_vendidos INTEGER;
BEGIN
    SELECT i.setor, i.evento_id INTO setor_nome, evento_id
    FROM Ingresso i WHERE i.id = NEW.ingresso_id;

    SELECT e.local_id INTO local_id FROM Evento e WHERE e.id = evento_id;

    SELECT s.capacidade INTO setor_capacidade
    FROM Setor s
    WHERE s.local_id = local_id AND s.nome = setor_nome;

    SELECT COUNT(*) INTO total_vendidos
    FROM ItemVenda iv
    JOIN Venda v ON iv.venda_id = v.id
    JOIN Ingresso i ON iv.ingresso_id = i.id
    WHERE v.status_pagamento = 'Confirmado'
      AND i.setor = setor_nome
      AND i.evento_id = evento_id;

    IF total_vendidos >= setor_capacidade THEN
        RAISE EXCEPTION 'Setor % do evento % já está lotado.', setor_nome, evento_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_valida_ocupacao_setor
BEFORE INSERT ON ItemVenda
FOR EACH ROW EXECUTE FUNCTION validar_ocupacao_setor();


CREATE OR REPLACE FUNCTION validar_capacidade_setores()
RETURNS TRIGGER AS $$
DECLARE
    capacidade_total INTEGER;
    lotacao_local INTEGER;
BEGIN
    SELECT COALESCE(SUM(capacidade), 0)
    INTO capacidade_total
    FROM Setor
    WHERE local_id = NEW.local_id;

    SELECT lotacao_maxima
    INTO lotacao_local
    FROM Local
    WHERE id = NEW.local_id;

    IF capacidade_total > lotacao_local THEN
        RAISE EXCEPTION 
        'A soma da capacidade dos setores (% lugares) excede a lotação máxima do local (% lugares).',
        capacidade_total, lotacao_local;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS tr_valida_setores ON Setor;

CREATE TRIGGER tr_valida_setores
AFTER INSERT OR UPDATE ON Setor
FOR EACH ROW
EXECUTE FUNCTION validar_capacidade_setores();


