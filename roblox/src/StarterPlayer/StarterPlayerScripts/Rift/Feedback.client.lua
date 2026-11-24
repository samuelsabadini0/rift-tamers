local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Input = game:GetService("UserInputService")

local player = Players.LocalPlayer
local shared = game:GetService("ReplicatedStorage"):WaitForChild("Rift")
local remote = shared:WaitForChild("Feedback")
local world = Instance.new("Folder")
world.Name = "Rift • efeitos locais"
world.Parent = workspace

local gold = Color3.fromHex("FFD577")
local mint = Color3.fromHex("9EEED5")
local chalk = Color3.fromHex("FFF1D0")
local dark = Color3.fromHex("40516B")
local active = {}
local sealGroup
local lastSound = {}
local rng = Random.new()
local V = Vector3.new

local function lightMode()
	return Input.TouchEnabled or player:GetAttribute("ReducedEffects") == true
end

local function batch(name,life)
	-- Cap simultaneous casts during multi-kills. Reserved capture batches have their own lifetime.
	if #active >= 24 then
		local oldest=table.remove(active,1)
		oldest:Destroy()
	end
	local folder = Instance.new("Folder")
	folder.Name, folder.Parent = name,world
	table.insert(active,folder)
	folder.Destroying:Once(function()
		local i=table.find(active,folder)
		if i then table.remove(active,i) end
	end)
	Debris:AddItem(folder,life)
	return folder
end

local function piece(parent,name,frame,size,color,shape)
	local p=Instance.new("Part")
	p.Name,p.Anchored,p.CanCollide=name,true,false
	p.CanTouch,p.CanQuery,p.CastShadow=false,false,false
	p.Shape=shape or Enum.PartType.Block
	p.Color,p.Material=color,Enum.Material.Neon
	p.Size,p.CFrame=size,frame
	p.Parent=parent
	return p
end

local function animate(item,seconds,goal,style)
	local tween=TweenService:Create(item,TweenInfo.new(seconds,style or Enum.EasingStyle.Quad,Enum.EasingDirection.Out),goal)
	tween:Play()
	return tween
end

local function audio(parent,filename,speed,volume,key)
	local now=os.clock()
	if key and now-(lastSound[key] or -10)<.14 then return end
	if key then lastSound[key]=now end
	local setting=player:GetAttribute("SfxVolume")
	if typeof(setting)=="number" then volume*=math.clamp(setting,0,1) end
	if volume<=0 then return end
	local sound=Instance.new("Sound")
	sound.SoundId="rbxasset://sounds/"..filename
	sound.Volume,sound.PlaybackSpeed=volume,speed
	sound.RollOffMinDistance,sound.RollOffMaxDistance=10,70
	sound.Parent=parent
	sound:Play()
end

local function gleam(group,pos,color,intensity)
	local star=piece(group,"Impacto",CFrame.new(pos),Vector3.one*.35,color,Enum.PartType.Ball)
	star.Transparency=.2
	animate(star,.18,{Size=Vector3.one*intensity,Transparency=1})
	return star
end

local function stroke(group,from,to,width,color)
	local delta=to-from
	if delta.Magnitude<.05 then return end
	local endPoint=from+delta.Unit*math.min(delta.Magnitude,160)
	local middle=(from+endPoint)/2
	local frame=CFrame.lookAt(middle,endPoint)
	local streak=piece(group,"Rastro",frame,V(width,width,(endPoint-from).Magnitude),color)
	streak.Transparency=.22
	animate(streak,.17,{Size=V(.04,.04,streak.Size.Z*.84),Transparency=1})
end

local function splinters(group,pos,color,count,reach)
	for i=1,count do
		local a=i*math.pi*2/count+rng:NextNumber(-.3,.3)
		local direction=V(math.cos(a),rng:NextNumber(.28,1),math.sin(a)).Unit
		local length=rng:NextNumber(.65,1.3)
		local chip=piece(group,"Faísca",CFrame.lookAt(pos,pos+direction),V(.1,.1,length),color)
		animate(chip,.31,{CFrame=chip.CFrame+direction*reach,Transparency=1,Size=V(.055,.055,length*.48)})
	end
end

local function ring(group,pos,color,startDiameter,diameter)
	local frame=CFrame.new(pos)*CFrame.Angles(0,0,math.pi/2)
	local disc=piece(group,"Onda",frame,V(.09,startDiameter,startDiameter),color,Enum.PartType.Cylinder)
	disc.Transparency=.74
	animate(disc,.34,{Size=V(.065,diameter,diameter),Transparency=1})
	return disc
end

