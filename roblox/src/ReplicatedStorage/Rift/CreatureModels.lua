-- Shapes are authored in body lengths. The body pivot faces negative Z.
local Models = {}
local V = Vector3.new
local gold = Color3.fromHex("FFCB66")
local cream = Color3.fromHex("F8DDB1")
local ink = Color3.fromHex("202C39")
local leaf = Color3.fromHex("70AA6C")
local teal = Color3.fromHex("6EE5C9")
local bark = Color3.fromHex("946244")
local flower = Color3.fromHex("FA87AD")
local neon, metal, wood = Enum.Material.Neon, Enum.Material.Metal, Enum.Material.Wood

local styles = {
	Fagulho={"fox","ED783C"}, Marolo={"otter","60B3CB"}, Raminho={"stag","95BF73"},
	Musguinho={"stump","83A85F"}, ["Sapo-Lanterna"]={"frog","4AABBA"}, Cogumestre={"mushroom","BA586A"},
	["Javali Raiz"]={"boar","9B7554"}, ["Coruja Bruma"]={"owl","8093B6"}, ["Ancião Carvalhorn"]={"stag","6A8E6D"},
	Escarabrilho={"beetle","CFAD56"}, ["Lagartixa Brasa"]={"lizard","E16E48"}, ["Cacto Tambor"]={"cactus","7AA166"},
	["Escorpião Prisma"]={"scorpion","A88ACE"}, ["Djinn de Areia"]={"djinn","E6A45F"}, ["Esfinge Solarya"]={"sphinx","D4A85A"},
	["Lúmen"]={"kingfly","78C9BA"}, Miragem={"serpent","79D4CE"},
	Brotinho={"sprout","99C166"}, ["Vagalume-Faísca"]={"firefly","62BAA1"}, ["Lesma de Musgo"]={"slug","92A765"},
	["Lobo de Folhas"]={"fox","699B71"}, Areinha={"sprout","CFAD6E"}, Cristalino={"crystal","91CBCE"},
	Escorpinho={"scorpion","B98671"}, ["Abutre Prisma"]={"owl","9A85AA"}, ["Ent Guardião"]={"stump","698C60"},
	["Xamã Cogumelo"]={"mushroom","9E679A"}, ["Golem de Vidro"]={"crystal","7ED7C8"}, ["Mago das Dunas"]={"djinn","AE805B"},
}
local builders = {}
function builders.fox(a)
	for _,s in {-1,1} do a.fin("Orelha",s*.23,.39,-.25,.21,.46,.22,0,0,-s*14,a.base) end
	a.blob("Focinho",0,-.01,-.5,.42,.32,.36,cream)
	a.blob("Cauda",0,.2,.54,.43,.4,.91,a.base,-30)
	a.blob("Ponta",0,.42,.85,.28,.28,.33,gold)
	a.feet(4)
end
function builders.otter(a)
	for _,s in {-1,1} do
		a.blob("Orelha",s*.33,.33,-.2,.21,.21,.13,a.base)
		a.blob("Bochecha",s*.13,-.02,-.45,.3,.26,.22,cream)
	end
	a.blob("Concha",0,-.21,-.43,.19,.17,.09,cream)
	a.blob("Cauda",0,-.23,.58,.34,.18,.81,a.base,15)
	a.feet(4)
end
function builders.stag(a)
	a.blob("Focinho",0,-.02,-.51,.42,.31,.44,cream)
	for _,s in {-1,1} do
		a.blob("Orelha",s*.34,.3,-.18,.32,.16,.18,a.base)
		a.rod("Galhada",V(s*.19,.26,-.16),V(s*.32,.78,-.04),.085,bark)
		a.rod("Galho",V(s*.29,.61,-.08),V(s*.56,.75,-.16),.07,bark)
		a.rod("Galho",V(s*.32,.76,-.04),V(s*.37,.89,.06),.06,bark)
		a.blob("Flor",s*.55,.77,-.16,.15,.13,.15,flower)
	end
	a.feet(4)
