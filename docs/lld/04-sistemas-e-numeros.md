# Sistemas e números

**Tudo no combate sai de um número só: o Poder.** A vida do time, o dano e a dificuldade de cada inimigo são frações do Poder do time ou do Poder recomendado da fase. Assim, para balancear, basta mexer no Poder recomendado; o resto acompanha.

## Atributos e fórmulas

**Poder de um monstro:**

```latex
Poder = PB \cdot (1 + 0{,}08 \cdot (N - 1)) \cdot (1 + 0{,}2 \cdot (E - 1))
```

Na fórmula, *PB* é o Poder base da espécie (já com o bioma e o papel embutidos, como no Bestiário), *N* é o nível (de 1 a 100) e *E* são as estrelas (de 1 a 5). Tamanho e mutação mexem só na renda e no visual, nunca no Poder. A regra para a criança é simples: "espécie, nível e estrelas deixam mais forte; tamanho e mutação deixam mais rico".

- **Poder do time (P):** a soma do Poder dos 3 monstros do time. É o número grande no HUD, e é ele que se compara com o Poder recomendado.
- **Vida do time:** 10 × P, numa barra só, compartilhada pelo avatar e pelo monstro principal.
- **Ataque básico:** o monstro principal dá 2 golpes por segundo de 0,25 × P cada (0,5 × P por segundo) no inimigo mais próximo, até 12 studs do jogador. Usa o elemento do monstro principal.
- **Crítico:** 5% de chance de dano em dobro. O Raio da Luz é sempre crítico.
- **Vantagem de elemento:** +50% de dano causado. Se o monstro principal tem vantagem sobre o atacante, o time recebe 25% menos dano.
- **Esquiva:** 12 studs, recarga de 3 s, invulnerável por 0,4 s.
- **Posição:** frente, lado e costas são medidos a partir do jogador. O monstro principal fica sempre a até 4 studs dele.
- **Cura:** não há regeneração em combate. Entre um estágio e outro o time recupera 30% da vida; 5% dos inimigos derrubados soltam uma Gota de Vida (cura 10%); a arena do boss tem 2 flores de cura (25% cada, uma vez só).

**Habilidades.** Cada monstro do time empresta a habilidade do seu elemento, e o boss muda um detalhe dela (o tempero do Bestiário).

| Elemento | Habilidade | Dano | Área | Efeito | Recarga |
| --- | --- | --- | --- | --- | --- |
| Fogo | Explosão | 3 × P | Cone de 90° e 14 studs | — | 8 s |
| Água | Onda | 1,5 × P | Cone de 60° e 18 studs | Empurra e junta os inimigos 6 studs à frente | 6 s |
| Natureza | Raízes | 1 × P | Círculo de 10 studs no alvo | Prende por 2 s | 10 s |
| Luz | Raio | 2 × P (sempre crítico: 4 × P) | Linha de 30 por 3 studs | — | 9 s |
| Sombra | Vórtice | 1 × P | Círculo de 14 studs | Puxa todos para o centro | 12 s |

## Inimigos em números

A vida dos inimigos é uma fração do Poder recomendado (PR) da fase, já multiplicado pela dificuldade. O dano é uma porcentagem da **vida de referência**, que é a vida de um time com exatamente o PR (10 × PR). Com mais Poder, o mesmo golpe pesa menos.

| Inimigo | Vida | Dano por golpe | Ritmo | Velocidade (studs/s) | Pontos na barra |
| --- | --- | --- | --- | --- | --- |
| Brotinho | 0,25 × PR | 2% | 1 por segundo, encostado | 8 | 1 |
| Vagalume-Faísca | 0,2 × PR | 4% | 1 tiro a cada 2,5 s | 10 | 1 |
| Lesma de Musgo | 0,6 × PR | 3% | 1 por segundo, encostada | 5 | 2 |
| Lobo de Folhas | 0,15 × PR | 5% | Bote a cada 3 s | 18 | 1 |
| Areinha | 0,25 × PR | 3% | 1 por segundo, encostada | 10 | 1 |
| Cristalino | 0,2 × PR | 15% na explosão | Ao morrer | 6 | 1 |
| Escorpinho | 0,3 × PR | 10% | Ferroada a cada 3 s | 9 | 1 |
| Abutre Prisma | 0,2 × PR | 15% | Mergulho a cada 5 s | 14 (voando) | 1 |
| Ent Guardião (elite) | 6 × PR | 15% | Soco a cada 4 s | 6 | 15 |
| Xamã Cogumelo (elite) | 4 × PR | — | Invoca a cada 6 s | Parado | 15 |
| Golem de Vidro (elite) | 8 × PR | 15% | Tapa a cada 4 s | 5 | 15 |
| Mago das Dunas (elite) | 5 × PR | 20% no anel | Feitiço a cada 6 s | Teleporta | 15 |
| Boss | 40 × PR | Na ficha da fase | Na ficha da fase | 10 | — |
| Rei | 60 × PR | Na ficha da fase | Na ficha da fase | 10 | — |

