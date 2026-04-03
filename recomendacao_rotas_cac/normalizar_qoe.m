% Script para normalizar a coluna valor_qoe e salvar em novo CSV
% Rosana - 2025

clear; clc;

% 1. Configurações de arquivos
arquivo_entrada = 'qoe20.csv';
arquivo_saida = 'qoe20_normalizado.csv';

% 2. Leitura do arquivo
if exist(arquivo_entrada, 'file')
    tabela = readtable(arquivo_entrada);
else
    error('Arquivo %s não encontrado!', arquivo_entrada);
end

% 3. Identificação da coluna alvo
coluna_alvo = 'valor_qoe';

% 4. Cálculo da Normalização Min-Max
v_min = min(tabela.(coluna_alvo));
v_max = max(tabela.(coluna_alvo));

if v_max > v_min
    % Aplica a fórmula: (x - min) / (max - min)
    tabela.(coluna_alvo) = (tabela.(coluna_alvo) - v_min) / (v_max - v_min);
    fprintf('Sucesso: Coluna %s normalizada entre 0 e 1.\n', coluna_alvo);
else
    % Caso todos os valores sejam idênticos
    tabela.(coluna_alvo)(:) = 1.0;
    fprintf('Aviso: Valores constantes detectados. Coluna preenchida com 1.0.\n');
end

% 5. Salva o novo arquivo CSV
writetable(tabela, arquivo_saida);

% Exibe as primeiras linhas para conferência no console do MATLAB
disp('--- Prévia dos Dados Normalizados ---');
head(tabela);
