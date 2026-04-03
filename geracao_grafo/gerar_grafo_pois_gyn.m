% Autora: Rosana de Oliveira Santos
% gera_mapa_POIs.m
% Extrai POIs no Setor Universitário de Goiânia e gera:
% grafo_pois_gyn.csv e custo.csv


clc; clear; close all;

% === Parâmetros ===
velocidade_pedestre = 5; %w km/h
% lat_sul   = -16.6992; 
% lon_oeste = -49.2718; 
% lat_norte = -16.6788; 
% lon_leste = -49.2398; 

lat_sul   = -16.7100;  
lon_oeste = -49.2850; 
lat_norte = -16.6700; 
lon_leste = -49.2300; 

% === Monta consulta Overpass API ===
query = sprintf([ ...
    '[out:json][timeout:200];' ...
    '(' ...
    'node["shop"="supermarket"](%f,%f,%f,%f);' ...
    'node["leisure"="park"](%f,%f,%f,%f);' ...
    'node["amenity"="place_of_worship"](%f,%f,%f,%f);' ...
    'node["shop"](%f,%f,%f,%f);' ...
    'node["tourism"](%f,%f,%f,%f);' ...
    'node["amenity"="university"](%f,%f,%f,%f);' ...
    'node["amenity"="school"](%f,%f,%f,%f);' ...
    ');' ...
    'out geom tags;'], ...
    lat_sul, lon_oeste, lat_norte, lon_leste, ...
    lat_sul, lon_oeste, lat_norte, lon_leste, ...
    lat_sul, lon_oeste, lat_norte, lon_leste, ...
    lat_sul, lon_oeste, lat_norte, lon_leste, ...
    lat_sul, lon_oeste, lat_norte, lon_leste, ...
    lat_sul, lon_oeste, lat_norte, lon_leste, ...
    lat_sul, lon_oeste, lat_norte, lon_leste);

% === Consulta API ===
% === Consulta API com retry ===
url_base = 'https://overpass-api.de/api/interpreter?data=';
fullUrl = [url_base urlencode(query)];
options = weboptions('Timeout', 200);

maxTentativas = 3;
data = [];

for tentativa = 1:maxTentativas
    try
        fprintf('1. Consultando Overpass API (tentativa %d/%d)...\n', tentativa, maxTentativas);
        data = webread(fullUrl, options);
        fprintf('Consulta concluída com sucesso.\n');
        break; % saiu sem erro, para o loop
    catch e
        fprintf('Erro na tentativa %d: %s\n', tentativa, e.message);
        if tentativa < maxTentativas
            pausaSeg = 15 * tentativa; % espera 15s, 30s...
            fprintf('Aguardando %ds antes de tentar novamente...\n', pausaSeg);
            pause(pausaSeg);
        else
            error('Falha após %d tentativas. Tente mais tarde.', maxTentativas);
        end
    end
end

fprintf('2. Gerando grafo de POIs\n');
% === Extrai POIs ===
n = length(data.elements);
POIs = table('Size', [n 4], ...
             'VariableTypes', {'double','string','double','double'}, ...
             'VariableNames', {'poiid','Nome','Latitude','Longitude'});

for i = 1:n
    if isfield(data.elements(i), 'lat') && isfield(data.elements(i), 'lon')
        lat = data.elements(i).lat;
        lon = data.elements(i).lon;
        if isfield(data.elements(i), 'tags') && isfield(data.elements(i).tags, 'name')
            nome = string(data.elements(i).tags.name);
        else
            nome = "";
        end
        POIs.poiid(i) = i;
        POIs.Nome(i) = nome;
        POIs.Latitude(i) = lat;
        POIs.Longitude(i) = lon;
    end
end

POIs = unique(POIs);
writetable(POIs, 'grafo_pois_gyn.csv');

fprintf('- grafo_pois_gyn.csv gerado (%d POIs)\n', height(POIs));
fprintf('3. Gerando custos entre POIs\n');
% === Calculando custos entre POIs ===
nPOI = height(POIs);
Arestas = table('Size', [0 7], ...
    'VariableTypes', {'double','double','double','double','double','double','double'}, ...
    'VariableNames', {'poi_origem','poi_destino','Lat_Origem','Lon_Origem','Distancia_m','Tempo_s','Tempo_min'});

wgs84 = wgs84Ellipsoid('meters');
for i = 1:nPOI
    for j = i+1:nPOI
        % Distância em metros
        dist_m = deg2km(distance(POIs.Latitude(i), POIs.Longitude(i), POIs.Latitude(j), POIs.Longitude(j), wgs84 ));

        % Tempo em segundos (velocidade -> m/s)
        tempo_s = dist_m / (velocidade_pedestre * 1000 / 3600);
        tempo_min = tempo_s / 60;

        % Arredonda
        dist_m = round(dist_m, 2);
        tempo_s = round(tempo_s, 2);
        tempo_min = round(tempo_min, 2);

        % Adiciona linha
        Arestas = [Arestas;
                   {POIs.poiid(i), POIs.poiid(j), POIs.Latitude(i), POIs.Longitude(i), dist_m, tempo_s, tempo_min}];
    end
end


% === Gera custo.csv com segundos e minutos ===
Custo = Arestas(:, {'poi_origem', 'poi_destino', 'Tempo_s', 'Tempo_min'});
Custo.Properties.VariableNames = {'poi_origem', 'poi_destino', 'tdeslocamento_s', 'tdeslocamento_min'};
writetable(Custo, 'custo.csv');
fprintf('- custo.csv gerado (%d linhas)\n', height(Custo));

