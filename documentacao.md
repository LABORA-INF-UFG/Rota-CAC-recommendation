# Documentação das Funções

Este documento descreve os contratos das principais funções do projeto, com seus parâmetros de entrada, saídas e comportamento esperado.

---

## Etapa 1: Pré-processamento — Geração do Grafo de POIs

### `main.m`
Script principal da Etapa 1. Orquestra a execução sequencial das etapas de pré-processamento.

**Execução:**
```matlab
cd geracao_grafo
main.m
```

**Fluxo:**
1. Chama `gerar_grafo_pois_gyn` — extrai POIs e gera os arquivos CSV
2. Chama `plotPOIs('grafo_pois_gyn.csv')` — plota o mapa com os POIs
3. Chama `carregar_pois` — distribui Pokémons e carrega valores de QoE-CAC nos POIs

**Saídas geradas:**
- `grafo_pois_gyn.csv`
- `custo.csv`
- `grafo_pois_poke_qoe.csv`

---

### `gerar_grafo_pois_gyn.m`
Extrai Pontos de Interesse (POIs) do Setor Universitário de Goiânia via Overpass API e calcula os custos de deslocamento entre eles.

**Parâmetros internos configuráveis:**

| Parâmetro | Valor padrão | Descrição |
|---|---|---|
| `velocidade_pedestre` | 5 km/h | Velocidade usada para calcular tempo de deslocamento |
| `lat_sul`, `lon_oeste`, `lat_norte`, `lon_leste` | Coordenadas do Setor Universitário de Goiânia | Delimitam a área geográfica de busca |

**Comportamento:**
- Consulta a Overpass API buscando POIs das categorias: supermercados, parques, igrejas, lojas, turismo, universidades e escolas
- Realiza até 3 tentativas automáticas em caso de erro 504 (Gateway Timeout)
- Calcula a distância entre cada par de POIs usando a fórmula de **Haversine** (sem dependência do Mapping Toolbox)
- Calcula o tempo de deslocamento em segundos e minutos com base na velocidade do pedestre

**Saídas:**
- `grafo_pois_gyn.csv` — tabela com colunas: `poiid`, `Nome`, `Latitude`, `Longitude`
- `custo.csv` — tabela com colunas: `poi_origem`, `poi_destino`, `tdeslocamento_s`, `tdeslocamento_min`

---

### `carregar_pois.m`
Distribui aleatoriamente Pokémons e valores de QoE-CAC entre os POIs gerados.

**Entradas (arquivos CSV lidos automaticamente):**

| Arquivo | Descrição |
|---|---|
| `grafo_pois_gyn.csv` | Lista de POIs com coordenadas |
| `pokemon.csv` | Lista de Pokémons disponíveis |
| `qoecac.csv` | Lista de valores de QoE-CAC disponíveis |

**Comportamento:**
- Distribui aleatoriamente um Pokémon para cada POI
- Associa aleatoriamente um valor de QoE-CAC para cada POI
- Define um tempo de visita aleatório entre 60 e 180 segundos para cada POI

**Saída:**
- `grafo_pois_poke_qoe.csv` — tabela com colunas: `poiID`, `lat`, `long`, `pokemon`, `tempovisita`, `qoeid`

---

### `plotPOIs(nomeArquivoCSV, conectar)`
Plota os POIs de um arquivo CSV em um mapa geográfico interativo.

**Parâmetros:**

| Parâmetro | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `nomeArquivoCSV` | string | Sim | Caminho do arquivo CSV contendo colunas `Latitude` e `Longitude` |
| `conectar` | boolean | Não (padrão: `false`) | Se `true`, desenha linhas conectando todos os pares de POIs |

**Comportamento:**
- Lê o arquivo CSV informado
- Plota os POIs como pontos vermelhos sobre um mapa de ruas
- Anota o ID de cada POI no mapa
- Se `conectar = true`, desenha arestas entre todos os pares de POIs

**Exemplo de uso:**
```matlab
plotPOIs('grafo_pois_gyn.csv');         % apenas pontos
plotPOIs('grafo_pois_gyn.csv', true);   % pontos conectados
```

**Requisito:** O arquivo CSV deve obrigatoriamente conter as colunas `Latitude` e `Longitude`.

