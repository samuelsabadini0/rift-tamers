local Players = game:GetService("Players")
local Input = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local shared = game:GetService("ReplicatedStorage"):WaitForChild("Rift")
local Campaign = require(shared:WaitForChild("Campaign"))
local Rules = require(shared:WaitForChild("Rules"))
local UI = require(script.Parent:WaitForChild("GuiStyle"))
local Journal = require(script.Parent:WaitForChild("Journal"))
local remote = shared:WaitForChild("Action")
local at, box = UDim2.fromOffset, UDim2.new
local gui = Instance.new("ScreenGui")
gui.Name = "RiftHUD"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local function attr(key, fallback)
	local v = player:GetAttribute(key)
	if v == nil then return fallback end
	return v
end

local touch = Input.TouchEnabled
local info = UI.panelAt(gui, "Objetivo", at(12, 8), at(340, 91))
UI.compass(info, at(11, 10), 26, UI.gold)
local chapter = UI.label(info, "Bioma", at(47, 6), box(1, -55, 0, 16), "", UI.bold, 12, UI.gold)
local location = UI.label(info, "Local", at(46, 20), box(1, -55, 0, 28), "", UI.serif, 24)
local tip = UI.label(info, "Missão", at(13, 47), box(1, -26, 1, -50), "", UI.body, 15, UI.soft)
tip.TextWrapped = true
tip.TextTruncate = Enum.TextTruncate.None
tip.TextYAlignment = Enum.TextYAlignment.Top
local stats = UI.panelAt(gui, "Time", box(0, 12, 1, -12), at(253, 60))
stats.AnchorPoint = Vector2.new(0, 1)
local statTitle = UI.label(stats, "Poder", at(11, 4), box(1, -22, 0, 21), "", UI.bold, 15)
local statValue = UI.label(stats, "Recursos", at(11, 24), box(1, -22, 0, 22), "", UI.body, 14, UI.gold)
local hpTrack = UI.frame(stats, "Vida", at(11, 49), box(1, -22, 0, 4), UI.panel, 2)
local hpFill = UI.frame(hpTrack, "Atual", UDim2.new(), UDim2.fromScale(1, 1), UI.mint, 2)

local encounter = UI.panelAt(gui, "Encontro", box(0.5, 0, 0, 8), at(314, 67))
encounter.AnchorPoint = Vector2.new(0.5, 0)
local enemyTitle = UI.label(encounter, "Inimigo", at(10, 3), box(1, -20, 0, 25), "", UI.serif, 23)
enemyTitle.TextXAlignment = Enum.TextXAlignment.Center
local progressText = UI.label(encounter, "Progresso", at(8, 28), box(1, -16, 0, 20), "", UI.bold, 14, UI.gold)
progressText.TextXAlignment = Enum.TextXAlignment.Center
local track = UI.frame(encounter, "Barra", at(12, 52), box(1, -24, 0, 6), UI.panel, 3)
local fill = UI.frame(track, "Progresso", UDim2.new(), UDim2.fromScale(1, 1), UI.mint, 3)
local threshold = UI.frame(track, "Captura", UDim2.fromScale(0.15, 0), box(0, 2, 1, 0), UI.gold)
local journal = Journal.new(gui, player, Campaign.stages, remote)
journal.frame.ZIndex = 10
local bookButton = UI.button(gui, "AbrirDiário", box(1, -12, 0, 8), at(107, 39), "Diário  [M]", function()
	journal.toggle()
end)
bookButton.AnchorPoint = Vector2.new(1, 0)
bookButton.TextColor3 = UI.gold
local auto = UI.button(gui, "Auto", box(1, -12, 0, 54), at(107, 35), "Auto", function() remote:FireServer("auto") end)
auto.AnchorPoint = Vector2.new(1, 0)

local combat = UI.frame(gui, "Ações", box(1, -14, 1, -14), at(210, 57), UI.ink)
combat.AnchorPoint = Vector2.new(1, 1)
combat.BackgroundTransparency = 1
local dodge = UI.button(combat, "Esquiva", at(0, 7), at(92, 50), "Esquiva", function() remote:FireServer("dodge") end)
local skill = UI.button(combat, "Habilidade", at(99, 0), at(111, 57), "", function() remote:FireServer("skill") end)
local skillFill = UI.frame(skill, "Recarga", box(0, 6, 1, -5), box(1, -12, 0, 2), UI.gold, 1)

local equippedSlots = 0
local function updateSlots()
	local ok, slots = pcall(HttpService.JSONDecode, HttpService, attr("Equipped", "[]"))
	equippedSlots = ok and type(slots) == "table" and #slots or 0
