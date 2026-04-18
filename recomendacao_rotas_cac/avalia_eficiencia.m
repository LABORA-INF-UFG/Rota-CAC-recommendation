% avalia_eficiencia.m
% Objetivo: Rodar 30 simulações e calcular a eficiência da QoE (Valor/Tempo)

% OBS: Este script assume que você rodou o script main_todos.m ANTES, 
% e que as variáveis globais (userid, budget_tempo, pois, etc.) 
% estão disponíveis no Workspace do MATLAB.

if ~exist('userid', 'var') || ~exist('num_execucoes', 'var')
    error('Por favor, rode o script main_todos.m primeiro para carregar os parametros.');
end

%num_execucoes = 30;  %% se quiser explicitar o numero de conexoes

% Matrizes para armazenar os resultados de cada rodada
res_pontos = zeros(num_execucoes, 4); % [Greedy, ACO_05, ACO_0, ACO_1]
res_qoe    = zeros(num_execucoes, 4);
res_tempo  = zeros(num_execucoes, 4);
fprintf('-----Análise de eficiência da QoE...\n');
fprintf('Iniciando %d execuções para análise de eficiência da QoE e de Pontos...\n', num_execucoes);

for i = 1:num_execucoes
    %fprintf('Rodada %d/30...\n', i);
    fprintf('Rodada %d/%d...\n', i, num_execucoes);

    % 1. Rodar Greedy (AGORA PASSANDO limiar e atraso_maximo)
    [~, p_g, q_g, t_g] = calcular_rota_greedy(userid, budget_tempo, pois, pokemons, custos, qoe, poiid_inicio, limiar, atraso_maximo);
    
    % 2. Rodar ACO Equilibrado (eta=0.5) - Passando todos os 15 parametros
    [~, p_aco05, q_aco05, t_aco05] = calcular_rota_aco(userid, budget_tempo, pois, pokemons, custos, qoe, poiid_inicio, 0.5, num_formigas, num_iter, alfa, beta, rho, limiar, atraso_maximo);
    
    % 3. Rodar ACO QoE (eta=0)
    [~, p_aco0, q_aco0, t_aco0] = calcular_rota_aco(userid, budget_tempo, pois, pokemons, custos, qoe, poiid_inicio, 0, num_formigas, num_iter, alfa, beta, rho, limiar, atraso_maximo);
    
    % 4. Rodar ACO Desempenho (eta=1)
    [~, p_aco1, q_aco1, t_aco1] = calcular_rota_aco(userid, budget_tempo, pois, pokemons, custos, qoe, poiid_inicio, 1, num_formigas, num_iter, alfa, beta, rho, limiar, atraso_maximo);
    
    % Armazenar resultados
%     res_pontos(i, :) = [p_g, p_aco05, p_aco0, p_aco1];
%     res_qoe(i, :)    = [q_g, q_aco05, q_aco0, q_aco1];
%     res_tempo(i, :)  = [t_g, t_aco05, t_aco0, t_aco1];

    res_pontos(i, :) = [p_g, p_aco05, p_aco1, p_aco0];
    res_qoe(i, :)    = [q_g, q_aco05, q_aco1, q_aco0];
    res_tempo(i, :)  = [t_g, t_aco05, t_aco1, t_aco0];
end

% --- CÁLCULO DA EFICIÊNCIA (Média das 30 rodadas) ---
efic_qoe = mean(res_qoe ./ res_tempo);

efic_pontos = mean(res_pontos ./ res_tempo);

% --- GERAÇÃO DO GRÁFICO (NOMES E CORES CUSTOMIZADOS) ---
%metodos = {'Greedy', 'RotaCAC-0.5', 'RotaCAC-0', 'RotaCAC-1'};
%os nomes dos metodos já estao de acordo com o eta (eta
metodos = {'Greedy', 'RotaCAC-0.5', 'RotaCAC-1', 'RotaCAC-0'};


figure('Name', 'Análise de Eficiência de QoE e de Pontos)', 'Color', 'w');

% Definição das cores em RGB [R G B]
% [Azul, Vermelho, Cinza, Laranja] -> Mapeado para as 4 barras
cores_custom = [
    0.8 0.8 0.8; % Greedy: Cinza claro
    0.3 0.6 1.0; % ACO Equi: Azul claro
    0.0 0.0 0.6; % ACO QoE: Azul escuro
    0.0 0.0 0.0  % ACO Desempenho: Preto
];
subplot(1,2,1);
b1 = bar(efic_qoe, 'FaceColor', 'flat');
% Aplica as cores customizadas
for k = 1:4
    b1.CData(k, :) = cores_custom(k, :);
end
%title('Eficiência de QoE (QoE por Segundo)');
%ylabel('QoE / Tempo Total');
%ylabel('$\mathcal{Q}^{CAC} / Tempo Total$', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('$\mathcal{E}_{{\mathcal{Q}^{CAC}}}$', 'Interpreter', 'latex', 'FontSize', 12);

set(gca, 'XTickLabel', metodos);
grid on;

subplot(1,2,2);
b2 = bar(efic_pontos, 'FaceColor', 'flat');
% Aplica as cores customizadas
for k = 1:4
    b2.CData(k, :) = cores_custom(k, :);
end
%title('Eficiência de Pontos (Pontos por Segundo)');
%ylabel('Pontos / Tempo Total');
ylabel('$\mathcal{E}_{Pontos}$', 'Interpreter', 'latex', 'FontSize', 12);

set(gca, 'XTickLabel', metodos);
grid on;