end
function builders.stump(a)
	a.blob("Musgo",0,.24,0,.98,.36,.96,a.base)
	for i=1,7 do
		local angle=i*math.pi*2/7
		a.rod("Raiz",V(.28*math.cos(angle),-.19,.28*math.sin(angle)),V(.53*math.cos(angle),-.34,.53*math.sin(angle)),.16,bark)
	end
	a.rod("Ramo",V(0,.33,0),V(.03,.61,0),.07,bark)
	for _,s in {-1,1} do a.blob("Folha",s*.12,.58,0,.29,.11,.19,leaf,0,0,s*25) end
end
function builders.frog(a)
	for _,s in {-1,1} do
		a.blob("Órbita",s*.27,.31,-.22,.34,.34,.3,a.base)
		a.blob("Pupila",s*.27,.33,-.36,.16,.17,.08,ink)
		a.blob("Pata",s*.41,-.19,.16,.48,.36,.53,a.base)
		a.blob("Palma",s*.39,-.32,-.14,.38,.11,.45,cream)
	end
	a.rod("Haste",V(0,.27,0),V(0,.67,-.17),.065,leaf)
	a.blob("Lanterna",0,.63,-.25,.22,.27,.22,gold,0,0,0,neon)
end
function builders.mushroom(a)
	a.blob("Chapéu",0,.32,0,1.28,.52,1.19,a.base)
	for i=1,6 do
		local angle=i*math.pi/3
		a.blob("Pinta",.4*math.cos(angle),.5,.36*math.sin(angle),.19,.075,.17,cream)
	end
	a.fin("Barba",0,-.12,-.43,.44,.41,.16,170,0,0,cream)
	a.rod("Cajado",V(.55,-.32,-.05),V(.59,.49,-.08),.075,bark)
	a.blob("Esporo",.59,.52,-.08,.18,.20,.18,teal,0,0,0,neon)
end
function builders.boar(a)
	a.blob("Focinho",0,-.06,-.51,.5,.32,.32,bark)
	for _,s in {-1,1} do a.fin("Presa",s*.24,-.03,-.55,.12,.32,.13,-15,0,-s*22,cream) end
	for i=0,2 do a.fin("Casca",0,.39,-.14+i*.23,.19,.27,.28,20,0,0,bark) end
	a.feet(4)
end
function builders.owl(a)
	for _,s in {-1,1} do
		a.blob("Asa",s*.41,-.03,.02,.32,.65,.48,a.base:Lerp(ink,.25),-15,0,s*17)
		a.blob("Disco facial",s*.18,.13,-.37,.36,.39,.16,cream)
		a.blob("Íris",s*.18,.15,-.46,.22,.22,.075,gold)
		a.blob("Pupila",s*.18,.15,-.50,.12,.14,.04,ink)
		a.fin("Tufo",s*.26,.39,-.14,.25,.33,.20,10,0,-s*25,a.base)
	end
	a.fin("Bico",0,-.02,-.51,.17,.2,.15,175,0,0,gold)
end
function builders.beetle(a)
	for _,s in {-1,1} do
		a.blob("Élitro",s*.19,.18,.12,.44,.45,.89,a.base,0,0,0,metal)
		for i=-1,1 do a.rod("Perna",V(s*.28,-.11,i*.24),V(s*.61,-.31,i*.31),.09,ink) end
	end
	a.fin("Chifre",0,.25,-.4,.14,.47,.24,-21,0,0,gold)
end
function builders.lizard(a)
	a.blob("Cauda",0,-.14,.68,.28,.27,1.01,a.base,6)
	for i=0,4 do a.fin("Escama",0,.36-i*.05,-.15+i*.20,.14,.27,.23,22,0,0,gold) end
	a.feet(4)
