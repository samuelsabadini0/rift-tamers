local UI = require(script.Parent.GuiStyle)
local RouteMap = {}

-- Plot the surveyed room centers in the direction of travel, from the camp to the keep.
function RouteMap.new(parent, nodes, room, player)
	local paper = UI.frame(parent, "Mapa da expedição", UDim2.new(), UDim2.new(1, -6, 0, 117), UI.panel, 6)
	UI.label(paper, "Legenda", UDim2.fromOffset(10, 3), UDim2.new(1, -20, 0, 22),
		"Entrada   →   Salas I, II e III   →   Chefe", UI.body, 14, UI.gold)
	local plot = UI.frame(paper, "Traçado", UDim2.fromOffset(13, 32), UDim2.new(1, -26, 1, -43), UI.panel)
	local points = {}
	local minX, maxX, minY, maxY = math.huge, -math.huge, math.huge, -math.huge
	for _, node in nodes do
		local x, y = -node[2], node[1]
		table.insert(points, Vector2.new(x, y))
		minX, maxX = math.min(minX, x), math.max(maxX, x)
		minY, maxY = math.min(minY, y), math.max(maxY, y)
	end
	local function project(x, y)
		local viewport = plot.AbsoluteSize
		local a = (x - minX) / math.max(1, maxX - minX)
		local b = (y - minY) / math.max(1, maxY - minY)
		return Vector2.new(7 + math.clamp(a, 0, 1) * math.max(1, viewport.X - 14), 9 + math.clamp(b, 0, 1) * math.max(1, viewport.Y - 18))
	end
	local pins, roads = {}, {}
	for i = 1, #points do
		if i > 1 then
			local road = UI.frame(plot, "Ponte", UDim2.new(), UDim2.new(), i <= room + 1 and UI.gold or UI.edge, 2)
			road.AnchorPoint = Vector2.new(0.5, 0.5)
			roads[i] = road
		end
		local icon = UI.frame(plot, "Sala" .. i, UDim2.new(), UDim2.fromOffset(12, 12), i == room + 1 and UI.gold or UI.ink, 2)
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Rotation = 45
		icon.ZIndex = 2
		UI.stroke(icon, UI.gold)
		pins[i] = icon
	end
	local dot = UI.frame(plot, "Sua posição", UDim2.new(), UDim2.fromOffset(7, 7), UI.mint, 4)
	dot.AnchorPoint, dot.ZIndex = Vector2.new(0.5, 0.5), 3
	UI.stroke(dot, UI.ink)
	local function draw()
		local last
		for i, point in points do
			local pos = project(point.X, point.Y)
			pins[i].Position = UDim2.fromOffset(pos.X, pos.Y)
			if last then
				local delta = pos - last
				local mid = (pos + last)/2
				roads[i].Position = UDim2.fromOffset(mid.X, mid.Y)
				roads[i].Size = UDim2.fromOffset(delta.Magnitude, 2)
				roads[i].Rotation = math.deg(math.atan2(delta.Y, delta.X))
			end
			last = pos
		end
	end
	plot:GetPropertyChangedSignal("AbsoluteSize"):Connect(draw)
	draw()
	task.spawn(function()
		while paper.Parent do
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			dot.Visible = root ~= nil
			if root then
				local pos = project(-root.Position.Z, root.Position.X)
				dot.Position = UDim2.fromOffset(pos.X, pos.Y)
			end
			task.wait(0.25)
		end
	end)
	return paper
end

return RouteMap
