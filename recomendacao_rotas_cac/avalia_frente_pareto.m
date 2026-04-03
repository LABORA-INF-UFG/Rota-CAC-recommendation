% Plota a Frente de Pareto com os resultados médios das 30 execuções

% Dados médios do console:
media_pontos = [2.2687, 3.9158, 2.8029, 4.3693]; 
media_qoe    = [1.6628, 3.1206, 3.5162, 2.4136]; 
metodos = {'Greedy', 'ACO 0.5', 'ACO QoE', 'ACO Desemp'};

figure('Name', 'Analise de Trade-off (Frente de Pareto)', 'Color', 'w');
hold on;
% Plota os pontos
scatter(media_pontos, media_qoe, 100, 'filled', 'MarkerFaceColor', [0 0.4470 0.7410]);

% Adiciona os rótulos aos pontos para fácil identificação
text(media_pontos + 0.05, media_qoe, metodos, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');

title('Frente de Pareto: Trade-off Pontos vs QoE');
xlabel('Média de Pontos Pokemon (Maximize ->)');
ylabel('Média de QoE Total (Maximize ->)');
grid on;
box on;
hold off;
