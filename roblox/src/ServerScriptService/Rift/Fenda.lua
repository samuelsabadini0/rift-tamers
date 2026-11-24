-- Fenda a céu aberto: três áreas no chão do Bosque Musgoso ligadas por portais.
-- Uma barra de Purificação (0–100) vale para a fenda toda: 30% abre a Área 2, 65% abre a Área 3, 100% chama o chefe.
-- O servidor é dono de vida, dano e Purificação; o cliente só desenha névoa, cor do chão e HUD.
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Rift")
local Models = require(Shared.CreatureModels)
local Campaign = require(Shared.Campaign)
local World = require(script.Parent.Scenery)
local Horde = require(script.Parent.Horde)

local Fenda = {}
local V, C, M = Vector3.new, Color3.fromRGB, Enum.Material
local UP = Vector3.yAxis
local flat = V(1, 0, 1)
local TAU = 2 * math.pi

Fenda.THRESHOLDS = {0, 30, 65, 100}
-- Ritmo: cerca de 1 minuto por área jogando ativo (fenda inteira em ~3 min + chefe).
Fenda.VALUE = {common = .08, summoned = .04, elite = 2, crystal = 5, mini = 6}
-- O que cada inimigo derruba no chão. Coleta passando por cima (raio PICKUP).
-- Calibrado no playtest: uma fenda inteira rende ~1–2 níveis no começo, ouro perto de 1/3 da recompensa
-- do chefe e ~5 fragmentos.
Fenda.DROPS = {
	common = {xp = .3, goldChance = .05},
	summoned = {xp = .15, goldChance = .02},
	elite = {xp = 2, gold = 1, fragmentChance = .25},
	crystal = {xp = 3, gold = 1, fragments = 1},
	mini = {xp = 6, gold = 3, fragments = 2, large = .25},
}
Fenda.PICKUP = 7
Fenda.CAP_PER_PLAYER = 40
Fenda.AREAS = {
	{name = "Clareira Sombria", offset = V(0, 0, 0), radius = 62, crystals = 2, clearings = 4},
	{name = "Bosque das Raízes", offset = V(60, 0, 245), radius = 82, crystals = 3, clearings = 6, mini = "Guardião Corrompido"},
	{name = "Coração Corrompido", offset = V(-40, 0, 545), radius = 104, crystals = 3, clearings = 8, mini = "Colosso Corrompido"},
}

local palette = {
	floor = C(78, 146, 74), clearing = C(136, 200, 98), corrupt = C(92, 72, 108),
	bark = C(118, 86, 60), leaf = {C(70, 168, 92), C(110, 194, 84), C(52, 146, 112), C(156, 204, 90)},
	rock = C(136, 148, 160), moss = C(104, 178, 88), ruin = C(214, 202, 174),
	stain = C(122, 58, 168), stainDark = C(78, 36, 110), fog = C(168, 104, 220),
	flowers = {C(255, 140, 186), C(255, 218, 92), C(146, 206, 255), C(255, 172, 112), C(240, 240, 255)},
	mush = {C(238, 92, 92), C(255, 172, 70), C(184, 122, 236)},
	portal = C(130, 244, 214), red = C(255, 108, 70),
}
Fenda.palette = palette

