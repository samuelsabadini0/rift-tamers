local shared = game:GetService("ReplicatedStorage"):WaitForChild("Rift")
local Campaign = require(shared.Campaign)
local Models = require(shared.CreatureModels)
local World = require(script.Parent.Scenery)
local Encounters = {creature = Models.create}
local red = Color3.fromHex("FF6C46")
local gold = Color3.fromHex("FFD269")
local cyan = Color3.fromHex("6AE8E1")
local soil = Color3.fromHex("896A54")
local V = Vector3.new

function Encounters.enemy(parent,stage,index,pos)
	local enemies = Campaign.stages[stage].enemies
	local name = enemies[(index-1)%#enemies+1]
	return Models.create(parent,name,pos,3)
end

local function flat(v)
	return V(v.X,0,v.Z)
end

local function towards(from,to)
	local delta = flat(to-from)
	return delta.Magnitude > .01 and delta.Unit or -Vector3.zAxis
end

local function face(model,pos,dir)
	model:PivotTo(CFrame.lookAt(pos,pos+dir))
end

local function announce(s,text)
	if s.members then
		for member in s.members do member.player:SetAttribute("BossMove",text) end
	elseif s.player then
		s.player:SetAttribute("BossMove",text)
	end
end

local function marker(parent,name,position,size,color,shape)
	local part = World.part(parent,name,position,size,color,shape,Enum.Material.Neon)
	part.CanCollide,part.CanTouch,part.CanQuery=false,false,false
	part.CastShadow=false
	return part
end

local function disc(parent,name,center,radius,color)
	local part = marker(parent,name,center,V(.15,radius*2,radius*2),color,Enum.PartType.Cylinder)
	part.Orientation=V(0,0,90)
	part.Transparency=.52
	return part
end

local function zone(e,center,radius,name)
	local part=disc(e.group,name,V(center.X,e.floor+.24,center.Z),radius,red)
	table.insert(e.zones,{part=part,center=center,radius=radius})
	return part
end

local function lane(e,start,direction,length,width,name)
	local center=start+direction*(length/2)
	center=V(center.X,e.floor+.23,center.Z)
	local frame=CFrame.lookAt(center,center+direction)
	local part=marker(e.group,name,center,V(width,.16,length),red)
	part.CFrame,part.Transparency=frame,.43
	table.insert(e.zones,{part=part,frame=frame,width=width,length=length})
end

local function hit(zoneInfo,pos)
	if zoneInfo.radius then return flat(pos-zoneInfo.center).Magnitude<=zoneInfo.radius end
	local localPos=zoneInfo.frame:PointToObjectSpace(pos)
	return math.abs(localPos.X)<=zoneInfo.width/2 and math.abs(localPos.Z)<=zoneInfo.length/2
end

local function bound(s,point,radius)
	local delta=flat(point-s.arena)
	if delta.Magnitude>radius then delta=delta.Unit*radius end
	return s.arena+delta
end

local tracks = {
	{"Rolada","Pancada"}, {"Salto","Língua"}, {"Minas","Esporos"}, {"Investida","Coice"},
	{"Mergulho","Penas"}, {"Raízes","Investida","Minas","Salto"}, {"Casco","Rolada"},
	{"Brasa","Faíscas"}, {"Tambor","Anel"}, {"Prisma","Ferrão","Pinças"},
	{"Tempestade","Meteoro"}, {"Raio Solar","Tambor","Faíscas","Tempestade"},
}
local function selectMove(s,e)
	local track=tracks[s.stage]
	local index=e.turn
	if s.secret and s.stage==5 then return index%2==1 and "Lanternas Giratórias" or "Raio Solar" end
	if s.secret and s.stage==12 then return index%2==1 and "Oásis Falso" or "Faíscas" end
	if s.stage==6 then
		if s.hp>s.maxHP*.66 then return index%2==1 and "Raízes" or "Investida" end
		if s.hp>s.maxHP*.33 then return index%2==1 and "Minas" or "Salto" end
		return index%2==1 and "Mergulho" or "Raízes"
	end
	if s.stage==12 and (e.shieldPhase or 0)<(s.hp<s.maxHP*.33 and 3 or s.hp<s.maxHP*.66 and 2 or 1) then
		return "Selos"
	end
	if (s.stage==1 or s.stage==2 or s.stage==4) and s.hp<s.maxHP*.5 then
		return index%3==0 and track[2] or track[1]
	end
	return track[(index-1)%#track+1]
end

local function opacity(model,value)
	for _,p in model:GetChildren() do
		if p:IsA("BasePart") and p.Name~="Olho" and p.Name~="Íris" and p.Name~="Pupila" then p.Transparency=value end
	end
end

local function effectsOff(s,e)
	if e.highlight then e.highlight:Destroy() e.highlight=nil end
	if s.boss and s.boss.Parent then opacity(s.boss,0) end
end

function Encounters.clear(s)
	local e=s.encounter
	if not e then return end
	effectsOff(s,e)
	e.group:Destroy()
	s.encounter=nil
	announce(s,"")
end

local function shelter(e,s)
	e.pillars={}
	for i=1,4 do
		local angle=math.pi/4+i*math.pi/2
		local pos=s.arena+V(math.cos(angle)*18,3.5,math.sin(angle)*18)
		local p=World.part(e.group,"Abrigo",pos,V(4,7,4),soil,nil,Enum.Material.Sandstone)
		p.CanTouch=false
		local gem=marker(e.group,"Cristal",pos+Vector3.yAxis*4.7,V(2.8,2.8,2.8),cyan)
		gem.Orientation=V(45,45,0)
		table.insert(e.pillars,pos)
	end
end

local function newEncounter(s,t,harm)
	Encounters.clear(s)
	local folder=Instance.new("Folder")
	folder.Name,folder.Parent="Sinais do guardião",s.run
	local e={boss=s.boss,group=folder,floor=s.arena.Y,turn=0,due=t+1.35,zones={},embers={},harm=harm,altitude=s.boss:GetPivot().Y-s.arena.Y}
	s.encounter=e
	if s.stage==11 or (s.stage==12 and not s.secret) then shelter(e,s) end
	return e
end

local glyphs={"Sol","Lua","Estrela","Cometa","Aurora"}
local function startPuzzle(s,e,t)
	e.shieldPhase=(e.shieldPhase or 0)+1
	local length=e.shieldPhase+2
	local pads={}
	for i=1,length do
		local angle=2*math.pi*(i-1)/length
		local pos=s.arena+V(math.sin(angle)*12,.27,-math.cos(angle)*12)
		local pad=disc(e.group,glyphs[i],pos,3.1,gold)
		pad.Transparency=.6
		local label=World.label(pad,glyphs[i],2)
		label.TextColor3=gold
		table.insert(pads,pad)
	end
	local order={}
	for i=1,length do order[i]=((i-1)*(length-1)+e.shieldPhase)%length+1 end
	e.puzzle={pads=pads,order=order,step=1,started=t,index=0}
	announce(s,"Observe a sequência dos selos.")
end

local function solvePuzzle(s,e,r,t,harm)
	local p=e.puzzle
	local beat=math.floor((t-p.started)/.85)+1
	if beat<=#p.order then
		if p.index~=beat then
			p.index=beat
			for i,pad in p.pads do
				pad.Color=i==p.order[beat] and cyan or gold
				pad.Transparency=i==p.order[beat] and .05 or .68
			end
			announce(s,"Selo "..beat.." • "..glyphs[p.order[beat]])
		end
		return
	end
	if not p.revealed then
		p.revealed=true
		for _,pad in p.pads do pad.Color=gold pad.Transparency=.55 end
		announce(s,"Pise nos selos na ordem mostrada.")
	end
	local touched
	for i,pad in p.pads do
		if flat(r.Position-pad.Position).Magnitude<=3.2 then touched=i break end
	end
	if touched and touched~=p.last then
		if touched==p.order[p.step] then
			p.pads[touched].Color=cyan
			p.step+=1
			if p.step>#p.order then
				for _,pad in p.pads do pad:Destroy() end
				e.puzzle=nil
				e.due=t+2
				announce(s,"Escudo quebrado!")
				return
			end
		else
			harm(s,15)
			p.step,p.index,p.revealed,p.started=1,0,false,t
		end
	end
	p.last=touched
end

local function beginMove(s,e,r,t)
	e.turn+=1
	local name=selectMove(s,e)
	e.move=name
	local start=s.boss:GetPivot().Position
	local dir=towards(start,r.Position)
	local aim=bound(s,r.Position,26)
	e.destination=nil
	e.damage=20
	e.impact=t+1.05
	if name=="Selos" then
		startPuzzle(s,e,t)
		e.impact=nil
		return
	end
	face(s.boss,start,dir)
	announce(s,name)
	if name=="Lanternas Giratórias" then
		e.orbit={started=t,lights={},lastHit=t}
		for i=1,4 do
			local orb=marker(e.group,"Lanterna",start,V(2,2,2),gold,Enum.PartType.Ball)
			local stamp=disc(e.group,"Círculo de luz",start,4.2,red)
			table.insert(e.orbit.lights,{orb=orb,stamp=stamp})
		end
		e.impact=t+4.4
		announce(s,"Lanternas giratórias • atravesse entre as luzes!")
	elseif name=="Oásis Falso" then
		local offset=V(11,0,7)*(e.turn%4==1 and 1 or -1)
		e.oases={}
		for i,side in {-1,1} do
			local pos=s.arena+offset*side+Vector3.yAxis*.25
			local pool=disc(e.group,"Oásis",pos,6,cyan)
			local trunk=World.part(e.group,"Palmeira",pos+V(4,2,0),V(1,4,1),soil,nil,Enum.Material.Wood)
			trunk.CanCollide=false
			local crown=marker(e.group,"Palha",trunk.Position+Vector3.yAxis*2.2,V(4.7,1.2,3.7),Color3.fromHex("77BD85"),Enum.PartType.Ball)
			table.insert(e.oases,{pool=pool,trunk=trunk,crown=crown})
			if i==1 then
				local ripple=disc(e.group,"Ondulação",pos+Vector3.yAxis*.1,2,Color3.fromHex("DEFFF3"))
				e.oases[i].ripple=ripple
				e.shelterSpot=pos
			end
		end
		e.impact=t+3
		announce(s,"Oásis falso • procure a água que ondula!")
	elseif name=="Casco" then
		local highlight=Instance.new("Highlight")
		highlight.FillColor,highlight.OutlineColor=gold,Color3.new(1,1,1)
		highlight.FillTransparency,highlight.Parent=.2,s.boss
		e.highlight=highlight
		e.impact=t+(s.hp<s.maxHP*.5 and 2.5 or 2)
		announce(s,"Casco espelhado • afaste-se!")
	elseif name=="Prisma" then
		e.decoys={}
		local count=s.hp<s.maxHP*.5 and 4 or 2
		for i=1,count do
			local a=i*math.pi*2/(count+1)+e.turn
			local pos=s.arena+V(math.cos(a)*13,e.altitude,math.sin(a)*13)
			local decoy=s.boss:Clone()
			decoy.Name="Reflexo"
			for _,p in decoy:GetChildren() do if p:IsA("BasePart") then p.CastShadow=false p.Transparency=.26 end end
			face(decoy,pos,towards(pos,r.Position))
			decoy.Parent=e.group
			table.insert(e.decoys,decoy)
			zone(e,pos,5,"Refração")
		end
		e.damage,e.impact=12,t+3
		announce(s,"Prisma • siga a sombra do verdadeiro!")
	elseif name=="Tempestade" then
		local finish=s.arena+dir*34
		lane(e,finish-dir*68,dir,68,64,name)
		e.wind=dir
		e.impact=t+1.6
		e.damage=23
		announce(s,"Tempestade • abrigue-se atrás de um cristal!")
	elseif name=="Tambor" or name=="Anel" then
		local radius=name=="Tambor" and 14 or 20
		local gap=math.floor(e.turn%12)
		for i=0,11 do
			if i~=gap and i~=(gap+1)%12 then
				local a=i*math.pi/6
				zone(e,s.arena+V(math.cos(a)*radius,0,math.sin(a)*radius),radius*.29,name)
			end
		end
		e.impact=t+1.4
		announce(s,"Anel de espinhos • procure a abertura!")
	elseif name=="Salto" or name=="Meteoro" then
		zone(e,aim,name=="Salto" and 8 or 10,name)
		e.damage,e.impact=25,t+1.2
		if name=="Salto" then e.destination=aim end
	elseif name=="Minas" then
		local count=s.hp<s.maxHP*.5 and 6 or 4
		for i=1,count do
			local a=2*math.pi*i/(count-1)+e.turn*.7
			local p=i==1 and aim or bound(s,aim+V(math.cos(a)*10,0,math.sin(a)*10),27)
			zone(e,p,5.8,"Esporos")
			local cap=marker(e.group,"Mina",V(p.X,e.floor+1,p.Z),V(1.8,1,1.8),gold,Enum.PartType.Ball)
			e.zones[#e.zones].cap=cap
		end
		e.impact=t+3.4
		announce(s,"Minas • saia dos círculos dourados!")
	elseif name=="Raízes" or name=="Penas" or name=="Faíscas" or name=="Esporos" then
		local count=name=="Faíscas" and 3 or 5
		for i=1,count do
			local a=math.rad((i-(count+1)/2)*15)
			local radial=CFrame.fromAxisAngle(Vector3.yAxis,a):VectorToWorldSpace(dir)
			lane(e,start,radial,name=="Esporos" and 17 or 34,2.8,name)
		end
		e.damage=15
	elseif name=="Pancada" or name=="Pinças" or name=="Coice" or name=="Língua" then
		if name=="Coice" then
			face(s.boss,start,-dir)
		end
		lane(e,start,dir,name=="Língua" and 20 or 12,name=="Língua" and 3.5 or 10,name)
		e.damage,e.impact=12,t+.85
	else
		local distance=name=="Ferrão" and 27 or math.clamp(flat(aim-start).Magnitude+6,12,34)
		lane(e,start,dir,distance,name=="Raio Solar" and 4 or 6,name)
		if name~="Ferrão" and name~="Raio Solar" then e.destination=bound(s,start+dir*distance,29) end
		if name=="Mergulho" then opacity(s.boss,.84) end
		e.traceStart=start
		if name=="Rolada" then e.impact=t+1.2 end
	end
end

local function impact(s,e,r,t,harm)
	local struck=false
	for _,z in e.zones do
		if hit(z,r.Position) then struck=true end
		z.part:Destroy()
		if z.cap then z.cap:Destroy() end
	end
	table.clear(e.zones)
	if e.move=="Tempestade" and struck then
		for _,pillar in e.pillars do
			local rel=flat(r.Position-pillar)
			local along=rel:Dot(e.wind)
			if along>=-1 and along<18 and (rel-e.wind*along).Magnitude<4.5 then struck=false break end
		end
	end
	if e.orbit then
		for _,light in e.orbit.lights do light.orb:Destroy() light.stamp:Destroy() end
		e.orbit=nil
	end
	if e.oases then
		struck=flat(r.Position-e.shelterSpot).Magnitude>6
		for _,oasis in e.oases do for _,p in oasis do p:Destroy() end end
		e.oases=nil
	end
	if struck then
		harm(s,e.damage)
		if e.move=="Língua" then r.CFrame+=towards(r.Position,s.boss:GetPivot().Position)*4 end
	end
	if e.destination then
		local start=s.boss:GetPivot().Position
		local finish=V(e.destination.X,e.floor+e.altitude,e.destination.Z)
		e.dash={from=start,to=finish,dir=towards(start,finish),started=t,jump=e.move=="Salto"}
		if e.move=="Brasa" then
			for i=1,5 do
				local pos=start:Lerp(finish,i/5)
				local fire=disc(e.group,"Rastro de brasa",V(pos.X,e.floor+.25,pos.Z),3.6,red)
				table.insert(e.embers,{part=fire,untilTime=t+6})
			end
		end
	end
	if e.decoys then for _,model in e.decoys do model:Destroy() end e.decoys=nil end
	effectsOff(s,e)
	e.due=t+(s.hp<s.maxHP*.5 and 1.9 or 2.65)
	e.impact=nil
	e.move=nil
end

function Encounters.step(s,r,t,dt,harm)
	if not s.boss or not s.boss.PrimaryPart then return end
	local e=s.encounter
	if not e or e.boss~=s.boss then e=newEncounter(s,t,harm) end
	e.harm=harm
	for i=#e.embers,1,-1 do
		local fire=e.embers[i]
		if t>=fire.untilTime then
			fire.part:Destroy()
			table.remove(e.embers,i)
		elseif flat(r.Position-fire.part.Position).Magnitude<3.7 and t>=(e.lastBurn or 0)+1 then
			e.lastBurn=t
			harm(s,5)
		end
	end
	if e.puzzle then solvePuzzle(s,e,r,t,harm) return end
	if e.dash then
		local dash=e.dash
		local alpha=math.clamp((t-dash.started)/.38,0,1)
		local lift=dash.jump and math.sin(math.pi*alpha)*6 or 0
		face(s.boss,dash.from:Lerp(dash.to,alpha)+Vector3.yAxis*lift,dash.dir)
		if alpha>=1 then e.dash=nil end
	elseif e.impact then
		if e.orbit then
			local elapsed=t-e.orbit.started
			for i,light in e.orbit.lights do
				local a=i*math.pi/2+elapsed*.9
				local pos=s.arena+V(math.cos(a)*12,.25,math.sin(a)*12)
				light.orb.Position=pos+Vector3.yAxis*3
				light.stamp.Position=pos
				if elapsed>.8 and t-e.orbit.lastHit>.65 and flat(r.Position-pos).Magnitude<=4.2 then
					harm(s,12)
					e.orbit.lastHit=t
				end
			end
		elseif e.oases then
			local diameter=3+2*math.sin(t*4)
			e.oases[1].ripple.Size=V(.15,diameter,diameter)
		end
		if t>=e.impact then impact(s,e,r,t,harm) end
	elseif t>=e.due then
		beginMove(s,e,r,t)
	else
		local start=s.boss:GetPivot().Position
		local delta=flat(r.Position-start)
		if delta.Magnitude>7 then
			local step=delta.Unit*math.min(delta.Magnitude-7,8*dt)
			local dest=bound(s,start+step,29)
			face(s.boss,V(dest.X,start.Y,dest.Z),delta.Unit)
		end
	end
end

function Encounters.damageScale(s,r,t)
	if not r then return 1 end
	local e=s.encounter
	if e and e.boss==s.boss then
		if e.puzzle then return 0 end
		if e.move=="Casco" and e.impact and t<e.impact then
			if t>=(e.lastReflect or 0)+.45 then e.lastReflect=t e.harm(s,5) end
			return 0
		end
	end
	if s.stage==4 and s.boss then
		local body=s.boss:GetPivot()
		local dot=body.LookVector:Dot(towards(body.Position,r.Position))
		if dot>.55 then return .1 elseif dot<-.45 then return 1.25 end
	end
	return 1
end
return Encounters
