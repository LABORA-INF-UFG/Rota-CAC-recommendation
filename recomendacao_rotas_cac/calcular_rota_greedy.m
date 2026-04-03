function [rota, pontuacao_total, qoe_total, tempo_total] = calcular_rota_greedy(userid, tempo_max, pois, pokemons, custos, qoe, poiid_inicio, limiar, atraso_maximo)
    num_pois = height(pois);
    poipokemon = containers.Map(pokemons.pkid, pokemons.valor);
    qoe_map = containers.Map(qoe.qoeid, qoe.valor_qoe);

    poi_atual = poiid_inicio;
    visitados = false(num_pois, 1);
    visitados(poi_atual) = true;
    
    q_ini = 0; if isKey(qoe_map, pois.qoeid(poi_atual)), q_ini = qoe_map(pois.qoeid(poi_atual)); end
    t_v_ini = pois.tvisit(poi_atual);
    if q_ini < limiar, t_v_ini = t_v_ini + (1 - q_ini) * atraso_maximo; end
    
    rota = [poi_atual];
    tempo_total = t_v_ini;
    pontuacao_total = 0; if isKey(poipokemon, pois.pkid(poi_atual)), pontuacao_total = poipokemon(pois.pkid(poi_atual)); end
    qoe_total = q_ini;

    while true
        melhor_poi = -1; melhor_ratio = -Inf;
        for j = 1:num_pois
            if visitados(j), continue; end
            idx = find(custos.de == poi_atual & custos.para == j);
            if isempty(idx), continue; end

            t_d = custos.tdeslocamento(idx);
            vq = 0; if isKey(qoe_map, pois.qoeid(j)), vq = qoe_map(pois.qoeid(j)); end
            t_v_p = pois.tvisit(j);
            if vq < limiar, t_v_p = t_v_p + (1 - vq) * atraso_maximo; end
            
            t_delta = t_d + t_v_p;
            if (tempo_total + t_delta) > tempo_max, continue; end

            p_pk = 0; if isKey(poipokemon, pois.pkid(j)), p_pk = poipokemon(pois.pkid(j)); end
            ratio = (p_pk + vq) / t_delta;

            if ratio > melhor_ratio
                melhor_ratio = ratio; melhor_poi = j;
                m_t = t_delta; m_p = p_pk; m_q = vq;
            end
        end
        if melhor_poi == -1, break; end
        rota = [rota, melhor_poi]; tempo_total = tempo_total + m_t;
        pontuacao_total = pontuacao_total + m_p; qoe_total = qoe_total + m_q;
        visitados(melhor_poi) = true; poi_atual = melhor_poi;
    end
end
