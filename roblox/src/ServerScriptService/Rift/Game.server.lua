local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Rift")
local Http = game:GetService("HttpService")
local Rules = require(Shared.Rules)
local stages = require(Shared.Campaign).stages
local World = require(script.Parent.Scenery)
local Dungeon = require(script.Parent.Dungeon)
local Fenda = require(script.Parent.Fenda)
local Encounters = require(script.Parent.Encounters)
local Tuco=require(script.Parent.Tuco)
local Profiles = require(script.Parent.Profiles)
local Plaza=require(script.Parent.Plaza)
local Horde=require(script.Parent.Horde)
local Quests=require(script.Parent.Quests)
local Collection=require(script.Parent.Collection)
local Progress = require(script.Parent.Progression)

require(script.Parent.Environment).light()
local preview=workspace:FindFirstChild("Rift Tamers • Cenário")
if preview and preview:GetAttribute("RiftPreview") then preview:Destroy() end
local action = Instance.new("RemoteEvent")
action.Name, action.Parent = "Action", Shared
local sessions, expeditions = {}, {}
local feedback=Instance.new("RemoteEvent")
feedback.Name,feedback.Parent="Feedback",Shared
local instances = {}
local plots,plazas={},{}
local goldColor = Color3.fromRGB(240,184,74)
local function attr(s,k,v) s.player:SetAttribute(k,v) end
local function root(s)
	local c=s.player.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end
local function phase(s,name,tip)
	s.phase=name
	attr(s,"Phase",name)
	attr(s,"Tip",tip)
end
local function move(s,pos)
	-- A fenda fica longe da praça: pede o streaming do destino antes de mover o personagem.
	task.spawn(pcall,s.player.RequestStreamAroundAsync,s.player,pos)
	local r=root(s)
	if r then r.Parent:PivotTo(CFrame.new(pos+Vector3.yAxis*4)) end
end
local function quest(s,event)
	if Quests.advance(s.data,event,Progress.income(s.data)) then
		attr(s,"Quests",Http:JSONEncode(Quests.list(s.data,os.time())))
		attr(s,"Gold",s.data.gold)
		attr(s,"Gems",s.data.gems)
	end
end
local function reflect(s)
	local d=s.data
	for name,value in {Gold=d.gold,Gems=d.gems,Fragments=d.fragments,Bank=math.floor(d.bank),Income=Progress.income(d),
		Power=Progress.power(d),Level=d.level,XP=math.floor(d.xp or 0),XPNext=Rules.price(d.level),Stars=d.stars,Starter=d.starter,Ascension=d.ascension,
		Stage=d.stage,Difficulty=d.difficulty,Unlocked=d.unlocked,DailyReady=d.dailyDay<math.floor(os.time()/86400),
		CanAscend=d.ascension==0 and d.cleared["12"]~=nil and d.gold>=10000000,AscendCost=10000000,
		Auto=s.auto or false, SupremeCrystals=d.supreme, LargeCrystals=d.large, MasterCrystals=d.master,Crystal=s.crystal or "Comum", BossName=s.expedition and s.expedition.bossName or stages[d.stage].boss} do attr(s,name,value) end
	for name,value in {Collection=d.collection,Cleared=d.cleared,Equipped=d.equipped,Specimens=d.specimens,SpeciesStars=d.speciesStars,Quests=Quests.list(d,os.time())} do attr(s,name,Http:JSONEncode(value)) end
end
local function activeSpec(s)
	local index=s.data.equipped[s.active or 0]
	if index then return Rules.elements[stages[index].element] end
	return Rules.starters[s.data.starter]
end
local function syncSkill(s)
	local spec=activeSpec(s)
	if not spec then return end
	local key=s.active or 0
	s.skill=s.cooldowns[key] or 0
	attr(s,"ActiveSkillName",spec.skill)
	attr(s,"ActiveColor",spec.color)
	attr(s,"ActiveCooldown",spec.cooldown)
	attr(s,"SkillReady",workspace:GetServerTimeNow()+math.max(0,s.skill-os.clock()))
end
local function effect(s,kind,to)
	local r=root(s)
	if not r then return end
	local origin=s.pet and s.pet:GetPivot().Position or r.Position
	local color=activeSpec(s).color
	feedback:FireClient(s.player,kind,origin,to,color)
end
local function station(s,part,verb,fn)
	return World.prompt(part,verb,function(player)
		local r=root(s)
		if player==s.player and r and (r.Position-part.Position).Magnitude<=13 then fn() end
	end)
end
local function checkpoint(s,release)
	if not s.persistent then return end
	while s.saving do task.wait(.1) end
	s.saving=true
	local ok=Profiles.save(s.player.UserId,s.data,release)
	s.saving=false
	if s.player.Parent then attr(s,"SaveStatus",ok and "Salvo" or "Salvamento pendente") end
	return ok
end
local function leave(s)
	local e=s.expedition
	if e then
		e.members[s]=nil
		if not next(e.members) then
			Encounters.clear(e)
			e.run:Destroy()
			expeditions[e]=nil
			instances[e.slot]=nil
		end
	end
	if s.followers then
		for _,model in s.followers do model:Destroy() end
		s.followers=nil
	end
	s.active=0
	s.expedition=nil
	s.auto=false
	attr(s,"Auto",false)
	attr(s,"RouteMap",nil)
	attr(s,"RiftFolder",nil)
	attr(s,"AutoWalk",nil)
	attr(s,"Purification",nil)
	attr(s,"Destination",nil)
	attr(s,"BossMove",nil)
