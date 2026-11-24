local Campaign = {stages = {}}
local forest = {"Brotinho", "Vagalume-Faísca", "Lesma de Musgo", "Lobo de Folhas"}
local dunes = {"Areinha", "Cristalino", "Escorpinho", "Abutre Prisma"}

local function stage(name, boss, power, basePower, income, fragments, chance, rarity, element, hex, enemies, elite)
	local index = #Campaign.stages + 1
	Campaign.stages[index] = {
		name = name, boss = boss, power = power, basePower = basePower, income = income,
		fragments = fragments, chance = chance, rarity = rarity, element = element,
		color = Color3.fromHex(hex), enemies = enemies, elite = elite,
		biome = index <= 6 and "Bosque Musgoso" or "Dunas de Cristal",
		king = index == 6 or index == 12,
	}
end

stage("Clareira do Musguinho", "Musguinho", 10, 8, 6, 5, .9, "Comum", "Natureza", "69945A", {forest[1]}, "Ent Guardião")
stage("Lagoa dos Vagalumes", "Sapo-Lanterna", 25, 18, 9.6, 6, .8, "Incomum", "Água", "49AAB6", {forest[1],forest[2]}, "Xamã Cogumelo")
stage("Anel de Cogumelos", "Cogumestre", 50, 20, 36, 8, .65, "Raro", "Natureza", "B7586C", {forest[1],forest[2],forest[3]}, "Ent Guardião")
stage("Trilha das Raízes", "Javali Raiz", 80, 48, 64, 10, .5, "Épico", "Natureza", "896449", {forest[1],forest[3],forest[4]}, "Ent Guardião")
stage("Vale da Bruma", "Coruja Bruma", 180, 48, 64, 12, .5, "Épico", "Água", "7897B5", forest, "Xamã Cogumelo")
stage("Coração do Bosque", "Ancião Carvalhorn", 270, 80, 250, 20, .35, "Lendário", "Natureza", "62855D", forest, "Ent Guardião")
stage("Oásis Cintilante", "Escarabrilho", 500, 40, 60, 15, .9, "Comum", "Luz", "C59A42", {dunes[1]}, "Golem de Vidro")
stage("Cânion de Brasa", "Lagartixa Brasa", 550, 90, 96, 18, .8, "Incomum", "Fogo", "DB6A48", {dunes[1],dunes[2]}, "Mago das Dunas")
stage("Círculo dos Tambores", "Cacto Tambor", 700, 100, 360, 24, .65, "Raro", "Natureza", "79A46B", {dunes[1],dunes[2],dunes[3]}, "Golem de Vidro")
stage("Galeria dos Espelhos", "Escorpião Prisma", 900, 240, 640, 30, .5, "Épico", "Luz", "A78BE7", {dunes[2],dunes[3],dunes[4]}, "Mago das Dunas")
stage("Olho da Tempestade", "Djinn de Areia", 1500, 240, 640, 36, .5, "Épico", "Fogo", "D59150", dunes, "Mago das Dunas")
stage("Templo do Sol", "Esfinge Solarya", 2200, 400, 2500, 60, .35, "Lendário", "Luz", "D7AA5D", dunes, "Golem de Vidro")
return Campaign
