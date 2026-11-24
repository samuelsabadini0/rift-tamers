local Rules = {}
Rules.starters = {
	Fagulho = {color = Color3.fromRGB(244, 118, 65), skill = "Explosão", cooldown = 8, range = 14, factor = 3},
	Marolo = {color = Color3.fromRGB(65, 198, 228), skill = "Onda", cooldown = 6, range = 18, factor = 1.5},
	Raminho = {color = Color3.fromRGB(150, 213, 87), skill = "Raízes", cooldown = 10, range = 10, factor = 1},
}
Rules.elements={
	Fogo=Rules.starters.Fagulho,
	["Água"]=Rules.starters.Marolo,
	Natureza=Rules.starters.Raminho,
	Luz={color=Color3.fromHex("FFF398"),skill="Raio",cooldown=9,range=30,factor=4},
	Sombra={color=Color3.fromHex("AE89EB"),skill="Vórtice",cooldown=12,range=14,factor=1},
}
function Rules.power(level)
	return 12 * (1 + 0.08 * (level - 1))
end
function Rules.price(level)
	return math.floor(200 * 1.25 ^ (level - 1))
end
function Rules.chance(first, timing, base, marks)
	if first then return 1 end
	local bonus = 0
	if timing >= 0.76 and timing <= 0.84 then bonus = 0.25
	elseif timing >= 0.675 and timing <= 0.925 then bonus = 0.10 end
	return math.min(0.95,(base or 0.9)*(1+bonus)+0.05*(marks or 0))
end
return Rules