end
player:GetAttributeChangedSignal("Equipped"):Connect(updateSlots)
updateSlots()
local nextSkill = UI.button(combat, "TrocarHabilidade", at(63, -39), at(147, 34), "Trocar habilidade", function()
	remote:FireServer("nextSkill")
end)

local crystal = UI.panelAt(gui, "Selar", box(0.5, 0, 1, -18), at(285, 84))
crystal.AnchorPoint = Vector2.new(0.5, 1)
local dial = UI.frame(crystal, "Anel", at(8, 7), at(70, 70), UI.panel, 35)
local function ringPoint(fraction, radius)
	local a = fraction * 2 * math.pi
	return at(35 + radius * math.sin(a), 35 - radius * math.cos(a))
end
for i = 0, 39 do
	local position = i / 40
	local tint = UI.edge
	if position >= 0.675 and position <= 0.925 then tint = UI.mint end
	if position >= 0.76 and position <= 0.84 then tint = UI.gold end
	local tick = UI.frame(dial, "Marca", ringPoint(position, 29), at(3, tint == UI.gold and 9 or 5), tint, 1)
	tick.AnchorPoint = Vector2.new(0.5, 0.5)
	tick.Rotation = position * 360
end
local needle = UI.frame(dial, "Luz", ringPoint(0, 27), at(8, 8), UI.text, 4)
needle.AnchorPoint = Vector2.new(0.5, 0.5)
UI.compass(dial, at(24, 24), 22, UI.gold)
local chanceText = UI.label(crystal, "Chance", at(87, 5), at(190, 27), "", UI.bold, 15, UI.gold)
local seal = UI.button(crystal, "Cristal", at(84, 34), at(191, 42), "Lançar cristal", function()
	remote:FireServer("capture")
end)
seal.BackgroundColor3 = UI.forest

local changeCrystal = UI.button(crystal, "TrocarCristal", box(0.5, 0, 0, -39), at(190, 34), "", function()
	local choices = {"Comum"}
	if attr("LargeCrystals", 0) > 0 then table.insert(choices, "Grande") end
	if attr("MasterCrystals", 0) > 0 then table.insert(choices, "Mestre") end
	if attr("SupremeCrystals", 0) > 0 then table.insert(choices, "Supremo") end
	local current = table.find(choices, attr("Crystal", "Comum")) or 1
	if #choices > 1 then remote:FireServer("crystal", choices[current % #choices + 1]) end
end)
changeCrystal.AnchorPoint = Vector2.new(0.5, 0)

local waypoint = UI.frame(gui, "Destino", UDim2.new(), at(94, 42), UI.panel, 6)
waypoint.AnchorPoint = Vector2.new(0.5, 0.5)
waypoint.BackgroundTransparency = 0.16
UI.stroke(waypoint, UI.gold, 0.22)
local routeArrow = UI.label(waypoint, "Direção", at(4, 2), at(22, 35), "◆", UI.bold, 20, UI.gold)
routeArrow.TextXAlignment = Enum.TextXAlignment.Center
local routeDistance = UI.label(waypoint, "Distância", at(29, 3), at(61, 35), "", UI.bold, 13)

local compact, narrow = false, false
local function layout()
	local width = gui.AbsoluteSize.X
	compact = width < 960
	narrow = width < 660
	local bookWidth = narrow and 78 or 107
	bookButton.Size = at(bookWidth, 39)
	auto.Size = at(bookWidth, 35)
	local infoWidth = math.clamp(width - bookWidth - 37, 145, narrow and 280 or 340)
	info.Size = at(infoWidth, narrow and 85 or 91)
	if compact then
		encounter.AnchorPoint = Vector2.zero
		encounter.Position = at(12, narrow and 98 or 105)
		encounter.Size = at(infoWidth, 62)
	else
		encounter.AnchorPoint = Vector2.new(0.5, 0)
		encounter.Position = box(0.5, 19, 0, 8)
		encounter.Size = at(294, 65)
	end
	local touchBottom = touch and 104 or 16
	combat.Position = box(1, -14, 1, -touchBottom)
	stats.AnchorPoint = touch and Vector2.zero or Vector2.new(0, 1)
	stats.Position = touch and at(12, narrow and 98 or 105) or box(0, 12, 1, -12)
	stats.Size = at(narrow and 190 or 245, 58)
	crystal.Position = box(0.5, 0, 1, touch and -60 or -18)
end
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
layout()

