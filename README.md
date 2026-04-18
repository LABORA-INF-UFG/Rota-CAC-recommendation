# Recomendação de Rotas Consciente de QoE com Atenção e Comunicação

Este trabalho propõe um modelo de recomendação de rotas (itinerários) para Jogos baseados em localização com Realidade Aumentada (JBLRA),
denominado **Rota-CAC** (*Rota Consciente de Atenção e Comunicação).
Propomos uma formulação que integra explicitamente fatores de comunicação, mobilidade e atenção do usuário por meio da métrica QoE-CAC.
Diferentemente de abordagens tradicionais centradas apenas na distância ou na pontuação do jogo, o modelo proposto incorpora condições dinâmicas de rede 5G
como critério decisório no planejamento de trajetórias.
O modelo considera a Qualidade de Experiência (QoE-CAC) do jogador, o contexto dos Pontos de Interesse (POIs) e o custo de deslocamento entre eles.
Para resolver o problema de recomendação de rotas, foi proposto um algoritmo heurístico baseado em  Ant Colony Optimization (ACO). 
Experimentos com dados reais de rede demonstram que a abordagem equilibrada (RotaCAC-0.5) 
oferece melhor compromisso entre a pontuação e a QoE percebida frente a estratégias não conscientes de QoE.

---
# Estrutura 
```
Rota-CAC-recommendation/
├── dataset/               # Dados utilizados nos experimentos. Arquivo descricao_geral.txt detalha o conteúdo de cada arquivo .csv
├── geracao_grafo/         # Código MATLAB para extração de POIs e geração do grafo
└── recomendacao_rotas/    # Código MATLAB para recomendação de rotas (Greedy e RotaCAC-η)
```
O repositório está organizado em três seções que correspondem: 
- **dataset:** Contém os arquivos CSV com POIs, pokémons normalizados, custos de deslocamento, valores de QoE e descrição geral.
- **geracao_grafo:** Responsável pela consulta à Overpass API, geração do grafo de POIs e cálculo das distâncias e tempos de deslocamento.
- **recomendacao_rotas:** Este é o principal diretório. Implementa os algoritmos de recomendação (Greedy e  RotaCAC-η), recomendando as rotas e realizando os experimentos e análises.


---

# Selos Considerados

- Artefatos Disponíveis (SeloD)
- Artefatos Funcionais (SeloF)
- Artefatos Sustentáveis (SeloS)
- Experimentos Reprodutíveis (SeloR)

Com base nos códigos e datasets disponibilizados neste repositório.

---

# Informações básicas
Para execução do código, necessita-se dos seguintes pre-requisitos:

- **Sistema Operacional:** Windows, macOS ou Linux
- **Software:** MATLAB R2022b ou superior
- **Hardware mínimo:** 4GB RAM, 500MB de espaço em disco


# Dependências
- Necessária conexão com a internet (para consulta à Overpass API na geração do grafo)
- Nenhuma Toolbox adicional é necessária


---

# Preocupações com Segurança

A execução deste artefato é isenta de riscos para os avaliadores. Não há necessidade de operações que possam comprometer o sistema. A consulta à Overpass API é somente leitura.

---

# Instalação

Não é necessária instalação de dependências adicionais além do MATLAB R2022b. Basta clonar o repositório:

```
git clone https://github.com/LABORA-INF-UFG/Rota-CAC-recommendation.git
cd Rota-CAC-recommendation
```

# Teste Mínimo

Para validar a instalação, após download, entre na pasta `recomendacao_rotas_cac/` e execute o script principal no MATLAB: main_todos.m

```matlab
cd recomendacao_rotas_cac
main_todos.m

O script executará uma avaliação geral para os métodos Greedy e Rota-CAC
e exibirá um resumo comparativo de rotas semelhante ao abaixo:
==================================================================
           RESUMO COMPARATIVO DE ROTAS
==================================================================
Algoritmo                 || Tamanho Rota    || Pontos     || QoE       
------------------------------------------------------------------
Greedy (Baseline)         || 7               || 3.61       || 2.47      
ACO Equilibrado           || 15              || 6.87       || 5.45      
ACO Foco Pontos           || 14              || 6.60       || 5.15      
ACO Foco QoE              || 14              || 5.39       || 5.78

Se quiser avançar para os experimentos, 
responda ao prompt no MatLab:
======================================================
       EXPERIMENTOS
======================================================
Deseja executar os experimentos? (s/n):

Para execução mínima, escolha pelo menos 2 execuções 
O arquivo main_todos invoca os seguintes módulos:
avalia_eficiencia;
analise_totais_absolutos;
analise_comparativa;
 Em cada um destes módulos, são feitas 30 execuções 

Ao final, espera-se que o script execute sem erros e gere os seguintes gráficos: 
Gráfico Análise de Eficiência,
Grafíco com Pontuação total, QCAC total e número médio de POIs,
Gráfico de Impacto da Penalidade.
```
---

