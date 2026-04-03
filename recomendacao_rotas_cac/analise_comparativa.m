% analise_comparativa.m
% Objetivo: Rodar 30 simulações para 2 cenários e plotar comparativo 

%%%compara com e sem penalidade 

%clc; clear;

% --- 1. Leitura dos dados (precisa estar na mesma pasta que os CSVs) ---
usuarios = readtable('usuarios_cdf.csv');
pois = readtable('poi.csv');
pokemons = readtable('pokemon_normalizado.csv');
custos = readtable('custo.csv');
qoe = readtable('qoe_normalizado.csv');

% --- 2. Parâmetros Fixos ---
userid = 1;
budget_tempo = usuarios.budget_tempo(userid);
poiid_inicio = usuarios.poiid_inicio(userid);
limiar = 0.2;
num_formigas = 20; num_iter = 50; alfa = 1; beta = 3; rho = 0.1; etas = [0.5, 0, 1];
%titulos_aco = ["RotaCAC_0.5", "RotaCAC_0", "RotaCAC_1"];
titulos_aco = ["RotaCAC-0.5", "RotaCAC-1", "RotaCAC-0"];


num_execucoes = 30;

fprintf('-----Análise Comparativa de Rotas sem/com Penalidades...\n');

% --- 3. Configurações dos Cenários ---
ATRASO_CENARIO_1 = 0;   % Sem penalidade (Baseline)
ATRASO_CENARIO_2 = 60; % Com penalidade (Exemplo de 5 minutos extras)

% --- 4. Estruturas para Armazenamento ---
% Colunas: [Greedy, ACO_05, ACO_0, ACO_1]
resC1_pontos = zeros(num_execucoes, 4); resC1_qoe = zeros(num_execucoes, 4); resC1_tamanhos = zeros(num_execucoes, 4);
resC2_pontos = zeros(num_execucoes, 4); resC2_qoe = zeros(num_execucoes, 4); resC2_tamanhos = zeros(num_execucoes, 4);

fprintf('Iniciando 30 execuções para ambos os cenários...\n');

for i = 1:num_execucoes
    fprintf('Rodada %d/30...\n', i);  
    rng(i); % Garante que cada rodada seja única

    % --- Roda Cenário 1: Sem Penalidade (atraso_max = 0) ---
    [rota_g, p_g, q_g, ~] = calcular_rota_greedy(userid, budget_tempo, pois, pokemons, custos, qoe, poiid_inicio, limiar, ATRASO_CENARIO_1);
    resC1_pontos(i, 1) = p_g; resC1_qoe(i, 1) = q_g; resC1_tamanhos(i, 1) = length(rota_g);
    for j = 1:length(etas)
        [r_aco, p_aco, q_aco, ~] = calcular_rota_aco(userid, budget_tempo, pois, pokemons, custos, qoe, poiid_inicio, etas(j), num_formigas, num_iter, alfa, beta, rho, limiar, ATRASO_CENARIO_1);
        resC1_pontos(i, j+1) = p_aco; resC1_qoe(i, j+1) = q_aco; resC1_tamanhos(i, j+1) = length(r_aco);
    end

    % --- Roda Cenário 2: Com Penalidade (atraso_max = 300) ---
    [rota_g, p_g, q_g, ~] = calcular_rota_greedy(userid, budget_tempo, pois, pokemons, custos, qoe, poiid_inicio, limiar, ATRASO_CENARIO_2);
    resC2_pontos(i, 1) = p_g; resC2_qoe(i, 1) = q_g; resC2_tamanhos(i, 1) = length(rota_g);
    for j = 1:length(etas)
        [r_aco, p_aco, q_aco, ~] = calcular_rota_aco(userid, budget_tempo, pois, pokemons, custos, qoe, poiid_inicio, etas(j), num_formigas, num_iter, alfa, beta, rho, limiar, ATRASO_CENARIO_2);
        resC2_pontos(i, j+1) = p_aco; resC2_qoe(i, j+1) = q_aco; resC2_tamanhos(i, j+1) = length(r_aco);
    end
end

fprintf('Execuções concluídas. Gerando gráficos...\n');

% --- 5. Cálculo das Médias, STD e IC 95% ---
N = num_execucoes;
t_score_95 = 2.045; % t-score para N-1=29 graus de liberdade, alpha=0.05

% Médias
mediaC1_p = mean(resC1_pontos); mediaC1_q = mean(resC1_qoe); mediaC1_t = mean(resC1_tamanhos);
mediaC2_p = mean(resC2_pontos); mediaC2_q = mean(resC2_qoe); mediaC2_t = mean(resC2_tamanhos);

% Intervalos de Confiança (Erro = t_score * STD / sqrt(N))
erroC1_p = t_score_95 * std(resC1_pontos) / sqrt(N); erroC1_q = t_score_95 * std(resC1_qoe) / sqrt(N); erroC1_t = t_score_95 * std(resC1_tamanhos) / sqrt(N);
erroC2_p = t_score_95 * std(resC2_pontos) / sqrt(N); erroC2_q = t_score_95 * std(resC2_qoe) / sqrt(N); erroC2_t = t_score_95 * std(resC2_tamanhos) / sqrt(N);


% --- 6. Geração dos Subplots Lado a Lado ---
%metodos_nomes = {'Greedy', 'RotaCAC_0.5.', 'RotaCAC_0', 'RotaCAC_1'};
metodos_nomes = {'Greedy', 'RotaCAC-0.5.', 'RotaCAC-1', 'RotaCAC-0'};

figure('Name', 'Análise Comparativa SBRC: Impacto da Penalidade', 'Color', 'w', 'Position', [100, 100, 1200, 400]);

% Subplot 1: Score Total (Pontuação Total)
subplot(1, 3, 1);
data_pontos = [mediaC1_p; mediaC2_p]';
erro_pontos = [erroC1_p; erroC2_p]';
bar_handle = bar(data_pontos);
set(gca, 'XTickLabel', metodos_nomes);
ylabel('Pontuação Total Média');
% title('Scores Totais'); % 
legend({'Cenário 1 (atraso = 0)', 'Cenário 2 (atraso = 60)'}, ...
       'Location', 'northwest', 'Orientation', 'horizontal');
%legend({'Cenário 1 (atraso = 0)', 'Cenário 2 (atraso = 60)'}, 'Location', 'northwest');
grid on;
hold on;
% Adiciona Error Bars

hold off;


% Subplot 2: QoE Total
subplot(1, 3, 2);
data_qoe = [mediaC1_q; mediaC2_q]';
erro_qoe = [erroC1_q; erroC2_q]';
bar_handle = bar(data_qoe);
set(gca, 'XTickLabel', metodos_nomes);
ylabel('$\mathcal{Q}_{media}^{CAC}$ total', 'Interpreter', 'latex', 'FontSize', 14);
%ylabel('QoE Total Média');
% title('QoE Total'); % 
grid on;
hold on;

hold off;

% Subplot 3: Tamanho da Rota
subplot(1, 3, 3);
data_tamanhos = [mediaC1_t; mediaC2_t]';
erro_tamanhos = [erroC1_t; erroC2_t]';
bar_handle = bar(data_tamanhos);
set(gca, 'XTickLabel', metodos_nomes);
ylabel('Tamanho da Rota Médio (# POIs)');
% title('Tamanho da Rota'); % 
grid on;
hold on;

hold off;
