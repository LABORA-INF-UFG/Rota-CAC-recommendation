% analise_comparativa_sbrc_simples.m
%clc; clear;

% --- 1. Leitura dos dados ---
usuarios = readtable('usuarios_cdf.csv');
pois = readtable('poi.csv');
pokemons = readtable('pokemon_normalizado.csv');
custos = readtable('custo.csv');
qoe = readtable('qoe_normalizado.csv');


fprintf('-----Análise de Pontuação ...\n');

% --- 2. Parâmetros Fixos ---
userid = 1;
budget_tempo = usuarios.budget_tempo(userid);
poiid_inicio = usuarios.poiid_inicio(userid);
limiar = 0.2;
num_formigas = 20; num_iter = 50; alfa = 1; beta = 3; rho = 0.1; etas = [0.5, 0, 1];
%metodos_nomes = {'Greedy', 'RotaCAC_{0.5}', 'RotaCAC_{0}', 'RotaCAC_{1}'};
metodos_nomes = {'Greedy', 'RotaCAC-0.5', 'RotaCAC-1', 'RotaCAC-0'};


num_execucoes = 30; 

% --- DEFINIÇÃO DE CORES POR ALGORITMO ---
% Linha 1: Greedy (Azul) | Linha 2: ACO 0.5 (Verde) | Linha 3: ACO 0 (Laranja) | Linha 4: ACO 1 (Roxo)
cores = [
    0.00, 0.45, 0.74; % Azul
    0.47, 0.67, 0.19; % Verde
    0.85, 0.33, 0.10; % Laranja
    0.49, 0.18, 0.56  % Roxo
];

% --- 3. Configuração do Cenário ---
ATRASO_MAX = 60; 

% --- 4. Estruturas para Armazenamento ---
res_pontos = zeros(num_execucoes, 4); 
res_qoe = zeros(num_execucoes, 4); 
res_tamanhos = zeros(num_execucoes, 4);

fprintf('Iniciando 30 execuções para análise de pontos...\n');

for i = 1:num_execucoes
    fprintf('Rodada %d/30...\n', i);
    rng(i); 
    [rota_g, p_g, q_g, ~] = calcular_rota_greedy(userid, budget_tempo, pois, pokemons, custos, qoe, poiid_inicio, limiar, ATRASO_MAX);
    res_pontos(i, 1) = p_g; res_qoe(i, 1) = q_g; res_tamanhos(i, 1) = length(rota_g);
    
    for j = 1:length(etas)
        [r_aco, p_aco, q_aco, ~] = calcular_rota_aco(userid, budget_tempo, pois, pokemons, custos, qoe, poiid_inicio, etas(j), num_formigas, num_iter, alfa, beta, rho, limiar, ATRASO_MAX);
        res_pontos(i, j+1) = p_aco; res_qoe(i, j+1) = q_aco; res_tamanhos(i, j+1) = length(r_aco);
    end
end

media_p = mean(res_pontos); media_q = mean(res_qoe); media_t = mean(res_tamanhos);

% --- 6. Geração dos Gráficos com Cores por Algoritmo ---
figure('Name', 'Resultados RecRota_QoeCAC', 'Color', 'w', 'Position', [100, 100, 1200, 400]);

% Subplot 1: Score Total
subplot(1, 3, 1);
b1 = bar(media_p, 'FaceColor', 'flat');
b1.CData = cores; % Aplica as cores específicas para cada barra
set(gca, 'XTickLabel', metodos_nomes);
ylabel('Pontuação Total Média');
grid on;

% Subplot 2: QoE Total
subplot(1, 3, 2);
b2 = bar(media_q, 'FaceColor', 'flat');
b2.CData = cores; % Mantém a consistência das cores
set(gca, 'XTickLabel', metodos_nomes);
%ylabel('QoE Total Média');
ylabel('$\mathcal{Q}_{media}^{CAC}$ total', 'Interpreter', 'latex', 'FontSize', 14);
grid on;

% Subplot 3: Tamanho da Rota
subplot(1, 3, 3);
b3 = bar(media_t, 'FaceColor', 'flat');
b3.CData = cores; % Mantém a consistência das cores
set(gca, 'XTickLabel', metodos_nomes);
ylabel('Nº Médio de POIs');
grid on;
