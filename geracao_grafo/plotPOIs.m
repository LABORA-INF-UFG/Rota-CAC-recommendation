function plotPOIs(nomeArquivoCSV, conectar)
    % plotPOIs - Plota os POIs de um arquivo CSV em um mapa
    %
    % nomeArquivoCSV : caminho do arquivo CSV contendo colunas Latitude e Longitude
    % conectar       : true/false para desenhar linhas entre todos os pontos
    
    if nargin < 2
        conectar = false; % padrão: não conecta pontos
    end
    
    % Lê o CSV
    T = readtable(nomeArquivoCSV);
        
    if ~all(ismember({'Latitude','Longitude'}, T.Properties.VariableNames))
        error('O arquivo CSV deve conter colunas "Latitude" e "Longitude".');
    end
    
    % Criar figura
    figure;
    
    % Plota pontos
    geoscatter(T.Latitude, T.Longitude, 50, 'filled', 'MarkerFaceColor','r');
    geobasemap streets; % fundo de ruas
    title('Mapa de POIs');
    
    % Anota IDs
    if ismember('poiid', T.Properties.VariableNames)
        labels = string(T.poiid);
    else
        labels = string((1:height(T))');
    end
    text(T.Longitude, T.Latitude, labels, 'FontSize',8, 'Color','b');
    
    % Conecta pontos se solicitado
    if conectar
        hold on;
        for i = 1:height(T)
            for j = i+1:height(T)
                geoplot([T.Latitude(i), T.Latitude(j)], ...
                        [T.Longitude(i), T.Longitude(j)], 'b-');
            end
        end
        hold off;
    end
end
