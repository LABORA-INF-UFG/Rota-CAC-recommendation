% Script para calcular a CDF da coluna valor_qoe
clc;

% 1. Carregar o dataset
qoe_table = readtable('qoe20_normalizado.csv');

% 2. Extrair especificamente a coluna desejada
% Usando o nome exato para evitar confusão com IDs ou outras métricas
qoe_normalizada = qoe_table.valor_qoe;

% 3. Calcular a CDF Empírica
[f, x] = ecdf(qoe_normalizada);

% 4. Plotagem
figure('Name', 'Análise de QoE Normalizada', 'Color', 'w');
stairs(x, f, 'LineWidth', 2.5, 'Color', [0 0.5 0]); % Verde escuro para QoE

% Configuração dos Eixos (Garantindo escala 0 a 1)
grid on;
xlim([0 1]); 
ylim([0 1.05]);

% Títulos e Rótulos
title('Função de Distribuição Acumulada (CDF) - valor\_qoe');
xlabel('Qualidade de Experiência (Normalizada 0-1)');
ylabel('P(X \leq x)');

% Adicionar linha do limiar de 0.2 definido no seu Main
hold on;
xline(0.2, 'r--', 'Limiar RecRota (0.2)', 'LabelVerticalAlignment', 'bottom');
hold off;

% Exibir conferência no Command Window
fprintf('Estatística da Coluna: valor_qoe\n');
fprintf('Média: %.4f\n', mean(qoe_normalizada));
fprintf('Percentual abaixo do limiar (0.2): %.2f%%\n', sum(qoe_normalizada <= 0.2)/length(qoe_normalizada)*100);
