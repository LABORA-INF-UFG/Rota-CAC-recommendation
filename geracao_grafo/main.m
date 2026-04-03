% Autora: Rosana de Oliveira Santos
% Extrai POIs no Setor Universitário de Goiânia e gera:
% grafo_pois_gyn.csv e custo.csv


%%% Etapa de pre-processamento, gerando o mapa de POIs com pokemons e
%%% QoE-CAC


% chamar modulo para gerar mapa pois goiania
gerar_grafo_pois_gyn;

%% para plotar o mapa com os pontos
plotPOIs('grafo_pois_gyn.csv');

% Distribuir os pokemons entre os POIs e associar valores de QoE-CAC
carregar_pois;

