-- Ruins are built around a continuous processional road. All route points are floor positions.
local Dungeon = {}
local V = Vector3.new
local C = Color3.fromRGB
local M = Enum.Material
local UP = Vector3.yAxis
local pi = math.pi

local forest = {
	rock=C(56,78,85), dark=C(37,53,64), face=C(112,139,132), crown=C(169,189,157),
	floor=C(112,134,119), ground=C(73,112,83), cloth=C(26,105,102), metal=C(199,160,85),
	glow=C(128,244,207), flame=C(255,187,91), flora=C(45,105,81), bloom=C(235,153,153),
}
local dunes = {
	rock=C(162,103,75), dark=C(83,62,77), face=C(214,162,104), crown=C(252,208,139),
	floor=C(205,164,120), ground=C(208,150,84), cloth=C(57,98,137), metal=C(233,175,67),
	glow=C(110,225,251), flame=C(246,137,217), flora=C(56,130,119), bloom=C(231,106,138),
}
local chapterAccents = {
	C(118,229,172),C(98,217,255),C(226,143,235),C(244,179,100),C(158,181,252),C(225,236,127),
	C(255,213,113),C(255,119,76),C(243,139,171),C(159,201,255),C(148,221,238),C(255,223,125),
}

local function part(parent,name,cf,size,color,material,solid,shape)
	local p=Instance.new("Part")
	p.Name=name
	p.Anchored=true
	p.Size=size
	p.CFrame=cf
	p.Color=color
	p.Material=material
	p.CanCollide=solid==true
	p.CanQuery=solid==true
	p.CanTouch=false
	p.TopSurface=Enum.SurfaceType.Smooth
	p.BottomSurface=Enum.SurfaceType.Smooth
	if shape then p.Shape=shape end
	p.Parent=parent
	return p
end

local function disc(parent,name,pos,radius,depth,color,mat,solid)
	return part(parent,name,CFrame.new(pos)*CFrame.Angles(0,0,pi/2),V(depth,radius*2,radius*2),color,mat,solid,Enum.PartType.Cylinder)
end

local function block(parent,name,base,x,y,z,w,h,d,color,mat,solid)
	return part(parent,name,base*CFrame.new(x,y,z),V(w,h,d),color,mat,solid)
end

local function strut(parent,name,a,b,width,depth,color,mat)
	local offset=b-a
	local guide=math.abs(offset.Unit:Dot(UP))>0.99 and Vector3.zAxis or UP
	return part(parent,name,CFrame.lookAt((a+b)/2,b,guide),V(width,depth,offset.Magnitude),color,mat)
end

local function gem(parent,base,color,size)
	-- Two opposed pyramidal silhouettes read as a cut gemstone at a distance.
	local scale=size/4
	for i=0,1 do
		local p=Instance.new("WedgePart")
		p.Anchored=true
		p.CanCollide,p.CanTouch,p.CanQuery=false,false,false
		p.Material,p.Color=M.Neon,color
		p.Size=V(2.5,4,2.5)*scale
		p.CFrame=base*CFrame.Angles(0,pi/4,0)*CFrame.new(0,0,(i-0.5)*2.5*scale)*CFrame.Angles(0,i*pi,0)
		p.Name="Cristal lapidado"
		p.Parent=parent
	end
end

local function light(parent,color,range)
	local lamp=Instance.new("PointLight")
	lamp.Range,lamp.Brightness,lamp.Color=range,1.5,color
	lamp.Parent=parent
end

local function brazier(parent,cf,palette,scale)
	block(parent,"Peanha",cf,0,1.1*scale,0,2.4*scale,2.2*scale,2.4*scale,palette.rock,M.Slate)
	local rim=block(parent,"Taça",cf,0,2.4*scale,0,3.1*scale,0.8*scale,3.1*scale,palette.metal,M.Metal)
	gem(parent,cf*CFrame.new(0,3.8*scale,0),palette.flame,2.6*scale)
	light(rim,palette.flame,17*scale)
end

