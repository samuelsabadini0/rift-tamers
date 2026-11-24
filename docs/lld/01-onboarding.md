# Onboarding

**Em 10 minutos o jogador captura dois bosses, monta a Toca, treina o time e libera o modo automático, sem ler uma única tela de texto.** A meta é que 90% dos jogadores capturem o primeiro boss em menos de 3 minutos e que 70% cheguem ao fim do onboarding.

## Princípios

- **Ensinar fazendo.** Nenhuma tela de regras. O guia fala no máximo 12 palavras por vez, num balão no canto, e sempre aponta o alvo com seta ou brilho.
- **Um conceito por passo.** É o *chunking* de Koster: mover, atacar, habilidade, esquiva, captura, Toca, coleta, treino, chance. Nunca dois ao mesmo tempo.
- **Sem derrota nos 3 primeiros minutos.** Na fenda tutorial a vida não cai abaixo de 1.
- **Algo sobe, cai ou brilha a cada 20 a 30 segundos.** Abate, barra, fragmento, Ouro, Poder.
- **Celular primeiro.** Tudo se faz com o polegar; cada dica tem versão para toque, teclado e controle.
- **Nada de compra nem de anúncio falso.** A primeira oferta só aparece no último passo, e só se o jogador não acabou de perder.
- **Tudo medido.** Cada passo registra um evento com `AnalyticsService:LogOnboardingFunnelStepEvent`, para ver em que ponto o jogador desiste.

## O guia: Tuco, o Guardião das Fendas

Uma tartaruga velha e baixinha, com um lampião aceso no casco que muda de cor conforme o elemento da fenda. É gentil, animado e um pouco desajeitado. Fala curto e comemora tudo ("Opa!", "Isso aí!"). Nunca pressiona o jogador a comprar nada.

Depois do onboarding, o Tuco fica na praça: entrega as missões diárias, explica sistemas novos quando eles liberam e solta pistas dos bosses secretos ("Dizem que alguém acende lanternas no fundo do bosque…"). No MVP ele não tem voz gravada: só balão de texto e um som curto de "blip" a cada fala.

## Roteiro passo a passo

São 19 passos em 3 atos. A coluna "Avança quando" diz a condição exata para o próximo passo e o que o jogo faz se o jogador travar. Nas falas, *{parceiro}* é o nome do monstro inicial escolhido.

### Ato 1: a primeira fenda (0:00 a 2:30)

