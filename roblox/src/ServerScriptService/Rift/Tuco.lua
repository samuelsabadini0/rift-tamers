local World = require(script.Parent.Scenery)
local Quests = require(script.Parent.Quests)
local Tuco = {}

local jade = Color3.fromHex("75A98C")
local shell = Color3.fromHex("345C55")
local scute = Color3.fromHex("528075")
local ivory = Color3.fromHex("E2C58B")
local brass = Color3.fromHex("BF9758")
local wick = Color3.fromHex("FFCB67")
local ink = Color3.fromHex("243335")
local wood = Color3.fromHex("765641")
local plum = Color3.fromHex("9974AD")
local supreme = Color3.fromHex("B999FA")
local V = Vector3.new
local M = Enum.Material

local function piece(parent, label, cf, dimensions, tint, material, shape)
	local part = World.part(parent, label, cf.Position, dimensions, tint, shape, material)
	part.CFrame = cf
	part.CanCollide, part.CanTouch, part.CanQuery = false, false, false
	return part
end

local function turtle(parent, home)
	local model = Instance.new("Model")
	model.Name = "Tuco"
	local pos = home + V(-19, 0.12, -4)
	local cf = CFrame.lookAt(pos, V(home.X, pos.Y, home.Z))
	local function blob(name, x, y, z, w, h, d, color)
		return piece(model, name, cf * CFrame.new(x, y, z), V(w, h, d), color, M.SmoothPlastic, Enum.PartType.Ball)
	end
	local carapace = blob("Casco", 0, 1.49, 0.3, 3.85, 2.75, 4.05, shell)
	blob("Orla do casco", 0, 1.13, 0.26, 4.02, 0.5, 4.15, ivory)
	blob("Barriga", 0, 0.98, 0.25, 3.41, 1.02, 3.68, jade)
	for _, side in {-1, 1} do
		for _, z in {-0.94, 1.3} do
			blob("Pata", side * 1.37, 0.49, z, 0.95, 0.94, 1.16, jade)
		end
		for _, z in {-0.61, 0.58, 1.26} do
			local plate = blob("Escudo do casco", side * 0.92, 2.48 - math.abs(z - 0.25) * 0.16, z, 1.21, 0.54, 1.06, scute)
			plate.CFrame *= CFrame.Angles(0, 0, -side * 0.5)
		end
	end
	local head = blob("Tuco", 0, 1.68, -1.80, 1.93, 1.70, 1.90, jade)
	blob("Focinho", 0, 1.47, -2.37, 1.55, 0.76, 1.13, jade:Lerp(ivory, 0.25))
	for _, side in {-1, 1} do
		blob("Olho", side * 0.46, 1.96, -2.50, 0.32, 0.39, 0.20, ink)
		blob("Reflexo", side * 0.46 + 0.04, 2.03, -2.60, 0.085, 0.095, 0.04, Color3.new(1, 1, 1))
		local brow = blob("Sobrancelha", side * 0.44, 2.19, -2.38, 0.54, 0.14, 0.26, ivory)
		brow.CFrame *= CFrame.Angles(0, 0, side * 0.19)
	end
	local lamp = cf * CFrame.new(0, 3.38, 0.32)
	local function fitting(name, x, y, z, w, h, d, tint, mat)
		return piece(model, name, lamp * CFrame.new(x, y, z), V(w, h, d), tint, mat)
	end
	fitting("Pé do lampião", 0, -0.62, 0, 1.22, 0.24, 1.22, brass, M.Metal)
	local flame = fitting("Luz do guardião", 0, 0, 0, 0.58, 0.92, 0.58, wick, M.Neon)
	fitting("Chapéu do lampião", 0, 0.62, 0, 1.24, 0.23, 1.24, brass, M.Metal)
	for _, x in {-0.45, 0.45} do
		for _, z in {-0.45, 0.45} do
			fitting("Armação", x, 0, z, 0.10, 1.24, 0.10, brass, M.Metal)
		end
	end
	fitting("Alça", 0, 0.87, 0, 0.45, 0.37, 0.12, brass, M.Metal)
	local light = Instance.new("PointLight")
	light.Range, light.Color, light.Brightness = 11, wick, 1.8
	light.Parent = flame
	model.PrimaryPart = carapace
	model.Parent = parent
	World.label(head, "Tuco  ·  Guardião das Fendas", 3.6)
	return head
end