local function part(parent, name, cf, size, color, material, solid, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or M.SmoothPlastic
	p.CanCollide = solid == true
	p.CanQuery = solid == true
	p.CanTouch = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	if shape then p.Shape = shape end
	if not solid then p.CastShadow = false end
	p.Parent = parent
	return p
end

local function disc(parent, name, pos, radius, depth, color, material, solid)
	return part(parent, name, CFrame.new(pos) * CFrame.Angles(0, 0, math.pi / 2), V(depth, radius * 2, radius * 2), color, material, solid, Enum.PartType.Cylinder)
end

local function free(list, pos, radius)
	for _, o in list do
		if ((o.p - pos) * flat).Magnitude < o.r + radius then return false end
	end
	return true
end

local function scatter(rng, center, R)
	local a = rng:NextNumber(0, TAU)
	local d = math.sqrt(rng:NextNumber(.02, 1)) * R
	return center + V(math.cos(a) * d, 0, math.sin(a) * d)
end

-- Ground reads as forest floor with lighter clearings. The client lerps it from corrupt to healthy.
local function healthy(p, color)
	p:SetAttribute("Saudavel", color)
	p.Color = palette.corrupt:Lerp(color, .2)
end

local function ground(folder, center, R, rng, clearings)
	local f = Instance.new("Folder")
	f.Name = "Chão"
	f.Parent = folder
	local base = part(f, "Chão da floresta", CFrame.new(center - UP * 2), V(2 * R + 90, 4, 2 * R + 90), palette.floor, M.Grass, true)
	healthy(base, palette.floor)
	local heart = disc(f, "Clareira central", center + UP * .03, R * .42, .1, palette.clearing, M.Grass)
	healthy(heart, palette.clearing)
	for i = 1, clearings do
		local pos = scatter(rng, center, R * .75)
		local tint = palette.clearing:Lerp(palette.floor, rng:NextNumber(0, .45))
		local p = disc(f, "Clareira", pos + UP * (.035 + i * .003), rng:NextNumber(R * .18, R * .34), .1, tint, M.Grass)
		healthy(p, tint)
	end
end

local function tree(parent, pos, rng)
	local h = rng:NextNumber(6, 9)
	local trunk = part(parent, "Tronco", CFrame.new(pos + UP * h / 2), V(h, 2.2, 2.2), palette.bark, M.Wood, true, Enum.PartType.Cylinder)
	trunk.CFrame = CFrame.new(pos + UP * h / 2) * CFrame.Angles(0, 0, math.pi / 2)
	local leaf = palette.leaf[rng:NextInteger(1, #palette.leaf)]
	local s = rng:NextNumber(9, 14)
	part(parent, "Copa", CFrame.new(pos + UP * (h + s * .3)), V(s, s * .8, s), leaf, M.Grass, false, Enum.PartType.Ball)
	if rng:NextNumber() < .6 then
		local off = V(rng:NextNumber(-3, 3), 0, rng:NextNumber(-3, 3))
		part(parent, "Copa", CFrame.new(pos + off + UP * (h + s * .6)), V(s * .7, s * .6, s * .7), leaf:Lerp(C(220, 240, 140), .2), M.Grass, false, Enum.PartType.Ball)
	end
end

local function bush(parent, pos, rng)
	local s = rng:NextNumber(4, 7)
	part(parent, "Arbusto", CFrame.new(pos + UP * s * .3), V(s, s * .7, s), palette.leaf[rng:NextInteger(1, #palette.leaf)], M.Grass, false, Enum.PartType.Ball)
end

local function border(folder, center, R, rng)
	local f = Instance.new("Folder")
	f.Name = "Limite"
	f.Parent = folder
	local n = 32
	for i = 1, n do
		local a = i * TAU / n
		local pos = center + V(math.cos(a), 0, math.sin(a)) * (R + 3)
		local w = 2 * (R + 3) * math.tan(math.pi / n) + 1
		local wall = part(f, "Barreira", CFrame.lookAt(pos + UP * 6, center + UP * 6), V(w, 12, 2), palette.floor, M.SmoothPlastic, true)
		wall.Transparency = 1
		wall.CastShadow = false
	end
	for _ = 1, math.floor(R * 1.1) do
		local a = rng:NextNumber(0, TAU)
		tree(f, center + V(math.cos(a), 0, math.sin(a)) * (R + rng:NextNumber(5, 32)), rng)
	end
	for _ = 1, math.floor(R * .9) do
		local a = rng:NextNumber(0, TAU)
		bush(f, center + V(math.cos(a), 0, math.sin(a)) * (R + rng:NextNumber(-1, 5)), rng)
	end
end

-- Low obstacles only (rocks, logs, ruin stubs): cover to kite hordes around, never platforms.
local function rock(parent, pos, rng)
	local w = rng:NextNumber(5, 9)
	local h = rng:NextNumber(2.6, 4.2)
	local body = part(parent, "Pedra", CFrame.new(pos + UP * h * .35) * CFrame.Angles(0, rng:NextNumber(0, TAU), 0), V(w, h, w * rng:NextNumber(.7, 1)), palette.rock:Lerp(C(110, 120, 150), rng:NextNumber(0, .5)), M.Rock, true, Enum.PartType.Ball)
	part(parent, "Musgo", body.CFrame * CFrame.new(0, h * .32, 0), V(w * .7, h * .35, w * .6), palette.moss, M.Grass, false, Enum.PartType.Ball)
	if rng:NextNumber() < .5 then
		local s = rng:NextNumber(2, 3.4)
		part(parent, "Pedrinha", CFrame.new(pos + V(w * .55, s * .3, rng:NextNumber(-2, 2))), V(s, s * .8, s), palette.rock, M.Rock, true, Enum.PartType.Ball)
	end
	return w * .6
end

local function log(parent, pos, rng)
	local len = rng:NextNumber(10, 16)
	local cf = CFrame.new(pos + UP * 1.1) * CFrame.Angles(0, rng:NextNumber(0, TAU), 0)
	part(parent, "Tronco caído", cf, V(len, 2.3, 2.3), palette.bark, M.Wood, true, Enum.PartType.Cylinder)
	part(parent, "Musgo", cf * CFrame.new(0, 1, 0), V(len * .7, .5, 1.6), palette.moss, M.Grass)
	for _, side in {-1, 1} do
		disc(parent, "Anel do tronco", Vector3.zero, 1.05, .1, C(214, 178, 120), M.Wood).CFrame = cf * CFrame.new(side * (len / 2 + .02), 0, 0)
	end
	return len * .45
end

local function ruin(parent, pos, rng)
	local yaw = rng:NextNumber(0, TAU)
	local cf = CFrame.new(pos) * CFrame.Angles(0, yaw, 0)
	for i = 1, rng:NextInteger(2, 3) do
		local h = rng:NextNumber(2.4, 4)
		local w = rng:NextNumber(5, 8)
		part(parent, "Muro em ruína", cf * CFrame.new((i - 2) * 7, h / 2, rng:NextNumber(-1.5, 1.5)), V(w, h, 1.6), palette.ruin:Lerp(palette.rock, rng:NextNumber(0, .3)), M.Limestone, true)
	end
	local column = part(parent, "Coluna caída", cf * CFrame.new(rng:NextNumber(-3, 3), .9, 4.5) * CFrame.Angles(0, rng:NextNumber(-.6, .6), 0), V(8, 1.8, 1.8), palette.ruin, M.Limestone, true, Enum.PartType.Cylinder)
	part(parent, "Hera", column.CFrame * CFrame.new(0, .8, 0), V(5, .4, 1.2), palette.moss, M.Grass)
	return 11
end

local function details(folder, center, R, rng, keep)
	local f = Instance.new("Folder")
	f.Name = "Decoração"
	f.Parent = folder
	for _ = 1, math.floor(R * .24) do
		for _ = 1, 8 do
			local pos = scatter(rng, center, R - 9)
			if free(keep, pos, 7) then
				local roll = rng:NextNumber()
				local r = roll < .45 and rock(f, pos, rng) or roll < .75 and log(f, pos, rng) or ruin(f, pos, rng)
				table.insert(keep, {p = pos, r = r + 3})
				break
			end
		end
	end
	for _ = 1, math.floor(R * .3) do
		local pos = scatter(rng, center, R - 4)
		local h = rng:NextNumber(1, 2)
		part(f, "Pé de cogumelo", CFrame.new(pos + UP * h / 2) * CFrame.Angles(0, 0, math.pi / 2), V(h, .6, .6), C(240, 226, 196), M.SmoothPlastic, false, Enum.PartType.Cylinder)
		part(f, "Chapéu de cogumelo", CFrame.new(pos + UP * h), V(2.2, 1, 2.2), palette.mush[rng:NextInteger(1, #palette.mush)], M.SmoothPlastic, false, Enum.PartType.Ball)
	end
	-- Flowers and tall grass only bloom as the area is purified (client reveals by Limiar).
	local life = Instance.new("Folder")
	life.Name = "Vida"
	life.Parent = folder
	for _ = 1, math.floor(R * .9) do
		local pos = scatter(rng, center, R - 3)
		local threshold = rng:NextNumber(.05, 1)
		if rng:NextNumber() < .55 then
			local color = palette.flowers[rng:NextInteger(1, #palette.flowers)]
			for j = 1, 4 do
				local p = part(life, "Flor", CFrame.new(pos + V(rng:NextNumber(-1.6, 1.6), .35, rng:NextNumber(-1.6, 1.6))), V(.8, .5, .8), color, M.SmoothPlastic, false, Enum.PartType.Ball)
				p.Transparency = 1
				p:SetAttribute("Limiar", threshold)
			end
		else
			for j = 1, 3 do
				local p = part(life, "Capim", CFrame.new(pos + V(j * .5 - 1, .7, 0)) * CFrame.Angles(rng:NextNumber(-.3, .3), rng:NextNumber(0, TAU), rng:NextNumber(-.3, .3)), V(.3, 1.4, .9), palette.moss:Lerp(C(180, 230, 110), rng:NextNumber()), M.Grass)
				p.Transparency = 1
				p:SetAttribute("Limiar", threshold)
			end
		end
	end
end

-- Purple stains on the ground and low fog sheets. Each piece has a Limiar (0..1 of this area's share).
local function corruption(folder, center, R, rng)
	local f = Instance.new("Folder")
	f.Name = "Corrupção"
	f.Parent = folder
	for i = 1, math.floor(R * .4) do
		local pos = scatter(rng, center, R - 4)
		local p = disc(f, "Mancha corrompida", pos + UP * (.09 + i * .002), rng:NextNumber(4, 13), .1, palette.stain:Lerp(palette.stainDark, rng:NextNumber()), M.SmoothPlastic)
		p.Transparency = .12
		p:SetAttribute("Limiar", rng:NextNumber(0, .95))
	end
	for _ = 1, math.floor(R * .14) do
		local pos = scatter(rng, center, R)
		local p = disc(f, "Névoa corrompida", pos + UP * rng:NextNumber(2, 5.5), rng:NextNumber(16, 30), .6, palette.fog, M.SmoothPlastic)
		p.Transparency = .8
		p:SetAttribute("Limiar", rng:NextNumber(.1, 1))
		p:SetAttribute("Nevoa", true)
	end
	for _ = 1, math.floor(R * .12) do
		local pos = scatter(rng, center, R - 6)
		local threshold = rng:NextNumber(0, .9)
		for j = 1, 3 do
			local h = rng:NextNumber(1.5, 3.2)
			local p = part(f, "Espinho corrompido", CFrame.new(pos + V(j - 2, h / 2, rng:NextNumber(-1, 1))) * CFrame.Angles(rng:NextNumber(-.4, .4), 0, rng:NextNumber(-.4, .4)), V(.6, h, .6), palette.stain, M.Neon)
			p:SetAttribute("Limiar", threshold)
		end
	end
end

function Fenda.build(parent, origin, stage)
	local rng = Random.new(stage * 7919 + 13)
	local scene = Instance.new("Folder")
	scene.Name = "Bosque Musgoso • Fenda " .. stage
	scene.Parent = parent
	local layout = {areas = {}}
	local centers = {}
	for i, a in Fenda.AREAS do centers[i] = origin + a.offset end
	for i, a in Fenda.AREAS do
		local center, R = centers[i], a.radius
		local folder = Instance.new("Folder")
		folder.Name = "Área " .. i .. " • " .. a.name
		folder:SetAttribute("Area", i)
		local toNext = centers[i + 1] and ((centers[i + 1] - center) * flat).Unit
		local fromPrev = centers[i - 1] and ((center - centers[i - 1]) * flat).Unit
		local entryDir = fromPrev and -fromPrev or -toNext
		local entry = center + entryDir * (R * .72)
		local exit = toNext and center + toNext * (R * .72)
		local keep = {{p = center, r = 18}, {p = entry, r = 12}}
		if exit then table.insert(keep, {p = exit, r = 12}) end
		if i == 2 then
			layout.secret = center + entryDir:Cross(UP) * (R - 12)
			table.insert(keep, {p = layout.secret, r = 8})
		end
		ground(folder, center, R, rng, a.clearings)
		border(folder, center, R, rng)
		details(folder, center, R, rng, keep)
		corruption(folder, center, R, rng)
		local mark = disc(folder, "Ponto de chegada", entry + UP * .12, 4, .12, palette.portal, M.Neon)
		mark.Transparency = .55
		folder.Parent = scene
		layout.areas[i] = {center = center, radius = R, entry = entry, exit = exit, exitDir = toNext, folder = folder, name = a.name}
		task.wait()
	end
	layout.entry = layout.areas[1].entry
	layout.boss = layout.areas[#layout.areas].center
	layout.scene = scene
	return layout
end

------------------------------------------------------------------ runtime

local pool, pooled = {}, 0
local function acquire(e, name, pos)
	local list = pool[name]
	local model = list and table.remove(list)
	if model then
		pooled -= 1
		model:PivotTo(CFrame.new(pos))
		model.Parent = e.run
		return model
	end
	return Models.create(e.run, name, pos, 3)
end

-- Common enemies go back to a pool instead of being destroyed.
function Fenda.release(model, mob)
	if mob and mob.kind == "common" and pooled < 160 and model.Parent then
		model.Parent = nil
		pool[model.Name] = pool[model.Name] or {}
		table.insert(pool[model.Name], model)
		pooled += 1
	else
		model:Destroy()
	end
end

local function inside(e, pos, margin)
	return ((pos - e.center) * flat).Magnitude <= e.radius - margin
end

local function census(e)
	local live, elites = 0, 0
	for _, mob in e.enemies do
		if mob.kind ~= "crystal" then live += 1 end
		if mob.kind == "elite" then elites += 1 end
	end
	return live, elites
end

local function add(e, model, kind, hp, extra)
	local mob = {hp = hp, kind = kind, value = Fenda.VALUE[kind], contact = 0, spawn = model:GetPivot().Position, elite = kind == "elite"}
	if extra then for k, v in extra do mob[k] = v end end
	e.enemies[model] = mob
	return mob
end

function Fenda.spawnPoint(e, from, near, far)
	for _ = 1, 12 do
		local a = math.random() * TAU
		local d = near + math.random() * (far - near)
		local p = from + V(math.cos(a) * d, 0, math.sin(a) * d)
		if inside(e, p, 6) then return V(p.X, e.center.Y, p.Z) end
	end
	local away = (e.center - from) * flat
	local dir = away.Magnitude > 1 and away.Unit or V(1, 0, 0)
	return e.center + dir * (e.radius - 8)
end

local function common(e, name, pos)
	local model = acquire(e, name, V(pos.X, e.center.Y + 1.8, pos.Z))
	return add(e, model, "common", e.reference * (Horde.health[name] or .3) * e.scale)
end

-- Continuous hordes: a pack of 6–10 every 2–3 s from off-screen, faster while the field is thin.
function Fenda.horde(e, t, roots)
	if #roots == 0 then return end
	e.cap = Fenda.CAP_PER_PLAYER * #roots
	if t < (e.nextWave or 0) then return end
	local stage = Campaign.stages[e.stage]
	local live, elites = census(e)
	e.nextWave = t + (live < e.cap * .5 and 1.2 or 2 + math.random())
	local room = e.cap - live
	if room <= 0 then return end
	local r = roots[math.random(#roots)]
	local at = Fenda.spawnPoint(e, r.Position, 46, 62)
	e.waves = (e.waves or 0) + 1
	for i = 1, math.min(room, math.random(6, 10)) do
		local a = i * 2.4
		local pos = at + V(math.cos(a), 0, math.sin(a)) * (1.5 + i * .6)
		common(e, stage.enemies[math.random(#stage.enemies)], pos)
	end
	if e.waves % 4 == 0 and elites < 2 then
		local model = Models.create(e.run, stage.elite, V(at.X, e.center.Y + 3, at.Z), 4)
		model:ScaleTo(model:GetScale() * 1.65)
		World.label(model.PrimaryPart, "Elite corrompida", 4)
		add(e, model, "elite", e.reference * (Horde.health[stage.elite] or 4) * .7 * e.scale)
	end
end

-- Cristal Corrompido: sits on the ground and keeps emitting enemies until destroyed.
function Fenda.crystal(e, pos)
	local model = Instance.new("Model")
	model.Name = "Cristal Corrompido"
	local base = part(model, "Base", CFrame.new(pos + UP * .5), V(7, 1.4, 7), palette.stainDark, M.Slate, false, Enum.PartType.Ball)
	local core = part(model, "Núcleo", CFrame.new(pos + UP * 4) * CFrame.Angles(0, math.pi / 4, math.rad(8)), V(2.4, 7, 2.4), palette.stain, M.Neon)
	for i = 1, 3 do
		local a = i * TAU / 3
		part(model, "Lasca", CFrame.new(pos + V(math.cos(a) * 1.8, 2.2, math.sin(a) * 1.8)) * CFrame.Angles(math.cos(a) * .5, a, math.sin(a) * .5), V(1.3, 4, 1.3), palette.fog, M.Neon)
	end
	disc(model, "Mancha", pos + UP * .16, 9, .1, palette.stainDark, M.SmoothPlastic)
	local glow = Instance.new("PointLight")
	glow.Color, glow.Range, glow.Brightness = palette.fog, 16, 2
	glow.Parent = core
	model.PrimaryPart = core
	World.label(core, "Cristal Corrompido", 5)
	model.Parent = e.run
	local _ = base
	return add(e, model, "crystal", e.reference * 3 * e.scale, {nextEmit = os.clock() + 3})
end

function Fenda.crystalStep(e, model, mob, t)
	if t < mob.nextEmit then return end
	mob.nextEmit = t + 5
	local live = census(e)
	local stage = Campaign.stages[e.stage]
	local pos = model:GetPivot().Position
	for i = 1, math.min(3, (e.cap or 40) - live) do
		local a = i * TAU / 3 + t
		table.insert(e.queue, {stage.enemies[math.random(#stage.enemies)], pos + V(math.cos(a) * 5, 0, math.sin(a) * 5)})
	end
end

function Fenda.flush(e)
	for _, item in e.queue do common(e, item[1], item[2]) end
	table.clear(e.queue)
end

-- Mini-bosses of areas 2 and 3: one readable mechanic each.
function Fenda.mini(e, near)
	local area = Fenda.AREAS[e.area]
	local stage = Campaign.stages[e.stage]
	local p = Fenda.spawnPoint(e, near, 30, 45)
	local model = Models.create(e.run, stage.elite, V(p.X, e.center.Y + 4, p.Z), 4)
	model:ScaleTo(model:GetScale() * 2.6)
	model.Name = area.mini
	World.label(model.PrimaryPart, area.mini, 10)
	local glow = Instance.new("Highlight")
	glow.FillColor, glow.FillTransparency, glow.OutlineColor = palette.stain, .65, palette.fog
	glow.Parent = model
	return add(e, model, "mini", e.reference * 22 * e.scale, {mechanic = e.area == 2 and "Pisão" or "Investida", next = os.clock() + 3})
end

local function telegraph(parent, cf, size, shape)
	local p = part(parent, "Aviso", cf, size, palette.red, M.Neon, false, shape)
	p.Transparency = .45
	return p
end

function Fenda.miniStep(e, model, mob, r, t, dt, onHit)
	local pos = model:GetPivot().Position
	local floor = e.center.Y + .25
	local attack = mob.attack
	if attack then
		if t < attack.impact then return end
		local hit
		if attack.radius then
			hit = ((r.Position - attack.center) * flat).Magnitude <= attack.radius
		else
			local lp = attack.frame:PointToObjectSpace(r.Position)
			hit = math.abs(lp.X) <= attack.width / 2 and math.abs(lp.Z) <= attack.length / 2
		end
		attack.part:Destroy()
		if attack.finish then model:PivotTo(CFrame.lookAt(attack.finish, attack.finish + attack.dir)) end
		if hit then onHit(e.reference * 2) end
		mob.attack = nil
		mob.next = t + 4.5
		return
	end
	local delta = (r.Position - pos) * flat
	local dir = delta.Magnitude > .1 and delta.Unit or V(0, 0, -1)
	if t >= mob.next and delta.Magnitude < 34 then
		if mob.mechanic == "Pisão" then
			local center = V(pos.X, floor, pos.Z)
			local p = telegraph(e.run, CFrame.new(center) * CFrame.Angles(0, 0, math.pi / 2), V(.15, 24, 24), Enum.PartType.Cylinder)
			mob.attack = {impact = t + 1.3, radius = 12, center = center, part = p}
		else
			local length = 30
			local start = V(pos.X, floor, pos.Z)
			local mid = start + dir * length / 2
			local frame = CFrame.lookAt(mid, mid + dir)
			local p = telegraph(e.run, frame, V(7, .16, length))
			local finish = pos + dir * length
			if not inside(e, finish, 8) then
				local off = (finish - e.center) * flat
				finish = e.center + off.Unit * (e.radius - 8) + UP * (pos.Y - e.center.Y)
			end
			mob.attack = {impact = t + 1.1, frame = frame, width = 7, length = length, part = p, finish = finish, dir = dir}
		end
		return
	end
	if delta.Magnitude > 6 then
		local n = pos + dir * math.min(delta.Magnitude - 6, 7 * dt)
		model:PivotTo(CFrame.lookAt(n, n + dir))
	end
end

------------------------------------------------------------------ loot
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local LOOT = {
	xp = {name = "Orbe de experiência", color = C(120, 232, 255), size = V(.9, .9, .9), shape = Enum.PartType.Ball},
	gold = {name = "Moeda de ouro", color = C(255, 206, 80), size = V(.3, 1.3, 1.3), shape = Enum.PartType.Cylinder},
	fragments = {name = "Fragmento", color = C(206, 146, 255), size = V(.8, 1.2, .8)},
	large = {name = "Cristal Grande", color = C(120, 255, 204), size = V(1.2, 2, 1.2)},
}

local function lay(e, pos, item, amount)
	e.loot = e.loot or {}
	-- Teto de itens no chão: acima dele, soma no item mais antigo do mesmo tipo.
	if #e.loot >= 120 then
		for _, l in e.loot do
			if l.item == item then l.amount += amount return end
		end
	end
	local spec = LOOT[item]
	local a = math.random() * TAU
	local at = V(pos.X, e.center.Y + .9, pos.Z) + V(math.cos(a), 0, math.sin(a)) * math.random() * 2.5
	local cf = CFrame.new(at)
	if item == "gold" then cf *= CFrame.Angles(0, a, 0) elseif item ~= "xp" then cf *= CFrame.Angles(0, a, math.rad(20)) end
	local p = part(e.run, spec.name, cf, spec.size, spec.color, M.Neon, false, spec.shape)
	p:SetAttribute("Loot", item)
	table.insert(e.loot, {part = p, item = item, amount = amount, born = os.clock()})
end

function Fenda.drop(e, pos, kind)
	local spec = Fenda.DROPS[kind] or Fenda.DROPS.common
	local stage = Campaign.stages[e.stage]
	local orbs = math.clamp(math.ceil(spec.xp / 2), 1, 4)
	for _ = 1, orbs do lay(e, pos, "xp", spec.xp / orbs * 3 ^ (e.rank - 1)) end
	local coin = math.max(1, math.floor(stage.income * .5 * 1.5 ^ (e.rank - 1)))
	local coins = spec.gold or (math.random() < (spec.goldChance or 0) and 1 or 0)
	for _ = 1, coins do lay(e, pos, "gold", coin) end
	local frags = spec.fragments or (math.random() < (spec.fragmentChance or 0) and 1 or 0)
	for _ = 1, frags do lay(e, pos, "fragments", 1) end
	if spec.large and math.random() < spec.large then lay(e, pos, "large", 1) end
end

-- members: lista de {root=, s=}. give(s, item, amount) credita no servidor.
function Fenda.collect(e, t, members, give)
	if not e.loot then return end
	for i = #e.loot, 1, -1 do
		local l = e.loot[i]
		if not l.part.Parent or t - l.born > 30 then
			l.part:Destroy()
			table.remove(e.loot, i)
		elseif t - l.born > .35 then
			for _, m in members do
				if ((m.root.Position - l.part.Position) * flat).Magnitude <= Fenda.PICKUP then
					give(m.s, l.item, l.amount)
					TweenService:Create(l.part, TweenInfo.new(.18), {Position = m.root.Position, Size = l.part.Size * .4}):Play()
					Debris:AddItem(l.part, .2)
					table.remove(e.loot, i)
					break
				end
			end
		end
	end
end

-- Ao trocar de área, o que ficou no chão vai direto para quem atravessou.
function Fenda.vacuum(e, s, give)
	if not e.loot then return end
	for _, l in e.loot do
		give(s, l.item, l.amount)
		l.part:Destroy()
	end
	table.clear(e.loot)
end

function Fenda.enter(e, index)
	local a = e.layout.areas[index]
	e.area = index
	e.center, e.radius, e.entry, e.arena = a.center, a.radius, a.entry, a.center
	e.portal = nil
	e.nextWave = 0
	e.waves = 0
	e.queue = e.queue or {}
	e.miniAt = Fenda.AREAS[index].mini and (os.clock() + 15) or nil
	e.run:SetAttribute("Area", index)
	e.run:SetAttribute("Purificacao", e.purification)
	for _ = 1, Fenda.AREAS[index].crystals do
		Fenda.crystal(e, Fenda.spawnPoint(e, e.entry, 30, e.radius * 1.6))
	end
end

function Fenda.purify(e, amount)
	e.purification = math.min(Fenda.THRESHOLDS[e.area + 1], e.purification + amount)
	e.run:SetAttribute("Purificacao", e.purification)
	return e.purification
end

function Fenda.openPortal(e)
	local a = e.layout.areas[e.area]
	local model = Instance.new("Model")
	model.Name = "Portal para a Área " .. (e.area + 1)
	local pos = a.exit
	local frame = CFrame.lookAt(pos, pos + a.exitDir)
	for i = 0, 12 do
		local ang = i * math.pi / 12
		local stone = part(model, "Pedra do arco", frame * CFrame.new(5.2 * math.cos(ang), 5.2 * math.sin(ang) + .6, 0), V(1.6, 1.6, 2), palette.ruin, M.Limestone)
		stone.CFrame *= CFrame.Angles(0, 0, ang)
	end
	local veil = part(model, "Véu do portal", frame * CFrame.new(0, 3.4, 0) * CFrame.Angles(0, math.pi / 2, 0), V(.4, 9, 9), palette.portal, M.Neon, false, Enum.PartType.Cylinder)
	veil.Transparency = .3
	disc(model, "Círculo do portal", pos + UP * .14, 6, .12, palette.portal, M.Neon).Transparency = .4
	local light = Instance.new("PointLight")
	light.Color, light.Range, light.Brightness = palette.portal, 24, 3
	light.Parent = veil
	model.PrimaryPart = veil
	World.label(veil, "Portal • Área " .. (e.area + 1), 7).Parent.MaxDistance = 400
	model.Parent = a.folder
	return veil
end

return Fenda