end
function builders.cactus(a)
	for _,s in {-1,1} do
		a.rod("Braço",V(s*.24,-.02,0),V(s*.52,.03,0),.19,a.base)
		a.blob("Braço",s*.52,.18,0,.21,.46,.21,a.base)
		for j=0,2 do a.fin("Espinho",s*.39,j*.16-.2,-.1,.06,.13,.06,0,0,-s*70,cream) end
	end
	for i=1,5 do
		local t=i*math.pi*2/5
		a.blob("Pétala",.15+.12*math.cos(t),.39,.12*math.sin(t),.19,.12,.19,flower)
	end
	a.blob("Tambor",0,-.12,-.42,.54,.45,.14,cream)
end
function builders.scorpion(a)
	for _,s in {-1,1} do
		a.blob("Pinça",s*.42,-.06,-.33,.31,.27,.44,a.base)
		a.fin("Garra",s*.46,-.03,-.59,.12,.15,.23,72,0,0,cream)
		for i=-1,1 do a.rod("Perna",V(s*.27,-.1,.17*i),V(s*.57,-.27,.25*i),.075,a.base) end
	end
	a.rod("Cauda",V(0,0,.29),V(0,.27,.65),.21,a.base)
	a.rod("Cauda",V(0,.27,.65),V(0,.61,.47),.17,a.base)
	a.fin("Ferrão",0,.61,.33,.15,.26,.20,54,0,0,teal,neon)
end
function builders.djinn(a)
	for _,s in {-1,1} do
		a.blob("Punho",s*.47,.11,-.19,.31,.32,.32,a.base)
		a.blob("Bracelete",s*.42,.1,-.04,.31,.33,.13,gold,0,0,0,metal)
	end
	for i=1,3 do a.blob("Redemoinho",math.sin(i)*.09,-.23-i*.1,.07*i,.68-i*.12,.24,.62-i*.1,cream) end
	a.blob("Turbante",0,.32,0,.79,.23,.62,gold)
	a.fin("Gema",0,.34,-.31,.16,.21,.12,0,0,0,teal,neon)
end
function builders.sphinx(a)
	for i=1,11 do
		local angle=i*math.pi*2/11
		local x,y=math.cos(angle),math.sin(angle)
		a.fin("Raio da juba",x*.41,y*.39,-.14,.26,.45,.24,0,0,math.deg(angle)-90,gold,metal)
	end
	a.blob("Focinho",0,-.04,-.48,.4,.24,.27,cream)
	for _,s in {-1,1} do a.fin("Orelha",s*.24,.37,-.22,.23,.31,.17,0,0,-s*15,a.base) end
	a.feet(4)
end
function builders.sprout(a)
	a.blob("Folha",-.1,.39,0,.39,.12,.18,leaf,0,0,-25)
	a.blob("Folha",.1,.42,0,.39,.12,.18,leaf,0,0,34)
end
function builders.firefly(a)
	a.blob("Lanterna",0,-.05,.37,.42,.39,.55,gold,0,0,0,neon)
	for _,s in {-1,1} do a.blob("Asa",s*.42,.26,.05,.57,.09,.48,teal,0,0,s*25) end
end
function builders.kingfly(a)
	for _,side in {-1,1} do
		for i=0,1 do
			local tint=i==0 and teal or flower
			a.blob("Vitral",side*(.55-i*.07),.2+i*.1,.28-i*.51,.94,.1,.54,tint,-8,side*(25-i*50),side*20,Enum.Material.Glass)
			a.rod("Nervura",V(side*.23,.16,.04),V(side*.86,.33,.37-i*.62),.045,gold)
		end
		a.rod("Antena",V(side*.13,.27,-.28),V(side*.23,.65,-.49),.045,gold)
		a.blob("Lume",side*.23,.65,-.49,.14,.14,.14,gold,0,0,0,neon)
	end
	a.blob("Lanterna real",0,-.03,.43,.56,.55,.65,gold,0,0,0,neon)
	for i=1,5 do
		local angle=i*2*math.pi/5
		a.fin("Coroa",math.cos(angle)*.22,.44,math.sin(angle)*.16-.08,.17,.28,.14,0,-math.deg(angle),0,gold,metal)
	end
