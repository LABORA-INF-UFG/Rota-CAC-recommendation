function resultado(metodo, userid, budget_tempo, rota, total_pontos, total_qoe, tempo_total, tempo_execucao)
%function resultado(metodo, userid, budget_tempo, rota, total_pontos, total_qoe, tempo_total, tempo_execucao, ndcg_val, k)
    % Função para imprimir os resultados da simulação
    
    fprintf('\n=== Resultados ===\n');
    fprintf('Metodologia: %s\n', metodo);
    fprintf('Usuário ID: %d\n', userid);
    fprintf('Budget de tempo: %.2f segundos\n', budget_tempo);
    fprintf('Rota recomendada: %s\n', mat2str(rota));
    fprintf('Total Pontos do usuário: %.2f\n', total_pontos);
    fprintf('Total QoE da rota: %.2f\n', total_qoe);
    fprintf('Score Total: %.2f\n', total_qoe + total_pontos);
    fprintf('Tempo total gasto pela rota: %.2f segundos\n', tempo_total);
    fprintf('Tempo de execução do algoritmo: %.4f segundos\n', tempo_execucao);
   % fprintf('Avaliação da rota usando NDCG@%d: %.4f\n', k, ndcg_val);
end