local function arch(parent,cf,span,height,palette,accent)
	local half=span/2
	local shoulder=height*0.6
	for _,side in {-1,1} do
		local x=side*half
		block(parent,"Sapata",cf,x,1.4,0,6.4,2.8,6.4,palette.rock,M.Slate)
		block(parent,"Fuste",cf,x,shoulder/2,0,3.5,shoulder,3.8,palette.face,M.Limestone)
		block(parent,"Capitel",cf,x,shoulder,0,5,2,5,palette.crown,M.Sandstone)
		strut(parent,"Arco ogival",cf:PointToWorldSpace(V(x,shoulder,0)),cf:PointToWorldSpace(V(side*half*0.47,height*0.87,0)),3.4,3.4,palette.face,M.Limestone)
		strut(parent,"Arco ogival",cf:PointToWorldSpace(V(side*half*0.47,height*0.87,0)),cf:PointToWorldSpace(V(0,height,0)),3.4,3.4,palette.face,M.Limestone)
	end
	local key=block(parent,"Fecho de bronze",cf,0,height,0,3.8,4,4.2,palette.metal,M.Metal)
	gem(parent,key.CFrame*CFrame.new(0,0,2.2),accent,2.1)
end

local function banner(parent,cf,palette)
	block(parent,"Haste",cf,0,0,0,6.4,0.4,0.5,palette.metal,M.Metal)
	block(parent,"Estandarte",cf,0,-3.8,0,5.1,7.4,0.23,palette.cloth,M.Fabric)
	block(parent,"Bordado",cf,0,-6.7,0.15,5.1,0.42,0.12,palette.metal,M.Fabric)
	local badge=cf*CFrame.new(0,-3.35,0.18)*CFrame.Angles(0,0,pi/4)
	part(parent,"Brasão",badge,V(1.8,1.8,0.12),palette.metal,M.Metal)
end

local function tree(parent,pos,scale,palette)
	local cf=CFrame.new(pos)
	local fork=pos+V(0,10,0)*scale
	strut(parent,"Tronco antigo",pos-UP*scale,fork,3.8*scale,3.8*scale,C(88,71,55),M.Wood)
	for i=1,3 do
		local a=i*2*pi/3+pos.Z%1.5
		local tip=fork+V(math.cos(a)*5,3+i,math.sin(a)*5)*scale
		strut(parent,"Galho",fork-UP*3*scale,tip,1.9*scale,1.8*scale,C(88,71,55),M.Wood)
		local leaves=cf.Rotation*CFrame.Angles(0,a,0)
		part(parent,"Copa de folhas",CFrame.new(tip)*leaves,V(10,6+i,9)*scale,palette.flora:Lerp(palette.crown,i*0.065),M.Grass,false,Enum.PartType.Ball)
	end
end

local function landmark(parent,cf,kind,palette,accent,scale)
	-- Room-specific silhouettes frame the arena's open fighting space.
	if kind=="tree" then
		tree(parent,cf.Position,scale,palette)
	elseif kind=="shelf" then
		for i=1,3 do
			local foot=cf:PointToWorldSpace(V((i-2)*3,0,math.sin(i)*3)*scale)
			local h=(4+i*1.5)*scale
			disc(parent,"Pé do cogumelo",foot+UP*h/2,0.9*scale,h,palette.crown,M.Wood)
			part(parent,"Chapéu",CFrame.new(foot+UP*h),V(6+i,2.8,6+i)*scale,accent:Lerp(palette.cloth,0.4),M.SmoothPlastic,false,Enum.PartType.Ball)
			disc(parent,"Lamelas",foot+UP*(h-0.55*scale),(2.5+i*0.35)*scale,0.35*scale,palette.glow,M.Neon)
		end
	elseif kind=="obelisk" then
		block(parent,"Base de oferendas",cf,0,1.2*scale,0,8*scale,2.4*scale,8*scale,palette.rock,M.Sandstone)
		block(parent,"Obelisco entalhado",cf,0,9*scale,0,3.5*scale,16*scale,3.5*scale,palette.face,M.Sandstone)
		block(parent,"Cartucho",cf,0,9*scale,1.8*scale,0.6*scale,11*scale,0.2*scale,palette.metal,M.Metal)
		gem(parent,cf*CFrame.new(0,18*scale,0),accent,4*scale)
	else
		for i=1,3 do
			local crystal=cf*CFrame.new((i-2)*2.2*scale,(3+i)*scale,math.sin(i)*scale)*CFrame.Angles(math.rad(i*4),i,math.rad((2-i)*15))
			part(parent,"Veio de cristal",crystal,V(2.6,6+i,2.6)*scale,palette.cloth:Lerp(accent,i/4),M.Glass)
			gem(parent,crystal*CFrame.new(0,(3+i/2)*scale,0),accent,2.4*scale)
		end
	end
