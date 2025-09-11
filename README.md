# Ragnarok Online - AI

## Introdução

Este é um projeto de AI para o jogo Ragnarok Online, desenvolvido em Lua.

## Como usar

### Arquivo zip

Click em Code > Download ZIP e extraia o arquivo zip para a pasta `C:\\Gravity\\Ragnarok\\AI`,
deverá ficar assim: `C:\\Gravity\\Ragnarok\\AI\\USER_AI`.

### Ferramenta de versionamento

Se você usar um software de versionamento, como o [Git](https://git-scm.com/downloads), você pode clonar o repositório do projeto usando o comando no terminal:

```bash
git clone https://github.com/maxmx03/USER_AI.git C:\\Gravity\\Ragnarok\\AI\\USER_AI
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

| Variável   | Descrição                                |
| ---------- | ---------------------------------------- |
| MyLevel    | Level do seu homunculus, sempre atualize |
| LifCanHeal | LIF pode usar curar?                     |

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
- [ ] Homunculus S
  - [ ] Bayeri
  - [ ] Dieter
  - [ ] Eira
  - [ ] Sera
  - [x] Eleanor
- [ ] PVP
- [ ] WOE
- [x] PVM
- [ ] Detect MVP
- [x] Skill and Cooldown
- [ ] User commands

## Projetos Alternativos

- [AzzyAI](https://github.com/SpenceKonde/AzzyAI)