| Passo | Tempo | O que acontece | Fala do Tuco | Avança quando |
| --- | --- | --- | --- | --- |
| `ftue_01_spawn` | 0:00 | O jogador surge na clareira do hub. A câmera passeia por 3 s: Tuco, três pedestais com filhotes e o portal brilhando. | "Opa! Uma fenda se abriu. Escolha um parceiro!" | Toca num pedestal. Travou 8 s: os pedestais pulsam e uma seta aponta o do meio. |
| `ftue_02_starter` | 0:10 | Três cartões grandes: **Fagulho** (Fogo), **Marolo** (Água) e **Raminho** (Natureza), cada um com uma animação curta e a habilidade que empresta. | "Não tem escolha errada. Vocês vão crescer juntos." | Confirma a escolha. O parceiro (Comum, Poder 12) pula de alegria e passa a seguir o jogador. Travou 15 s: "Toque em quem você achou mais legal." |
| `ftue_03_move` | 0:20 | Uma trilha de setas no chão leva ao portal, a 25 studs. | "Vem comigo até o portal!" | Entra no portal. Travou 10 s: aparece um analógico fantasma animado (ou as teclas WASD no PC). |
| `ftue_04_first_kills` | 0:30 | Fenda tutorial na Clareira do Musguinho. Chegam 5 Brotinhos bem lentos. Cada abate solta um número saltando e um fragmento que voa até o jogador. | "Chegue perto. O {parceiro} ataca sozinho!" | 5 abates. Travou 10 s: os Brotinhos andam até o jogador. |
| `ftue_05_bar` | 0:45 | A barra da fenda aparece no topo da tela com um brilho. Chega uma onda de 8 Brotinhos. | "Cada inimigo enche a barra. Vamos encher!" | Barra em 50%. |
| `ftue_06_skill` | 1:00 | Um grupo de 10 Brotinhos chega junto. O botão de habilidade brilha e o tempo desacelera para 50% enquanto o grupo se aproxima. | "Muitos juntos? Golpe especial!" | Usa a habilidade e acerta 3 ou mais. Aparece "MULTI!" e cai uma chuva de fragmentos. Travou 6 s: um dedo animado aparece sobre o botão, e o tempo segue lento até o toque. |
| `ftue_07_portal` | 1:20 | A barra enche, o portal do boss se abre com um som grave e a câmera mostra o portal por 1 s. | "O dono da clareira acordou. Entre!" | Entra no portal. Travou 8 s: trilha de setas até ele. |
| `ftue_08_dodge` | 1:30 | Arena redonda. O Musguinho entra rolando, com a faixa "MUSGUINHO · Comum · Natureza" e o ícone de fraqueza a Fogo. Ele prepara a investida: uma faixa vermelha aparece no chão por 1,2 s. | "Viu a marca no chão? Saia do caminho!" | Desvia da primeira investida (esquiva ou andando para o lado). Travou: a primeira investida para antes de acertar e o botão de esquiva pulsa. |
| `ftue_09_boss_fight` | 1:40 | Luta curta: no tutorial o Musguinho tem vida reduzida para cair em uns 20 s. Ele repete a investida a cada 5 s. | Em 50% de vida: "Isso! Continue assim!" | O boss chega a 15% de vida e fica tonto, com estrelinhas girando. |
| `ftue_10_capture` | 2:00 | O botão central vira o Cristal de Selo e o anel de timing aparece. A chance mostra "100% · primeira captura". O cristal treme 1, 2, 3 vezes… **CAPTURADO!**, com confete e o cartão do monstro (raridade, tamanho e mutação). | "Agora! Toque quando a luz passar no dourado!" | Toca no cristal, com qualquer timing. Travou 5 s: o anel fica mais lento e o botão pulsa; aos 10 s o cristal é lançado sozinho. |
| `ftue_11_chest` | 2:15 | Baú do tutorial: 500 Ouro e 10 Fragmentos, com contador subindo. | "Tudo seu! Agora vamos para casa." | Toca no baú. Um portal leva de volta ao hub. |

Na primeira captura, tamanho e mutação são sorteados normalmente, mas o resultado nunca é Mini. Assim, o primeiro monstro já pode sair Dourado, e isso vira história para contar.

### Ato 2: a Toca (2:30 a 4:00)

| Passo | Tempo | O que acontece | Fala do Tuco | Avança quando |
| --- | --- | --- | --- | --- |
| `ftue_12_lair` | 2:30 | A câmera mostra a Toca do jogador: um terreno com 4 vagas vazias e uma placa com o nome dele. | "Esta é a sua Toca. Coloque o Musguinho aqui!" | Coloca o Musguinho numa vaga. Aparece "+6 Ouro/s" e moedas começam a pingar no cofre. Travou: a vaga pisca e uma seta aponta o cartão do Musguinho. |
| `ftue_13_collect` | 2:50 | O cofre já tem 100 Ouro de presente, com moedas flutuando em cima. | "Seu cofre enche sozinho. Toque para coletar!" | Coleta. Chuva de moedas e o contador de Ouro sobe. |
| `ftue_14_train` | 3:10 | O Poste de Treino da Toca brilha. O próximo portal mostra "Poder recomendado: 25". | "Ouro deixa o time mais forte. Treine o {parceiro}!" | Treina o parceiro 2 níveis (200 e 250 Ouro). O Poder do time sobe de 20 para 22, com os números contando. Travou: seta no botão "Treinar". |

### Ato 3: chance e autonomia (4:00 a 10:00)