end

local function ring(parent,pos,radius,color,width,segments)
	for i=1,segments do
		local a,b=(i-1)*2*pi/segments,i*2*pi/segments
		local v=pos+V(math.cos(a)*radius,0,math.sin(a)*radius)
		local w=pos+V(math.cos(b)*radius,0,math.sin(b)*radius)
		strut(parent,"Marchetaria",v,w,width,0.12,color,M.Metal)
	end
end

local function bridge(parent,a,b,ra,rb,palette,accent,secret)
	local dir=(b-a).Unit
	local start=a+dir*(ra-1.5)
	local finish=b-dir*(rb-1.5)
	local cf=CFrame.lookAt((start+finish)/2,finish)
	local len=(finish-start).Magnitude
	local width=secret and 12 or 20
	block(parent,"Tabuleiro da ponte",cf,0,-2.1,0,width,4.2,len,palette.rock,M.Slate,true)
	block(parent,"Calçamento",cf,0,0.03,0,width-1,0.06,len,palette.floor,M.Cobblestone,true)
	for _,side in {-1,1} do
		local x=side*(width/2-0.6)
		block(parent,"Parapeito",cf,x,1.1,0,1.2,2.2,len,palette.face,M.Limestone,true)
		block(parent,"Friso da ponte",cf,x,2.3,0,1.5,0.25,len,palette.metal,M.Metal)
		for i=0,2 do
			local z=(i-1)*len*0.46
			block(parent,"Talha-mar",cf,x,-3.6,z,3.5,14,4.8,palette.face,M.Slate)
			gem(parent,cf*CFrame.new(x,4.2,z),accent,1.6)
		end
	end
	if not secret then
		arch(parent,cf, width+1,21,palette,accent)
		for i=-1,1 do
			local marker=cf*CFrame.new(0,0.14,i*len/4)
			for _,side in {-1,1} do
				strut(parent,"Seta de navegação",marker:PointToWorldSpace(V(side*2.1,0,1)),marker:PointToWorldSpace(V(0,0,-1.2)),0.48,0.12,accent,M.Neon)
			end
		end
	end
end

local function chamber(parent,pos,radius,openings,style,palette,accent,biome,stage)
	disc(parent,"Maciço",pos-UP*10,radius-2,20,palette.rock,M.Rock,true)
	disc(parent,"Laje",pos-UP*2.4,radius,4.8,palette.face,M.Slate,true)
	disc(parent,"Piso",pos+UP*0.04,radius-1.5,0.08,palette.floor,M.Cobblestone,true)
	local inner=radius*0.52
	disc(parent,"Medalhão de pedra",pos+UP*0.1,inner,0.12,palette.floor:Lerp(palette.crown,0.23),M.Limestone)
	ring(parent,pos+UP*0.2,inner-0.5,palette.metal,0.65,12)
	for i=1,8 do
		local a=i*pi/4
		local frame=CFrame.new(pos)*CFrame.Angles(0,a,0)
		local sigil=frame*CFrame.new(0,0.19,inner-3)*CFrame.Angles(0,pi/4,0)
		part(parent,"Runa cardinal",sigil,V(1.75,0.14,1.75),accent,M.Neon)
	end
	local segments=12
	local function nearPass(radial)
		for _,target in openings do
			local along=(target-pos).Unit
			if along:Dot(radial)>math.cos(math.rad(26)) then return true end
		end
		return false
	end
	for i=1,segments do
		local a=i*2*pi/segments
		local radial=V(math.cos(a),0,math.sin(a))
		if nearPass(radial) then continue end
		local edge=pos+radial*(radius-2)
		local frame=CFrame.lookAt(edge,pos)
		local w=2*(radius-2)*math.tan(pi/segments)+0.15
		local height=style=="sanctum" and 24 or 12+(i+stage)%3*3
		block(parent,"Muralha",frame,0,height/2,0,w,height,3,palette.rock,M.Slate,true)
		block(parent,"Cornija",frame,0,height,0,w+0.5,1.1,4,palette.crown,M.Limestone)
		block(parent,"Contraforte",frame,0,height*0.55,-1.4,3.2,height*1.1,4.2,palette.face,M.Limestone)
		if i%2==0 then
			banner(parent,frame*CFrame.new(0,height-1,-4)*CFrame.Angles(0,pi,0),palette)
		end
		local setting=frame*CFrame.new(w*0.25,0,-5)
		if style=="sanctum" and i%2==1 then
			arch(parent,frame*CFrame.new(0,height,0),w-4,16,palette,accent)
		elseif i%2==1 then
			local kind
			if biome=="Bosque" then kind=style=="gallery" and "shelf" or "tree"
			else kind=style=="gallery" and "crystal" or "obelisk" end
			landmark(parent,setting,kind,palette,accent,style=="nave" and 1.45 or 0.88)
		end
	end