local function hit(from,to,color)
	local group=batch("Golpe",1.1)
	stroke(group,from,to,.17,color)
	local impact=gleam(group,to,color,1.8)
	splinters(group,to,chalk,lightMode() and 2 or 4,1.7)
	audio(impact,"action_jump_land.mp3",rng:NextNumber(1.4,1.75),.24,"hit")
end

local function skill(from,to,color)
	local group=batch("Habilidade",1.4)
	stroke(group,from,to,.43,color)
	ring(group,to-Vector3.yAxis*1.3,color,2,13)
	local burst=gleam(group,to,color,3)
	splinters(group,to,chalk,lightMode() and 3 or 8,3.9)
	audio(burst,"impact_water.mp3",1.25,.4,"skill")
end

local function kill(from,to,color)
	local group=batch("Fragmentos",1.4)
	local flash=gleam(group,to,color,2.5)
	audio(flash,"volume_slider.ogg",1.35,.15,"loot")
	local count=lightMode() and 1 or 3
	for i=1,count do
		local angle=i*math.pi*2/count
		local offset=V(math.cos(angle),.9,math.sin(angle))
		local start=to+offset*.5
		local shard=piece(group,"Fragmento",CFrame.new(start)*CFrame.Angles(.4,angle,.7),V(.34,.57,.34),mint)
		local apex=shard.CFrame+offset*2.6
		local lift=animate(shard,.19,{CFrame=apex})
		lift.Completed:Once(function()
			if not shard.Parent then return end
			local char=player.Character
			local root=char and char:FindFirstChild("HumanoidRootPart")
			local destination=root and root.Position or from
			animate(shard,.35,{Position=destination,Size=Vector3.one*.07,Transparency=1},Enum.EasingStyle.Sine)
		end)
	end
end

local function stopSeal()
	if sealGroup then
		sealGroup:Destroy()
		sealGroup=nil
	end
end

local function seal(from,to,color)
	stopSeal()
	local group=batch("Ressonância do selo",2.1)
	sealGroup=group
	local light=gleam(group,from,color,1.15)
	audio(light,"action_jump.mp3",1.7,.25)
	for i=1,3 do
		task.delay(.36+(i-1)*.48,function()
			if group.Parent then
				local pulse=ring(group,to,color,.4,1.8+i*.4)
				audio(pulse,"action_jump_land.mp3",1.05+i*.16,.16+i*.045)
			end
		end)
	end
end

local function reveal(pos,color,caught)
	stopSeal()
	local group=batch(caught and "Capturado" or "Fuga",2.5)
	local lamp=gleam(group,pos,caught and gold or dark,caught and 3.2 or 1.8)
	if caught then
		local beam=piece(group,"Luz de captura",CFrame.new(pos+Vector3.yAxis*2),V(.68,4,.68),color)
		beam.Transparency=.5
		animate(beam,.58,{Position=pos+Vector3.yAxis*5,Size=V(.12,10,.12),Transparency=1})
		splinters(group,pos,gold,lightMode() and 4 or 12,4.2)
		ring(group,pos-Vector3.yAxis*.5,color,1,8)
		for i,pitch in {1.18,1.49,1.79} do
			task.delay((i-1)*.13,function()
				if lamp.Parent then audio(lamp,"volume_slider.ogg",pitch,.22) end
			end)
		end
	else
		audio(lamp,"action_get_up.mp3",.85,.22)
		for i=1,(lightMode() and 2 or 5) do
			local offset=V(rng:NextNumber(-1,1),rng:NextNumber(.4,1),rng:NextNumber(-1,1))
			local smoke=piece(group,"Névoa",CFrame.new(pos+offset*.4),Vector3.one*.45,dark,Enum.PartType.Ball)
			smoke.Material,smoke.Transparency=Enum.Material.SmoothPlastic,.45
			animate(smoke,.6,{Position=pos+offset*2.2+Vector3.yAxis,Size=Vector3.one*1.5,Transparency=1})
		end
	end
end

local handlers={
	hit=hit, skill=skill, kill=kill, seal=seal,
	caught=function(_,to,color) reveal(to,color,true) end,
	escaped=function(_,to,color) reveal(to,color,false) end,
}
remote.OnClientEvent:Connect(function(kind,from,to,color)
	local handler=handlers[kind]
	if handler and typeof(from)=="Vector3" and typeof(to)=="Vector3" and typeof(color)=="Color3" then
		handler(from,to,color)
	end
end)
player.CharacterRemoving:Connect(stopSeal)
script.Destroying:Connect(function()
	stopSeal()
	world:Destroy()
end)
