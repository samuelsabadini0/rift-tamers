# Rift Tamers (nome provisório)

**Entre na fenda, limpe as hordas, derrote o boss, e ele passa a ser seu.** Jogo de Roblox que junta a dungeon de hordas por portal (no estilo Chaos Dungeon) com a coleção de monstros que rendem Ouro por segundo (no estilo Steal a Brainrot e Fish It). O design segue a *Theory of Fun*, de Raph Koster.

**Situação:** o design do MVP está fechado. O próximo passo é a Fase 0, um protótipo cinza no Roblox Studio, que ainda não começou.

## Comece por aqui

| Documento | Para quem | O que tem |
| --- | --- | --- |
| [Resumo em 1 página](docs/00-resumo.md) | Quem precisa entender e comprar a ideia | O jogo, uma partida em 4 minutos, por que prende, público, monetização e próximo passo |
| [Visão geral (HLD)](docs/01-visao-geral-hld.md) | Todo o time | O macro: referências, regras da Theory of Fun, loops, biomas, Ascensão, PvP, monetização, limites do Roblox e roadmap |
| [Design detalhado (LLD)](docs/02-design-detalhado-lld.md) | Quem vai construir | O micro, em 6 partes (abaixo) |

O design detalhado está dividido em:

1. [Onboarding](docs/lld/01-onboarding.md): os primeiros 10 minutos em 19 passos, com as falas do guia Tuco.
2. [Fases 1 a 12](docs/lld/02-fases-1-a-12.md): as 12 fases do MVP (Bosque Musgoso e Dunas de Cristal), com arena, ondas, elite, boss, loot e segredos.
3. [Bestiário](docs/lld/03-bestiario.md): parceiros iniciais, os 12 bosses, variantes, bosses secretos, inimigos e direção de arte para o Blender.
4. [Sistemas e números](docs/lld/04-sistemas-e-numeros.md): fórmulas de combate, níveis, captura, cristais, missões e recompensas.
5. [Interface e feedback](docs/lld/05-interface-e-feedback.md): HUD, telas, o "juice" de cada evento e acessibilidade.
6. [Produção e primeiro sprint](docs/lld/06-producao-e-primeiro-sprint.md): lista de assets, estrutura no Roblox Studio, eventos remotos, formato do save e o sprint do protótipo.

## Balanceamento

[`balanceamento/rift-tamers-balanceamento.xlsx`](balanceamento/rift-tamers-balanceamento.xlsx) tem as abas:

- **Como usar:** legenda de cores e o que cada aba faz.
- **Premissas:** todas as alavancas (raridade, tamanho, mutação, papéis, Poder base, combate, Toca, Ascensão).
- **Renda:** calculadora da renda de um monstro.
- **Curva MVP:** os 12 bosses em ordem, o tempo-alvo de cada passo e o custo em Ouro (a 1ª Ascensão cai em cerca de 4 horas).
- **Ascensões:** Ouro sugerido para cada Ascensão.
- **Combate:** Poder recomendado, vida do boss, Ouro por vitória e o nível do time em cada fase.

Texto azul é valor para editar; fundo amarelo é alavanca principal; texto preto é fórmula.

Para gerar a planilha de novo a partir do script (precisa de Python com `openpyxl`):

```bash
python balanceamento/build_balance.py balanceamento/rift-tamers-balanceamento.xlsx
```

O script grava só as fórmulas. Os valores aparecem quando a planilha é aberta no Excel ou recalculada no LibreOffice.

## Ferramentas previstas

- **Blender + MCP:** modelos e animações low poly.
- **Roblox Studio + MCP:** scripts, montagem dos mapas e playtests.
- **Plugin de VFX do Roblox:** efeitos de habilidade, captura e raridade.