end
local function home(s,msg)
	leave(s)
	move(s,s.home)
	local r=root(s)
	local h=r and r.Parent:FindFirstChildOfClass("Humanoid")
	if h and h.Health>0 then h.MaxHealth=100 h.Health=100 end
	phase(s,"Praça",msg or "Escolha sua fenda no diário e atravesse o portal.")
	reflect(s)
end
local function members(e,key,value)
	for s in e.members do attr(s,key,value) end
end
local function transition(e,name,tip)
	e.phase=name
	for s in e.members do phase(s,name,tip) end
end
local function harm(s,amount)
	if os.clock()<s.invulnerable then return end
	local r=root(s)
	local h=r and r.Parent:FindFirstChildOfClass("Humanoid")
	if h and h.Health>0 then h.Health=math.max(s.data.wins==0 and 1 or 0,h.Health-amount) end
end
-- Loot que cai dos bichos: XP sobe o nível do time de graça (mesma curva do treino), o resto vai pro save.
local function loot(s,item,amount)
	local d=s.data
	if not d or not s.player.Parent then return end
	s.runLoot=s.runLoot or {}
	s.runLoot[item]=(s.runLoot[item] or 0)+amount
	if item=="xp" then
		d.xp=(d.xp or 0)+amount
		local before=d.level
		while d.level<100 and d.xp>=Rules.price(d.level) do
			d.xp-=Rules.price(d.level)
			d.level+=1
		end
		if d.level>before then
			local r=root(s)
			local h=r and r.Parent:FindFirstChildOfClass("Humanoid")
			if h then
				local max=Progress.power(d)*10
				h.Health=math.min(max,h.Health+(max-h.MaxHealth)+.25*max)
				h.MaxHealth=max
			end
			attr(s,"Level",d.level)
			attr(s,"Power",Progress.power(d))
			attr(s,"LevelUp",d.level)
			attr(s,"Tip","Subiu para o nível "..d.level.."! Seu time ficou mais forte.")
		end
		attr(s,"XP",math.floor(d.xp))
		attr(s,"XPNext",Rules.price(d.level))
		attr(s,"RunXP",math.floor(s.runLoot.xp))
	elseif item=="gold" then
		d.gold+=amount
		attr(s,"Gold",d.gold)
		attr(s,"RunGold",s.runLoot.gold)
	elseif item=="fragments" then
		d.fragments+=amount
		attr(s,"Fragments",d.fragments)
		attr(s,"RunFragments",s.runLoot.fragments)
	elseif item=="large" then
		d.large+=amount
		attr(s,"LargeCrystals",d.large)
		attr(s,"Tip","Você achou um Cristal Grande!")
	end
end
local function prepare(s,e)
	s.active=0
	s.cooldowns={}
	syncSkill(s)
	s.followers={}
	for _,index in s.data.equipped do
		local stage=stages[index]
		table.insert(s.followers,Encounters.creature(e.run,stage.boss,e.layout.entry+Vector3.yAxis*3,2.4,stage.color))
	end
	s.expedition=e
	e.members[s]=true
	s.runLoot={}
	for _,key in {"RunXP","RunGold","RunFragments"} do attr(s,key,0) end
	attr(s,"XP",math.floor(s.data.xp or 0))
	attr(s,"XPNext",Rules.price(s.data.level))
	local points={}
	for _,p in {e.layout.entry,e.layout.areas[1].center,e.layout.areas[2].center,e.layout.areas[3].center} do table.insert(points,{p.X,p.Z}) end
	attr(s,"RouteMap",Http:JSONEncode(points))
	attr(s,"Room",e.area)
	attr(s,"RiftFolder",e.run.Name)
	attr(s,"Purification",e.purification)
	attr(s,"Kills",e.kills)
	attr(s,"BossName",stages[e.stage].boss)
	move(s,e.entry)
	local r=root(s)
	local h=r and r.Parent:FindFirstChildOfClass("Humanoid")
	if h then h.MaxHealth=Progress.power(s.data)*10 h.Health=h.MaxHealth end
	phase(s,"Horda","Purifique a clareira: derrote as hordas e quebre os Cristais Corrompidos.")
end
local function rescale(e)
	local count=0
	for _ in e.members do count+=1 end
	e.scale=1+0.7*(math.max(1,count)-1)
	e.reference=stages[e.stage].power*3^(e.rank-1)
