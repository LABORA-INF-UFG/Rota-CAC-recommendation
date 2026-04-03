function ndcg = calcular_ndcg(rota, pois, pokemons, qoe, k)
    % Mapeamentos
    poipokemon = containers.Map(pokemons.pkid, pokemons.valor);
    qoe_map = containers.Map(qoe.qoeid, qoe.valor_qoe);

    % Relevâncias (pokepontos + qoe) para cada POI da rota
    relevancias = zeros(length(rota), 1);
    for i = 1:length(rota)
        idx = rota(i);
        pkid = pois.pkid(idx);
        qoeid = pois.qoeid(idx);

        ponto_pk = 0;
        if isKey(poipokemon, pkid)
            ponto_pk = poipokemon(pkid);
        end

        valor_qoe = 0;
        if isKey(qoe_map, qoeid)
            valor_qoe = qoe_map(qoeid);
        end

        relevancias(i) = ponto_pk + valor_qoe;
    end

    % Calcula DCG@k
    k = min(k, length(relevancias));
    rel_top_k = relevancias(1:k);
    dcg = sum(rel_top_k ./ log2((1:k) + 1));

    % Calcula IDCG@k (ideal)
    rel_ideal_top_k = sort(relevancias, 'descend');
    rel_ideal_top_k = rel_ideal_top_k(1:k);
    idcg = sum(rel_ideal_top_k ./ log2((1:k) + 1));

    % NDCG
    if idcg == 0
        ndcg = 0;
    else
        ndcg = dcg / idcg;
    end
end
