# Ragnarok Online - AI

**Ragnarok AI** projetado para funcionar no cliente original do [Ragnarok Online](https://playragnarokonlinebr.com/). A AI é destinada ao uso dos Homunculus, que são criaturas que acompanham os Bioquímicos no jogo. É importante observar que os Homunculus não atacarão automaticamente os inimigos; em vez disso, eles fornecerão suporte ao Bioquímico, ativando habilidades específicas em momentos estratégicos.

## Comportamento dos Humunculus

Usar buffs e habilidades de suporte quando o dono precisar. ~~O script não verifica o tipo específico de Homunculus; em vez disso, verifica se o Homunculus possui uma determinada habilidade e a utiliza conforme necessário.~~

Aqui estão alguns exemplos de comportamento esperado para diferentes tipos de Homunculus:

### LIF

- Usar `Cura pelas Mãos` quando o dono estiver com uma certa porcentagem de HP perdida.
- Usar `Bater em Retirada` quando o dono levar dano.

## AMISTIR

- Usar `Troca de Lugar` quando o dono estiver morrendo.
- Usar `Fortaleza` quando o dono levar dano.
- Usar `Desejo por Sangue` quando o Homunculus entrar em combate.

## EIRA

- Usar `Luz da Vida` quando o dono estiver morto.

## docs

[AI_MANUAL](http://winter.sgv417.jp/alchemy/download/official/AI_manual_en.html)
