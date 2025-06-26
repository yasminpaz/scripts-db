CREATE OR REPLACE FUNCTION public.validar_ocupacao_setor()
RETURNS trigger
LANGUAGE plpgsql AS $function$
DECLARE
    setor_nome VARCHAR;
    v_evento_id INTEGER; 
    local_id_var INTEGER;
    setor_capacidade INTEGER;
    total_vendidos INTEGER;
BEGIN
    SELECT i.setor, i.evento_id INTO setor_nome, v_evento_id
    FROM Ingresso i WHERE i.id = NEW.ingresso_id;

    SELECT e.local_id INTO local_id_var 
    FROM Evento e 
    WHERE e.id = v_evento_id;

    SELECT s.capacidade INTO setor_capacidade
    FROM Setor s
    WHERE s.local_id = local_id_var AND s.nome = setor_nome;

    SELECT COUNT(*) INTO total_vendidos
    FROM ItemVenda iv
    JOIN Venda v ON iv.venda_id = v.id
    JOIN Ingresso i ON iv.ingresso_id = i.id
    WHERE v.status_pagamento = 'Confirmado'
      AND i.setor = setor_nome
      AND i.evento_id = v_evento_id; 

    IF total_vendidos >= setor_capacidade THEN
        RAISE EXCEPTION 'Setor % do evento % já está lotado.', setor_nome, v_evento_id;
    END IF;

    RETURN NEW;
END;