O avatar anda a 16 studs/s, o padrão do Roblox. Só o Lobo de Folhas é mais rápido que o jogador; ele é frágil de propósito, para ensinar a lutar em vez de fugir. Em grupo, a vida de todos os inimigos sobe 70% por jogador extra.

**Conferência rápida:** com o Poder igual ao recomendado, um Brotinho cai em meio segundo só com o ataque básico, e uma Explosão limpa um grupo inteiro. O boss leva cerca de 60 s de luta e o Rei cerca de 90 s, dentro da faixa de 60 a 120 s da visão geral.

## Dificuldade, loot e regra anti-farm

| Dificuldade | Poder recomendado | Loot | Abre quando | Extra |
| --- | --- | --- | --- | --- |
| Normal | 1x | 1x | A fase anterior foi vencida no Normal | — |
| Difícil | 3x | 1,5x | Esta fase foi vencida no Normal | A primeira vitória libera o modo automático nesta fenda |
| Pesadelo | 9x | 2,25x | Esta fase foi vencida no Difícil e o Rei do bioma foi vencido | Único lugar da variante Ancestral (1 em 500) |

**Loot de uma vitória:** Ouro igual a 60 vezes a renda base do boss, os Fragmentos da ficha da fase e a tentativa de captura, tudo multiplicado pelo loot da dificuldade. O baú ainda tem 10% de chance de um Cristal Grande e 3% de uma Poção de Sorte de 5 minutos. A primeira vitória em cada fenda dá +10 Gemas, e em cada Rei, +50.

**Regra anti-farm:** se o Poder do time é 3 vezes maior que o recomendado da dificuldade escolhida, Ouro e Fragmentos caem pela metade. A chance de Alfa continua igual, para a fenda fácil não ficar sem graça. O portal avisa antes de entrar: "Esta fenda ficou fácil demais. Tente o Difícil!" É a regra de Koster: o jeito mais eficiente de jogar precisa ser também o mais divertido.

**Cristais:**

| Cristal | Multiplica a chance | Como se consegue |
| --- | --- | --- |
| Comum | 1x | Grátis e ilimitado |
| Grande | 1,5x | 1.000 Ouro no Bosque e 10.000 nas Dunas; baú (10%) |
| Mestre | 2x | 60 Fragmentos na Forja; calendário; Pacote Inicial |
| Supremo | Captura garantida | 99 Robux ou 150 Gemas |

**Forja (gasto de Fragmentos):** Cristal Mestre por 60, Poção de Sorte de 5 minutos por 40 e cosméticos do bioma a partir de 200. O Despertar do parceiro inicial também consome Fragmentos.

## Onde ficam os monstros, níveis e estrelas

- **Bolsa:** guarda todos os monstros capturados, sem limite no MVP. É a coleção. Monstro só na Bolsa não rende.
- **Toca:** de 4 a 12 vagas (16 com o passe). Só quem está numa vaga gera Ouro.
- **Time:** 3 monstros escolhidos da Bolsa ou da Toca. Quem está no time e também numa vaga rende 25% enquanto luta.

**Custo de nível:** subir do nível *N* para o *N + 1* custa 200 × 1,25^(N − 1) Ouro. A visão geral falava em 15% de aumento por nível; a calibração com a curva da planilha pediu 25%, e a visão geral foi atualizada.

| Nível | Custo para o próximo nível | Custo total desde o nível 1 | Poder |
| --- | --- | --- | --- |
| 2 | 250 | 200 | 1,08x |
| 3 | 312 | 450 | 1,16x |
| 5 | 488 | 1.153 | 1,32x |
| 10 | 1.490 | 5.160 | 1,72x |
| 15 | 4.547 | 17.390 | 2,12x |
| 20 | 13.878 | 54.711 | 2,52x |
| 25 | 42.352 | 168.607 | 2,92x |
| 30 | 129.247 | 516.188 | 3,32x |
| 35 | 394.430 | 1.576.922 | 3,72x |
| 40 | 1.203.706 | 4.814.025 | 4,12x |

O Poste de Treino tem três botões: "+1", "+10" e "Até o recomendado", que mostra o custo antes de confirmar. O nível máximo é 100, e a Ascensão zera os níveis.

**Estrelas:** fundir cópias da mesma espécie custa 1, 2, 4 e 8 cópias (15 no total até 5★). Cada estrela dá +20% de Poder e +10% de renda, e o visual muda na 3★ e na 5★. A fusão fica com o maior tamanho, a melhor mutação e o maior nível entre as cópias, então fundir nunca faz perder nada.

**Libertar:** soltar uma cópia repetida rende o Ouro de 10 minutos da renda dela. O jogo pede confirmação quando a cópia tem mutação ou tamanho Gigante ou maior.

**Despertar:** o parceiro inicial sobe de estrela com Fragmentos (100, 300, 800 e 2.000), como no Bestiário.