local previousHealth
local fightModes = {Horda = true, Boss = true}
local expeditionModes = {Explorar = true, Horda = true, Portal = true, Boss = true, Captura = true, Cristal = true, ["Baú"] = true}
local function keyboardKey(key, gamepad)
	if touch then return "" end
	if Input:GetLastInputType() == Enum.UserInputType.Gamepad1 then return "  " .. gamepad end
	return "  [" .. key .. "]"
end
local function updateWaypoint(dest, root)
	if not root or typeof(dest) ~= "Vector3" then waypoint.Visible = false return end
	local camera = workspace.CurrentCamera
	if not camera then waypoint.Visible = false return end
	local distance = (dest - root.Position).Magnitude
	if distance < 9 then waypoint.Visible = false return end
	local screen = gui.AbsoluteSize
	local projected, visible = camera:WorldToScreenPoint(dest + Vector3.yAxis * 6)
	local pos = Vector2.new(projected.X, projected.Y)
	local maxX = math.max(53, screen.X - 55)
	local maxY = math.max(73, screen.Y - (touch and 103 or 75))
	local minY = math.min(maxY, compact and 169 or 91)
	if not visible or projected.Z <= 0 then
		local localDir = camera.CFrame:VectorToObjectSpace(dest - camera.CFrame.Position)
		local heading = math.atan2(localDir.X, -localDir.Z)
		pos = Vector2.new(screen.X/2 + math.sin(heading)*(screen.X/2 - 60), screen.Y/2 - math.cos(heading)*(screen.Y/2 - minY))
		routeArrow.Text = math.abs(heading) > 2.35 and "↓" or heading > 0 and "→" or "←"
	else
		routeArrow.Text = "◆"
	end
	waypoint.Position = at(math.clamp(pos.X, 52, maxX), math.clamp(pos.Y, minY, maxY))
	routeDistance.Text = math.round(distance) .. " st"
	waypoint.Visible = true
end

local keys = {
	[Enum.KeyCode.T] = "nextSkill", [Enum.KeyCode.ButtonR1] = "nextSkill",
	[Enum.KeyCode.Q] = "skill", [Enum.KeyCode.R] = "dodge", [Enum.KeyCode.F] = "capture",
	[Enum.KeyCode.ButtonR2] = "skill", [Enum.KeyCode.ButtonL2] = "dodge", [Enum.KeyCode.ButtonX] = "capture",
}
Input.InputBegan:Connect(function(key, used)
	if used then return end
	local code = key.KeyCode
	if code == Enum.KeyCode.M or code == Enum.KeyCode.ButtonY then journal.toggle() return end
	if journal.frame.Visible then
		if code == Enum.KeyCode.ButtonB then journal.toggle() end
		return
	end
	local verb = keys[code]
	local phase = attr("Phase")
	if verb == "capture" and phase == "Captura" or verb and fightModes[phase] then remote:FireServer(verb) end
end)

local cleared = {}
local function getClears()
	local data = attr("Cleared", "{}")
	local ok, entries = pcall(HttpService.JSONDecode, HttpService, data)
	cleared = ok and type(entries) == "table" and entries or {}
end
player:GetAttributeChangedSignal("Cleared"):Connect(getClears)
getClears()

local banner = UI.panelAt(gui, "Aviso", UDim2.fromScale(0.5, 0.31), at(275, 47))
banner.AnchorPoint = Vector2.new(0.5, 0.5)
banner.Visible = false
local bannerText = UI.label(banner, "Mensagem", at(7, 2), box(1, -14, 1, -4), "", UI.serif, 24, UI.gold)
bannerText.TextXAlignment = Enum.TextXAlignment.Center
local lastPhase, noticeUntil
local function announce(text)
	bannerText.Text = text
	noticeUntil = os.clock() + 2.1
	banner.Position = UDim2.fromScale(0.5, 0.33)
	TweenService:Create(banner, TweenInfo.new(0.24, Enum.EasingStyle.Quad), {Position = UDim2.fromScale(0.5, 0.31)}):Play()
end

