# Ragnarok Online - YggAI

- [English](https://github.com/maxmx03/YggAI/blob/main/README_EN.md)
- [Español](https://github.com/maxmx03/YggAI/blob/main/README_ESP.md)

> [!CAUTION]
> O ROLATAM apresenta um bug que duplica o homunculus quando o dono passa pelo portal.
> Isso ocorre porque o homunculus ataca um monstro no momento em que o dono tenta atravessar o portal.
> Devido a isso, o meu script fará com que o homunculus seja agressivo contra monstros de instância, illusionais, boss e MVP, e só utilizará buffs apenas se o dono estiver em combate, para evitar que o homunculus use habilidades dentro da cidade. [Veja](https://youtu.be/A_NnJk_ZBRQ?si=M3BAxdLwUaw-pCib)

## Introdução

Este é um projeto de AI para o jogo Ragnarok Online, desenvolvido em Lua.

## Arquitetura

A inteligência artificial deste projeto é construída utilizando [Behavior Trees](https://dev.epicgames.com/documentation/en-us/unreal-engine/behavior-tree-in-unreal-engine---overview). Essa abordagem organiza a lógica de decisão em uma estrutura hierárquica,
permitindo um comportamento adaptável e fácil de gerenciar para os personagens
controlados pela AI.

## Como usar

### Arquivo zip

Click em Code > Download ZIP e extraia o arquivo zip, copie o contéudo da pasta de YggAI para a pasta `C:\\Gravity\\Ragnarok\\AI\\USER_AI`.
Depois entre no jogo e digite `/hoai` para ativar o YggAI, para voltar pro script original basta digitar novamente o
mesmo comando.

### Ferramenta de versionamento

Se você usar um software de versionamento, como o [Git](https://git-scm.com/downloads), você pode clonar o repositório do projeto usando o comando no terminal:

```bash
git clone https://github.com/maxmx03/YggAI.git C:\\Gravity\\Ragnarok\\AI\\USER_AI
cd C:\\Gravity\\Ragnarok\\AI\\USER_AI
git pull # busca por novas atualizações.
```

Caso não queira utilizar o terminal, você pode utilizar o [Github Desktop](https://desktop.github.com).

## Config.lua

Abra o arquivo `config.lua` e atualize as variáveis conforme necessário, você
pode utilizar qualquer editor de texto disponível no seu sistema operacional.

- [Notepad](https://apps.microsoft.com/detail/9msmlrh6lzf3?hl=pt-BR&gl=BR)
- [Notepad++](https://notepad-plus-plus.org)
- [Vscode](https://code.visualstudio.com)

| Variável                             | Descrição                                |
| ------------------------------------ | ---------------------------------------- |
| `MyLevel`                            | Level do seu homunculus, sempre atualize |
| `LifCanHeal`                         | LIF pode usar curar?                     |
| `shouldPreventHomunculusDuplication` | Prevenir o bug de duplicação?            |

### Exemplo

```lua
MyLevel = 50 -- level do seu homunculus, sempre atualize
LifCanHeal = true -- LIF pode usar curar? true ou false (requer poção compacta)
```

## Contribuindo

Você pode contribuir com o projeto, seja reportando bugs, sugerindo novas
funcionalidades ou até mesmo corrigindo bugs.
Para reportar um bug, crie um novo tópico no [Issues](https://github.com/maxmx03/USER_AI/issues).

Caso queira contribuir de outra forma mande um rodex no jogo para `Freya/Pelunia (BIO)`
ou `Freya/Millianor (AB)`, mandando zenys ou semente da vida.

## TODO

- [x] Homunculus
  - [x] Lif
  - [x] Vanilmirth
  - [x] Amistr
  - [x] Filir
- [x] Homunculus S
  - [x] Bayeri
  - [x] Dieter
  - [x] Eira
  - [x] Sera
  - [x] Eleanor
- [ ] PVP
- [ ] WOE
- [x] PVM
- [x] Detect MVP
- [x] Avoid Plant
- [x] Skill and Cooldown
- [x] Prevention of Homunculus Duplication Bug
- [x] User commands (Gravity Implementation)

## Projetos Alternativos

> [!CAUTION]
> Usuários do AzzyAI, desativem qualquer autobuff ou qualquer
> outra função que faça com que o homunculus cause este bug de duplicação.

- [AzzyAI](https://github.com/SpenceKonde/AzzyAI)
