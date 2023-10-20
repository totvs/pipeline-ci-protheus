# pipeline-ci-protheus

Repositório com o exemplo de CI apresentado na palestra: **Linha Protheus - Utilizando CodeAnalysis em seu processo de integração contínua** no evento Spin-off Code no Code do dia do Profissional de TI (19/10/2023).

Para baixá-lo, faça um clone deste repositório em seu ambiente local: `git clone https://github.com/totvs/pipeline-ci-protheus.git`.

Caso deseje fazer uma execução totalmente local, considere as instruções deste repositório: https://github.com/totvs/protheus-ci-universo

Dúvidas podem ser encaminhadas via issue neste repositório. Sugestões via Pull Requests.

## Pipeline (etapas)

Esta pipeline de exemplo consiste em 4 etapas (veja aba Actions deste repositório):

```
push
 ├── 1. Code Analysis -> Realiza a execução da análise de qualidade de código;
 ├── 2. Build -> Compila os fontes e gera o RPO Custom;
 ├── 3. TIR -> Baixa o RPO custom e realiza os testes usando o TIR sem interface;
 └── 4. Patch Gen -> Gera um patch com os fontes Protheus do repositório.
```

Esta pipeline foi configurada para executar sequencialmente, cada uma etapa depende que a anterior tenha sido executada com sucesso.

A definição está no arquivo `.github/workflows/pipeline.yml`, onde cada etapa é um job do GitHub Actions que executa alguns scripts para realizar a tarefa da etapa em questão.

### Solução para execução do ambiente local

O job do TIR tem uma característica diferente dos outros, pois ele não executa nos agents/runners do GitHub, e sim num agent hospedado na infraestrutura interna da TOTVS, para ter comunicação com um ambiente Protheus sendo executado em Docker (esta é uma das diversas possibilidades).

A nossa solução foi criar uma imagem Docker contendo o agent dos runners do GitHub ([veja aqui documentação sobre isso](https://docs.github.com/pt/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners)), herdando a imagem base do TIR (https://hub.docker.com/r/totvsengpro/tir).

Essa imagem compartilha a mesma rede e o volume do RPO do ambiente em Docker (`/share/protheus/apo/`), permitindo que a imagem TIR+Agent faça a troca a quente do RPO, e permita a execução do TIR.

Para tratar os erros e falhas dos scripts de testes do TIR, é necessário que o script da suíte tenha um tratamento para quebrar em caso de falhas. Para isso adicione a seguinte instrução no final da suíte:

```python
runner = unittest.TextTestRunner(verbosity=2)
result = runner.run(suite)

if len(result.errors) > 0 or len(result.failures) > 0:
    print("custom exit")
    exit(1)
```

### Visão aba Actions

Na imagem abaixo é possível ver uma execução com sucesso da pipeline, onde foram executadas as 4 etapas e gerado os artefatos (custom rpo e patch) para aplicação no ambiente.

![image](https://github.com/totvs/pipeline-ci-protheus/assets/10109480/722bb3c0-5f83-4ead-8c85-86fb76ded58e)

*imagem anexada pois a retenção máxima do GitHub Actions é de 90 dias.
  
## Ambiente Protheus com Docker

Se deseja subir o ambiente Protheus via Docker deste exemplo, siga os seguinte passos:

1. Rode o seguinte script: `cd pipeline-ci-protheus && bash ci/scripts/up_env.sh`;
2. Baixe os seguintes artefatos: includes, rpo default e o dicionário;
3. Adicione na **[pasta protheus](#estrutura-de-pastas)** os artefatos baixados em suas respectivas subpastas;
4. Configure-o (ip/porta webapp) nas configs do TIR (`tir/config.json`),

## Scripts do CI

Estes são os scripts externos desta pipeline CI de exemplo:

1. `up_env.sh`: Sobe a stack ambiente Protheus local em Docker;
2. `down_env.sh`: Remove a stack do ambiente Protheus;
4. `list-files.sh`: Lista os arquivos de código Protheus do repositório para geração do patch;

Obs.: Caso um dos scripts retorne erro, a pipeline irá "quebrar", não continuando a realização dos próximos.

## Estrutura de pastas

Este projeto contém a seguinte estrutura de pastas e seus respectivos propósitos:

```
.
├── .github
│    └── workflows
│         └── pipeline.yml (pipeline GitHub Actions)
├── analyser               (arquivos do analisador estático)
│    ├── config.json       (arquivo de configuração do analisador)
│    └── output            (saída da execução da análise)
├── ci
│    ├── scripts           (scripts externos da pipeline)
│    └── docker            (arquivos para execução do ambiente Protheus local)
├── protheus               (arquivos para execução local do Protheus e AppServer command line via Docker)
│    ├── apo               (volume dos RPOs do ambiente Protheus)
│    ├── includes          (volume dos includes da compilação)
│    └── systemload        (volume dos arquivos de dicionário)
├── src                    (códigos-fonte)
└── tir                    (suítes de testes e configuração para execução do TIR)
```

## Documentações relacionadas

- [Code Analysis via Docker](https://hub.docker.com/r/totvsengpro/advpl-tlpp-code-analyzer)
- [Protheus via Docker](https://docker-Protheus.engpro.totvs.com.br)
- [AppServer command line](https://tdn.totvs.com/pages/viewpage.action?pageId=6064914)
- [Sonar Rules](https://sonar-rules.engpro.totvs.com.br/menu/rules)
- [Git](https://git-scm.com)
- [Docker](https://docs.docker.com)
- [CodeAnalysis](https://codeanalysis.totvs.com.br)
- [TIR](https://github.com/totvs/tir)