end

local function vault(parent,pos,radius,palette,accent,desert)
	-- An interrupted barrel vault leaves skylights over the nave and an open central aisle.
	for _,offset in {-17,17} do
		local cf=CFrame.new(pos)*CFrame.new(0,0,offset)
		local span=radius*1.46
		arch(parent,cf,span,40,palette,accent)
		for _,side in {-1,1} do
			local rafter=cf*CFrame.new(side*span*0.31,33.5,0)*CFrame.Angles(0,0,-side*math.rad(28))
			part(parent,"Pano da abóbada",rafter,V(span*0.36,1.8,18),desert and palette.face or palette.dark,M.Slate)
			block(parent,"Longarina",cf,side*span/2,24,0,2.4,2.6,22,palette.crown,M.Limestone)
		end
	end
	for _,side in {-1,1} do
		brazier(parent,CFrame.new(pos+V(side*31,0,-6)),palette,1.15)
	end
	local chain=pos+V(0,39,0)
	strut(parent,"Viga de cumeeira",chain+V(0,0,-20),chain+V(0,0,20),2.4,2.4,palette.rock,M.Slate)
	strut(parent,"Suspensão",chain,chain-UP*9,0.38,0.38,palette.metal,M.Metal)
	disc(parent,"Candelabro",chain-UP*9,4,0.9,palette.metal,M.Metal)
	for i=1,4 do
		local a=i*pi/2
		gem(parent,CFrame.new(chain+V(3*math.cos(a),-7.9,3*math.sin(a))),accent,2.2)
	end
end

local function signature(parent,pos,stage,palette,accent)
	-- Each chapter's side altars share the palette of its boss arena.
	local motif=(stage-1)%6+1
	for _,side in {-1,1} do
		local cf=CFrame.new(pos)*CFrame.new(35*side,0,-13)*CFrame.Angles(0,-side*pi/2,0)
		if motif==1 then
			landmark(parent,cf,stage==1 and "tree" or "crystal",palette,accent,1.55)
		elseif motif==2 then
			for i=1,3 do
				block(parent,"Aqueduto",cf,i*2-4,1.5+i,0,2.1,3+i*2,10,palette.face,M.Limestone)
			end
			local color=stage==2 and C(74,190,206) or C(248,110,60)
			local stream=block(parent,"Queda",cf,0,3.5,-5.1,7,7,0.7,color,M.Glass)
			stream.Transparency=0.23
			disc(parent,"Bacia",cf:PointToWorldSpace(V(0,0.2,-6)),5,0.32,color,M.Glass)
		elseif motif==3 then
			if stage==3 then landmark(parent,cf,"shelf",palette,accent,1.9)
			else
				for i=1,3 do
					local center=cf:PointToWorldSpace(V((i-2)*4,2+i,0))
					disc(parent,"Tambor votivo",center,2.1,4+i,palette.rock,M.Sandstone)
					disc(parent,"Pele do tambor",center+UP*(2+i/2),2.25,0.35,accent,M.Fabric)
				end
			end
		elseif motif==4 then
			local kind=stage==4 and "tree" or "crystal"
			landmark(parent,cf,kind,palette,accent,1.25)
			landmark(parent,cf*CFrame.new(5,0,-2),kind,palette,accent,0.75)
		elseif motif==5 then
			for i=1,3 do
				local stone=cf*CFrame.new((i-2)*3,(4+i),i)*CFrame.Angles(0,i,math.rad(i*3))
				part(parent,"Monólito da vigília",stone,V(2.6,8+i*2,3),palette.dark,M.Slate)
				gem(parent,stone*CFrame.new(0,4.5+i,0),accent,2.5)
			end
		else
			arch(parent,cf,14,25,palette,accent)
			banner(parent,cf*CFrame.new(0,21,0),palette)
			landmark(parent,cf,stage==6 and "tree" or "obelisk",palette,accent,1.4)
		end
	end