end
local function begin(s)
	if s.phase~="Praça" then return end
	if s.data.stage>=7 and Progress.power(s.data)<500 then attr(s,"Tip","As Dunas exigem Poder 500. Equipe e treine seu time.") return end
	phase(s,"Entrada","Abrindo a fenda…")
	local d=s.data
	local folder=Instance.new("Folder")
	folder.Name="Fenda_"..s.player.UserId
	folder.Parent=workspace
	local e={run=folder,stage=d.stage,rank=d.difficulty,area=1,purification=0,kills=0,members={},enemies={},queue={},phase="Horda",player=s.player}
	local slot=1
	while instances[slot] do slot+=1 end
	instances[slot]=true
	e.slot=slot
	-- Fendas ficam no chão, no mesmo servidor, a ~2400 studs da praça (sem teleporte).
	e.layout=Fenda.build(folder,Vector3.new((slot-1)*900,0,2400),d.stage)
	if sessions[s.player]~=s or not s.player.Parent then folder:Destroy() instances[slot]=nil return end
	e.members[s]=true
	rescale(e)
	Fenda.enter(e,1)
	expeditions[e]=true
	prepare(s,e)
	local relic=World.part(folder,"Relicário",e.layout.secret+Vector3.yAxis*2,Vector3.new(4,4,4),goldColor,Enum.PartType.Ball,Enum.Material.Neon)
	World.label(relic,"Relicário esquecido",4)
	local claimed={}
	World.prompt(relic,"Investigar",function(p)
		local visitor=sessions[p]
		local r=visitor and root(visitor)
		if not visitor or not e.members[visitor] or claimed[p] or not r or (r.Position-relic.Position).Magnitude>13 then return end
		claimed[p]=true
		e.relic=true
		visitor.data.fragments+=3*e.stage
		reflect(visitor)
		attr(visitor,"Tip","Relíquia encontrada! +"..3*e.stage.." fragmentos.")
	end)
end
local function join(s)
	if s.phase~="Praça" or (s.data.stage>=7 and Progress.power(s.data)<500) then return end
	for e in expeditions do
		local count=0
		for _ in e.members do count+=1 end
		if count<4 and e.phase=="Horda" and e.area==1 and e.purification<Fenda.THRESHOLDS[2] and e.stage==s.data.stage and e.rank==s.data.difficulty then
			prepare(s,e)
			rescale(e)
			return
		end
	end
	attr(s,"Tip","Nenhum grupo na entrada desta fenda. Abra o portal para formar um.")
end
local function spawnBoss(e)
	local stage=stages[e.stage]
	rescale(e)
	do
		e.arena=e.layout.boss
		local first=false
		for s in e.members do if s.data.wins==0 then first=true end end
		if not first then
			if (e.stage==5 or e.stage==12) and e.relic and math.random(10)==1 then e.secret=true e.variant="Secreto"
			elseif e.rank==3 and math.random(500)==1 then e.variant="Ancestral"
			elseif math.random(e.stage==math.floor(os.time()/86400)%12+1 and 25 or 50)==1 then e.variant="Alfa" end
		end
		local species=e.secret and (e.stage==5 and "Lúmen" or "Miragem") or stage.boss
		e.bossName=species..(e.variant and not e.secret and " "..e.variant or "")
		e.boss=Encounters.creature(e.run,species,e.arena+Vector3.yAxis*4,stage.king and 12 or 8,stage.color)
		if e.variant then
			e.boss:ScaleTo(e.boss:GetScale()*1.3)
			World.label(e.boss.PrimaryPart,e.bossName,7)
			local glow=Instance.new("Highlight",e.boss)
			glow.FillColor,glow.FillTransparency=goldColor,.7
		end
		members(e,"BossName",e.bossName)
		e.maxHP=e.reference*(stage.king and 60 or 40)*e.scale*(e.variant and 1.5 or 1)
		if e.stage==1 and e.rank==1 then
			for s in e.members do if s.data.wins==0 then e.maxHP=145*e.scale break end end
		end
		e.hp=e.maxHP
		members(e,"BossHP",math.ceil(e.hp))
		members(e,"MaxBossHP",math.ceil(e.hp))
		transition(e,"Boss","Fenda purificada! O guardião despertou: leia as marcas no chão.")
	end
end
local function showPurification(e)
	local value=math.floor(e.purification*10+.5)/10
	members(e,"Purification",value)
	members(e,"Room",e.area)
end
local function clearArea(e)
	for model,mob in e.enemies do
		Horde.clear(mob)
		Fenda.release(model,mob)
	end
	table.clear(e.enemies)
	table.clear(e.queue)
end
-- Atravessar o portal leva o grupo inteiro para a próxima área (todas no chão, no mesmo servidor).
local function advance(e,traveler)
	Fenda.vacuum(e,traveler,loot)
	clearArea(e)
	Fenda.enter(e,e.area+1)
	rescale(e)
	for s in e.members do
		move(s,e.entry)
		attr(s,"Destination",nil)
		local r=root(s)
		local h=r and r.Parent:FindFirstChildOfClass("Humanoid")
		if h then h.Health=math.min(h.MaxHealth,h.Health+0.3*h.MaxHealth) end
	end
	showPurification(e)
	transition(e,"Horda",e.area==3 and "Último trecho! Purifique o Coração do Bosque até 100%."
		or "Quebre os Cristais Corrompidos e cuidado com o Guardião Corrompido.")
end
local function gain(e,amount)
	if e.phase~="Horda" then return end
	Fenda.purify(e,amount)
	showPurification(e)
	if e.purification<Fenda.THRESHOLDS[e.area+1] then return end
	if e.area<#Fenda.AREAS then
		if not e.portal then
			e.portal=Fenda.openPortal(e)
			for s in e.members do
				attr(s,"Destination",e.portal.Position)
				attr(s,"Tip","Portal aberto! Entre nele para seguir à Área "..(e.area+1)..".")
			end
		end
	else
		clearArea(e)
		spawnBoss(e)
	end
