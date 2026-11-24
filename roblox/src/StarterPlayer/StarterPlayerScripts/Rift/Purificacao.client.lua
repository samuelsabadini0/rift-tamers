-- Desenha a fenda a partir do estado do servidor (só visual, nada aqui decide jogo):
-- barra de Purificação no topo, névoa e manchas que recuam, chão que volta a ficar verde,
-- câmera alta e inclinada para ver a horda inteira, e o estouro de luz em 100%.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UI = require(script.Parent.GuiStyle)

local player = Players.LocalPlayer
local THRESHOLDS = {0, 30, 65, 100}
local AREA_NAMES = {"Clareira Sombria", "Bosque das Raízes", "Coração Corrompido"}
local riftPhases = {Horda = true, Boss = true, Captura = true, Cristal = true, ["Baú"] = true}
local CAMERA_OFFSET = Vector3.new(0, 62, 38)
local corruptGround = Color3.fromRGB(92, 72, 108)

------------------------------------------------------------------ HUD
local gui = Instance.new("ScreenGui")
gui.Name = "Purificacao"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 5
gui.Parent = player:WaitForChild("PlayerGui")

local top = UI.panelAt(gui, "Barra de Purificação", UDim2.new(0.5, 0, 0, 8), UDim2.fromOffset(460, 88))
top.AnchorPoint = Vector2.new(0.5, 0)
local title = UI.label(top, "Título", UDim2.fromOffset(14, 6), UDim2.new(1, -28, 0, 20), "PURIFICAÇÃO", UI.bold, 14, UI.gold)
local value = UI.label(top, "Valor", UDim2.fromOffset(14, 6), UDim2.new(1, -28, 0, 20), "0%", UI.bold, 16, UI.text)
value.TextXAlignment = Enum.TextXAlignment.Right
local track = UI.frame(top, "Trilho", UDim2.fromOffset(14, 32), UDim2.new(1, -28, 0, 16), Color3.fromRGB(58, 34, 74), 6)
local fill = UI.frame(track, "Preenchimento", UDim2.new(), UDim2.fromScale(0, 1), UI.mint, 6)
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new(Color3.fromRGB(170, 120, 240), Color3.fromRGB(124, 240, 196))
gradient.Parent = fill
for i, mark in {30, 65, 100} do
	UI.frame(track, "Marco " .. mark, UDim2.new(mark / 100, -1, 0, -3), UDim2.new(0, 3, 1, 6), UI.gold)
	local x = 14 + 432 * mark / 100 - (i < 3 and 22 or 34)
	UI.label(top, "Rótulo " .. mark, UDim2.fromOffset(x, 48), UDim2.fromOffset(60, 12), i < 3 and ("Portal " .. mark .. "%") or "Chefe", UI.body, 10, UI.soft)
end
-- XP do time e o loot recolhido nesta fenda.
local xpTrack = UI.frame(top, "Trilho de XP", UDim2.fromOffset(14, 66), UDim2.new(0, 150, 0, 6), Color3.fromRGB(26, 50, 60), 3)
local xpFill = UI.frame(xpTrack, "XP", UDim2.new(), UDim2.fromScale(0, 1), Color3.fromRGB(120, 232, 255), 3)
local xpText = UI.label(top, "Texto de XP", UDim2.fromOffset(172, 61), UDim2.fromOffset(120, 16), "", UI.bold, 12, Color3.fromRGB(150, 236, 255))
local lootText = UI.label(top, "Loot da fenda", UDim2.fromOffset(250, 61), UDim2.fromOffset(196, 16), "", UI.bold, 12, UI.gold)
lootText.TextXAlignment = Enum.TextXAlignment.Right
top.Visible = false

local banner = UI.label(gui, "Faixa", UDim2.new(0.5, 0, 0.3, 0), UDim2.fromOffset(700, 70), "", UI.serif, 54, UI.gold)
banner.AnchorPoint = Vector2.new(0.5, 0.5)
banner.TextXAlignment = Enum.TextXAlignment.Center
banner.TextStrokeTransparency = 0.2
banner.TextTransparency = 1
banner.TextStrokeColor3 = UI.ink
local flash = UI.frame(gui, "Clarão", UDim2.new(), UDim2.fromScale(1, 1), Color3.new(1, 1, 1))
flash.BackgroundTransparency = 1
flash.ZIndex = 0