end

local function ravine(parent,origin,stage,palette,desert)
	local random=Random.new(stage*7529)
	local width=510
	local bed=CFrame.new(origin+V(0,-43,-290))
	block(parent,"Fundo do desfiladeiro",bed,0,0,0,width,10,810,palette.rock,M.Rock)
	local water=block(parent,desert and "Oásis subterrâneo" or "Rio da fenda",bed,0,5.4,0,width-4,1.1,806,desert and C(91,161,161) or C(49,122,129),M.Glass)
	water.Reflectance=0.12
	for _,side in {-1,1} do
		for i=0,12 do
			local z=63-i*61+random:NextNumber(-9,9)
			local high=random:NextNumber(48,93)
			local nearCrypt=(side==(stage%2==1 and 1 or -1)) and z < -150 and z > -360
			local x=side*((nearCrypt and 252 or 191)+random:NextNumber(-8,10))
			local cf=CFrame.new(origin+V(x,-42+high/2,z))*CFrame.Angles(0,random:NextNumber(-0.23,0.23),0)
			local tint=palette.rock:Lerp(palette.face,random:NextNumber(.06,.34))
			block(parent,"Falésia",cf,0,0,0,49,high,98,tint,M.Rock)
			block(parent,"Estrato",cf,-side*4,high*0.18,0,48,3.7,99,palette.face:Lerp(tint,0.65),M.Slate)
			block(parent,"Cornija natural",cf,0,high/2,0,53,4,99,palette.ground,desert and M.Sandstone or M.Grass)
			if i%2==1 then
				local upper=cf:PointToWorldSpace(V(-side*5,high/2,0))
				if desert then
					landmark(parent,CFrame.new(upper),"crystal",palette,palette.glow,2.7)
				else
					tree(parent,upper,2.6,palette)
				end
			end
			if i%3==1 and not desert then
				local fall=block(parent,"Cascata",cf,-side*26,0,10,0.6,high,7.8,C(122,210,212),M.Glass)
				fall.Transparency=.18
			end
		end
	end
	for _,z in {92,-675} do
		local high=z<0 and 91 or 54
		local cf=CFrame.new(origin+V(0,-42+high/2,z))
		for i=-2,2 do
			local h=high+random:NextNumber(-8,10)
			local x=i*73
			block(parent,"Escarpa",cf,x,0,0,76,h,46,palette.rock,M.Rock)
			block(parent,"Crista",cf,x,h/2,0,78,3,48,palette.ground,desert and M.Sandstone or M.Grass)
		end
	end
end

local function sanctuary(parent,pos,palette,accent,desert)
	local frame=CFrame.new(pos)*CFrame.new(0,0,-41)
	for _,side in {-1,1} do
		local tower=frame*CFrame.new(side*15,0,1)
		block(parent,"Torre da coroa",tower,0,19,0,7,38,8,palette.rock,M.Slate)
		block(parent,"Coroamento",tower,0,37.5,0,9,2.6,10,palette.crown,M.Limestone)
		gem(parent,tower*CFrame.new(0,41,0),accent,7)
	end
	arch(parent,frame,25,35,palette,accent)
	local center=frame:PointToWorldSpace(V(0,33,-3))
	for i=1,12 do
		local a,b=(i-1)*pi/6,i*pi/6
		local p=center+V(math.cos(a)*10,math.sin(a)*10,0)
		local q=center+V(math.cos(b)*10,math.sin(b)*10,0)
		strut(parent,"Astrolábio",p,q,1.35,1.35,palette.metal,M.Metal)
	end
	gem(parent,CFrame.new(center),accent,desert and 9 or 7)
