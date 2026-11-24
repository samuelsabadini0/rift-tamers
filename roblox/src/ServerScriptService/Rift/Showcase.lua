local Dungeon = require(script.Parent.Dungeon)
local Plaza = require(script.Parent.Plaza)
local World = require(script.Parent.Scenery)
local Environment = require(script.Parent.Environment)
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Rift")
local Creatures = require(Shared.CreatureModels)
local Rules = require(Shared.Rules)

local Showcase = {}
local title = "Rift Tamers • Cenário"
local origin = Vector3.new(0,48,0)

-- Run from Studio Edit. The gameplay bootstrap removes this tagged preview on Play.
function Showcase.build(parent)
	local previous = parent:FindFirstChild(title)
	assert(not previous or previous:GetAttribute("RiftPreview"), "Nome do cenário ocupado por outro objeto")
	local scene = Instance.new("Folder")
	scene.Name=title
	scene:SetAttribute("RiftPreview",true)
	local ok,reason=pcall(function()
		Plaza.build(scene,origin-Plaza.home(8))
		World.island(scene,origin,37)
		Dungeon.hub(scene,origin)
		World.portal(scene,origin+Vector3.new(0,0,-23),"Portal das Fendas")
		for i,name in {"Fagulho","Marolo","Raminho"} do
			local pos=origin+Vector3.new((i-2)*9,0,-8)
			local pedestal=World.part(scene,name,pos+Vector3.yAxis*.45,Vector3.new(1,5.3,5.3),Color3.fromRGB(176,146,91),Enum.PartType.Cylinder,Enum.Material.Sandstone)
			pedestal.Orientation=Vector3.new(0,0,90)
			local partner=Creatures.create(scene,name,pos+Vector3.yAxis*2.55,3.7,Rules.starters[name].color)
			partner:PivotTo(partner:GetPivot()*CFrame.Angles(0,math.rad(167+(i-2)*6),0))
			World.label(partner.PrimaryPart,name,3.2)
		end
		local chest=World.part(scene,"Cofre",origin+Vector3.new(-13,1.5,7),Vector3.new(4,3,3),Color3.fromRGB(187,139,67),nil,Enum.Material.Metal)
		World.label(chest,"Cofre da Toca",3)
		local post=World.part(scene,"Treino",origin+Vector3.new(13,2,7),Vector3.new(3,4,3),Color3.fromRGB(143,98,65),nil,Enum.Material.WoodPlanks)
		World.label(post,"Poste de treino",4)
		for i=1,4 do
			World.part(scene,"Vaga "..i,origin+Vector3.new((i-2.5)*5.8,.4,14),Vector3.new(5,.8,5),Color3.fromRGB(132,151,96),nil,Enum.Material.Cobblestone)
		end
		Dungeon.build(scene,origin+Vector3.new(41,-23,-235),1)
	end)
	if not ok then scene:Destroy() error(reason) end
	if previous then previous:Destroy() end
	scene.Parent=parent
	if parent==workspace then
		Environment.light()
		local camera=workspace.CurrentCamera
		if camera then
			local look=origin+Vector3.new(0,4,-12)
			camera.CFrame=CFrame.lookAt(origin+Vector3.new(5,10.5,20),look)
			camera.Focus=CFrame.new(look)
		end
	end
	return scene
end
return Showcase