end
local function crystal(s,choice)
	local d,e=s.data,s.expedition
	if choice=="Grande" and d.large<=0 or choice=="Mestre" and d.master<=0 or choice=="Supremo" and d.supreme<=0 then return end
	attr(s,"Guaranteed",d.wins==0 or choice=="Supremo")
	s.crystal=choice
	attr(s,"Crystal",choice)
	local base=({Alfa=.2,Ancestral=.1,Secreto=.05})[e.variant] or stages[e.stage].chance
	attr(s,"Chance",base*(1+.05*d.ascension+((d.luckUntil or 0)>os.time() and .25 or 0))*(choice=="Grande" and 1.5 or choice=="Mestre" and 2 or 1))
end
local function stunned(e)
	Encounters.clear(e)
	e.phase="Captura"
	for s in e.members do
		s.captureAt=workspace:GetServerTimeNow()
		local stage=stages[e.stage]
		attr(s,"LastCatch",nil)
		attr(s,"CaptureAt",s.captureAt)
		attr(s,"CapturePeriod",stage.king and 1 or 1.4)
		crystal(s,"Comum")
		attr(s,"Marks",s.data.marks[tostring(e.stage)] or 0)
		attr(s,"Guaranteed",s.data.wins==0)
		attr(s,"BossMove",nil)
		phase(s,"Captura","Lance o cristal quando o anel tocar o dourado.")
	end
end
local function strike(s,target,damage)
	local e=s.expedition
	if not e then return end
	effect(s,"hit",target:GetPivot().Position)
	if target==e.boss and e.phase=="Boss" then
		damage*=Encounters.damageScale(e,root(s),os.clock())
		e.hp=math.max(0,e.hp-damage)
		members(e,"BossHP",math.ceil(e.hp))
		if e.hp<=e.maxHP*.15 then stunned(e) end
	elseif e.enemies[target] then
		local mob=e.enemies[target]
		mob.hp-=damage*Horde.damageScale(e,target,root(s))
		if mob.hp<=0 then
			effect(s,"kill",target:GetPivot().Position)
			Horde.clear(mob,true)
			e.enemies[target]=nil
			Fenda.drop(e,target:GetPivot().Position,mob.kind or (mob.summoned and "summoned" or "common"))
			Fenda.release(target,mob)
			if not mob.summoned then e.kills+=1 end
			quest(s,"kills")
			if mob.elite or mob.kind=="mini" then quest(s,"elite") end
			members(e,"Kills",e.kills)
			gain(e,mob.value or (mob.summoned and Fenda.VALUE.summoned or Fenda.VALUE.common))
		end
	end
end
local function seal(s,automatic)
	local e=s.expedition
	if not e or s.phase~="Captura" then return end
	local d=s.data
	local stage=stages[e.stage]
	local elapsed=workspace:GetServerTimeNow()-s.captureAt
	local timing=automatic and (s.auto and .7 or 0) or (elapsed/s.player:GetAttribute("CapturePeriod"))%1
	local chance=Rules.chance(d.wins==0 or s.crystal=="Supremo",timing,s.player:GetAttribute("Chance"),d.marks[tostring(e.stage)])
	if s.crystal=="Grande" then d.large-=1 elseif s.crystal=="Mestre" then d.master-=1 elseif s.crystal=="Supremo" then d.supreme-=1 end
	effect(s,"seal",e.boss:GetPivot().Position)
	phase(s,"Cristal","Selando "..e.bossName.."…")
	task.spawn(function()
		local caught=true
		for i=1,3 do
			task.wait(.6)
			if s.expedition~=e or s.phase~="Cristal" then return end
			attr(s,"Tip","Cristal de selo • "..i.."/3")
			if math.random()>chance^(1/3) then caught=false break end
		end
		effect(s,caught and "caught" or "escaped",e.boss:GetPivot().Position)
		if caught then
			local record=Collection.specimen(d,e.stage,e.variant,e.bossName)
			Collection.add(d,e.stage,record)
			attr(s,"LastCatch",record.name.." • "..record.size.." • "..record.mutation)
			quest(s,"captures")
			if timing>=.76 and timing<=.84 then quest(s,"perfect") end
		end
		if math.random()<.1 then d.large+=1 end
		quest(s,"wins")
		local reward=Progress.capture(d,e.stage,e.rank,caught)
		if e.scale>1 then local extra=math.floor(.2*reward) reward+=extra d.gold+=extra end
		s.auto=false
		reflect(s)
		phase(s,"Baú",(caught and e.bossName.." capturado!" or "Escapou! +1 Marca de Caça.").." +"..reward.." ouro. Volte pelo portal.")
		if not e.exit then
			e.exit=World.portal(e.run,e.arena+Vector3.new(0,0,-10),"Voltar à Toca")
			World.prompt(e.exit,"Voltar",function(p)
				local v=sessions[p]
				local r=v and root(v)
				if v and v.expedition==e and v.phase=="Baú" and r and (r.Position-e.exit.Position).Magnitude<13 then
					home(v,"Visite a Toca e o treino. O diário mostra as fendas liberadas.")
				end
			end)
		end
		attr(s,"Destination",e.exit.Position)
		task.spawn(checkpoint,s,false)
	end)
