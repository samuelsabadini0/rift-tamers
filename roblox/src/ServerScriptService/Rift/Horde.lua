local Models = require(game.ReplicatedStorage.Rift.CreatureModels)
local World = require(script.Parent.Scenery)
local Horde = {}
local V = Vector3.new
local flat = V(1,0,1)
local red = Color3.fromHex("FF734A")
local green = Color3.fromHex("96C870")
local cyan = Color3.fromHex("72DAEB")
local gold = Color3.fromHex("FFCB66")
local delays = {["Ent Guardião"]=4,["Golem de Vidro"]=4,["Mago das Dunas"]=6,
	["Xamã Cogumelo"]=6,["Lobo de Folhas"]=3,Escorpinho=3,["Abutre Prisma"]=5,["Vagalume-Faísca"]=2.5}
Horde.health={Brotinho=.25,["Vagalume-Faísca"]=.2,["Lesma de Musgo"]=.6,["Lobo de Folhas"]=.15,
	Areinha=.25,Cristalino=.2,Escorpinho=.3,["Abutre Prisma"]=.2,["Ent Guardião"]=6,
	["Xamã Cogumelo"]=4,["Golem de Vidro"]=8,["Mago das Dunas"]=5}
local speed={Brotinho=8,["Vagalume-Faísca"]=10,["Lesma de Musgo"]=5,["Lobo de Folhas"]=18,
	Areinha=10,Cristalino=6,Escorpinho=9,["Abutre Prisma"]=14,["Ent Guardião"]=6,["Golem de Vidro"]=5}

local function dir(a,b)
	local delta=(b-a)*flat
	return delta.Magnitude>.01 and delta.Unit or -Vector3.zAxis
end

local function walk(model,goal,speedPerSecond,dt,stopDistance)
	local pos=model:GetPivot().Position
	local delta=(goal-pos)*flat
	if delta.Magnitude<=stopDistance then return end
	local nextPos=pos+delta.Unit*math.min(speedPerSecond*dt,delta.Magnitude-stopDistance)
	model:PivotTo(CFrame.lookAt(nextPos,nextPos+delta.Unit))
end

local function part(parent,name,pos,size,tint,shape)
	local p=World.part(parent,name,pos,size,tint,shape,Enum.Material.Neon)
	p.CanQuery,p.CanTouch,p.CanCollide,p.CastShadow=false,false,false,false
	return p
end

local function circle(parent,name,pos,radius,tint)
	local p=part(parent,name,pos,V(.14,radius*2,radius*2),tint,Enum.PartType.Cylinder)
	p.Orientation,p.Transparency=V(0,0,90),.48
	return p
end

local function markerLine(parent,from,to,width)
	local length=math.max((to-from).Magnitude,.1)
	local mid=(to+from)/2
	local p=part(parent,"Bote",mid,V(width,.16,length),red)
	p.CFrame=CFrame.lookAt(mid,mid+dir(from,to))
	p.Transparency=.48
	return p
end

local function diskHit(pos,target,radius)
	return ((target-pos)*flat).Magnitude<=radius
end

local function combatant(e,character)
	if not e.members then return true end
	for s in e.members do if s.player.Character==character then return true end end
	return false
end

function Horde.clear(mob,killed)
	if not mob.fx then return end
	local fx=mob.fx
	if killed and fx.burst and fx.burst.run.Parent then
		local burst=fx.burst
		local stamp=circle(burst.run,"Cristal rachado",burst.position,6,red)
		task.delay(1,function()
			if not stamp.Parent then return end
			if burst.target.Parent and combatant(burst.expedition,burst.target.Parent)
				and diskHit(burst.position,burst.target.Position,6) then burst.hit(1.5*burst.expedition.reference) end
			stamp:Destroy()
		end)
	end
	fx.folder:Destroy()
	mob.fx=nil
end

function Horde.damageScale(e,model,attackerRoot)
	if e.stage>=3 and model.Name=="Ent Guardião" and attackerRoot then
		local cf=model:GetPivot()
		if cf.LookVector:Dot(dir(cf.Position,attackerRoot.Position))>.55 then return .1 end
	end
	return 1
end

