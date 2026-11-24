-- The dungeon HUD and the journal share the same ink, parchment and brass.
local UI = {}
UI.ink = Color3.fromRGB(18, 32, 36)
UI.panel = Color3.fromRGB(30, 48, 51)
UI.edge = Color3.fromRGB(138, 127, 94)
UI.gold = Color3.fromRGB(242, 202, 130)
UI.text = Color3.fromRGB(247, 241, 221)
UI.soft = Color3.fromRGB(194, 210, 199)
UI.mint = Color3.fromRGB(124, 228, 186)
UI.forest = Color3.fromRGB(42, 94, 82)
UI.red = Color3.fromRGB(236, 127, 113)
UI.serif = Enum.Font.Garamond
UI.body = Enum.Font.GothamMedium
UI.bold = Enum.Font.GothamBold

function UI.corner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
end

function UI.stroke(parent, color, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = color
	stroke.Transparency = transparency or 0
	stroke.Parent = parent
	return stroke
end

function UI.frame(parent, name, pos, size, color, radius)
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Position = pos
	frame.Size = size
	frame.BackgroundColor3 = color or UI.panel
	frame.BorderSizePixel = 0
	frame.Parent = parent
	if radius then UI.corner(frame, radius) end
	return frame
end

function UI.panelAt(parent, name, pos, size)
	local frame = UI.frame(parent, name, pos, size, UI.ink, 8)
	frame.BackgroundTransparency = 0.06
	UI.stroke(frame, UI.edge, 0.24)
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(200, 221, 218))
	gradient.Rotation = 45
	gradient.Parent = frame
	return frame
end

function UI.label(parent, name, pos, size, initial, font, textSize, color)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Position = pos
	label.Size = size
	label.BackgroundTransparency = 1
	label.Font = font or UI.body
	label.TextSize = textSize or 16
	label.TextColor3 = color or UI.text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Text = initial or ""
	label.Parent = parent
	return label
end

function UI.button(parent, name, pos, size, title, onPress)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Position = pos
	button.Size = size
	button.BackgroundColor3 = UI.panel
	button.BorderSizePixel = 0
	button.TextColor3 = UI.text
	button.TextSize = 15
	button.Font = UI.bold
	button.Text = title
	button.Parent = parent
	UI.corner(button, 6)
	UI.stroke(button, UI.edge, 0.35)
	button.Activated:Connect(onPress)
	return button
end

function UI.active(button, active)
	button.Active = active
	button.Selectable = active
	button.AutoButtonColor = active
	button.TextColor3 = active and UI.text or UI.soft
	button.BackgroundColor3 = active and UI.forest or UI.panel
end

function UI.number(value)
	value = tonumber(value) or 0
	for _, scale in {{1e12, "tri"}, {1e9, "bi"}, {1e6, "mi"}, {1e3, "mil"}} do
		if value >= scale[1] then
			return (string.format("%.1f", value / scale[1]):gsub("%.0$", ""):gsub("%.", ",")) .. " " .. scale[2]
		end
	end
	return tostring(math.round(value))
end

-- A four-point compass uses native geometry and remains crisp at small sizes.
function UI.compass(parent, pos, size, color)
	local frame = UI.frame(parent, "Bússola", pos, UDim2.fromOffset(size, size), UI.ink)
	frame.BackgroundTransparency = 1
	local middle = UDim2.fromScale(0.5, 0.5)
	for _, angle in {0, 90} do
		local needle = UI.frame(frame, "Agulha", middle, UDim2.fromScale(0.12, 0.96), color)
		needle.AnchorPoint = Vector2.new(0.5, 0.5)
		needle.Rotation = angle
	end
	local rose = UI.frame(frame, "Rosa", middle, UDim2.fromScale(0.50, 0.50), UI.ink)
	rose.AnchorPoint = Vector2.new(0.5, 0.5)
	rose.Rotation = 45
	UI.stroke(rose, color)
	local core = UI.frame(rose, "Centro", middle, UDim2.fromScale(0.43, 0.43), color)
	core.AnchorPoint = Vector2.new(0.5, 0.5)
	return frame
end

return UI