local function throwCrystal(bossName)
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local species = bossName:gsub(" Alfa$", ""):gsub(" Ancestral$", "")
	local target, nearest = nil, math.huge
	for _, zone in workspace:GetChildren() do
		if zone:IsA("Folder") and zone.Name:match("^Fenda_") then
			local model = zone:FindFirstChild(species)
			if model and model:IsA("Model") and model.PrimaryPart then
				local distance = (model.PrimaryPart.Position - root.Position).Magnitude
				if distance < nearest then
					target, nearest = model.PrimaryPart, distance
				end
			end
		end
	end
	if not target or nearest > 120 then return end
	local start = root.Position + root.CFrame.RightVector * 1.5 + Vector3.yAxis
	local stop = target.Position + Vector3.yAxis * (target.Size.Y/2 + 1.5)
	local stone = Instance.new("Part")
	stone.Name = "Cristal de Selo"
	stone.Size = Vector3.new(1.1, 1.5, 1.1)
	stone.Anchored = true
	stone.CanCollide, stone.CanQuery, stone.CanTouch = false, false, false
	local tint = ({Comum = UI.mint, Grande = UI.gold, Mestre = Color3.fromRGB(186, 155, 243), Supremo = Color3.fromRGB(246, 197, 244)})[attr("Crystal", "Comum")] or UI.mint
	stone.Material, stone.Color = Enum.Material.Neon, tint
	stone.CFrame = CFrame.new(start) * CFrame.Angles(0.3, 0.6, math.pi/4)
	stone.Parent = workspace
	local top = Instance.new("Attachment", stone)
	top.Position = Vector3.yAxis * 0.4
	local bottom = Instance.new("Attachment", stone)
	bottom.Position = -top.Position
	local trail = Instance.new("Trail", stone)
	trail.Attachment0, trail.Attachment1 = top, bottom
	trail.Color = ColorSequence.new(tint, UI.text)
	trail.Lifetime, trail.LightEmission = 0.28, 0.8
	local spark = Instance.new("ParticleEmitter", stone)
	spark.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	spark.Color = ColorSequence.new(tint, UI.gold)
	spark.Rate = 0
	spark.Speed = NumberRange.new(4, 8)
	spark.Lifetime = NumberRange.new(0.35, 0.7)
	spark.SpreadAngle = Vector2.new(180, 180)
	spark.Size = NumberSequence.new(0.32, 0)
	spark.LightEmission = 0.7
	task.spawn(function()
		local began = os.clock()
		local shake = -1
		while gui.Parent and attr("Phase") == "Cristal" do
			local elapsed = os.clock() - began
			local progress = math.min(elapsed / 0.36, 1)
			local pos = start:Lerp(stop, progress) + Vector3.yAxis * (math.sin(math.pi * progress) * math.clamp(nearest * 0.15, 2, 8))
			local pulse = math.max(0, elapsed - 0.36)
			local cycle = pulse % 0.6
			local tilt = math.sin(cycle / 0.6 * math.pi * 4) * math.exp(-cycle * 7) * 0.48
			stone.CFrame = CFrame.new(pos) * CFrame.Angles(0.35, elapsed * 3, math.pi/4 + tilt)
			if progress == 1 and math.floor(pulse / 0.6) > shake then
				shake = math.floor(pulse / 0.6)
				spark:Emit(5)
			end
			task.wait()
		end
		if stone.Parent then
			if attr("Phase") == "Baú" then spark:Emit(attr("LastCatch") and 24 or 6) end
			stone.Transparency = 1
			game:GetService("Debris"):AddItem(stone, 0.8)
		end
	end)
end