end

function Dungeon.build(parent,origin,stageNumber)
	local desert=stageNumber>6
	local palette=desert and dunes or forest
	local accent=chapterAccents[stageNumber] or palette.glow
	local side=stageNumber%2==1 and 1 or -1
	local stretch=((stageNumber-1)%3)*8
	local entry=origin
	local one=origin+V(0,0,-116-stretch)
	local two=origin+V(side*(67+stretch),0,-259)
	local three=origin+V(-side*22,0,-423-stretch)
	local boss=origin+V(0,0,-583)
	local secret=two+V(side*112,0,6)
	local biome=desert and "Dunas" or "Bosque"
	local scene=Instance.new("Folder")
	scene.Name=biome.." • Fenda "..stageNumber
	scene.Parent=parent
	ravine(scene,origin,stageNumber,palette,desert)
	local nodes={
		{entry,23,{one},"entrance"}, {one,43,{entry,two},"nave"},
		{two,47,{one,three,secret},"gallery"}, {three,43,{two,boss},"cloister"},
		{boss,54,{three},"sanctum"}, {secret,19,{two},"vault"},
	}
	for _,room in nodes do
		chamber(scene,room[1],room[2],room[3],room[4],palette,accent,biome,stageNumber)
	end
	for i=1,4 do
		bridge(scene,nodes[i][1],nodes[i+1][1],nodes[i][2],nodes[i+1][2],palette,accent,false)
	end
	bridge(scene,two,secret,47,19,palette,accent,true)
	vault(scene,one,43,palette,accent,desert)
	signature(scene,boss,stageNumber,palette,accent)
	local vault=CFrame.lookAt(secret,two)
	brazier(scene,vault*CFrame.new(-6,0,-1),palette,1.1)
	brazier(scene,vault*CFrame.new(6,0,-1),palette,1.1)
	arch(scene,CFrame.new(entry)*CFrame.new(0,0,-13),16,24,palette,accent)
	sanctuary(scene,boss,palette,accent,desert)
	return {
		entry=entry, rooms={one,two,three}, boss=boss, secret=secret,
		routes={{one},{two},{three},{boss}},
	}
end

local function lodge(parent,cf,palette,roof)
	block(parent,"Fundação",cf,0,.6,0,14,1.2,12,palette.rock,M.Slate,true)
	block(parent,"Paredes de reboco",cf,0,4.4,0,12,7.4,10,palette.crown,M.Plaster,true)
	for _,x in {-5.8,5.8} do
		for _,z in {-4.9,4.9} do
			block(parent,"Enxaimel",cf,x,4.6,z,.7,7.7,.7,palette.rock,M.Wood)
		end
	end
	for _,side in {-1,1} do
		local cfRoof=cf*CFrame.new(side*3.6,9.9,0)*CFrame.Angles(0,0,-side*math.rad(31))
		part(parent,"Telhado de ardósia",cfRoof,V(9,1.2,14.2),roof,M.Slate)
		block(parent,"Janela iluminada",cf,side*4.1,4.8,5.1,1.9,2.5,.22,palette.flame,M.Neon)
		block(parent,"Travessa",cf,side*4.1,4.8,5.29,2.3,.28,.23,palette.rock,M.Wood)
	end
	block(parent,"Porta",cf,0,3.25,5.14,2.9,5.2,.45,palette.cloth,M.WoodPlanks)
	block(parent,"Chaminé",cf,-3,10.2,-2.5,2.3,6,2.1,palette.face,M.Brick)
	block(parent,"Cumeeira",cf,0,12,0,1,1,14.6,palette.metal,M.Metal)
end

