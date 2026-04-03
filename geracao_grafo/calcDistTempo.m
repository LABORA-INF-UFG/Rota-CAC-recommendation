function [dist_m, tempo_s] = calcDistTempo(lat1, lon1, lat2, lon2, velocidade_kmh)
    % Calcula distância (m) e tempo (s) entre dois pontos dados lat/lon
    % velocidade_kmh - velocidade média em km/h (ex.: 5 para pedestre)
    
    if nargin < 5
        velocidade_kmh = 5; % valor padrão se não informado
    end
    
    % Distância geodésica (metros)
    dist_m = distance(lat1, lon1, lat2, lon2, wgs84Ellipsoid) * 1000;
    
    % Tempo em segundos
    tempo_s = dist_m / (velocidade_kmh * 1000 / 3600);
end