---

## Etapa 2: Recomendação de Rotas

### `main_todos.m`
Script principal da Etapa 2. Orquestra a execução dos algoritmos de recomendação de rotas e dos experimentos.

**Execução:**
```matlab
cd recomendacao_rotas
main_todos.m
```

**Parâmetros internos configuráveis:**

| Parâmetro | Valor padrão | Descrição |
|---|---|---|
| `userid` | 1 | ID do usuário na tabela `usuarios.csv` |
| `budget_tempo` | lido do CSV | Tempo máximo disponível para a rota (segundos) |
| `poiid_inicio` | lido do CSV | POI de início da rota |
| `limiar` | 0.2 | Limiar mínimo de QoE-CAC para visitar um POI |
| `atraso_maximo` | 60 s | Penalidade aplicada quando QoE está abaixo do limiar |
| `num_formigas` | 20 | Número de formigas no ACO |
| `num_iter` | 50 | Número de iterações do ACO |
| `alfa` | 1 | Peso do feromônio no ACO |
| `beta` | 3 | Peso da heurística no ACO |
| `rho` | 0.1 | Taxa de evaporação do feromônio no ACO |

**Entradas (arquivos CSV lidos automaticamente):**

| Arquivo | Descrição |
|---|---|
| `usuarios.csv` | Parâmetros do usuário (budget, POI inicial) |
| `poi.csv` | Lista de POIs com atributos |
| `pokemon_normalizado.csv` | Pokémons com pontuações normalizadas |
| `custo.csv` | Custos de deslocamento entre POIs |
| `qoe_normalizado.csv` | Valores de QoE-CAC normalizados |

**Fluxo:**
1. Executa o algoritmo **Greedy** (baseline) via `calcular_rota_greedy`
2. Executa três variantes do **ACO** via `calcular_rota_aco`: equilibrado (η=0.5), foco em pontos (η=0), foco em QoE (η=1)
3. Exibe o resumo comparativo de rotas
4. Pergunta ao usuário se deseja executar os experimentos completos
5. Se confirmado, chama: `avalia_eficiencia`, `analise_totais_absolutos` e `analise_comparativa`

---

### `calcular_rota_greedy(userid, budget_tempo, pois, pokemons, custos, qoe, poiid_inicio, limiar, atraso_maximo)`
Implementa o algoritmo guloso (baseline) para recomendação de rota.

**Parâmetros de entrada:**

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `userid` | inteiro | ID do usuário |
| `budget_tempo` | double | Tempo máximo disponível para a rota (segundos) |
| `pois` | table | Tabela de POIs |
| `pokemons` | table | Tabela de Pokémons normalizados |
| `custos` | table | Tabela de custos de deslocamento |
| `qoe` | table | Tabela de valores de QoE-CAC normalizados |
| `poiid_inicio` | inteiro | POI de início da rota |
| `limiar` | double | Limiar mínimo de QoE-CAC |
| `atraso_maximo` | double | Penalidade em segundos quando QoE < limiar |

**Retornos:**

| Retorno | Tipo | Descrição |
|---|---|---|
| `rota` | vetor | Sequência de IDs dos POIs visitados |
| `total_pontos` | double | Pontuação total acumulada na rota |
| `total_qoe` | double | QoE-CAC total acumulada na rota |
| `tempo_total` | double | Tempo total gasto na rota (segundos) |

---

### `calcular_rota_aco(userid, budget_tempo, pois, pokemons, custos, qoe, poiid_inicio, eta, num_formigas, num_iter, alfa, beta, rho, limiar, atraso_maximo)`
Implementa o algoritmo ACO (Ant Colony Optimization) para recomendação de rota, com parâmetro η para balancear pontuação e QoE.

**Parâmetros de entrada:**

