
function [melhor_rota, melhor_pontuacao_abs, melhor_qoe_abs, melhor_tempo] = calcular_rota_aco(userid, tempo_max, pois, pokemons, custos, qoe, poiid_inicio, eta, num_formigas, num_iter, alfa, beta, rho, limiar, atraso_max)
    num_pois = height(pois);
    poipokemon = containers.Map(pokemons.pkid, pokemons.valor);
    qoe_map = containers.Map(qoe.qoeid, qoe.valor_qoe);
    tau = ones(num_pois, num_pois) * 0.1; 
    eta_matrix = zeros(num_pois, num_pois); 
    td_matrix = inf(num_pois, num_pois);

    for i = 1:height(custos)
        de = custos.de(i); para = custos.para(i);
        q_v = 0; if isKey(qoe_map, pois.qoeid(para)), q_v = qoe_map(pois.qoeid(para)); end
        t_v_p = pois.tvisit(para);
        if q_v < limiar, t_v_p = t_v_p + (1 - q_v) * atraso_max; end
        t_tot = custos.tdeslocamento(i) + t_v_p;
        p_pk = 0; if isKey(poipokemon, pois.pkid(para)), p_pk = poipokemon(pois.pkid(para)); end
        %relevancia = (eta * p_pk) + ((1 - eta) * q_v);
        relevancia = ((1-eta) * p_pk) + ((eta) * q_v);
        eta_matrix(de, para) = relevancia / (t_tot + 0.001);
        td_matrix(de, para) = custos.tdeslocamento(i);
    end

    melhor_score_glob = -Inf; melhor_rota = []; 
    melhor_pontuacao_abs = 0; melhor_qoe_abs = 0; melhor_tempo = 0;

    for iter = 1:num_iter
        rotas_it = cell(num_formigas, 1); scores_it = zeros(num_formigas, 1);
        for k = 1:num_formigas
            [r, p, q, t] = construir_rota_formiga(poiid_inicio, tempo_max, num_pois, pois, poipokemon, qoe_map, td_matrix, tau, eta_matrix, alfa, beta, limiar, atraso_max);
           % score_p = ((eta) * p) + ((1-eta) * q);
            score_p = ((1-eta) * p) + ((eta) * q);
            if score_p > melhor_score_glob
                melhor_score_glob = score_p; melhor_rota = r;
                melhor_pontuacao_abs = p; melhor_qoe_abs = q; melhor_tempo = t;
            end
            rotas_it{k} = r; scores_it(k) = score_p;
        end
        tau = (1 - rho) * tau;
        for k = 1:num_formigas
            rf = rotas_it{k};
            if length(rf) > 1
                for s = 1:(length(rf)-1)
                    tau(rf(s), rf(s+1)) = tau(rf(s), rf(s+1)) + scores_it(k);
                end
            end
        end
    end
end

function [rota, pontuacao_total, qoe_total, tempo_total] = construir_rota_formiga(poi_ini, tempo_max, num_pois, pois, poipokemon, qoe_map, td_matrix, tau, eta_matrix, alfa, beta, limiar, atraso_max)
    visitados = false(num_pois, 1); poi_at = poi_ini; visitados(poi_at) = true;
    q_ini = 0; if isKey(qoe_map, pois.qoeid(poi_at)), q_ini = qoe_map(pois.qoeid(poi_at)); end
    t_v = pois.tvisit(poi_at);
    if q_ini < limiar, t_v = t_v + (1 - q_ini) * atraso_max; end
    rota = [poi_at]; tempo_total = t_v; qoe_total = q_ini;
    pontuacao_total = 0; if isKey(poipokemon, pois.pkid(poi_at)), pontuacao_total = poipokemon(pois.pkid(poi_at)); end

    while true
        cand = find(~visitados); probs = zeros(length(cand), 1);
        for c = 1:length(cand)
            j = cand(c);
            if isinf(td_matrix(poi_at, j)), continue; end
            vq = 0; if isKey(qoe_map, pois.qoeid(j)), vq = qoe_map(pois.qoeid(j)); end
            tv_e = pois.tvisit(j);
            if vq < limiar, tv_e = tv_e + (1 - vq) * atraso_max; end
            if (tempo_total + td_matrix(poi_at, j) + tv_e) > tempo_max, continue; end
            probs(c) = (tau(poi_at, j)^alfa) * (eta_matrix(poi_at, j)^beta);
        end
        if sum(probs) == 0, break; end
        prox = cand(randsample(length(cand), 1, true, probs/sum(probs)));
        vq_p = 0; if isKey(qoe_map, pois.qoeid(prox)), vq_p = qoe_map(pois.qoeid(prox)); end
        tv_p = pois.tvisit(prox);
        if vq_p < limiar, tv_p = tv_p + (1 - vq_p) * atraso_max; end
        tempo_total = tempo_total + td_matrix(poi_at, prox) + tv_p;
        rota = [rota, prox]; visitados(prox) = true;
        if isKey(poipokemon, pois.pkid(prox)), pontuacao_total = pontuacao_total + poipokemon(pois.pkid(prox)); end
        qoe_total = qoe_total + vq_p; poi_at = prox;
    end
end