local function spawnBuds(e,pos)
	local count=0
	for _ in e.enemies do count+=1 end
	for i=1,math.min(3,40-count) do
		local angle=math.pi*2*i/3
		local at=V(pos.X,e.arena.Y+1.5,pos.Z)+V(math.cos(angle)*3,0,math.sin(angle)*3)
		local m=Models.create(e.run,"Brotinho",at,2.6)
		e.enemies[m]={hp=Horde.health.Brotinho*e.reference*e.scale,spawn=at,contact=0,summoned=true}
	end
end

local function slow(character,t)
	local humanoid=character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid:GetAttribute("MusgoAte") then return end
	local old=humanoid.WalkSpeed
	humanoid:SetAttribute("MusgoAte",t+1.2)
	humanoid.WalkSpeed=old*.7
	task.delay(1.2,function()
		if not humanoid.Parent then return end
		if math.abs(humanoid.WalkSpeed-old*.7)<.01 then humanoid.WalkSpeed=old end
		humanoid:SetAttribute("MusgoAte",nil)
	end)
end

local function hazards(e,model,mob,r,dt,t,onHit)
	local fx=mob.fx
	local shot=fx.shot
	if shot then
		local from=shot.p.Position
		local length=math.min(dt*18,shot.remaining)
		local to=from+shot.heading*length
		local offset=(r.Position-from)*flat
		local segment=math.clamp(offset:Dot(shot.heading),0,length)
		if (offset-shot.heading*segment).Magnitude<=2.1 then
			onHit(e.reference*.4)
			shot.p:Destroy()
			fx.shot=nil
		elseif length>=shot.remaining then
			shot.p:Destroy()
			fx.shot=nil
		else
			shot.p.Position=to
			shot.remaining-=length
		end
	end
	if model.Name=="Lesma de Musgo" then
		local pos=model:GetPivot().Position
		if t>=(fx.nextTrail or 0) then
			local trail=circle(fx.folder,"Trilha de musgo",V(pos.X,e.arena.Y+.18,pos.Z),2.8,green)
			table.insert(fx.trails,{p=trail,untilTime=t+3})
			fx.nextTrail=t+.85
		end
		for i=#fx.trails,1,-1 do
			local trail=fx.trails[i]
			if trail.untilTime<=t then trail.p:Destroy() table.remove(fx.trails,i)
			elseif diskHit(trail.p.Position,r.Position,2.8) then slow(r.Parent,t) end
		end
	end
end

local function prepare(e,model,mob,r,t)
	local fx=mob.fx
	local name=model.Name
	local from=model:GetPivot().Position
	local direction=dir(from,r.Position)
	local floor=e.arena.Y+.2
	local origin=V(from.X,floor,from.Z)
	local attack={dir=direction,origin=origin,impact=t+.6,zones={}}
	local function area(pos,radius)
		local stamp=circle(fx.folder,name,pos,radius,red)
		table.insert(attack.zones,{p=stamp,center=pos,radius=radius})
	end
	local function line(length,width)
		local stamp=markerLine(fx.folder,origin,origin+direction*length,width)
		table.insert(attack.zones,{p=stamp})
	end
	if name=="Vagalume-Faísca" or name=="Xamã Cogumelo" then
		local glow=part(fx.folder,"Carregando",from+Vector3.yAxis*2,V(1.2,1.2,1.2),gold,Enum.PartType.Ball)
		attack.glow=glow
	elseif name=="Mago das Dunas" then
		local angle=(fx.turn or 0)*1.65
		fx.turn=(fx.turn or 0)+1
		local new=e.arena+V(math.cos(angle)*16,3,math.sin(angle)*16)
		model:PivotTo(CFrame.lookAt(new,new+dir(new,r.Position)))
		local center=V(r.Position.X,floor,r.Position.Z)
		for i=1,7 do
			local a=angle+i*math.pi/4
			area(center+V(math.cos(a)*5,0,math.sin(a)*5),2.25)
		end
		attack.impact,attack.damage=t+1.15,2
	elseif name=="Ent Guardião" then
		area(origin,8)
		attack.impact,attack.damage=t+1.2,1.5
	elseif name=="Golem de Vidro" then
		line(12,11)
		attack.impact,attack.damage=t+1,1.5
	elseif name=="Lobo de Folhas" or name=="Abutre Prisma" then
		local fly=name=="Abutre Prisma"
		local length=math.clamp(((r.Position-from)*flat).Magnitude+1,4,fly and 22 or 10)
		line(length,fly and 5 or 3.5)
		attack.destination=from+direction*length
		attack.impact,attack.damage=t+(fly and 1 or .5),fly and 1.5 or .5
	else
		line(8,4.5)
		attack.damage=1
	end
	fx.attack=attack
