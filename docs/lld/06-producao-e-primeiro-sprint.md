# Produção e primeiro sprint

**Esta aba transforma o design em trabalho: o que precisa ser feito, onde cada coisa mora no Roblox Studio e qual é o primeiro sprint.** O primeiro sprint é o protótipo cinza do roadmap e só começa com o seu OK.

## Lista de assets do MVP

| Categoria | O que entra | Quantidade | Ferramenta |
| --- | --- | --- | --- |
| Criaturas | 3 parceiros, 12 bosses, 2 secretos, 8 inimigos comuns, 4 elites, o Bolsinho Dourado e o Tuco | 31 modelos | Blender + MCP |
| Acessórios | Formas 3★ e 5★ dos parceiros, acessórios de estrela dos bosses e extras do Alfa | cerca de 42 malhas pequenas | Blender + MCP |
| Animações | Cerca de 10 por boss, 8 por parceiro, 6 por elite, 4 por inimigo comum e 5 do Tuco | cerca de 205 clipes | Blender + MCP; ajustes no editor de animação do Studio |
| Ambientes | Kit modular do Bosque e kit das Dunas (cerca de 40 peças cada), 12 arenas e o hub com a praça, 8 Tocas e os portais | 80 peças e 13 cenários montados | Peças no Blender; montagem no Studio + MCP |
| Toca | Vaga, Poste de Treino, Cofre, Fonte Mágica, Pedestal, cerca e placa, em 3 níveis visuais | 7 peças | Blender + MCP |
| Efeitos | 5 habilidades e 12 temperos, avisos no chão (linha, círculo, cone, anel), portal, captura completa, raios das 8 raridades, 5 auras de mutação, baú, moedas e anúncio global | cerca de 50 efeitos | Plugin de VFX |
| Interface | HUD, 10 telas e ícones de elementos, raridades, moedas, cristais e habilidades | cerca de 45 ícones | Ferramenta de UI e Studio |
| Áudio | Cerca de 60 efeitos sonoros e 6 músicas (hub, Bosque, Dunas, boss, Rei e vitória) | 66 arquivos | Biblioteca licenciada da Creator Store ou encomenda |
| Textos | Todas as falas e telas em português e inglês | 1 LocalizationTable | Studio |

A ordem de produção segue as fases: primeiro tudo o que a Fase 1 usa (parceiros, Brotinho, Ent, Musguinho, Clareira, Toca), porque é o que o onboarding mostra; o resto vem fase por fase.

## Estrutura do projeto no Roblox Studio

```text
ReplicatedStorage/
  Shared/
    Config/   Monsters, Rifts, Biomes, Rarity, Mutations, Economy, Abilities, Onboarding, Shop
    Util/     Formulas (Poder, renda, chance), NumberFormat, Signal
  Remotes/    criados pelo NetService na inicialização
  Assets/     Monsters, VFX, UI
ServerScriptService/
  Services/   DataService, EconomyService, LairService, TeamService, RiftService,
              HordeService, BossService, CaptureService, LootService, ProgressionService,
              OnboardingService, QuestService, ShopService, AnnouncementService, MetricsService
  Main.server
StarterPlayer/StarterPlayerScripts/
  Controllers/ Input, Camera, HUD, Rift, Capture, Lair, Shop, Tutorial, VFX
  Main.client
ServerStorage/
  Arenas/     as 12 arenas-modelo
  Mobs/       modelos dos inimigos
Workspace/
  Hub/        praça, Tocas 1 a 8, portais
  Rifts/      arenas clonadas a 2.000 studs do hub e entre si
```

**Como as hordas funcionam sem pesar:** no servidor, cada inimigo é só uma linha de dados (posição, vida, estado), simulada 10 vezes por segundo. O servidor manda as posições em lote por um `UnreliableRemoteEvent`, e o cliente desenha cada inimigo com um modelo reaproveitado de um pool, animado por `AnimationController`, sem Humanoid e sem física. Os acertos são calculados no servidor contra esses dados. Com no máximo 40 inimigos por arena e 8 jogadores por servidor, o pior caso é 320 inimigos ao mesmo tempo.