-- Both stalls fit below the village awnings at x = ±21.
local function counter(parent, home, side, crystal)
	local pos = home + V(side * 22, 0.14, 8)
	local cf = CFrame.new(pos)
	local name = crystal and "Cristal Supremo" or "Poção de Sorte"
	local tableTop = piece(parent, name, cf * CFrame.new(0, 2.34, 0), V(5.1, 0.38, 4.6), wood, M.WoodPlanks)
	for _, x in {-1.88, 1.88} do
		for _, z in {-1.67, 1.67} do
			piece(parent, "Pé da bancada", cf * CFrame.new(x, 1.13, z), V(0.42, 2.26, 0.42), wood, M.Wood)
		end
	end
	piece(parent, "Passadeira", cf * CFrame.new(0, 2.57, 0), V(2.5, 0.07, 4.6), crystal and plum or shell, M.Fabric)
	if crystal then
		for i, scale in {0.7, 1, 0.55} do
			local stand = cf * CFrame.new((i - 2) * 1.27, 2.68 + scale, (i % 2 - 0.5) * 0.64)
			piece(parent, "Fragmento supremo", stand * CFrame.Angles(0.35, 0.45, 0.68), V(1.03, 1.9, 0.99) * scale, supreme, M.Neon)
		end
	else
		for i, scale in {0.74, 1, 0.65} do
			local stand = cf * CFrame.new((i - 2) * 1.24, 2.63, (i % 2 - 0.5) * 0.8)
			piece(parent, "Frasco verde", stand * CFrame.new(0, 0.55 * scale, 0), V(1.16, 1.26, 1.16) * scale, jade, M.Glass, Enum.PartType.Ball)
			piece(parent, "Gargalo", stand * CFrame.new(0, 1.20 * scale, 0), V(0.48, 0.48, 0.48) * scale, jade, M.Glass)
			piece(parent, "Rolha", stand * CFrame.new(0, 1.50 * scale, 0), V(0.52, 0.28, 0.52) * scale, ivory, M.Wood)
		end
	end
	World.label(tableTop, name, 2.45)
	return tableTop
end

local tactics = {
	"Quando o Musguinho mirar, saia da faixa antes da rolada.",
	"Saia do círculo antes que o sapo aterrise.",
	"Mova-se entre as minas do Cogumestre.",
	"Contorne a carapaça. Os flancos do javali cedem.",
	"A bruma esconde a coruja. A marca revela seu mergulho.",
	"Olhe a galhada do Ancião quando as raízes subirem.",
	"Afaste-se do escaravelho enquanto o casco brilhar.",
	"Guarde a esquiva para atravessar a trilha de brasas.",
	"Acompanhe o ritmo dos tambores e atravesse a brecha.",
	"Procure a sombra para descobrir o verdadeiro escorpião.",
	"Os pilares abrigam você da tempestade do Djinn.",
	"Memorize os símbolos da Esfinge e repita a sequência.",
}

function Tuco.build(s, station, reflect)
	local merchant = Instance.new("Folder")
	merchant.Name, merchant.Parent = "Mercado de Tuco", s.map
	local count = 0
	station(s, turtle(merchant, s.home), "Conversar", function()
		if s.phase ~= "Praça" and s.phase ~= "Parceiro" then return end
		local d = s.data
		local openQuest
		for _, q in Quests.list(d, os.time()) do
			if not q.done then openQuest = q break end
		end
		local tips = {
			tactics[d.stage], "Um desvio no segundo salão leva ao relicário.",
			openQuest and (openQuest.title .. "  ·  " .. openQuest.count .. "/" .. openQuest.goal) or "Você completou as missões de hoje!",
		}
		if s.phase == "Parceiro" then
			s.player:SetAttribute("Tip", "Tuco: Fagulho, Marolo ou Raminho? Aproxime-se para escolher.")
		else
			s.player:SetAttribute("Tip", "Tuco: " .. tips[count % #tips + 1])
			count += 1
		end
	end)
	for _, offer in {{name = "Poção de Sorte", price = 40}, {name = "Cristal Supremo", price = 150}} do
		local crystal = offer.name == "Cristal Supremo"
		local stand = counter(merchant, s.home, crystal and 1 or -1, crystal)
		local verb = crystal and "Comprar • 150 gemas" or "Sorte 15 min • 40 gemas"
		local prompt = station(s, stand, verb, function()
			if s.phase ~= "Praça" then return end
			local d = s.data
			if d.gems < offer.price then
				s.player:SetAttribute("Tip", "Faltam " .. (offer.price - d.gems) .. " gemas para " .. offer.name .. ".")
				return
			end
			d.gems -= offer.price
			if crystal then
				d.supreme = (d.supreme or 0) + 1
				s.player:SetAttribute("Tip", "Cristal Supremo na bolsa. Escolha-o ao capturar um chefe.")
			else
				d.luckUntil = math.max(os.time(), d.luckUntil or 0) + 15 * 60
				s.player:SetAttribute("Tip", "Poção usada! Sua sorte ganhou mais 15 minutos.")
			end
			reflect(s)
		end)
		prompt.HoldDuration = 0.65
	end
end

return Tuco
