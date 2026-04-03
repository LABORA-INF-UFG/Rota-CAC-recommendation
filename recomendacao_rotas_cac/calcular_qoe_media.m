function qoe_media = calcular_qoe_media(rota, qoe_table)
    m = length(rota);
    if m == 0
        qoe_media = 0;
        return;
    end
    % Pega a última coluna da tabela de QoE, assumindo que são os valores
    dados_matriz = table2array(qoe_table);
    coluna_valor = size(dados_matriz, 2); 
    valores_extraidos = dados_matriz(rota, coluna_valor);
    qoe_media = mean(valores_extraidos);
end