end
function builders.serpent(a)
	for i=1,6 do
		local x=.38*math.sin(i*.77)
		local radius=.55-i*.06
		a.blob("Cauda de areia",x,-.05-.05*i,.22+i*.17,radius,radius,.44,i%2==0 and cream or a.base)
	end
	for _,side in {-1,1} do
		a.fin("Barbatana",side*.39,.13,-.05,.29,.72,.38,-22,0,-side*40,a.base,Enum.Material.Glass)
		a.fin("Olho de diamante",side*.21,.14,-.45,.17,.2,.13,0,0,0,teal,neon)
	end
	a.blob("Crista",0,.37,-.17,.17,.39,.25,teal,0,0,0,neon)
end
function builders.slug(a)
	a.blob("Caracol",0,.18,.19,.68,.68,.41,leaf)
	for _,s in {-1,1} do a.rod("Antena",V(s*.14,.18,-.3),V(s*.21,.43,-.43),.065,cream) end
end
function builders.crystal(a)
	for i=-1,1 do a.fin("Cristal",i*.23,.32,0,.26,.72-math.abs(i)*.24,.32,-12,0,-i*22,a.base,Enum.Material.Glass) end
end

function Models.create(parent,name,position,size,color)
	local spec = styles[name] or styles.Brotinho
	local base = color or Color3.fromHex(spec[2])
	local model = Instance.new("Model")
	model.Name = name
	local a = {base=base}
	local function part(class, shape, label,x,y,z,w,h,d,rx,ry,rz,tint,material)
		local p=Instance.new(class)
		if shape then p.Shape=shape end
		p.Name=label
		p.Anchored=true
		p.CanCollide,p.CanTouch,p.CanQuery=false,false,false
		p.Color,p.Material=tint,material or Enum.Material.SmoothPlastic
		p.Size=V(w,h,d)*size
		p.CFrame=CFrame.new(position+V(x,y,z)*size)*CFrame.fromOrientation(math.rad(rx or 0),math.rad(ry or 0),math.rad(rz or 0))
		p.Parent=model
		return p
	end
	function a.blob(label,x,y,z,w,h,d,tint,rx,ry,rz,material)
		return part("Part",Enum.PartType.Ball,label,x,y,z,w,h,d,rx,ry,rz,tint,material)
	end
	function a.fin(label,x,y,z,w,h,d,rx,ry,rz,tint,material)
		return part("WedgePart",nil,label,x,y,z,w,h,d,rx,ry,rz,tint,material)
	end
	function a.rod(label,start,finish,width,tint)
		local v=finish-start
		local center=(start+finish)/2
		local rod=part("Part",Enum.PartType.Cylinder,label,center.X,center.Y,center.Z,v.Magnitude,width,width,0,0,0,tint)
		rod.CFrame=CFrame.lookAt(position+center*size,position+finish*size)*CFrame.Angles(0,math.pi/2,0)
	end
	function a.feet(count)
		for i=1,count do
			local side=i%2==0 and 1 or -1
			a.blob("Pata",side*.27,-.29,(i<=2 and -.22 or .24),.25,.23,.33,base:Lerp(ink,.19))
		end
	end
	local bodyColor=base
	if spec[1]=="stump" then bodyColor=bark elseif spec[1]=="mushroom" then bodyColor=cream end
	local body=a.blob("Corpo",0,0,0,.87,.72,1,bodyColor,0,0,0,spec[1]=="stump" and wood or nil)
	model.PrimaryPart=body
	builders[spec[1]](a)
	if spec[1]~="owl" and spec[1]~="frog" and spec[1]~="serpent" then
		for _,side in {-1,1} do
			a.blob("Olho",side*.18,.115,-.432,.135,.17,.085,ink)
			a.blob("Reflexo",side*.18-.019,.15,-.47,.043,.05,.035,Color3.new(1,1,1))
		end
	end
	model.Parent=parent
	return model
end
return Models
