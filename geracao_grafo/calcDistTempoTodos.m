function resultados = calcDistTempoTodos(nomeArquivoCSV, velocidade_kmh)
    % Calcula distância e tempo entre todos os pares distintos de POIs de um CSV
    % nomeArquivoCSV - caminho do CSV com colunas: Latitude, Longitude
    % velocidade_kmh - velocidade média em km/h
    
    if nargin < 2
        velocidade_kmh = 5; % padrão se não informado
    end
    
    % Lê o CSV
    T = readtable(nomeArquivoCSV);
    
    if ~all(ismember({'Latitude', 'Longitude'}, T.Properties.VariableNames))
        error('O arquivo CSV deve conter colunas "Latitude" e "Longitude"');
    end
    
    N = height(T);
    idx = 1;
    resultados = table('Size', [0 6], ...
        'VariableTypes', {'double','double','double','double','double','double'}, ...
        'VariableNames', {'Lat_Origem','Lon_Origem','Lat_Destino','Lon_Destino','Distancia_m','Tempo_s'});
    
    % Percorre pares distintos (i < j)
    for i = 1:N
        for j = i+1:N
            [dist_m, tempo_s] = calcDistTempo(T.Latitude(i), T.Longitude(i), ...
                                              T.Latitude(j), T.Longitude(j), ...
                                              velocidade_kmh);
            resultados(idx,:) = {T.Latitude(i), T.Longitude(i), ...
                                 T.Latitude(j), T.Longitude(j), ...
                                 dist_m, tempo_s};
            idx = idx + 1;
        end
    end
end



