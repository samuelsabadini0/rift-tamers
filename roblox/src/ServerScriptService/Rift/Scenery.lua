local World = {}
local moss = Color3.fromRGB(104, 154, 102)
local stone = Color3.fromRGB(84, 107, 116)
local light = Color3.fromRGB(124, 244, 221)
function World.part(parent, name, pos, size, color, shape, material)
	local p = Instance.new("Part")
	p.Name, p.Anchored, p.Size, p.Position = name, true, size, pos
	p.Shape, p.Color, p.Material = shape or Enum.PartType.Block, color, material or Enum.Material.SmoothPlastic
	p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end
function World.label(part, text, height)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(180, 33)
	gui.StudsOffset = Vector3.new(0, height, 0)
	gui.MaxDistance = 56
	gui.Parent = part
	local l = Instance.new("TextLabel")
	l.Size, l.BackgroundTransparency = UDim2.fromScale(1, 1), 1
	l.Text, l.TextColor3, l.TextSize = text, Color3.new(1,1,1), 15
	l.Font, l.TextStrokeTransparency = Enum.Font.GothamBold, 0.35
	l.Parent = gui
	return l
end
function World.prompt(part, action, callback)
	local p = Instance.new("ProximityPrompt")
	p.ActionText, p.ObjectText = action, part.Name
	p.RequiresLineOfSight, p.MaxActivationDistance = false, 9
	p.Parent = part
	p.Triggered:Connect(callback)
	return p
end
function World.island(parent, origin, radius)
	local floor = World.part(parent, "Clareira", origin - Vector3.yAxis*2, Vector3.new(4,radius*2,radius*2), moss, Enum.PartType.Cylinder, Enum.Material.Grass)
	floor.Orientation = Vector3.new(0,0,90)
	for i=1,18 do
		local a = i * math.pi / 9
		local pos = origin + Vector3.new(math.cos(a),0,math.sin(a))*(radius-2)
		local trunk = World.part(parent, "Tronco", pos+Vector3.yAxis*2,Vector3.new(2,5,2),stone)
		trunk.CanCollide = false
		local foliage = World.part(parent,"Copa", pos+Vector3.yAxis*(5+i%3),Vector3.new(7,7+i%4,7),Color3.fromRGB(41,104+i%3*10,84),Enum.PartType.Ball)
		foliage.CanCollide = false
	end
end
function World.portal(parent, pos, name)
	for i=0,12 do
		local a = i*math.pi/12
		local arch = World.part(parent,"Arco",pos+Vector3.new(5*math.cos(a),5*math.sin(a)+2,0),Vector3.new(1.5,1.5,2),stone)
		arch.Orientation = Vector3.new(0,0,math.deg(a))
	end
	local gate = World.part(parent,name,pos+Vector3.yAxis*3,Vector3.new(8,7,0.7),light,Enum.PartType.Ball,Enum.Material.Neon)
	gate.Transparency, gate.CanCollide = 0.35,false
	World.label(gate,name,5)
	return gate
end
function World.critter(parent, name, pos, size, color)
	local model = Instance.new("Model")
	model.Name = name
	local body = World.part(model,name,pos,Vector3.new(size,size*0.8,size),color,Enum.PartType.Ball)
	model.PrimaryPart = body
	for _,side in {-1,1} do
		World.part(model,"Olho",pos+Vector3.new(side*0.21,0.05,-0.44)*size,Vector3.one*(size*0.115),Color3.fromRGB(27,36,49),Enum.PartType.Ball)
		local sprout = World.part(model,"Folha",pos+Vector3.new(side*0.15,0.43,0)*size,Vector3.new(0.22,0.36,0.14)*size,color:Lerp(light,0.4),Enum.PartType.Ball)
		sprout.Orientation=Vector3.new(0,0,-side*30)
	end
	for _,p in model:GetChildren() do p.CanCollide = false end
	model.Parent = parent
	return model
end
return World