function Dungeon.hub(parent,home)
	local palette=forest
	local scene=Instance.new("Folder")
	scene.Name="Santuário dos Domadores"
	scene.Parent=parent
	local base=CFrame.new(home)
	-- The village terraces form a skyline around the old clearing.
	disc(scene,"Terraço da vila",home-UP*5.5,55,10,palette.ground,M.Grass,true)
	disc(scene,"Escarpa do santuário",home-UP*16,53,19,palette.rock,M.Rock,true)
	for i=1,8 do
		local a=(i-.3)*pi/4
		local stone=home+V(math.cos(a)*44,-14,math.sin(a)*44)
		part(scene,"Afloramento",CFrame.new(stone)*CFrame.Angles(.12,a,.19),V(19,26,19),palette.rock,M.Rock,false,Enum.PartType.Ball)
	end
	local colors={C(61,101,118),C(82,132,114),C(168,99,74),C(93,111,143)}
	for i,offset in {V(-38,0,-21),V(38,0,-19),V(-33,0,26),V(32,0,27)} do
		local pos=home+offset
		lodge(scene,CFrame.lookAt(pos,pos+(pos-home).Unit),palette,colors[i])
	end
	for _,side in {-1,1} do
		tree(scene,home+V(side*32,0,-28),1.65,palette)
		tree(scene,home+V(side*47,-.2,8),1.35,palette)
	end
	local mosaic=V(0,0.09,0)
	disc(scene,"Pátio dos domadores",home+mosaic,20,0.15,palette.floor,M.Cobblestone)
	ring(scene,home+UP*0.22,18.8,palette.metal,0.42,18)
	for _,side in {-1,1} do
		brazier(scene,base*CFrame.new(side*7,0,-18),palette,0.85)
		local tower=base*CFrame.new(side*12,0,-23)
		block(scene,"Guarita",tower,0,5,0,4.8,10,5.2,palette.face,M.Limestone)
		block(scene,"Ameia",tower,0,10.1,0,6,1.5,6,palette.crown,M.Sandstone)
		banner(scene,tower*CFrame.new(0,9.1,2.8),palette)
		gem(scene,tower*CFrame.new(0,13,0),palette.glow,4)
		local canopy=base*CFrame.new(side*21,0,8)
		for _,z in {-4,4} do
			block(scene,"Esteio da tenda",canopy,0,3.5,z,0.75,7,0.75,palette.rock,M.Wood)
		end
		for _,slope in {-1,1} do
			part(scene,"Toldo",canopy*CFrame.new(slope*2.4,7.5,0)*CFrame.Angles(0,0,-slope*math.rad(18)),V(5.1,0.6,10),palette.cloth,M.Fabric)
		end
	end
	-- The interactable coffer and post occupy these stations in both Edit and Play.
	local coffer=base*CFrame.new(-13,0,7)
	part(scene,"Tampa abaulada",coffer*CFrame.new(0,3,0),V(4.2,1.65,3.05),C(160,103,48),M.WoodPlanks,false,Enum.PartType.Ball)
	for _,side in {-1,1} do
		block(scene,"Cinta do cofre",coffer,side*1.42,1.62,0,.37,3.3,3.12,palette.rock,M.Metal)
		block(scene,"Dobradura",coffer,side*1.42,3.34,0,.45,.39,2.65,palette.metal,M.Metal)
	end
	block(scene,"Fechadura",coffer,0,2.22,1.58,.82,1.02,.19,palette.rock,M.Metal)
	gem(scene,coffer*CFrame.new(0,2.2,1.76),palette.flame,.5)
	local training=base*CFrame.new(13,0,7)
	block(scene,"Trave do boneco",training,0,3.6,0,5.8,.72,.75,C(143,99,63),M.WoodPlanks)
	part(scene,"Cabeça de palha",training*CFrame.new(0,4.8,0),V(2.1,2.2,2.1),C(212,177,96),M.Fabric,false,Enum.PartType.Ball)
	for _,y in {1.1,2.3} do
		block(scene,"Corda do poste",training,0,y,0,3.1,.24,3.1,C(210,177,118),M.Fabric)
	end
	local swirl=base*CFrame.new(0,3.1,-22.7)
	for i=1,13 do
		local a=i*2*pi/13
		local mote=swirl*CFrame.new(math.sin(a)*3.35,math.cos(a)*2.93,0.45+math.sin(2*a)*.18)*CFrame.Angles(0,0,-a)
		part(scene,"Filamento da fenda",mote,V(.2,.66,.23),palette.glow,M.Neon)
	end
	arch(scene,base*CFrame.new(0,0,-24.6),19,18,palette,palette.glow)
end

return Dungeon
