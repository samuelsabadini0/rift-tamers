local HttpService = game:GetService("HttpService")
local UI = require(script.Parent.GuiStyle)
local RouteMap = require(script.Parent.RouteMap)
local CreatureModels = require(game:GetService("ReplicatedStorage"):WaitForChild("Rift"):WaitForChild("CreatureModels"))
local Journal = {}
local at = UDim2.fromOffset
local size = UDim2.new
local difficulties = {"Normal", "Difícil", "Pesadelo"}
local awakenCosts = {100, 300, 800, 2000}

local function decode(value)
	if type(value) ~= "string" then return {} end
	local ok, result = pcall(HttpService.JSONDecode, HttpService, value)
	return ok and type(result) == "table" and result or {}
end

local function scroller(parent, name)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = name
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.CanvasSize = UDim2.new()
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.ScrollBarImageColor3 = UI.edge
	scroll.ScrollBarThickness = 4
	scroll.Parent = parent
	local list = Instance.new("UIListLayout")
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 5)
	list.Parent = scroll
	return scroll
end

function Journal.new(gui, player, stages, remote)
	local state = {tab = "Fendas", index = 1, difficulty = 1, confirm = false}
	local function attr(key, fallback)
		local value = player:GetAttribute(key)
		if value == nil then return fallback end
		return value
	end
	local overlay = UI.frame(gui, "Diário", UDim2.new(), UDim2.fromScale(1, 1), Color3.fromRGB(7, 15, 17))
	overlay.BackgroundTransparency = 0.26
	overlay.Active = true
	overlay.Visible = false
	local book = UI.panelAt(overlay, "Manuscrito", UDim2.fromScale(0.5, 0.5), size(1, -28, 1, -24))
	book.AnchorPoint = Vector2.new(0.5, 0.5)
	local limit = Instance.new("UISizeConstraint")
	limit.MaxSize = Vector2.new(852, 534)
	limit.Parent = book
	UI.compass(book, at(16, 11), 28, UI.gold)
	UI.label(book, "Título", at(54, 6), size(1, -118, 0, 40), "Diário do domador", UI.serif, 29)
	local close = UI.button(book, "Fechar", size(1, -52, 0, 9), at(40, 34), "×", function()
		overlay.Visible = false
		state.confirm = false
	end)
	close.TextSize = 25
	local tabs = UI.frame(book, "Abas", at(14, 53), size(1, -28, 0, 37), UI.panel, 6)
	local tabButtons, rows, controls = {}, {}, {}
	local list = scroller(book, "Índice")
	local detail = scroller(book, "Ficha")
	local draw
	local function selectTab(tab)
		state.tab, state.confirm = tab, false
		state.index = math.clamp(attr("Stage", 1), 1, #stages)
		state.difficulty = attr("Difficulty", 1)
		list.CanvasPosition = Vector2.zero
		detail.CanvasPosition = Vector2.zero
		draw()
	end
	for i, tab in {"Fendas", "Bestiário", "Domador"} do
		tabButtons[tab] = UI.button(tabs, tab, size((i - 1) / 3, 0, 0, 0), size(1 / 3, -2, 1, 0), tab,
			function() selectTab(tab) end)
	end
	local function regionName(i)
		return i <= 6 and "Bosque Musgoso" or "Dunas de Cristal"
	end
	local portrait = Instance.new("ViewportFrame")
	portrait.Name = "Retrato"
	portrait.Size = size(1, -7, 0, 97)
	portrait.BorderSizePixel = 0
	portrait.BackgroundColor3 = UI.panel
	portrait.Ambient = Color3.fromRGB(176, 175, 159)
	portrait.LightColor = Color3.fromRGB(255, 238, 199)
	portrait.LightDirection = Vector3.new(-1, -1, -0.5)
	UI.corner(portrait, 6)
	local camera = Instance.new("Camera", portrait)
	camera.FieldOfView = 35
	portrait.CurrentCamera = camera
	local model
	local lastPortrait
	local function showPortrait(name, silhouette, order)
		local key = name .. tostring(silhouette)
		if lastPortrait ~= key then
			if model then model:Destroy() end
			model = CreatureModels.create(portrait, name, Vector3.zero, 2)
			if silhouette then
				for _, part in model:GetChildren() do
					if part:IsA("BasePart") then
						part.Color = Color3.fromRGB(39, 52, 57)
						part.Material = Enum.Material.SmoothPlastic
					end
				end
			end
			local center, bounds = model:GetBoundingBox()
			local dir = Vector3.new(-0.48, 0.26, -1).Unit
			camera.CFrame = CFrame.lookAt(center.Position + dir * bounds.Magnitude * 1.12, center.Position)
			lastPortrait = key
		end
		portrait.Parent = detail
		portrait.LayoutOrder = order
	end
	local function resetControls()
		for _, control in controls do control:Destroy() end
		table.clear(controls)
	end
	local function add(control)
		table.insert(controls, control)
		control.LayoutOrder = #controls
		return control
	end
	local function line(text, font, points, color, h)
		local l = add(UI.label(detail, "Descrição", at(0, 0), size(1, -6, 0, h or points + 9), text, font, points, color))
		l.TextWrapped = true
		l.TextTruncate = Enum.TextTruncate.None
		return l
	end
	local function command(name, caption, active, action)
		local b = add(UI.button(detail, name, at(0, 0), size(1, -6, 0, 38), caption, function()
			if active then action() end
		end))
		UI.active(b, active)
	end
	local function layout()
		local w, h = book.AbsoluteSize.X, book.AbsoluteSize.Y
		local compact = w < 500
		if compact then
			local rowsHeight = state.tab == "Domador" and 0 or math.floor((h - 108) * 0.37)
			list.Position, list.Size = at(14, 100), size(1, -27, 0, rowsHeight)
			detail.Position = at(14, 105 + rowsHeight)
			detail.Size = size(1, -27, 1, -119 - rowsHeight)
		else
			local left = state.tab == "Domador" and 0 or math.floor(w * 0.45)
			list.Position, list.Size = at(15, 102), size(0, math.max(0, left - 19), 1, -118)
			detail.Position, detail.Size = at(15 + left, 102), size(1, -33 - left, 1, -118)
		end
	end
	for i, stage in stages do
		local b = UI.button(list, "Fenda" .. i, at(0, 0), size(1, -7, 0, 46), "", function()
			state.index, state.confirm = i, false
			state.difficulty = i == attr("Stage", 1) and attr("Difficulty", 1) or 1
			detail.CanvasPosition = Vector2.zero
			draw()
		end)
		b.LayoutOrder = i
		local n = UI.label(b, "Número", at(10, 4), at(29, 38), string.format("%02d", i), UI.serif, 22, UI.gold)
		local name = UI.label(b, "Nome", at(46, 3), size(1, -57, 0, 22), stage.name, UI.bold, 15)
		local status = UI.label(b, "Estado", at(46, 23), size(1, -57, 0, 19), "", UI.body, 13, UI.soft)
		rows[i] = {button = b, title = name, status = status, number = n}
	end
	local function value(listing, i)
		return tonumber(listing[tostring(i)] or listing[i]) or 0
	end
	draw = function()
		if not overlay.Visible then return end
		local cleared = decode(attr("Cleared"))
		local collected = decode(attr("Collection"))
		local equipped = decode(attr("Equipped"))
		local owned = 0
		local stageIndex = state.index
		local stage = stages[stageIndex]
		local highest = attr("Unlocked", 1)
		local selected = attr("Stage", 1)
		local inHub = attr("Phase") == "Praça"
		for tab, button in tabButtons do
			button.BackgroundColor3 = state.tab == tab and UI.forest or UI.panel
			button.TextColor3 = state.tab == tab and UI.gold or UI.soft
		end
		list.Visible = state.tab ~= "Domador"
		for i, row in rows do
			local entry = stages[i]
			local count, wins = value(collected, i), value(cleared, i)
			if count > 0 then owned += 1 end
			row.button.BackgroundColor3 = i == stageIndex and UI.forest or UI.panel
			if state.tab == "Bestiário" then
				row.title.Text = count > 0 and entry.boss or "Espécie desconhecida"
				row.status.Text = count > 0 and (table.find(equipped, i) and "No time" or "Capturada") or entry.name
			else
				row.title.Text = entry.name
				row.status.Text = (i == selected and "No portal" or i > highest and "Bloqueada"
					or wins > 0 and "Vitória · " .. difficulties[math.clamp(wins, 1, 3)] or "Disponível")
			end
		end
		resetControls()
		portrait.Parent = nil
		if state.tab == "Fendas" then
			local wins = value(cleared, stageIndex)
			local king = stageIndex <= 6 and 6 or 12
			local diff = state.difficulty
			line(string.upper(regionName(stageIndex)) .. "   /   FENDA " .. stageIndex, UI.bold, 14, UI.gold)
			line(stage.name, UI.serif, 28, UI.text, 39)
			line(stage.boss .. "   ·   " .. stage.rarity .. "   ·   " .. stage.element, UI.body, 15, UI.soft, 27)
			local route = decode(attr("RouteMap"))
			if selected == stageIndex and #route == 5 then
				add(RouteMap.new(detail, route, attr("Room", 1), player))
			else
				showPortrait(stage.boss, false, 0)
			end
			local bar = add(UI.frame(detail, "Dificuldade", at(0, 0), size(1, -7, 0, 34), UI.panel, 5))
			for i, name in difficulties do
				local b = UI.button(bar, name, size((i-1)/3, 0, 0, 0), size(1/3, -2, 1, 0), name, function()
					state.difficulty = i
					draw()
				end)
				b.TextSize = 14
				b.BackgroundColor3 = i == diff and UI.forest or UI.panel
				b.TextColor3 = i == diff and UI.gold or UI.soft
			end
			line("Poder recomendado  " .. UI.number(stage.power * ({1, 3, 9})[diff])
				.. "     •     Seu time  " .. UI.number(attr("Power", 0)), UI.body, 15, UI.text, 39)
			local available = stageIndex <= highest and (diff == 1 or diff == 2 and wins >= 1
				or diff == 3 and wins >= 2 and value(cleared, king) >= 1)
			local active = stageIndex == selected and attr("Difficulty", 1) == diff
			local caption = active and "Selecionada no portal" or available and "Preparar esta fenda"
				or stageIndex > highest and "Vença a fenda anterior" or diff == 3 and "Vença o Difícil e o Rei" or "Vença no Normal"
			command("Selecionar", caption, available and not active and inHub, function()
				if selected ~= stageIndex then
					remote:FireServer("select", stageIndex, diff)
				else
					remote:FireServer("difficulty", diff)
				end
			end)
			if inHub and active then
				command("Grupo", "Juntar-se a uma expedição", true, function()
					remote:FireServer("join")
					overlay.Visible = false
				end)
				line("O portal da praça inicia sua própria expedição.", UI.body, 14, UI.soft, 36)
			end
		elseif state.tab == "Bestiário" then
			local count = value(collected, stageIndex)
			showPortrait(stage.boss, count == 0, 0)
			line("MONSTRODEX   /   " .. owned .. " DE " .. #stages, UI.bold, 14, UI.gold)
			line(count > 0 and stage.boss or "Espécie desconhecida", UI.serif, 28, UI.text, 40)
			line(regionName(stageIndex) .. "   ·   " .. stage.name, UI.body, 15, UI.soft, 38)
			if count > 0 then
				line("Na bolsa   " .. count .. "     •     Renda base   " .. UI.number(stage.income) .. "/s", UI.body, 16, UI.text, 36)
				local using = table.find(equipped, stageIndex) ~= nil
				command("Equipar", using and "Retirar do time" or "Equipar no time", inHub, function()
					remote:FireServer("equip", stageIndex)
				end)
				local specimens = decode(attr("Specimens"))
				local captured = specimens[tostring(stageIndex)] or specimens[stageIndex] or {}
				if #captured > 0 then
					line("Registros de captura", UI.serif, 22, UI.text)
					local grouped = {}
					for _, specimen in captured do
						local traits = {}
						for _, key in {"variant", "size", "mutation"} do
							local trait = specimen[key]
							if type(trait) == "string" and trait ~= "" and not table.find(traits, trait) then table.insert(traits, trait) end
						end
						local id = #traits > 0 and table.concat(traits, "  ·  ") or stage.boss
						grouped[id] = (grouped[id] or 0) + 1
					end
					local types = {}
					for id in grouped do table.insert(types, id) end
					table.sort(types)
					for _, id in types do line(grouped[id] .. " × " .. id, UI.body, 14, UI.soft, 28) end
				end
				local ranks = decode(attr("SpeciesStars"))
				local stars = math.max(1, value(ranks, stageIndex))
				local price = 2 ^ (stars - 1)
				local caption = stars == 5 and "Fusão completa" or "Fundir  ·  " .. price .. (price == 1 and " duplicata" or " duplicatas")
				line(stars .. " estrelas", UI.body, 15, UI.gold)
				command("Fundir", caption, inHub and stars < 5 and count > price, function() remote:FireServer("fuse", stageIndex) end)
			else
				line("Encontre este guardião no fim da fenda e lance um cristal.", UI.body, 16, UI.soft, 53)
			end
		else
			local stars = attr("Stars", 1)
			local starter = attr("Starter")
			if starter and starter ~= "" then showPortrait(starter, false, 0) else starter = "Domador" end
			line(starter .. "   ·   Nível " .. attr("Level", 1), UI.serif, 27, UI.text, 39)
			line("Poder " .. UI.number(attr("Power", 0)) .. "     •     " .. stars .. " estrelas     •     Ascensão " .. attr("Ascension", 0), UI.bold, 15, UI.gold, 30)
			line(UI.number(attr("Gold", 0)) .. " ouro     •     " .. UI.number(attr("Gems", 0)) .. " gemas     •     "
				.. UI.number(attr("Fragments", 0)) .. " fragmentos", UI.body, 15, UI.soft, 35)
			line("Cofre  " .. UI.number(attr("Bank", 0)) .. "     •     Renda  +" .. UI.number(attr("Income", 0)) .. "/s", UI.body, 15, UI.soft)
			local quests = decode(attr("Quests"))
			if #quests > 0 then
				line("Missões do dia", UI.serif, 23, UI.text)
				for _, quest in quests do
					line(quest.title .. "   ·   " .. (quest.done and "Concluída" or quest.count .. " / " .. quest.goal), UI.body, 15, quest.done and UI.mint or UI.soft, 32)
				end
			end
			local canClaim = attr("DailyReady", false)
			command("Diária", canClaim and "Receber recompensa diária" or "Diária recebida", inHub and canClaim, function() remote:FireServer("daily") end)
			line("Forja de cristais", UI.serif, 23, UI.text)
			line("Grande  ×" .. attr("LargeCrystals", 0) .. "      Mestre  ×" .. attr("MasterCrystals", 0), UI.body, 15, UI.gold)
			command("ForjarGrande", "Cristal Grande  ·  1 mil ouro", inHub and attr("Gold", 0) >= 1000, function() remote:FireServer("forge", "Grande") end)
			command("ForjarMestre", "Cristal Mestre  ·  60 fragmentos", inHub and attr("Fragments", 0) >= 60, function() remote:FireServer("forge", "Mestre") end)
			local cost = awakenCosts[stars]
			command("Despertar", cost and "Despertar parceiro  ·  " .. UI.number(cost) .. " fragmentos" or "Despertar completo",
				inHub and cost ~= nil and attr("Fragments", 0) >= (cost or 0), function() remote:FireServer("awakening") end)
			local full = attr("CanAscend", false)
			line("Ascensão", UI.serif, 23, UI.text)
			line("Vença Solarya e junte " .. UI.number(attr("AscendCost", 10000000)) .. " ouro.", UI.body, 15, UI.soft, 34)
			if state.confirm then
				line("Sua coleção, gemas e estrelas ficam. Ouro, cofre, vagas ocupadas, níveis e fases recomeçam.", UI.body, 15, UI.gold, 56)
			end
			command("Ascender", state.confirm and "Confirmar Ascensão" or "Ascender", inHub and full, function()
				if state.confirm then
					remote:FireServer("ascend")
					state.confirm = false
				else
					state.confirm = true
				end
				draw()
			end)
		end
		layout()
	end
	book:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
	local redrawScheduled = false
	local watched = {
		SpeciesStars=true, Specimens=true, LargeCrystals=true, MasterCrystals=true, RouteMap=true, Room=true, Quests=true, Stage=true, Difficulty=true, Unlocked=true, Cleared=true, Collection=true, Equipped=true, DailyReady=true,
		CanAscend=true, Power=true, Level=true, Fragments=true, Gems=true, Gold=true, Ascension=true, Stars=true, Phase=true,
	}
	player.AttributeChanged:Connect(function(key)
		if not overlay.Visible or not watched[key] or redrawScheduled then return end
		redrawScheduled = true
		task.defer(function()
			redrawScheduled = false
			draw()
		end)
	end)
	local function toggle(tab)
		if overlay.Visible then
			overlay.Visible = false
		else
			overlay.Visible = true
			selectTab(tab or state.tab)
		end
	end
	local function open(tab)
		overlay.Visible = true
		selectTab(tab or state.tab)
	end
	return {toggle = toggle, open = open, frame = overlay}
end

return Journal
