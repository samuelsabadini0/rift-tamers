# Código do jogo (espelho do Studio)

Cópia dos scripts do place no Roblox Studio (place 112964182462849), com as pastas iguais às do Explorer.
A fonte da verdade continua sendo o Studio (Team Create): edite lá e exporte de novo para cá antes de cada commit.

Extensões: `.server.lua` é Script, `.client.lua` é LocalScript, `.lua` é ModuleScript.

## A fenda (masmorra de hordas)

- `ServerScriptService/Rift/Fenda.lua`: mapa a céu aberto em 3 áreas no chão, hordas contínuas, Cristais Corrompidos, mini-chefes, portais, Purificação (30% / 65% / 100%) e loot (XP, ouro, fragmentos, Cristal Grande).
- `ServerScriptService/Rift/Game.server.lua`: sessões, praça, combate, chefe e captura; usa a `Fenda`.
- `StarterPlayer/StarterPlayerScripts/Rift/Purificacao.client.lua`: barra de Purificação, névoa que recua, câmera alta, faixas e o andar do modo Auto.

O castelo antigo em salas está guardado, desativado, em `ServerStorage/_Old` no place. Ele não está nesta pasta.
