# Interface e feedback

**A tela sempre responde a três perguntas: quanto eu tenho, quanto estou ganhando e qual é o próximo objetivo.** Tudo é pensado primeiro para o celular na horizontal, com o polegar esquerdo no analógico e o direito nos botões.

## Telas e HUD

### HUD no hub

- **Topo à esquerda:** Ouro, com o Ouro/s em verde logo abaixo, Gemas e Fragmentos.
- **Topo ao centro:** o Poder do time em número grande e o próximo objetivo ("Fenda 4: Poder 80 · faltam 12").
- **Topo à direita:** Monstrodex, Loja e Configurações.
- **Lateral esquerda:** as 3 missões do dia com barra de progresso e o calendário com selo quando há prêmio.
- **Base:** Time, Bolsa, Toca (leva para casa) e Portais.
- **Faixa do topo:** anúncios globais de capturas Míticas ou melhores.

### HUD na fenda

- **Topo:** barra da fenda com o estágio (1 ou 2) e a porcentagem. Na luta do boss, ela vira a barra do boss, com nome, raridade, elemento, ícone de fraqueza e uma linha dourada nos 15% que marca a captura.
- **Topo à esquerda:** vida do time e Poder.
- **Base à esquerda:** analógico.
- **Base à direita:** botão grande de esquiva e as 3 habilidades em arco, com recarga em círculo e a cor do elemento. O botão AUTO aparece quando estiver liberado.
- **Sem cronômetro:** nada de pressão de tempo. O tempo da partida só aparece no resultado, como recorde.

### Telas

| Tela | Abre por | O que mostra | Ação principal |
| --- | --- | --- | --- |
| Portal | Chegar perto de um portal | Boss, Poder recomendado em cada dificuldade comparado ao seu (verde, amarelo ou vermelho), loot previsto, chance de Alfa e o aviso anti-farm | Entrar, escolher dificuldade, ligar o AUTO |
| Time | Botão Time | 3 vagas e a lista de monstros com Poder, elemento e habilidade, destacando quem tem vantagem na próxima fenda | "Melhor time" monta o time sozinho |
| Bolsa | Botão Bolsa | Grade de cartões com filtros por raridade, elemento e mutação e ordem por renda ou Poder | Treinar, fundir, libertar |
| Cartão do monstro | Tocar num monstro | Modelo 3D girando, raridade, tamanho, mutação, estrelas, Poder, renda/s e habilidade | Para a Toca, para o time, treinar |
| Toca | Andar até ela (fica no mundo, não é tela) | Vagas físicas, Poste de Treino, Cofre, Fonte Mágica e Pedestal, cada um com um botão de proximidade | Coletar, treinar, melhorar |
| Resultado | Fim da fenda | Contador de Ouro e Fragmentos subindo e os itens do baú | Voltar ao hub ou jogar de novo |
| Monstrodex | Botão Monstrodex | Grade por bioma, com silhuetas e "???" para o que falta | Ver onde cada um vive |
| Loja | Botão Loja | Abas Ofertas, Passes, Gemas, Cristais e Cosméticos. Todo item aleatório tem o botão "Chances" | Comprar |
| Ascensão | Estátua da Ascensão no hub | O que zera, o que fica, o multiplicador e a mecânica nova | Confirmar duas vezes |
| Configurações | Botão de engrenagem | Som, música, qualidade dos efeitos (automática ou leve), vibração, idioma, reduzir tremidas e clarões, pular dicas | — |

## Feedback e sensação de impacto

O "juice" é o que transforma um número subindo numa sensação. Cada evento tem efeito visual, som e uma reação da interface ou da câmera. Os efeitos saem do plugin de VFX, e todos têm versão leve para celulares fracos.