# Experimentos

O experimento principal é o de Recomendação de Rotas (Etapa 2).
A Etapa 1 corresponde ao pre-processamento e já foi previamente executada para execução da Etapa 2.
Ela contém o código de pre-processamento para geração dos grafos e geração dos datasets utilizados. 
Cada etapa é descrita logo a seguir.

## Etapa 1: Pre-processamento: Geração do Grafo de POIs
Entre na pasta `geracao_grafo/` e execute o script principal no MATLAB:

```matlab
cd geracao_grafo
main
```
Este script consulta a Overpass API e gera os seguintes arquivos CSV:
- `grafo_pois_gyn.csv`  e   `grafo_pois_poke_qoe.csv` 
> **Atenção:** A consulta à Overpass API pode demorar alguns segundos. Em caso de erro 504 (Gateway Timeout), o script realiza até 3 tentativas automáticas.

## Etapa 2: Recomendação de Rotas

Entre na pasta `recomendacao_rotas/` e execute a análise comparativa:

```matlab
cd recomendacao_rotas
analise_comparativa_sbrc
```
Este script executa 30 simulações para dois cenários:
- **Cenário 1:** Sem penalidade de atraso (`atraso = 0`)
- **Cenário 2:** Com penalidade de atraso (`atraso = 60s`)

E compara quatro estratégias:
- Greedy
- RotaCAC-0.5 (η = 0.5)
- RotaCAC-1 (η = 1)
- RotaCAC-0 (η = 0)

## Reivindicação #1: Recomendação de Rotas
Esta etapa já considera todos os parâmetros e arquivos .csv necessários para execução 
Não é necessário efetuar a carga de pre-processamento para sua execução!

## Reivindicação #2: Geração do Grafo
Esta etapa não é obrigatória.
Ela já foi executada anteriormente e os arquivos necessários já estão carregados na etapa principal - Recomendação de Rotas
Para executar a etapa de pre-processamento, será necessária a conexão com internet.
A consulta à Overpass API pode demorar alguns segundos. Em caso de erro 504 (Gateway Timeout), o script realiza até 3 tentativas automáticas, ou tentar posteriormente.
Este script consulta a Overpass API e gera os seguintes arquivos CSV:
- `grafo_pois_gyn.csv`  e   `grafo_pois_poke_qoe.csv` 

---


# 🎯 Contribuições

- **Modelo de Recomendação Rota-CAC:** Propõe um modelo que integra QoE-CAC, contexto dos POIs e custo de deslocamento para recomendação de rotas em JBLRA.
- **Geração do Grafo de POIs:** Constrói um grafo georreferenciado de uma cidade, extraindo pontos de interesse reais via Overpass API com custo de deslocamento baseado em tempo de caminhada.
- **Recomendação de rotas:** A recomendação de rotas é implementada utilizando a estratégia Greedy (baseline) e as estratégias RotaCAC com base no ACO, variando o parâmetro eta (η):RotaCAC-1 (foco na QoE), RotaCAC-0 (foco na pontuação) e RotaCAC-0.5 (foco equilibrado entre QoE e pontuação).
- **Análises:** Os experimentos fornecem três análises distintas: análise de eficiência de QoE e pontuação, análise de totais de pontuação, QoE e tamanho da rota; e análise comparativa de cenários com/sem penalidades de atraso ao longo de 30 execuções, com intervalos de confiança de 95%.
- **Disponibilização do Código e Dataset:** Código-fonte e dataset disponibilizados para reprodução dos experimentos.


# Autores

- Rosana de Oliveira Santos
- Carlos Eduardo da S. Santos
- Ciro J. A. Macedo
- Antonio Oliveira-Jr

LABORA — Laboratory of Computer Networks and Multimedia Systems  
Instituto de Informática — Universidade Federal de Goiás (UFG)

---


# LICENSE

Este projeto está licenciado sob a licença [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/deed.pt-br).



