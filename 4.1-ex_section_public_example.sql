--INSERT INTO Local (nome, endereco, lotacao_maxima) VALUES ('Arena Central', 'Rua das Estrelas, 100', 1000);
--INSERT INTO Local (nome, endereco, lotacao_maxima) VALUES ('Maracana', 'R. Prof. Eurico Rabelo, 100', 78838);
-- INSERT INTO Local ("endereco", "lotacao_maxima", "nome") values ('R. José dos Reis, 425', 44661, 'Nilton Santos')

--Espera-se que funcione pois está nos limites estabelecidos pela lotaçao
DO $$
DECLARE
    arena_id INTEGER;
BEGIN
    SELECT id INTO arena_id FROM Local WHERE nome = 'Nilton Santos';

    INSERT INTO Setor (local_id, nome, capacidade) VALUES 
    (arena_id, 'Arquibancada Norte', 8000),
    (arena_id, 'Arquibancada Sul', 8000),
    (arena_id, 'Arquibancada Leste', 7000),
    (arena_id, 'Arquibancada Oeste', 7000),
    (arena_id, 'Cadeira Inferior', 5000),
    (arena_id, 'Cadeira Superior', 5000),
    (arena_id, 'Camarote', 1000),
    (arena_id, 'VIP', 1000),
    (arena_id, 'Pista', 1661);
END $$;

-- Verifica capacidade restante
SELECT 
    lotacao_maxima,
    (SELECT COALESCE(SUM(capacidade), 0) FROM Setor WHERE local_id = l.id) AS capacidade_total,
    lotacao_maxima - (SELECT COALESCE(SUM(capacidade), 0) FROM Setor WHERE local_id = l.id) AS lugares_restantes
FROM Local l
WHERE nome = 'Nilton Santos';

-- Erro (Terá 1 a mais, excede lotação)
DO $$
DECLARE
    arena_id INTEGER;
BEGIN
    -- Busca o id do local 'Arena Central' e armazena em variável
    SELECT id INTO arena_id FROM Local WHERE nome = 'Nilton Santos';

    -- Usa a variável para inserir setores
    INSERT INTO Setor (local_id, nome, capacidade) VALUES 
    (arena_id, 'Premium', 1001);
END $$;