local function show(text, seconds)
	banner.Text = text
	banner.TextTransparency = 0
	banner.TextStrokeTransparency = 0.2
	banner.Size = UDim2.fromOffset(560, 56)
	TweenService:Create(banner, TweenInfo.new(0.35, Enum.EasingStyle.Back), {Size = UDim2.fromOffset(700, 70)}):Play()
	task.delay(seconds or 2.4, function()
		if banner.Text ~= text then return end
		TweenService:Create(banner, TweenInfo.new(0.6), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
	end)
end

------------------------------------------------------------------ world visuals
local function runFolder()
	local name = player:GetAttribute("RiftFolder")
	return name and workspace:FindFirstChild(name)
end

local function areaShare(p, index, current)
	if index < current then return 1 end
	if index > current then return 0 end
	return math.clamp((p - THRESHOLDS[index]) / (THRESHOLDS[index + 1] - THRESHOLDS[index]), 0, 1)
end

local tracked = {} -- [part] = {kind, area, limiar, base}
local trackedFolder, streamConnection
local dirty = false
local function register(run, d)
	if not d:IsA("BasePart") then return end
	local area = d.Parent
	while area and area ~= run and not area:GetAttribute("Area") do area = area.Parent end
	local index = area and area:GetAttribute("Area")
	if not index then return end
	local healthy = d:GetAttribute("Saudavel")
	local limiar = d:GetAttribute("Limiar")
	if healthy then
		tracked[d] = {kind = "ground", area = index, color = healthy}
	elseif limiar then
		local reveal = d.Parent and d.Parent.Name == "Vida"
		tracked[d] = {kind = reveal and "life" or "corruption", area = index, limiar = limiar, base = d.Transparency, fog = d:GetAttribute("Nevoa")}
	else
		return
	end
	dirty = true
end
-- With streaming on, parts arrive over time: register them as they stream in.
local function collect(run)
	table.clear(tracked)
	if streamConnection then streamConnection:Disconnect() end
	trackedFolder = run
	for _, d in run:GetDescendants() do register(run, d) end
	streamConnection = run.DescendantAdded:Connect(function(d) register(run, d) end)
end

local function paint(p, current)
	for part, info in tracked do
		if not part.Parent then tracked[part] = nil continue end
		local share = areaShare(p, info.area, current)
		if info.kind == "ground" then
			part.Color = corruptGround:Lerp(info.color, 0.2 + 0.8 * share)
		elseif info.kind == "life" then
			part.Transparency = share >= info.limiar and 0 or 1
		else
			local gone = share >= info.limiar
			local target = gone and 1 or info.base
			if math.abs(part.Transparency - target) > 0.01 then
				TweenService:Create(part, TweenInfo.new(info.fog and 1.6 or 0.8), {Transparency = target}):Play()
			end
		end
	end
end

-- Purple tint on the whole screen while the current area is corrupt.
local tint = Instance.new("ColorCorrectionEffect")
tint.Name = "Corrupção da fenda"
tint.Enabled = false
tint.Parent = Lighting

local function burst(position)
	local ball = Instance.new("Part")
	ball.Anchored, ball.CanCollide, ball.CanQuery, ball.CanTouch, ball.CastShadow = true, false, false, false, false
	ball.Shape = Enum.PartType.Ball
	ball.Material = Enum.Material.Neon
	ball.Color = Color3.fromRGB(255, 246, 200)
	ball.Size = Vector3.one * 4
	ball.Position = position
	ball.Transparency = 0.1
	ball.Parent = workspace
	TweenService:Create(ball, TweenInfo.new(1.4, Enum.EasingStyle.Quad), {Size = Vector3.one * 260, Transparency = 1}):Play()
	game:GetService("Debris"):AddItem(ball, 1.5)
	flash.BackgroundTransparency = 0.15
	TweenService:Create(flash, TweenInfo.new(1.1), {BackgroundTransparency = 1}):Play()
end

------------------------------------------------------------------ camera
local camera = workspace.CurrentCamera
local topDown = false
local function setTopDown(on)
	if on == topDown then return end
	topDown = on
	camera = workspace.CurrentCamera
	if on then
		camera.CameraType = Enum.CameraType.Scriptable
		camera.FieldOfView = 60
	else
		camera.CameraType = Enum.CameraType.Custom
		camera.FieldOfView = 70
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then camera.CameraSubject = humanoid end
	end
end

RunService:BindToRenderStep("CameraDaFenda", Enum.RenderPriority.Camera.Value + 1, function()
	if not topDown then return end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local focus = root.Position
	local goal = CFrame.lookAt(focus + CAMERA_OFFSET, focus)
	camera.CFrame = camera.CFrame:Lerp(goal, 0.25)
end)

-- Modo Auto: o servidor publica o destino (AutoWalk) e o cliente, dono da física, anda até lá.
-- Se o jogador mexer no controle, o ControlModule tem prioridade sobre o MoveTo.
local lastGoal
task.spawn(function()
	while gui.Parent do
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		local goal = player:GetAttribute("AutoWalk")
		if humanoid and humanoid.Health > 0 and player:GetAttribute("Auto") and typeof(goal) == "Vector3"
			and riftPhases[player:GetAttribute("Phase")] then
			humanoid:MoveTo(goal)
			lastGoal = goal
		elseif lastGoal then
			lastGoal = nil
			if humanoid and humanoid.RootPart then humanoid:MoveTo(humanoid.RootPart.Position) end
		end
		task.wait(.2)
	end
end)

player:GetAttributeChangedSignal("LevelUp"):Connect(function()
	show("Subiu para o nível " .. tostring(player:GetAttribute("LevelUp")) .. "!", 2)
end)

------------------------------------------------------------------ loop
local lastP, lastArea = nil, nil
while gui.Parent do
	local phase = player:GetAttribute("Phase")
	local run = runFolder()
	local inRift = run ~= nil and riftPhases[phase] == true
	setTopDown(inRift)
	top.Visible = inRift and phase == "Horda"
	tint.Enabled = inRift
	if top.Visible then
		local xp, nextXp = player:GetAttribute("XP") or 0, math.max(1, player:GetAttribute("XPNext") or 1)
		xpFill.Size = UDim2.fromScale(math.clamp(xp / nextXp, 0, 1), 1)
		xpText.Text = "Nv. " .. (player:GetAttribute("Level") or 1) .. "  ·  " .. UI.number(xp) .. "/" .. UI.number(nextXp) .. " XP"
		local gold, frags = player:GetAttribute("RunGold") or 0, player:GetAttribute("RunFragments") or 0
		lootText.Text = "+" .. UI.number(gold) .. " ouro" .. (frags > 0 and ("  ·  +" .. frags .. " fragmentos") or "")
	end
	if inRift then
		if run ~= trackedFolder then collect(run) lastP, lastArea = nil, nil end
		local p = run:GetAttribute("Purificacao") or 0
		local area = run:GetAttribute("Area") or 1
		if p ~= lastP or area ~= lastArea or dirty then
			dirty = false
			if lastP then
				for i = 2, 3 do
					if lastP < THRESHOLDS[i] and p >= THRESHOLDS[i] then show("Portal aberto!", 2.2) end
				end
				if lastP < 100 and p >= 100 then
					local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
					if root then burst(root.Position) end
					show("Fenda Purificada!", 3.2)
				end
			end
			if lastArea and area ~= lastArea then show("Área " .. area .. " • " .. AREA_NAMES[area], 2.4) end
			lastP, lastArea = p, area
			paint(p, area)
			fill.Size = UDim2.fromScale(math.clamp(p / 100, 0, 1), 1)
			value.Text = string.format("%d%%", math.floor(p))
			title.Text = "PURIFICAÇÃO  ·  ÁREA " .. area .. " DE 3  ·  " .. string.upper(AREA_NAMES[area] or "")
			local share = areaShare(p, area, area)
			tint.TintColor = Color3.new(1, 1, 1):Lerp(Color3.fromRGB(226, 204, 246), 1 - share)
			tint.Saturation = -0.25 * (1 - share)
		end
	elseif trackedFolder then
		trackedFolder = nil
		if streamConnection then streamConnection:Disconnect() streamConnection = nil end
		table.clear(tracked)
	end
	task.wait(0.1)
end