end
local function skill(s)
	local e,r,t=s.expedition,root(s),os.clock()
	if not e or not r or (s.phase~="Boss" and s.phase~="Horda") or t<s.skill then return end
	local spec=activeSpec(s)
	s.skill=t+spec.cooldown
	s.cooldowns[s.active or 0]=s.skill
	quest(s,"skills")
	effect(s,"skill",r.Position)
	attr(s,"SkillReady",workspace:GetServerTimeNow()+spec.cooldown)
	local damage=Progress.power(s.data)*spec.factor
	local radius=spec.range
	if s.data.ascension>0 and #s.data.equipped==2 and stages[s.data.equipped[1]].element==stages[s.data.equipped[2]].element then damage*=1.5 radius*=1.25 end
	local targets=e.boss and {e.boss} or {}
	for mob in e.enemies do table.insert(targets,mob) end
	for _,mob in targets do
		if (mob:GetPivot().Position-r.Position).Magnitude<=radius+2 then
			strike(s,mob,damage)
			if e.enemies[mob] then
				if spec==Rules.elements.Natureza then e.enemies[mob].rootUntil=t+2
				elseif spec==Rules.elements["Água"] then mob:PivotTo(mob:GetPivot()+r.CFrame.LookVector*5) end
			end
		end
	end
	local flash=World.part(e.run,spec.skill,r.Position-Vector3.yAxis*2,Vector3.new(.3,radius*2,radius*2),spec.color,Enum.PartType.Cylinder,Enum.Material.Neon)
	flash.Orientation,flash.CanCollide,flash.Transparency=Vector3.new(0,0,90),false,.65
	game:GetService("Debris"):AddItem(flash,.24)
end
local function closest(e,position)
	local best,dist=nil,math.huge
	for s in e.members do
		local r=root(s)
		local h=r and r.Parent:FindFirstChildOfClass("Humanoid")
		if h and h.Health>0 then
			local d=(r.Position-position).Magnitude
			if d<dist then best,dist=s,d end
		end
	end
	return best,dist
end
-- O personagem é física do cliente: Humanoid:MoveTo no servidor não o move.
-- O servidor só publica o destino; o script Purificacao do cliente faz o MoveTo.
local function walk(s,pos)
	local old=s.player:GetAttribute("AutoWalk")
	if not old or (old-pos).Magnitude>1 then attr(s,"AutoWalk",pos) end
end
local function aim(s,pos)
	local old=s.player:GetAttribute("Destination")
	if not old or (old-pos).Magnitude>1 then attr(s,"Destination",pos) end
end
local function tickExpedition(e,t,dt)
	if e.phase=="Captura" then
		for s in e.members do
			if s.phase=="Captura" and workspace:GetServerTimeNow()-s.captureAt>8 then seal(s,true) end
		end
		return
	end
	for s in e.members do
		local r=root(s)
		if not r then continue end
		if r.Position.Y<e.arena.Y-18 then move(s,e.entry) end
	end
	local collectors={}
	for s in e.members do
		local r=root(s)
		if r then table.insert(collectors,{root=r,s=s}) end
	end
	Fenda.collect(e,t,collectors,loot)
	if e.phase=="Horda" then
		local roots={}
		for s in e.members do
			local r=root(s)
			if r then table.insert(roots,r) end
		end
		Fenda.horde(e,t,roots)
		if e.miniAt and t>=e.miniAt and roots[1] then
			e.miniAt=nil
			Fenda.mini(e,roots[1].Position)
			for s in e.members do attr(s,"Tip",Fenda.AREAS[e.area].mini.." apareceu! Fuja do aviso vermelho.") end
		end
		for model,mob in e.enemies do
			if not model.Parent then e.enemies[model]=nil continue end
			local s=closest(e,model:GetPivot().Position)
			if not s then continue end
			if mob.kind=="crystal" then Fenda.crystalStep(e,model,mob,t)
			elseif mob.kind=="mini" then Fenda.miniStep(e,model,mob,root(s),t,dt,function(amount) harm(s,amount) end)
			else Horde.step(e,model,mob,root(s),dt,t,function(amount) harm(s,amount*.5) end) end
		end
		Fenda.flush(e)
		if e.portal then
			for s in e.members do
				local r=root(s)
				if r and ((r.Position-e.portal.Position)*Vector3.new(1,0,1)).Magnitude<6 then advance(e,s) return end
			end
		end
	elseif e.phase=="Boss" then
		local target=closest(e,e.boss:GetPivot().Position)
		if target then
			e.player=target.player
			Encounters.step(e,root(target),t,dt,function(_,damage) harm(target,damage*e.reference*.1) end)
			local moveName=target.player:GetAttribute("BossMove")
			if moveName~=e.moveText then members(e,"BossMove",moveName) e.moveText=moveName end
		end
	end
	for s in e.members do
		if s.phase~="Boss" and s.phase~="Horda" then continue end
		local r=root(s)
		if not r then continue end
		local nearest=e.boss
		local distance=nearest and (nearest:GetPivot().Position-r.Position).Magnitude or math.huge
		for model in e.enemies do
			local d=(model:GetPivot().Position-r.Position).Magnitude
			if d<distance then nearest,distance=model,d end
		end
		if nearest then
			local goingOut=s.auto and e.portal and e.phase=="Horda"
			aim(s,e.portal and e.phase=="Horda" and e.portal.Position or nearest:GetPivot().Position)
			if goingOut then walk(s,e.portal.Position)
			elseif s.auto then
				if distance>9 then walk(s,nearest:GetPivot().Position) else attr(s,"AutoWalk",nil) end
				if distance<14 then skill(s) end
			end
			if nearest.Parent and distance<=14 and t>=s.nextHit then
				-- O golpe básico atinge até 5 inimigos colados no alvo: hordas grandes caem rápido.
				local damage=Progress.power(s.data)*.25*(math.random()<.05 and 2 or 1)
				local victims={nearest}
				if nearest~=e.boss then
					local center=nearest:GetPivot().Position
					for model in e.enemies do
						if #victims>=5 then break end
						if model~=nearest and ((model:GetPivot().Position-center)*Vector3.new(1,0,1)).Magnitude<=7 then table.insert(victims,model) end
					end
				end
				for _,v in victims do if v.Parent then strike(s,v,damage) end end
				s.nextHit=t+.5
			end
		end
	end