| Passo | Tempo | O que acontece | Fala do Tuco | Avança quando |
| --- | --- | --- | --- | --- |
| `ftue_15_rift2` | 4:00 | O portal da Fenda 2, a Lagoa do Sapo-Lanterna, ganha brilho. Daqui em diante valem as regras normais, mas o primeiro reviver é grátis. Dentro da fenda, o Tuco só fala quando algo novo aparece pela primeira vez. | "Tem um sapo bagunçando a lagoa. Vamos?" Na fenda: "Tiro de longe? Vá até ele!" e "Círculo no chão? Saia dele!" | Entra no portal. |
| `ftue_16_chance` | 6:30 | Captura com chance de verdade: "80% · 4 em 5", e o anel mostra "Bom +10%" e "Perfeito +25%". | "Agora não é garantido. Mire no dourado!" | Sai o resultado. Se falhar: "Não foi dessa vez. Ganhou uma Marca de Caça: +5% na próxima!" O baú vem do mesmo jeito. |
| `ftue_17_hard_auto` | 7:00 | De volta à praça, o portal da Fenda 1 mostra a opção Difícil (Poder recomendado 30). Nos primeiros 30 s, o modo automático roda como prévia, com o selo "AUTO · prévia", e depois devolve o controle. | "Vencendo no Difícil, eu libero o automático aqui." | Vence a Fenda 1 no Difícil. O botão AUTO fica liberado nesse portal. |
| `ftue_18_dex` | 9:00 | O Tuco abre o Monstrodex: 2 monstros capturados e o resto em silhueta, com a linha "Musguinho Alfa · 1 em 50 partidas". Se alguém do servidor capturou um Mítico nos últimos 10 minutos, a câmera mostra esse anúncio real na praça no lugar da silhueta. | "Cada boss tem versões raras. Já imaginou um Musguinho Alfa?" | Fecha o Monstrodex. |
| `ftue_19_done` | 10:00 | Recompensa de formatura: título "Domador Novato" e 2 Cristais Grandes. Logo depois, o cartão do Pacote Inicial aparece uma vez. | "Agora você é um Domador de Fendas! Estou sempre na praça." | Fecha o cartão do pacote (comprando ou não). O onboarding termina e as missões diárias liberam. |

Economia dos primeiros 10 minutos, para conferir no teste: 500 Ouro do baú tutorial, 100 de presente no cofre e cerca de 6 Ouro/s do Musguinho. O treino do passo 14 custa 450, então o jogador sempre tem Ouro para ele. No passo 17, o time (parceiro no nível 3, Sapo-Lanterna e Musguinho) soma cerca de 40 de Poder contra 30 recomendado no Difícil.

## Regras de segurança

- **Retomar:** o progresso salva a cada passo. Quem sai no meio volta no começo do ato em que estava, sem perder o que capturou.
- **Pular dicas:** depois do passo 3 aparece o botão "Pular dicas". Ele só cala o Tuco; a captura garantida, o baú e os presentes continuam. Não existe pular a fenda tutorial, porque é nela que o jogador ganha o primeiro monstro.
- **Derrota na Fenda 2:** o jogador volta na hora, o Tuco diz "Quase! Treine mais um nível e tente de novo" e dá 200 Ouro uma única vez, o suficiente para mais um nível. Nenhuma oferta de compra aparece.
- **Pacote Inicial:** 99 Robux, com 3 Cristais Mestre, 300 Gemas e uma skin, como na visão geral. O cartão aparece uma vez no passo 19. Se a última fenda terminou em derrota ou em captura que falhou, ele espera a próxima vitória. Depois fica na aba Ofertas da loja até ser comprado, sem contagem regressiva.
- **Anúncios:** nenhum anúncio em vídeo e nenhum pop-up de oferta durante o onboarding.
- **Jogador que volta:** quem já tem save nunca vê o onboarding de novo. Se um sistema novo liberar depois (Ascensão, duelo), o Tuco o apresenta em no máximo 3 falas.
- **Metas para o teste:** 90% chegam ao passo 10 em menos de 3 minutos, 80% chegam ao passo 16 e 70% chegam ao passo 19. Se um passo perde mais de 10% dos jogadores, ele é redesenhado antes do lançamento.