**Regra de ouro da rede:** o cliente só envia intenções ("quero usar a habilidade 2 nesta direção"). Abates, dano, loot e capturas são sempre decididos no servidor.

| Evento remoto | Direção | Dados | O servidor confere |
| --- | --- | --- | --- |
| `EnterRift` | Cliente → servidor | Fenda e dificuldade | Se está liberada, o Poder exigido no bioma e se o jogador já não está numa fenda |
| `RiftState` | Servidor → cliente | Estágio, barra, vida do boss, eventos | — |
| `MobBatch` | Servidor → cliente (não confiável) | Posições e estados dos inimigos | — |
| `UseAbility` | Cliente → servidor | Vaga da habilidade e direção | Recarga e alcance; calcula os acertos |
| `Dodge` | Cliente → servidor | Direção | Recarga; aplica a invulnerabilidade |
| `CaptureThrow` | Cliente → servidor | Cristal e momento do toque | Se tem o cristal e se o toque caiu na faixa, com 100 ms de tolerância; sorteia o resultado |
| `CaptureResult` | Servidor → cliente | Sucesso, tamanho, mutação, tremidas | — |
| `PlaceInLair` | Cliente → servidor | Monstro e vaga | Se o monstro é dele e a vaga existe |
| `CollectVault` | Cliente → servidor | — | Calcula o valor pelo tempo desde a última coleta, até o limite do cofre |
| `Train` | Cliente → servidor | Monstro e quantidade de níveis | Se tem Ouro para o custo total |
| `Fuse` e `Release` | Cliente → servidor | Monstros | Se são dele, da mesma espécie e não estão no time |
| `SetTeam` e `ToggleAuto` | Cliente → servidor | 3 monstros; fenda | Posse; se o AUTO está liberado |
| `ClaimDaily` e `ClaimQuest` | Cliente → servidor | Dia ou missão | Data do servidor e progresso salvo |
| `TutorialStep` | Servidor → cliente | Passo do onboarding | — |
| `Announcement` | Servidor → todos | Jogador, monstro, raridade | Vem do `MessagingService` entre servidores |

As compras usam o `MarketplaceService`: o cliente só abre a janela de compra, e o `ProcessReceipt` do servidor entrega o item uma única vez por recibo.

## Dados salvos do jogador

O perfil fica no ProfileStore, com trava de sessão contra duplicação. Ele salva sozinho a cada minuto e também logo depois de cada captura, compra e saída do jogo.

```lua
Profile = {
  version = 1,
  gold = 0, gems = 0, fragments = 0,
  starter = { species = "Fagulho", stars = 1 },
  monsters = {
    -- chave = id único (HttpService:GenerateGUID)
    ["a1b2"] = { species = "Musguinho", size = "Normal", mutation = "Nenhuma",
                 variant = nil, stars = 1, level = 1, capturedAt = 0 },
  },
  lair = { slots = 4, placed = {}, fountainLevel = 0, lastCollect = 0 },
  team = {},                -- até 3 ids
  rifts = { ["bosque_1"] = { normal = false, hard = false, nightmare = false,
                             auto = false, wins = 0 } },
  huntMarks = {},           -- espécie -> número de Marcas de Caça
  secrets = { lumen = false, miragem = false },
  ascension = 0,
  dex = { species = {}, variants = {}, mutations = {} },
  daily = { calendarDay = 1, lastClaim = 0, quests = {}, questDay = 0 },
  onboarding = { step = 0, done = false, skipTips = false },
  purchases = { receipts = {}, starterPack = false },
  settings = { music = 0.6, sfx = 1, lowFx = false, reduceShake = false, lang = "pt-br" },
  stats = { kills = 0, captures = 0, playtime = 0 },
}
```

