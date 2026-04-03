% avalia_cdf_qoe.m - CORRIGIDO (Incluindo Parâmetros do Main)
% Objetivo: Rodar 30 simulações e plotar a Função de Distribuição Cumulativa (CDF) da QoE

clear; % Limpa o workspace

% --- 1. CARGA DE DADOS ---
usuarios = readtable('usuarios_cdf.csv');
pois = readtable('poi20.csv');
pokemons = readtable('pokemon_normalizado.csv');
qoe = readtable('qoe20_normalizado.csv');
custos = readtable('custo20.csv');

% --- 2. PARÂMETROS DO EXPERIMENTO (Copiados do main_pokemon.m) ---
userid = 1; 
budget_tempo = usuarios.budget_tempo(userid);
poiid_inicio = usuarios.poiid_inicio(userid);
num_execucoes = 30;

% Adicionando parâmetros que estavam faltando nas chamadas de função:
LIMIAR_FIXO = 0.2; 
ATRASO_FIXO = 60;
% Parâmetros do ACO
num_formigas = 20; num_iter = 50; alfa = 1; beta = 3; rho = 0.1;

% Matrizes para armazenar SOMENTE a QoE Total de cada rodada
res_qoe_g    = zeros(num_execucoes, 1);
res_qoe_aco05 = zeros(num_execucoes, 1);
res_qoe_aco0  = zeros(num_execucoes, 1);
res_qoe_aco1  = zeros(num_execucoes, 1);

fprintf('Iniciando 30 execuções para análise de CDF...\n');

% --- 3. LOOP DE SIMULAÇÃO ---
for i = 1:num_execucoes
    rng(i); % Garante repetibilidade, se necessário
    
    % Chamadas CORRIGIDAS: agora incluem limiar e atraso fixos, e parâmetros ACO
    [~, ~, q_g, ~] = calcular_rota_greedy(userid, budget_tempo, pois, pokemons, custos, qoe, poiid_inicio, LIMIAR_FIXO, ATRASO_FIXO);
    [~, ~, q_aco05, ~] = calcular_rota_aco(userid, budget_tempo, pois, pokemons, custos, qoe, poiid_inicio, 0.5, num_formigas, num_iter, alfa, beta, rho, LIMIAR_FIXO, ATRASO_FIXO);
    [~, ~, q_aco0, ~] = calcular_rota_aco(userid, budget_tempo, pois, pokemons, custos, qoe, poiid_inicio, 0, num_formigas, num_iter, alfa, beta, rho, LIMIAR_FIXO, ATRASO_FIXO);
    [~, ~, q_aco1, ~] = calcular_rota_aco(userid, budget_tempo, pois, pokemons, custos, qoe, poiid_inicio, 1, num_formigas, num_iter, alfa, beta, rho, LIMIAR_FIXO, ATRASO_FIXO);
    
    res_qoe_g(i)    = q_g;
    res_qoe_aco05(i) = q_aco05;
    res_qoe_aco0(i)  = q_aco0;
    res_qoe_aco1(i)  = q_aco1;
end

% --- 4. CÁLCULO DOS DADOS DA CDF (Usando ECDF com saídas F e X) ---
[f_g, x_g] = ecdf(res_qoe_g);
[f_05, x_05] = ecdf(res_qoe_aco05);
[f_0, x_0] = ecdf(res_qoe_aco0);
[f_1, x_1] = ecdf(res_qoe_aco1);

% --- 5. GERAÇÃO DO GRÁFICO MANUAL COM PLOT() ---
figure('Name', 'Analise 2: CDF da QoE Total', 'Color', 'w');
hold on;
metodos = {'Greedy', 'ACO 0.5', 'ACO QoE', 'ACO Desemp'};

plot(x_g, f_g, 'Color', [0.5 0.5 0.5], 'LineWidth', 2); % Cinza
plot(x_05, f_05, 'Color', 'b', 'LineWidth', 2);           % Azul
plot(x_0, f_0, 'Color', 'g', 'LineWidth', 2);            % Verde
plot(x_1, f_1, 'Color', 'r', 'LineWidth', 2);            % Vermelho

grid on;
% Adiciona a legenda manualmente para garantir compatabilidade
legend(metodos, 'Location', 'SouthEast');
title('Função de Distribuição Cumulativa (CDF) da QoE Total');
xlabel('QoE Total (Valor)');
ylabel('Probabilidade Acumulada F(x)');
hold off;

fprintf('Análise de CDF concluída. Gráfico gerado.\n');