| Parâmetro | Tipo | Descrição |
|---|---|---|
| `userid` | inteiro | ID do usuário |
| `budget_tempo` | double | Tempo máximo disponível para a rota (segundos) |
| `pois` | table | Tabela de POIs |
| `pokemons` | table | Tabela de Pokémons normalizados |
| `custos` | table | Tabela de custos de deslocamento |
| `qoe` | table | Tabela de valores de QoE-CAC normalizados |
| `poiid_inicio` | inteiro | POI de início da rota |
| `eta` | double (0 a 1) | Peso do balanceamento: 0 = foco em pontos, 1 = foco em QoE, 0.5 = equilibrado |
| `num_formigas` | inteiro | Número de formigas |
| `num_iter` | inteiro | Número de iterações |
| `alfa` | double | Peso do feromônio |
| `beta` | double | Peso da heurística |
| `rho` | double | Taxa de evaporação do feromônio |
| `limiar` | double | Limiar mínimo de QoE-CAC |
| `atraso_maximo` | double | Penalidade em segundos quando QoE < limiar |

**Retornos:**

| Retorno | Tipo | Descrição |
|---|---|---|
| `rota` | vetor | Sequência de IDs dos POIs visitados |
| `total_pontos` | double | Pontuação total acumulada na rota |
| `total_qoe` | double | QoE-CAC total acumulada na rota |
| `tempo_total` | double | Tempo total gasto na rota (segundos) |

---

### `avalia_eficiencia.m`
Executa múltiplas simulações e calcula a eficiência da QoE e de Pontos por segundo para cada algoritmo.

> **Pré-requisito:** Deve ser chamado após `main_todos.m`, pois utiliza as variáveis do workspace (`userid`, `budget_tempo`, `pois`, `pokemons`, `custos`, `qoe`, `num_execucoes`, entre outras).

**Parâmetros utilizados do workspace:**

| Variável | Descrição |
|---|---|
| `num_execucoes` | Número de rodadas a executar (mínimo recomendado: 30) |
| `userid`, `budget_tempo`, `poiid_inicio` | Parâmetros do usuário |
| `limiar`, `atraso_maximo` | Parâmetros de QoE |
| `num_formigas`, `num_iter`, `alfa`, `beta`, `rho` | Parâmetros do ACO |

**Comportamento:**
- Executa `num_execucoes` rodadas para cada um dos 4 algoritmos: Greedy, RotaCAC-0.5, RotaCAC-1 e RotaCAC-0
- Calcula a eficiência de QoE (`QoE / Tempo Total`) e de Pontos (`Pontos / Tempo Total`) para cada algoritmo
- Gera gráfico de barras comparativo com dois subplots: Eficiência de QoE e Eficiência de Pontos

**Saída:**
- Gráfico: *Análise de Eficiência de QoE e de Pontos* (conforme Figura 3 do artigo)

---

### `analise_totais_absolutos.m`
Executa múltiplas simulações e compara os totais absolutos de pontuação, QoE e tamanho de rota entre os algoritmos.

> **Pré-requisito:** Deve ser chamado após `main_todos.m`.

**Parâmetros utilizados do workspace:**

| Variável | Descrição |
|---|---|
| `num_execucoes` | Número de rodadas a executar (mínimo recomendado: 30) |
| `userid`, `budget_tempo`, `poiid_inicio` | Parâmetros do usuário |
| `limiar` | Limiar mínimo de QoE-CAC |
| `num_formigas`, `num_iter`, `alfa`, `beta`, `rho` | Parâmetros do ACO |

**Comportamento:**
- Executa `num_execucoes` rodadas com `atraso_maximo = 60s`
- Compara os 4 algoritmos em termos de pontuação total média, QoE total média e número médio de POIs visitados
- Gera gráfico de barras com três subplots

**Saída:**
- Gráfico: *Resultados comparativos médios dos Algoritmos* (conforme Figura 4 do artigo)

---

### `analise_comparativa.m`
Compara os algoritmos em dois cenários: sem penalidade de atraso e com penalidade de atraso de 60s.

> **Pré-requisito:** Deve ser chamado após `main_todos.m`.

**Comportamento:**
- Executa `num_execucoes` rodadas para dois cenários:
  - **Cenário 1:** `atraso = 0` (sem penalidade)
  - **Cenário 2:** `atraso = 60s` (com penalidade)
- Compara o tamanho médio das rotas entre os cenários para cada algoritmo
- Calcula intervalos de confiança de 95%
- Gera gráfico comparativo entre os dois cenários

**Saída:**
- Gráfico: *Impacto da Penalidade — Tamanho da Rota Sem/Com Penalidades* (conforme Figura 5 do artigo)