## Captura: o minijogo do Cristal de Selo

É o pico de dopamina do jogo, então cada etapa tem tempo marcado. A fórmula é a da visão geral:

```latex
Chance = \min\left(95\%,\; B_{raridade} \cdot C_{cristal} \cdot (1 + T_{timing}) \cdot (1 + S_{sorte}) + 5\,p.p. \cdot Marcas\right)
```

**Sequência:**

1. **Atordoado (0 s):** com 15% de vida, o boss fica tonto, com estrelinhas girando. A música abaixa e a câmera aproxima 10%.
2. **Painel de chance:** o botão central vira o Cristal de Selo, e acima dele aparece a chance em porcentagem e em "1 em X" (ex.: "65% · 1 em 1,5"). Tocar no número abre a conta: base, cristal, sorte e Marcas. Uma seta troca o cristal.
3. **Anel de timing:** uma luz gira em volta do botão. A faixa **Bom** ocupa 25% da volta e a **Perfeito** ocupa 8%, no meio da Bom; a posição das faixas muda a cada tentativa. A luz dá uma volta em 1,4 s nos bosses Comuns e Incomuns, 1,2 s nos Raros e Épicos, 1,0 s nos Lendários e 0,8 s nos Míticos para cima.
4. **Lançamento:** um toque lança o cristal e mostra "PERFEITO!" (+25%), "BOM" (+10%) ou "OK" (sem bônus). Sem toque em 8 s, o cristal é lançado sozinho com "OK".
5. **Tremidas:** o cristal treme até 3 vezes, 0,6 s cada. Cada tremida é um sorteio real com a raiz cúbica da chance total, então o cristal quebra na 1ª, 2ª ou 3ª tremida de forma honesta. Não existe "quase" fabricado.
6. **Resultado:** se der certo, aparece "CAPTURADO!" e o cartão se revela em três batidas de 0,4 s: raridade, tamanho e mutação, com um som especial se houver mutação. Os botões são "Para a Toca" e "Para o time". Se der errado, o cristal racha, o boss foge numa nuvem de fumaça e aparece "+1 Marca de Caça: +5% na próxima". O baú vem do mesmo jeito.

**Regras:**

- **Marcas de Caça:** +5 pontos percentuais por falha na mesma espécie, zeradas na captura.
- **Modo automático:** lança sempre com "Bom".
- **Sorteio no servidor:** o servidor define a posição das faixas e o início do giro. O cliente só envia o momento do toque, que o servidor aceita com 100 ms de tolerância para latência. Chance, tamanho e mutação são sorteados no servidor.
- **Sem oferta depois de falhar:** a tela de falha nunca mostra loja nem o Cristal Supremo. Ele só aparece no seletor de cristal, antes do lançamento.

## Recompensas diárias, missões e Monstrodex

**Calendário de 7 dias:** acumulativo; perder um dia não zera, só pausa. Os prêmios em Ouro são medidos em minutos da renda do jogador, para valer a pena em qualquer fase do jogo.

| Dia | Prêmio |
| --- | --- |
| 1 | Ouro de 10 minutos de renda |
| 2 | 2 Cristais Grandes |
| 3 | 20 Gemas |
| 4 | Poção de Sorte de 5 minutos |
| 5 | Ouro de 30 minutos de renda |
| 6 | 3 Cristais Grandes |
| 7 | Cristal Mestre e 50 Gemas |

Depois do dia 7, o ciclo recomeça.

**Missões diárias:** 3 por dia, sorteadas desta lista. Cada uma dá 10 Gemas e 5 minutos de renda; fazer as 3 dá mais 10 Gemas, o que fecha 40 Gemas por dia, dentro da meta de 30 a 50 da visão geral.

- Capture 2 bosses.
- Vença 3 fendas.
- Use 30 habilidades.
- Derrote 200 inimigos.
- Faça 1 captura Perfeita.
- Colete o cofre 3 vezes.
- Treine monstros 5 níveis.
- Vença 1 fenda no Difícil.
- Derrote 3 elites.
- Vença 1 fenda com vantagem de elemento.

**Boss do Dia:** uma fenda sorteada por dia, a mesma em todos os servidores. Nela, as chances de mutação dobram e o Alfa aparece em 1 de cada 25 partidas. A tela de chances mostra os valores dobrados.

**Monstrodex:**

| Marco | Recompensa |
| --- | --- |
| Primeira captura de cada espécie | 5 Gemas |
| Primeira captura de cada variante (Alfa, Ancestral ou Secreto) | 20 Gemas |
| As 6 espécies de um bioma | +5% de renda permanente e o título "Explorador do Bosque" ou "Explorador das Dunas" |
| Todas as 6 mutações de uma mesma espécie | Aura cosmética dessa espécie |

As espécies que faltam aparecem em silhueta, com a fenda onde vivem. As variantes e os secretos aparecem como "???" até o primeiro encontro, para alimentar a curiosidade e as conversas entre jogadores.
