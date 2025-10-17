# Ragnarok Online - YggAI

- [English](https://github.com/maxmx03/YggAI/blob/main/README_EN.md)
- [Español](https://github.com/maxmx03/YggAI/blob/main/README_ESP.md)

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

| Variável     | Descrição                                   |
| ------------ | ------------------------------------------- |
| `MyLevel`    | Level do seu homunculus, sempre atualize    |
| `LifCanHeal` | LIF pode usar curar?                        |
| `MaxEnemies` | Número de máximo de inimigos para gerenciar |

### Exemplo

```lua
LifCanHeal = true -- LIF pode usar curar? true ou false (requer poção compacta)
shouldPreventHomunculusDuplication = false -- ou true (agressivo apenas contra monstros de instâncias, ilusionais, mvps e bosses
```

## Comportamento dos Homúnculus no YggAI

### Eira

<img width="300" height="417" alt="Eira_Card_Art" src="https://github.com/user-attachments/assets/00bfdb88-ba6e-4f5f-aa4c-181d99f8ac16" align="left" />

Eira é um homúnculo de combate ágil, focada em causar dano e manter a pressão no inimigo. Sua estratégia se baseia no uso contínuo de habilidades de ataque, com a habilidade **Eraser Cutter** sendo sua principal forma de dano.

- **Comportamento de Combate**: Prioriza o uso de **Xeno Slasher** contra monstros do tipo Água 💧 ou Veneno ☣️, ou quando o inimigo não é do tipo Vento. Sua principal habilidade ofensiva, **Eraser Cutter**, é usada repetidamente.
- **Habilidades Especiais**:
  - **Overed Boost**: Usada contra MVPs (monstros chefes) para aumentar seu poder de ataque.
  - **Light of Regene**: Uma habilidade de suporte crucial, ativada para curar o dono se ele estiver morto.

---

### Dieter

<img width="300" height="417" alt="Dieter_Card_Art" src="https://github.com/user-attachments/assets/6f9187c8-fb27-4843-b692-7bef1ba3b3af" align="right" />

Dieter é um homúnculo robusto e estratégico, especializado em ataques de área e sobrevivência. Seu comportamento é adaptável ao tipo de monstro que enfrenta, utilizando diferentes habilidades para maximizar o dano.

- **Comportamento de Combate**: Ele utiliza a habilidade **Lava Slide** para ataques de área contra a maioria dos inimigos, exceto monstros do tipo Fogo 🔥. Contra monstros do tipo Água 💧 ou Planta 🌿, ele prefere a habilidade **Volcanic Ash**.
- **Habilidades Especiais**:
  - **Granitic Armor**: Ativada em situações de emergência para aumentar sua defesa e proteção, quando o dono está morrendo.
  - **Magma Flow**: Uma habilidade poderosa de dano de área, usada contra inimigos que não são do tipo Fogo.
  - **Pyroclastic**: Sua habilidade final, ativada em combate contra qualquer tipo de inimigo.

---

### Eleanor

<img width="300" height="417" alt="Eleanor_Card_Art" src="https://github.com/user-attachments/assets/5a92ad5b-940d-4cfd-8bb7-80e70f4a7e15" align="left" />

Eleanor é uma atacante rápida e precisa, que utiliza uma sequência de habilidades para infligir grandes danos ao inimigo. Seu foco é executar um combo de ataque eficiente, mas também sabe se adaptar.

- **Comportamento de Combate**: Seu principal objetivo é executar um combo devastador que começa com **Sonic Craw**, seguido por **Silvervein Rush** e, por fim, **Midnight Frenzy**. O combo é acionado sempre que as habilidades estão disponíveis e o inimigo está dentro do alcance.
- **Habilidades Especiais**:
  - **Ataque Básico**: Quando as habilidades principais estão em tempo de recarga (cooldown), Eleanor continua a atacar o inimigo para acumular esferas, que são necessárias para suas habilidades.

---

### Sera

<img width="300" height="417" alt="Sera_Card_Art" src="https://github.com/user-attachments/assets/f31a2812-425e-4c13-ba53-f9f2d16916e2" align="right" />

Sera é uma homúncula de suporte e controle, especializada em incapacitar inimigos e auxiliar o dono em combate. Sua estratégia se concentra em usar habilidades que prejudicam o adversário e buffam a si mesma ou seu dono.

- **Comportamento de Combate**: Sera tenta usar **Poison Mist** para causar dano de área. Ela também foca em aplicar a habilidade de dano e paralisia **Needle of Paralyze** no inimigo para ajudar o dono.
- **Habilidades Especiais**:
  - **Summon Legion**: Usada especificamente contra MVPs para invocar ajuda.
  - **Pain Killer**: Uma habilidade de suporte ativada quando em combate para proteger o dono.

---

### Bayeri

<img width="300" height="417" alt="Bayeri_Card_Art" src="https://github.com/user-attachments/assets/b219099c-5ac1-4ea0-8d21-fa3b45f20e31" align="left" />

Bayeri é um homúnculo de combate direto, focado em causar dano massivo e fortalecer a si mesmo. Ele adapta seu estilo de ataque ao tipo de monstro que enfrenta, priorizando dano contra inimigos específicos.

- **Comportamento de Combate**: Ele usa habilidades como **Stahl Horn** e **Goldene Ferse** para atacar. Contra monstros do tipo Morto-Vivo 🧟 ou Sombrio 🦇, ele prioriza a habilidade **Heilige Stange**.
- **Habilidades Especiais**:
  - **Steinwand**: Habilidade de suporte ativada para proteger o dono, especialmente se ele estiver com pouca vida.
  - **Angriffs Modus**: Usado para fortalecer o próprio Bayeri em combate.

---

## Contribuindo

Você pode contribuir com o projeto, seja reportando bugs, sugerindo novas
funcionalidades ou até mesmo corrigindo bugs.
Para reportar um bug, crie um novo tópico no [Issues](https://github.com/maxmx03/YggAI/issues).
