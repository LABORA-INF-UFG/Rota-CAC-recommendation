% Script para normalizar a coluna 'valor' do arquivo pokemon.csv
% Gera o arquivo pokemon_normalizado.csv

clear; clc;

% 1. Definição dos nomes dos arquivos
arquivo_entrada = 'pokemon.csv';
arquivo_saida = 'pokemon_normalizado.csv';

% 2. Carregamento dos dados
if exist(arquivo_entrada, 'file')
    data = readtable(arquivo_entrada);
else
    error('O arquivo %s não foi encontrado no diretório atual.', arquivo_entrada);
end

% 3. Normalização Min-Max da coluna 'valor'
v_min = min(data.valor);
v_max = max(data.valor);

if v_max > v_min
    % Aplica a normalização mantendo os outros campos intactos
    data.valor = (data.valor - v_min) / (v_max - v_min);
    fprintf('Coluna "valor" normalizada com sucesso.\n');
else
    data.valor(:) = 1.0; % Fallback caso todos os valores sejam iguais
    warning('Valores idênticos detectados na coluna valor.');
end

% 4. Exportação para o novo CSV
writetable(data, arquivo_saida);

% Exibição do resultado para conferência
disp('--- Primeiras linhas do novo arquivo (pokemon_normalizado.csv) ---');
head(data)
