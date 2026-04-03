% main_pokemon.m - Rosana 03/01/26
% Sistema RecRota_QoeCAC
clc; clear;

% --- Leitura dos dados ---
usuarios = readtable('usuarios_cdf.csv');
pois = readtable('poi.csv');
pokemons = readtable('pokemon_normalizado.csv');
custos = readtable('custo.csv');
qoe = readtable('qoe_normalizado.csv');

% --- Parâmetros Gerais (Centralizados) ---
userid = 1;
budget_tempo = usuarios.budget_tempo(userid);
poiid_inicio = usuarios.poiid_inicio(userid);
limiar = 0.2;
atraso_maximo = 60;

% --- Parâmetros Específicos do ACO ---
num_formigas = 20;
num_iter = 50;
alfa = 1;
beta = 3;
rho = 0.1;

% Exibição dos Parâmetros de Entrada (Conforme solicitado)
fprintf('======================================================\n');
fprintf('       CONFIGURAÇÕES DO SISTEMA: RecRota_QoeCAC\n');
fprintf('======================================================\n');
fprintf('User ID: %d | Budget: %.2f s | POI Inicial: %d\n', userid, budget_tempo, poiid_inicio);
fprintf('Limiar QoE: %.2f | Penalidade: %d s\n', limiar, atraso_maximo);
fprintf('ACO: %d formigas, %d iterações, Rho: %.2f, Alfa: %d, Beta: %d\n', num_formigas, num_iter, rho, alfa, beta);
fprintf('------------------------------------------------------\n\n');

fprintf('======================================================\n');
fprintf('       Teste básico de execução\n');
fprintf('======================================================\n');
% --- Execução Greedy (Baseline) ---
tic;
[rota_g, total_pontos_g, total_qoe_g, tempo_total_g] = calcular_rota_greedy(userid, budget_tempo, pois, pokemons, custos, qoe, poiid_inicio, limiar, atraso_maximo);
tempo_execucao_g = toc;

disp("--- Resultado Heurística Greedy Gulosa ---");
disp("Rota: " + mat2str(rota_g));
disp("Pontos Totais: " + total_pontos_g + " | QoE Total: " + total_qoe_g);
disp("Tempo Total Rota: " + tempo_total_g + "s | Execução: " + tempo_execucao_g + "s");

% --- Execução ACO Variantes ---
etas = [0.5, 0, 1];
titulos = ["ACO Equilibrado", "ACO Foco QoE", "ACO Foco Desempenho"];
res_tamanhos = zeros(1, length(etas));
res_pontos = zeros(1, length(etas));
res_qoe = zeros(1, length(etas));

for i = 1:length(etas)
    eta_atual = etas(i);
    tic;
    [r_aco, p_aco, q_aco, t_aco] = calcular_rota_aco(userid, budget_tempo, pois, pokemons, custos, qoe, poiid_inicio, eta_atual, num_formigas, num_iter, alfa, beta, rho, limiar, atraso_maximo);
    tempo_aco = toc;
    
    % Armazenando para a análise comparativa
    res_tamanhos(i) = length(r_aco);
    res_pontos(i) = p_aco;
    res_qoe(i) = q_aco;
    
    fprintf("\n--- %s (eta=%.1f) ---\n", titulos(i), eta_atual);
    disp("Rota: " + mat2str(r_aco));
    disp("Pontos: " + p_aco + " | QoE: " + q_aco);
    disp("Tempo Total Rota: " + t_aco + "s | Execução: " + tempo_aco + "s");
end

% --- ANÁLISE COMPARATIVA FINAL ---
fprintf('\n\n======================================================\n');
fprintf('           RESUMO COMPARATIVO DE ROTAS\n');
fprintf('======================================================\n');
fprintf('%-25s || %-15s || %-10s\n', 'Algoritmo', 'Tamanho Rota', 'Pontos');
fprintf('------------------------------------------------------\n');
fprintf('%-25s || %-15d || %-10.2f\n', 'Greedy (Baseline)', length(rota_g), total_pontos_g);

for i = 1:length(etas)
    fprintf('%-25s || %-15d || %-10.2f\n', titulos(i), res_tamanhos(i), res_pontos(i));
end
fprintf('======================================================\n\n\n');