- **Tamanho:** cada monstro ocupa cerca de 120 bytes, então milhares cabem com folga no limite de 4 MB por chave do DataStore.
- **Compras:** `purchases.receipts` guarda cada recibo já entregue, o que torna o `ProcessReceipt` idempotente.
- **Versão:** `version` permite migrar perfis antigos quando o formato mudar.
- **Sem dados pessoais:** o perfil guarda só dados de jogo, ligados ao UserId.

## Primeiro sprint: o protótipo cinza

O objetivo é descobrir se o loop é divertido antes de gastar com arte. Tudo é feito com blocos cinza, exceto um único boss modelado no Blender, para testar o caminho do Blender até o Studio cedo.

| # | Tarefa | Ferramenta | Pronto quando |
| --- | --- | --- | --- |
| 1 | Criar o place com StreamingEnabled e a estrutura de pastas acima | Studio + MCP | Pastas e scripts vazios no lugar |
| 2 | DataService com ProfileStore e o perfil acima | Studio + MCP | O Ouro continua o mesmo depois de sair e entrar |
| 3 | Tabelas de Config com os números deste documento | Studio + MCP | Um script de teste imprime Poder e renda de cada boss iguais aos do Bestiário |
| 4 | Hub cinza com a praça, 1 portal e 1 Toca de 4 vagas | Studio + MCP | O jogador anda do spawn até o portal |
| 5 | Arena instanciada longe do hub, com entrada e saída por CFrame | Studio + MCP | Entra e sai sem tela de carregamento |
| 6 | HordeService com inimigos de dados e blocos cinza num pool | Studio + MCP | 40 inimigos a 30 FPS ou mais num celular de entrada |
| 7 | Ataque básico automático, 1 habilidade em área e a esquiva | Studio + MCP | Dá para limpar uma onda inteira |
| 8 | Barra da fenda e portal do boss | Studio + MCP | Barra cheia abre o portal |
| 9 | Boss cinza com a Rolada e a Pancada do Musguinho, e as marcas no chão | Studio + MCP e plugin de VFX | Dá para desviar só lendo o chão |
| 10 | Captura completa: anel, lançamento, tremidas e sorteio no servidor | Studio + MCP | Em 1.000 lançamentos simulados, a taxa de sucesso bate com a chance mostrada |
| 11 | Toca: colocar o monstro, renda por segundo e cofre | Studio + MCP | O Ouro/s aparece e o contador sobe |
| 12 | Poste de Treino | Studio + MCP | Treinar aumenta o Poder mostrado e o dano causado |
| 13 | Funil mínimo de onboarding (passos 1, 10, 12 e 14) com o AnalyticsService | Studio + MCP | Os eventos aparecem no painel do Creator Hub |
| 14 | Musguinho no Blender, com modelo e as animações parado, andar e rolar, no lugar do cubo | Blender + MCP | Importado e animado no Studio |
| 15 | Teste com 5 a 10 jogadores do público, sem ajuda | — | Roteiro de observação preenchido |

## Quando o protótipo está pronto

O protótipo passa para o MVP se cumprir estes critérios. Se dois ou mais falharem, o loop é ajustado antes de produzir arte em série.

- **Loop inteiro sem travar:** portal, hordas, boss, captura, Toca, treino e portal de novo.
- **Desempenho:** 40 inimigos a 30 FPS ou mais num Android de entrada e a 60 FPS no PC.
- **Primeira captura:** em menos de 3 minutos para 9 de cada 10 testadores, sem ajuda.
- **"Só mais uma":** depois de 3 fendas, pelo menos 7 de cada 10 testadores querem continuar.
- **Teste de Koster:** os testadores sentem que o segundo boss foi diferente do primeiro e sabem dizer o que aprenderam.
- **Segurança:** nenhum evento remoto forjado gera Ouro, dano ou monstro. A equipe testa disparando os eventos com valores falsos.
- **Save:** 20 entradas e saídas seguidas sem nenhuma perda.