| Evento | Efeito visual | Som | Interface e câmera |
| --- | --- | --- | --- |
| Abate comum | Estouro pequeno na cor do elemento e número de dano saltando | "Pop" curto, com tom variando um pouco a cada vez | — |
| 5 ou mais abates em 1 s | Texto "MULTI x5!" que cresce | Notas em escada subindo | Tremida leve de 0,1 s |
| Crítico | Número amarelo maior, com "!" | "Tink" metálico | — |
| Fragmento coletado | Voa em arco até o jogador, como ímã | "Plim" que sobe de tom em sequência | O contador pulsa |
| Habilidade | Efeito do elemento | Grave com brilho agudo | Pausa de 50 ms se acertar 5 ou mais |
| Dano recebido | O avatar pisca | Batida seca | Borda vermelha por 0,2 s e vibração curta no celular |
| Aviso de ataque | Marca vermelha no chão que enche de fora para dentro até o golpe | Som de carga crescendo | — |
| Esquiva no último instante | Rastro azul e o texto "PERFEITO" | "Whoosh" | Câmera lenta por 0,2 s |
| Barra cheia | Portal abre com raios | Corneta | A câmera mostra o portal por 1 s |
| Elite surge | Marcador vermelho sobre ele | Rugido | Seta na borda da tela |
| Bolsinho Dourado | Trilha de moedas por onde ele passa | Sininho único | Seta dourada na borda da tela |
| Boss entra | Apresentação com nome, raridade e elemento | Tema do boss | Câmera de apresentação por 2 s |
| Boss na fase 2 | A aura muda de cor | Rugido e música mais rápida | A tela pulsa uma vez |
| Boss tonto (15%) | Estrelinhas girando | A música abaixa | Câmera aproxima 10% |
| Lançamento Perfeito | O anel dourado explode | "Ding" cristalino | Clarão suave |
| Cada tremida do cristal | O cristal balança | "Tum", mais alto a cada vez | Câmera aproxima 3% |
| Capturado | Confete e um raio de luz vertical na cor da raridade | Fanfarra, mais longa quanto maior a raridade | O cartão sobe do cristal |
| Mutação revelada | O material brilha | Som exclusivo de cada mutação | Do Arco-íris para cima, a tela escurece 0,3 s antes |
| Captura falhou | O cristal racha e solta fumaça | "Puff" suave, sem som triste | Aparece a Marca de Caça ganha |
| Baú | Raio na cor do melhor item | Tique-taque acelerando | Contador subindo |
| Coletar o cofre | Chuva de moedas na Toca | Cascata de moedas | Número grande subindo |
| Treinar | O monstro brilha e cresce 5% por 0,3 s | "Power up" | O Poder conta até o novo valor |
| Fenda nova liberada | O portal acende no hub | Sino | Seta até o portal |
| Anúncio global | Faixa dourada no topo para o servidor inteiro | Fanfarra curta | Nome do jogador e do monstro |

## Textos, tom de voz e acessibilidade

- **Tom:** um amigo animado. Frases de até 12 palavras, falando com "você", sem gírias regionais fortes e sem ironia, que criança pequena não pega.
- **Exemplos certos:** "CAPTURADO!", "Quase! Tente de novo.", "Esta fenda ficou fácil demais. Tente o Difícil!"
- **Proibido:** "Compre agora!", "Última chance", "Só hoje" e qualquer frase que pressione a compra.
- **Números grandes:** em português, "1,5 mil", "2,3 mi", "4 bi" e "7 tri"; em inglês, K, M, B e T. Sempre com no máximo 3 algarismos e uma casa decimal.
- **Idiomas:** português e inglês no lançamento, espanhol depois. Todo texto mora numa LocalizationTable, com chaves como `ftue.tuco.01`.
- **Daltonismo:** cor nunca vem sozinha. A raridade tem cor e uma gema de formato diferente; o elemento tem cor e ícone.
- **Leitura:** texto de no mínimo 14 px no celular e contraste que passa no nível AA.
- **Conforto:** a opção "reduzir tremidas e clarões" troca o clarão do Escorpião Prisma por um escurecimento suave e desliga a tremida de câmera.
- **Som:** todo aviso sonoro importante também tem aviso visual, então dá para jogar sem som.
- **Nomes dados pelo jogador:** passam pelo `TextService:FilterStringAsync` antes de aparecer para outras pessoas.
