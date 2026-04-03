% Autora: Rosana de Oliveira Santos
% Distribui pokemons pelos pois 
%Etapa final do pre-processamento

% gera_poi_final.m
%clc; clear;

fprintf('4. Distribuir Pokémons e efetuar carga de QoE-CAC nos POIs\n');
% === 1. Carregar Arquivos ===
Pois_Gyn = readtable('grafo_pois_gyn.csv'); 
Pks = readtable('pokemon.csv');
QoEs = readtable('qoecac.csv');

% === 2. Parâmetros ===
num_pois = height(Pois_Gyn);
num_pks = height(Pks);
num_qoes = height(QoEs);

% === 3. Distribuição Aleatória ===
rng('shuffle'); 
indices_pk = randi(num_pks, num_pois, 1);
indices_qoe = randi(num_qoes, num_pois, 1);

% === 4. Montar Tabela Final com Nomes Específicos ===
POI = table();
POI.poiID = (1:num_pois)';       
POI.lat = Pois_Gyn.Latitude;
POI.long = Pois_Gyn.Longitude;
POI.pokemon = Pks.pkid(indices_pk);
%POI.tempovisita = repmat(300, num_pois, 1);  %% se tempo de visita fixo em 300 segundos
POI.tempovisita = randi([60 180], num_pois, 1); %% se tempo de visita aleatório entre 1 e 3 minutos
POI.qoeid = QoEs.qoeid(indices_qoe);

% === 5. Salvar ===
writetable(POI, 'grafo_pois_poke_qoe.csv');
fprintf(' - grafo_pois_poke_qoe.csv gerado com sucesso (%d POIs)!\n', num_pois);