while gui.Parent do
	local now = workspace:GetServerTimeNow()
	local phase = attr("Phase", "Parceiro")
	local fighting = fightModes[phase] == true
	local inRun = expeditionModes[phase] == true
	local stageIndex = math.clamp(attr("Stage", 1), 1, #Campaign.stages)
	local stage = Campaign.stages[stageIndex]
	local boss = attr("BossName", stage.boss)
	local room = attr("Room", 1)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if lastPhase and phase ~= lastPhase then
		if phase == "Boss" then announce(boss)
		elseif phase == "Captura" then announce("Guardião atordoado")
		elseif phase == "Portal" then announce("Passagem liberada")
		elseif phase == "Cristal" then throwCrystal(boss)
		elseif phase == "Baú" then announce(attr("LastCatch", "") ~= "" and attr("LastCatch") or "Expedição concluída") end
	end
	lastPhase = phase
	local menuOpen = journal.frame.Visible
	info.Visible, bookButton.Visible = not menuOpen, not menuOpen
	-- Na horda a barra de Purificação (script Purificacao) ocupa o topo; este painel fica só para o chefe.
	encounter.Visible = fighting and not menuOpen and phase == "Boss"
	combat.Visible = fighting and not menuOpen
	crystal.Visible = phase == "Captura" and not menuOpen
	stats.Visible = not menuOpen and not (compact and touch and (inRun or phase == "Captura"))
	banner.Visible = noticeUntil ~= nil and noticeUntil > os.clock() and not menuOpen
	local best = tonumber(cleared[tostring(stageIndex)] or cleared[stageIndex]) or 0
	auto.Visible = not menuOpen and best >= 2 and (inRun or phase == "Praça")
	auto.Text = attr("Auto", false) and "Auto ligado" or "Auto"
	bookButton.Text = "Diário" .. keyboardKey("M", "Y")
	chapter.Text = inRun and (string.upper(stage.biome) .. "  /  " .. string.format("%02d", stageIndex)) or "RIFT TAMERS"
	location.Text = inRun and stage.name or "Praça dos Domadores"
	tip.Text = attr("Tip", "Escolha um parceiro para entrar na fenda.")
	local power, lvl = attr("Power", 0), attr("Level", 1)
	local starterName = attr("Starter")
	if not starterName or starterName == "" then starterName = "Domador" end
	statTitle.Text = starterName .. "  ·  Nv. " .. lvl .. "   |   Poder " .. UI.number(power)
	statValue.Text = inRun and string.format("Vida   %d / %d", humanoid and math.ceil(humanoid.Health) or 0, humanoid and math.round(humanoid.MaxHealth) or 0)
		or UI.number(attr("Gold", 0)) .. " ouro    ·    +" .. UI.number(attr("Income", 0)) .. "/s"
	if humanoid then
		local health = humanoid.Health
		hpFill.Size = UDim2.fromScale(math.clamp(health / math.max(1, humanoid.MaxHealth), 0, 1), 1)
		if previousHealth and health < previousHealth then
			hpFill.BackgroundColor3 = UI.red
			TweenService:Create(hpFill, TweenInfo.new(0.42), {BackgroundColor3 = UI.mint}):Play()
		end
		previousHealth = health
	end
	if fighting then
		local bossFight = phase == "Boss"
		local current = bossFight and attr("BossHP", 0) or attr("Kills", 0)
		local total = math.max(1, bossFight and attr("MaxBossHP", 1) or attr("Goal", 1))
		enemyTitle.Text = bossFight and boss or ("Sala " .. math.max(1, room) .. "  ·  Horda")
		progressText.Text = bossFight and (UI.number(current) .. " / " .. UI.number(total) .. " PV")
			or (current .. " / " .. total .. " inimigos")
		if compact and touch and humanoid then
			progressText.Text ..= "   ·   Sua vida " .. math.round(humanoid.Health / math.max(1, humanoid.MaxHealth) * 100) .. "%"
		end
		fill.Size = UDim2.fromScale(math.clamp(current / total, 0, 1), 1)
		fill.BackgroundColor3 = bossFight and UI.red or UI.mint
		threshold.Visible = bossFight
		if bossFight and attr("BossMove", "") ~= "" then tip.Text = attr("BossMove") end
		local spec = Rules.starters[attr("Starter")]
		local remaining = math.max(0, attr("SkillReady", 0) - now)
		local activeName = attr("ActiveSkillName", spec and spec.skill or "Golpe")
		local cooldown = attr("ActiveCooldown", spec and spec.cooldown or 8)
		local color = attr("ActiveColor", spec and spec.color or UI.forest)
		nextSkill.Visible = equippedSlots > 0
		nextSkill.Text = "Trocar habilidade" .. keyboardKey("T", "RB")
		skill.Text = remaining > 0 and (math.ceil(remaining) .. " s") or activeName .. keyboardKey("Q", "RT")
		skill.BackgroundColor3 = UI.panel:Lerp(color, 0.33)
		skillFill.Size = box(1 - math.clamp(remaining / math.max(1, cooldown), 0, 1), -4, 0, 2)
		dodge.Text = "Esquiva" .. keyboardKey("R", "LT")
	end
	if phase == "Captura" then
		local t = ((now - attr("CaptureAt", now)) / math.max(0.1, attr("CapturePeriod", 1))) % 1
		needle.Position = ringPoint(t, 27)
		local chance = Rules.chance(attr("Guaranteed", false), t, attr("Chance", 0.9), attr("Marks", 0))
		changeCrystal.Visible = attr("LargeCrystals", 0) + attr("MasterCrystals", 0) + attr("SupremeCrystals", 0) > 0
		changeCrystal.Text = "Cristal " .. attr("Crystal", "Comum") .. "   ⇄"
		chanceText.Text = "Selo   ·   " .. math.round(chance * 100) .. "% de chance"
		seal.Text = "Lançar cristal" .. keyboardKey("F", "X")
	end
	if not fighting and not menuOpen and phase ~= "Captura" then updateWaypoint(attr("Destination"), root) else waypoint.Visible = false end
	task.wait(crystal.Visible and 0.025 or 0.12)
end