end

local function release(e,model,mob,r,t,onHit)
	local fx=mob.fx
	local attack=fx.attack
	fx.attack=nil
	if attack.glow then attack.glow:Destroy() end
	if model.Name=="Vagalume-Faísca" then
		if fx.shot then fx.shot.p:Destroy() end
		local orb=part(fx.folder,"Faísca",model:GetPivot().Position+Vector3.yAxis*.5,V(.92,.92,.92),cyan,Enum.PartType.Ball)
		fx.shot={p=orb,heading=attack.dir,remaining=38}
	elseif model.Name=="Xamã Cogumelo" then
		spawnBuds(e,model:GetPivot().Position)
	end
	local hit=false
	for _,z in attack.zones do
		if z.radius then
			hit=hit or diskHit(z.center,r.Position,z.radius)
		else
			local p=z.p.CFrame:PointToObjectSpace(r.Position)
			hit=hit or math.abs(p.X)<=z.p.Size.X/2 and math.abs(p.Z)<=z.p.Size.Z/2
		end
		z.p:Destroy()
	end
	if attack.destination then model:PivotTo(CFrame.lookAt(attack.destination,attack.destination+attack.dir)) end
	if hit then
		onHit(e.reference*attack.damage)
		if model.Name=="Golem de Vidro" then r.CFrame+=attack.dir*10 end
	end
	mob.contact=t+(delays[model.Name] or 1)
end

function Horde.step(e,model,mob,r,dt,t,onHit)
	local pos=model:GetPivot().Position
	local delta=(r.Position-pos)*flat
	if not mob.fx then
		local folder=Instance.new("Folder")
		folder.Name,folder.Parent="Sinais • "..model.Name,e.run
		mob.fx={folder=folder,trails={}}
		if model.Name=="Areinha" then
			mob.fx.arrive=t+.8
			mob.fx.emergence=circle(folder,"Areia movediça",V(pos.X,e.arena.Y+.2,pos.Z),2,gold)
			model:PivotTo(model:GetPivot()-Vector3.yAxis*2.6)
		end
	end
	local fx=mob.fx
	if model.Name=="Cristalino" then
		fx.burst={expedition=e,run=e.run,target=r,hit=onHit,position=V(pos.X,e.arena.Y+.2,pos.Z)}
	end
	hazards(e,model,mob,r,dt,t,onHit)
	if fx.arrive then
		if t<fx.arrive then return end
		fx.emergence:Destroy()
		fx.arrive=nil
		model:PivotTo(model:GetPivot()+Vector3.yAxis*2.6)
	end
	if fx.attack then
		if t>=fx.attack.impact then release(e,model,mob,r,t,onHit) end
		return
	end
	if (mob.rootUntil or 0)>t or delta.Magnitude>85 then return end
	local name=model.Name
	local reach=4.5
	local stop=2
	local goal=r.Position
	if name=="Vagalume-Faísca" then reach,stop=26,15
	elseif name=="Xamã Cogumelo" or name=="Mago das Dunas" then reach=80
	elseif name=="Lobo de Folhas" then
		reach=9
		local tangent=dir(pos,r.Position):Cross(Vector3.yAxis)
		if delta.Magnitude>10 then goal+=tangent*(mob.spawn.X%2<1 and 6 or -6) end
	elseif name=="Abutre Prisma" then reach,stop=23,14
	elseif mob.elite or name=="Escorpinho" then reach=8 end
	if t>=mob.contact and delta.Magnitude<=reach then
		if delays[name] then
			prepare(e,model,mob,r,t)
			return
		elseif name~="Cristalino" then
			local fraction=(name=="Areinha" or name=="Lesma de Musgo") and .3 or .2
			onHit(e.reference*fraction)
			mob.contact=t+1
		end
	end
	if speed[name] then walk(model,goal,speed[name],dt,stop) end
end

return Horde
