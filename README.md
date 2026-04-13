# Recomendação de Rotas Consciente de QoE com Atenção e Comunicação

Este trabalho propõe um modelo de recomendação de rotas (itinerários) para Jogos baseados em localização com Realidade Aumentada (JBLRA),
denominado **Rota-CAC** (*Rota Consciente de Atenção e Comunicação).
Propomos uma formulação que integra explicitamente fatores de comunicação, mobilidade e atenção do usuário por meio da métrica QoE-CAC.
Diferentemente de abordagens tradicionais centradas apenas na distância ou na pontuação do jogo, o modelo proposto incorpora condições dinâmicas de rede 5G
como critério decisório no planejamento de trajetórias.
O modelo considera a Qualidade de Experiência (QoE-CAC) do jogador, o contexto dos Pontos de Interesse (POIs) e o custo de deslocamento entre eles.
Para resolver o problema de recomendação de rotas, foi proposto um algoritmo heurístico baseado em \ac{ACO}. 
Experimentos com dados reais de rede demonstram que a abordagem equilibrada (RotaCAC-0.5) 
oferece melhor compromisso entre a pontuação e a QoE percebida frente a estratégias não conscientes de QoE.

---
# Estrutura 
```
Rota-CAC-recommendation/
├── dataset/               # Dados utilizados nos experimentos
├── geracao_grafo/         # Código MATLAB para extração de POIs e geração do grafo
└── recomendacao_rotas/    # Código MATLAB para recomendação de rotas (Greedy e RotaCAC-η)
```
O repositório está organizado em três seções que correspondem: 
- **dataset:** Contém os arquivos CSV com POIs, pokémons normalizados, custos de deslocamento, valores de QoE e descrição geral.
- **geracao_grafo:** Responsável pela consulta à Overpass API, geração do grafo de POIs e cálculo das distâncias e tempos de deslocamento.
- **recomendacao_rotas:** Implementa os algoritmos de recomendação (Greedy e  RotaCAC-η), recomendando as rotas e realizando os experimentos e análises.

Para uma explicação detalhada sobre execução do código, consulte o arquivo [tutorial.pdf] (./tutorial.pdf)

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

---

# Execução

## Etapa 1: Geração do Grafo de POIs

Entre na pasta `geracao_grafo/` e execute o script principal no MATLAB:

```matlab
cd geracao_grafo
main
```

Este script consulta a Overpass API e gera os seguintes arquivos CSV:
- `pois_universitario_gyn.csv` — POIs extraídos
- `custo_novo.csv` — Custos de deslocamento entre POIs (em segundos e minutos)

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

---

# Teste Mínimo

Para validar a instalação, execute teste.m que fará a avaliação da melhor rota para um usuário.

Se quiser avançar para os experimentos, execute o arquivo main_todos. 
O arquivo main_todos invoca os seguintes módulos:
avalia_eficiencia;
analise_totais_absolutos;
analise_comparativa;
 Em cada um destes módulos, são feitas 30 execuções 
 
 altere no código, o parâmetro 

```matlab
num_execucoes = 2;
```

Espera-se que o script execute sem erros e gere os seguintes gráficos 
Gráfico Análise de Eficiência, Grafíco com Pontuação total, QCAC total e número médio de POIs, Gráfico de Impacto da Penalidade
---

# Experimentos

## Reivindicação #1: Geração do Grafo

Executa a extração de POIs reais e gera o grafo com custos de deslocamento baseados em velocidade de caminhada (5 km/h). Os POIs são extraídos da região do Setor Universitário de Goiânia-GO via Overpass API.

## Reivindicação #2: Análise Comparativa

Executa 30 rodadas independentes (com `rng(i)` para reprodutibilidade) comparando os algoritmos Greedy e ACO com três valores de η nos dois cenários. Os resultados são apresentados em gráficos de barras com intervalos de confiança de 95% (t-score = 2.045 para N-1 = 29 graus de liberdade).

### Parâmetros do ACO utilizados nos experimentos:

| Parâmetro | Valor |
|-----------|-------|
| Número de formigas | 20 |
| Número de iterações | 50 |
| α (feromônio) | 1 |
| β (heurística) | 3 |
| ρ (evaporação) | 0.1 |
| η testados | 0, 0.5, 1 |

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

Este projeto está licenciado sob a licença Creative Commons Attribution 4.0 International (CC BY 4.0).