end

local function refreshLair(s)
	s.residents:ClearAllChildren()
	local copies={}
	for i,spot in s.pads do
		local index=s.data.lair[i]
		local capacity=math.min(12,s.data.slots+s.data.ascension)
		spot.prompt.ActionText=i>capacity and ("Abrir • "..500*3^(s.data.slots-4).." ouro") or index and "Trocar morador" or "Alojar criatura"
		spot.prompt.Enabled=i<=capacity+1
		spot.part.Transparency=spot.prompt.Enabled and 0 or 1
		spot.part.CanCollide=spot.prompt.Enabled
		if index then
			local stage=stages[index]
			copies[index]=(copies[index] or 0)+1
			local list=s.data.specimens[tostring(index)]
			local record=list and list[copies[index]]
			local name=record and record.variant=="Secreto" and record.name or stage.boss
			local resident=Encounters.creature(s.residents,name,spot.part.Position+Vector3.yAxis*2.4,3.5,stage.color)
			Collection.style(resident,record)
		end
	end
end
local function setupHub(s)
	local d=s.data
	Dungeon.hub(s.map,s.home)
	Tuco.build(s,station,reflect)
	local fountain=World.part(s.map,"Fonte Mágica",s.home+Vector3.new(-18,1,0),Vector3.new(2,6,6),Color3.fromHex("68E5CA"),Enum.PartType.Cylinder,Enum.Material.Neon)
	fountain.Orientation=Vector3.new(0,0,90)
	World.label(fountain,"Fonte Mágica",3)
	station(s,fountain,"Melhorar fonte",function()
		if s.phase~="Praça" or d.fountain>=10 then return end
		local cost=1000*4^d.fountain
		if d.gold<cost then attr(s,"Tip","A próxima melhoria da fonte custa "..cost.." ouro.") return end
		d.gold-=cost d.fountain+=1 reflect(s)
		attr(s,"Tip","Fonte nível "..d.fountain.." • bônus de renda +"..10*d.fountain.."%.")
	end)
	local gate=World.portal(s.map,s.home+Vector3.new(0,0,-23),"Portal das Fendas")
	station(s,gate,"Entrar",function() begin(s) end)
	for i,name in {"Fagulho","Marolo","Raminho"} do
		local pos=s.home+Vector3.new((i-2)*9,0,-8)
		local pedestal=World.part(s.map,name,pos+Vector3.yAxis*.45,Vector3.new(1,5,5),Color3.fromRGB(161,131,87),Enum.PartType.Cylinder,Enum.Material.Sandstone)
		pedestal.Orientation=Vector3.new(0,0,90)
		local model=Encounters.creature(s.map,name,pos+Vector3.yAxis*2.5,3.4,Rules.starters[name].color)
		model:PivotTo(model:GetPivot()*CFrame.Angles(0,math.pi,0))
		World.label(model.PrimaryPart,name,3)
		local prompt=station(s,model.PrimaryPart,"Escolher",function()
			if s.phase~="Parceiro" then return end
			d.starter=name
			s.pet=Encounters.creature(s.map,name,pos,2.8,Rules.starters[name].color)
			home(s,"Atravesse o portal para explorar o Bosque Musgoso.")
		end)
		prompt.ObjectText=name
	end
	s.pads={}
	s.residents=Instance.new("Folder",s.map)
	for i=1,12 do
		local pos=s.home+Vector3.new(((i-1)%4-1.5)*5.8,.4,14+math.floor((i-1)/4)*5.7)
		local part=World.part(s.map,"Vaga "..i,pos,Vector3.new(5,.8,5),Color3.fromRGB(132,151,96),nil,Enum.Material.Cobblestone)
		local prompt=station(s,part,"Alojar",function()
			if s.phase~="Praça" then return end
			local capacity=math.min(12,d.slots+d.ascension)
			if i>capacity then
				local price=500*3^(d.slots-4)
				if i==capacity+1 and d.gold>=price then
					d.gold-=price d.slots+=1 refreshLair(s) reflect(s)
				else attr(s,"Tip","Esta vaga custa "..price.." ouro.") end
				return
			end
			-- Vagas vazias são preenchidas em ordem para preservar arrays no save.
			if i>#d.lair+1 then attr(s,"Tip","Ocupe a vaga "..(#d.lair+1).." primeiro.") return end
			local used={}
			for j,index in d.lair do if i~=j then used[index]=(used[index] or 0)+1 end end
			local eligible={}
			for j=1,#stages do
				if (d.collection[tostring(j)] or 0)>(used[j] or 0) then table.insert(eligible,j) end
			end
			if #eligible==0 then attr(s,"Tip","Capture um chefe para alojá-lo na Toca.") return end
			local nextIndex=((table.find(eligible,d.lair[i]) or 0)%#eligible)+1
			if #d.lair==0 then d.bank+=100 end
			d.lair[i]=eligible[nextIndex]
			refreshLair(s)
			reflect(s)
			attr(s,"Tip",stages[d.lair[i]].boss.." está rendendo ouro na Toca.")
		end)
		prompt.Exclusivity=Enum.ProximityPromptExclusivity.AlwaysShow
		prompt.MaxActivationDistance=5
		s.pads[i]={part=part,prompt=prompt}
	end
	refreshLair(s)
	local chest=World.part(s.map,"Cofre",s.home+Vector3.new(-13,1.5,7),Vector3.new(4,3,3),goldColor,nil,Enum.Material.Metal)
	World.label(chest,"Cofre da Toca",3)
	station(s,chest,"Coletar",function()
		if s.phase~="Praça" then return end
		local gold=math.floor(d.bank)
		d.gold+=gold
		d.bank-=gold
		if gold>0 then quest(s,"bank") end
		reflect(s)
		attr(s,"Tip","Você recolheu "..gold.." ouro.")
	end)
	local pole=World.part(s.map,"Treino",s.home+Vector3.new(13,2,7),Vector3.new(3,4,3),Color3.fromRGB(143,98,65),nil,Enum.Material.WoodPlanks)
	local sign=World.label(pole,"Treinar • "..Rules.price(d.level).." ouro",4)
	station(s,pole,"Treinar time",function()
		if s.phase~="Praça" then return end
		local ok=Progress.train(d)
		if ok then quest(s,"train") end
		sign.Text="Treinar • "..Rules.price(d.level).." ouro"
		attr(s,"Tip",ok and "Time treinado! Nível "..d.level or "Treino custa "..Rules.price(d.level).." ouro.")
		reflect(s)
	end)
end

local function create(player)
	if sessions[player] then return end
	player.CameraMaxZoomDistance=36
	local slot=1
	while plots[slot] do slot+=1 end
	plots[slot]=player
	local district=math.floor((slot-1)/8)
	local offset=Vector3.new(district*800,0,0)
	if not plazas[district] then plazas[district]=Plaza.build(workspace,offset) or true end
	local homePos=Plaza.home((slot-1)%8+1,offset)
	local s={player=player,slot=slot,home=homePos,skill=0,cooldowns={},dodge=0,invulnerable=0,nextHit=0,auto=false}
	sessions[player]=s
	local map=Instance.new("Folder")
	map.Name,map.Parent="Clareira_"..player.UserId,workspace
	s.map=map
	World.island(map,homePos,37)
	local spawn=Instance.new("SpawnLocation")
	spawn.Name,spawn.Anchored="Entrada",true
	spawn.Size,spawn.Position=Vector3.new(8,1,8),homePos
	spawn.Transparency,spawn.Duration=1,0
	spawn.Parent=map
	player.RespawnLocation=spawn
	phase(s,"Entrada","Preparando sua Toca…")
	local function respawn(c)
		if not c:WaitForChild("HumanoidRootPart",10) or c~=player.Character then return end
		if s.data and s.data.starter~="" then home(s)
		else move(s,s.home) end
	end
	player.CharacterAdded:Connect(respawn)
	if player.Character then task.spawn(respawn,player.Character) end
	local d,persistent,status=Profiles.open(player.UserId)
	if not d then player:Kick(status) return end
	if sessions[player]~=s or not player.Parent then
		if persistent then Profiles.save(player.UserId,d,true) end
		return
	end
	s.data,s.persistent=d,persistent
	attr(s,"SaveStatus",status)
	Progress.accrue(d,math.max(0,os.time()-d.lastSeen),false)
	setupHub(s)
	reflect(s)
	if d.starter=="" then phase(s,"Parceiro","Escolha seu parceiro nos três pedestais.")
	else
		s.pet=Encounters.creature(map,d.starter,homePos,2.8,Rules.starters[d.starter].color)
		home(s,"Seu time voltou à praça. Confira o cofre e o diário.")
	end
end

local function hubAction(s,verb,value,rank)
	local d=s.data
	if verb=="join" then join(s) return end
	if verb=="select" and type(value)=="number" and stages[value] and value<=d.unlocked then
		d.stage,d.difficulty,s.auto=value,(rank==2 or rank==3) and Progress.difficulty(d,value,rank) and rank or 1,false
	elseif verb=="difficulty" and (value==1 or value==2 or value==3) and Progress.difficulty(d,d.stage,value) then
		d.difficulty,s.auto=value,false
	elseif verb=="equip" and type(value)=="number" and stages[value] then Progress.equip(d,value)
	elseif verb=="forge" and value=="Grande" and d.gold>=1000 then d.gold-=1000 d.large+=1
	elseif verb=="forge" and value=="Mestre" and d.fragments>=60 then d.fragments-=60 d.master+=1
	elseif verb=="fuse" and type(value)=="number" and stages[value] then
		if not Collection.fuse(d,value) then attr(s,"Tip","Você precisa de mais cópias desta espécie.") return end
		refreshLair(s)
	elseif verb=="awakening" then
		local cost=({100,300,800,2000})[d.stars]
		if not cost or d.fragments<cost then attr(s,"Tip","Fragmentos insuficientes para despertar.") return end
		d.fragments-=cost
		d.stars+=1
	elseif verb=="daily" and d.dailyDay<math.floor(os.time()/86400) then
		d.dailyDay=math.floor(os.time()/86400)
		d.dailyCount+=1
		local day=(d.dailyCount-1)%7+1
		local msg
		if day==1 or day==5 then
			local bonus=math.max(100,math.floor(Progress.income(d)*(day==1 and 600 or 1800)))
			d.gold+=bonus msg=bonus.." ouro"
		elseif day==2 or day==6 then
			local n=day==2 and 2 or 3
			d.large+=n msg=n.." cristais Grandes"
		elseif day==7 then d.master+=1 d.gems+=50 msg="Cristal Mestre e 50 gemas"
		elseif day==4 then d.luckUntil=os.time()+300 msg="5 minutos de sorte"
		else d.gems+=20 msg="20 gemas" end
		attr(s,"Tip","Dia "..day.." • "..msg.."!")
	elseif verb=="auto" and (d.cleared[tostring(d.stage)] or 0)>=2 then s.auto=not s.auto
	elseif verb=="ascend" and d.ascension==0 and d.gold>=10000000 and d.cleared["12"] then
		d.slots,d.fountain=4,0
		d.ascension,d.level,d.unlocked,d.stage,d.difficulty=1,1,1,1,1
		d.gold,d.bank,d.cleared,d.lair,s.auto=0,0,{},{},false
		refreshLair(s)
		attr(s,"Tip","Primeira Ascensão! Sua coleção agora rende o dobro.")
	else return end
	reflect(s)
end
action.OnServerEvent:Connect(function(player,verb,value,rank)
	local s=sessions[player]
	if not s or not s.data or type(verb)~="string" then return end
	local now=os.clock()
	if now<(s.nextInput or 0) then return end
	s.nextInput=now+.06
	if s.phase=="Praça" then hubAction(s,verb,value,rank) return end
	if verb=="crystal" and s.phase=="Captura" and (value=="Comum" or value=="Grande" or value=="Mestre" or value=="Supremo") then crystal(s,value) return end
	if verb=="capture" then seal(s,false) return end
	if verb=="auto" and s.expedition and (s.data.cleared[tostring(s.data.stage)] or 0)>=2 then
		s.auto=not s.auto attr(s,"Auto",s.auto) return
	end
	if verb=="nextSkill" and s.expedition and (s.phase=="Horda" or s.phase=="Boss" or s.phase=="Explorar") then
		s.active=((s.active or 0)+1)%(#s.data.equipped+1)
		syncSkill(s)
		return
	end
	if verb=="skill" then skill(s) return end
	if verb=="dodge" and now>=s.dodge and (s.phase=="Horda" or s.phase=="Boss") then
		local r=root(s)
		if not r then return end
		s.dodge,s.invulnerable=now+3,now+.4
		local dir=r.Parent.Humanoid.MoveDirection
		if dir.Magnitude<.1 then dir=r.CFrame.LookVector end
		local params=RaycastParams.new()
		params.FilterType=Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances={r.Parent,s.pet}
		params.RespectCanCollide=true
		local step=dir*12
		local hit=workspace:Raycast(r.Position,step,params)
		if hit then step=dir*math.max(0,hit.Distance-2) end
		r.CFrame+=step
	end
end)
local function remove(player)
	local s=sessions[player]
	if not s then return end
	sessions[player]=nil
	plots[s.slot]=nil
	leave(s)
	s.map:Destroy()
	if s.persistent then checkpoint(s,true) end
end
Players.PlayerRemoving:Connect(remove)
Players.PlayerAdded:Connect(create)
for _,p in Players:GetPlayers() do task.spawn(create,p) end
game:BindToClose(function()
	local pending=0
	for _,s in sessions do
		if s.persistent then
			pending+=1
			task.spawn(function() checkpoint(s,true) pending-=1 end)
		end
	end
	local untilTime=os.clock()+25
	while pending>0 and os.clock()<untilTime do task.wait(.1) end
end)
local last=os.clock()
while true do
	task.wait(.1)
	local t=os.clock()
	for e in expeditions do tickExpedition(e,t,math.min(.3,t-last)) end
	for _,s in sessions do
		if not s.data then continue end
		local r=root(s)
		if r and s.pet then
			s.pet:PivotTo(r.CFrame*CFrame.new(3,-1+.2*math.sin(t*4),1))
			if s.followers then for i,model in s.followers do
				model:PivotTo(r.CFrame*CFrame.new(i==1 and -3 or .5,-1+.24*math.sin(t*4+i),i==1 and 1 or 3.8))
			end end
		end
		if math.floor(t)>math.floor(last) then
			Progress.accrue(s.data,math.floor(t)-math.floor(last),s.expedition~=nil)
			attr(s,"Bank",math.floor(s.data.bank))
		end
		if math.floor(t/60)>math.floor(last/60) and not s.saving then task.spawn(checkpoint,s,false) end
	end
	last=t
end
