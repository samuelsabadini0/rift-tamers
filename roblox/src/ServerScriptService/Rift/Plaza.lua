-- Social market. All eight spokes meet a continuous ring street.
local Plaza={}
local V=Vector3.new
local RGB=Color3.fromRGB
local M=Enum.Material
local UP=Vector3.yAxis
local RADIUS=150
local SQUARE=48
local PLOT=55
local base=V(0,42,0)
local stone=RGB(109,132,129)
local ivory=RGB(211,207,170)
local slate=RGB(66,82,93)
local brass=RGB(209,166,84)
local jade=RGB(61,153,141)
local water=RGB(105,217,211)
local colors={
	RGB(46,139,127),RGB(217,124,87),RGB(80,141,176),RGB(149,121,160),
	RGB(217,162,69),RGB(94,145,98),RGB(174,104,119),RGB(82,131,164),
}

local function part(parent,name,cf,size,tint,mat,solid,shape)
	local p=Instance.new("Part")
	p.Name,p.Size,p.CFrame=name,size,cf
	p.Color,p.Material=tint,mat
	p.Anchored,p.CanCollide,p.CanQuery,p.CanTouch=true,solid==true,solid==true,false
	p.TopSurface,p.BottomSurface=Enum.SurfaceType.Smooth,Enum.SurfaceType.Smooth
	if shape then p.Shape=shape end
	p.Parent=parent
	return p
end

local function block(parent,name,cf,x,y,z,w,h,d,tint,mat,solid)
	return part(parent,name,cf*CFrame.new(x,y,z),V(w,h,d),tint,mat,solid)
end

local function round(parent,name,pos,r,h,color,mat,solid)
	return part(parent,name,CFrame.new(pos)*CFrame.Angles(0,0,math.pi/2),V(h,2*r,2*r),color,mat,solid,Enum.PartType.Cylinder)
end

local function spoke(slot)
	local angle=(slot-1)*math.pi/4
	return V(math.sin(angle),0,-math.cos(angle))
end

function Plaza.home(slot,offset)
	assert(slot%1==0 and slot>=1 and slot<=8,"Vaga de Toca fora da praça")
	return base+(offset or Vector3.zero)+spoke(slot)*RADIUS
end

local function crystal(parent,cf,size,color)
	for _,side in {-1,1} do
		local wedge=Instance.new("WedgePart")
		wedge.Name="Ponta de cristal"
		wedge.Size=V(.65,1,.6)*size
		wedge.CFrame=cf*CFrame.new(0,0,side*.3*size)*CFrame.Angles(0,side==1 and math.pi or 0,0)
		wedge.Material,wedge.Color=M.Neon,color
		wedge.CanCollide,wedge.CanQuery,wedge.CanTouch,wedge.Anchored=false,false,false,true
		wedge.Parent=parent
	end
end

local function bridge(parent,center,slot)
	local dir=spoke(slot)
	local start=center+dir*(SQUARE-1.1)
	local finish=center+dir*(RADIUS-PLOT+2)
	local cf=CFrame.lookAt((start+finish)/2,finish)
	local length=(finish-start).Magnitude
	block(parent,"Ponte para a Toca "..slot,cf,0,-2,0,15.8,4,length,stone,M.Cobblestone,true)
	for _,side in {-1,1} do
		block(parent,"Parapeito",cf,side*7.4,1.3,0,.88,2.6,length,ivory,M.Limestone,true)
		block(parent,"Corrimão",cf,side*7.4,2.8,0,1.13,.35,length,brass,M.Metal,true)
		for _,z in {-length*.42,length*.42} do
			block(parent,"Pilar da ponte",cf,side*7.3,-.8,z,2.15,9.6,2.15,slate,M.Slate)
			crystal(parent,cf*CFrame.new(side*7.3,5,z),2.6,colors[slot]:Lerp(Color3.new(1,1,1),.4))
		end
	end
	local stripe=colors[slot]
	for i=1,3 do
		block(parent,"Tessela da ala",cf,0,.04,length*(i-2)*.24,1.4,.08,3.8,stripe,M.Glass)
	end
end

local function canopy(parent,cf,tint)
	for _,side in {-1,1} do
		for _,z in {-2.8,2.8} do
			block(parent,"Esteio de madeira",cf,side*4.3,3.2,z,.52,6.4,.52,slate,M.Wood)
		end
	end
	for i=1,5 do
		local x=(i-3)*1.98
		local color=i%2==0 and ivory or tint
		local roof=cf*CFrame.new(x,6.4,0)*CFrame.Angles(math.rad(10),0,0)
		part(parent,"Lona listrada",roof,V(1.98,.4,7.7),color,M.Fabric)
		block(parent,"Sanefa",cf,x,5.48,3.75,1.98,.66,.25,color,M.Fabric)
	end
	block(parent,"Balcão",cf,0,1.1,1.5,8.7,2.2,2.2,RGB(138,96,63),M.WoodPlanks,true)
	for i=1,3 do
		local display=cf*CFrame.new((i-2)*2.5,2.75,1.5)
		part(parent,"Mercadoria",display,V(1.4,1.5,1.4),tint:Lerp(brass,i*.2),M.Glass,false,Enum.PartType.Ball)
	end
end

local function overlook(parent,cf)
	-- The ramp terminates flush with the deck. Rails leave the approach open.
	local rise,run=10,21
	local start=(cf*CFrame.new(0,0,run)).Position
	local finish=(cf*CFrame.new(0,rise,0)).Position
	local ramp=CFrame.lookAt((start+finish)/2,finish)
	part(parent,"Rampa do mirante",ramp*CFrame.new(0,-.36,0),V(6.5,.72,(finish-start).Magnitude+.8),stone,M.Cobblestone,true)
	for _,side in {-1,1} do
		part(parent,"Guarda-corpo",ramp*CFrame.new(side*3.2,1.3,0),V(.4,2.5,(finish-start).Magnitude),ivory,M.Limestone,true)
		block(parent,"Pilar do mirante",cf,side*4.4,rise/2,-5,2.2,rise,2.2,slate,M.Slate,true)
		block(parent,"Balaustrada",cf,side*5.4,rise+1.2,-4.6,.6,2.4,9.4,ivory,M.Limestone,true)
	end
	block(parent,"Terraço do mirante",cf,0,rise-.5,-4.6,11.6,1,9.8,stone,M.Cobblestone,true)
	block(parent,"Parapeito elevado",cf,0,rise+1.2,-9.3,11.5,2.4,.6,ivory,M.Limestone,true)
end

function Plaza.build(parent,offset)
	offset=offset or Vector3.zero
	local center=base+offset
	local name="Praça dos Domadores • "..tostring(offset)
	local existing=parent:FindFirstChild(name)
	if existing then
		assert(existing:GetAttribute("RiftMarket"),"Nome do mercado ocupado")
		return existing
	end
	local model=Instance.new("Folder")
	model.Name=name
	model:SetAttribute("RiftMarket",true)
	round(model,"Embasamento",center-UP*8,SQUARE-1,16,slate,M.Rock,true)
	round(model,"Praça de pedra",center-UP*1.5,SQUARE,3,stone,M.Cobblestone,true)
	round(model,"Ágora",center+UP*.045,32,.09,ivory,M.Limestone)
	for i=1,8 do
		bridge(model,center,i)
		-- Empty lots still have a lawn at the far end of the bridge.
		-- Occupied lots add their own raised player terrace over this foundation.
		local plot=Plaza.home(i,offset)
		round(model,"Lote "..i,plot-UP*4.8,55,8,RGB(99,140,99),M.Grass,true)
		local domain=CFrame.lookAt(plot,center)
		for _,side in {-1,1} do
			local pos=(domain*CFrame.new(side*18,-1,-38)).Position
			round(model,"Canteiro",pos,3.3,.5,ivory,M.Limestone)
			for bloom=1,3 do
				local a=bloom*2*math.pi/3
				part(model,"Lavanda",CFrame.new(pos+V(math.cos(a),1.4,math.sin(a))),V(1.6,2.2,1.4),colors[i],M.Grass,false,Enum.PartType.Ball)
			end
		end
		local angle=(i-.5)*math.pi/4
		local radial=V(math.sin(angle),0,-math.cos(angle))
		if i==2 then
			local centerDeck=center+radial*34
			overlook(model,CFrame.lookAt(centerDeck,centerDeck+radial))
		else
			local pos=center+radial*31
			canopy(model,CFrame.lookAt(pos,pos+radial),colors[i])
		end
	end
	-- Fountain and astronomical dial at the shared meeting point.
	round(model,"Borda da fonte",center+UP*.65,8.2,1.3,slate,M.Slate,true)
	round(model,"Água",center+UP*1.34,7.5,.12,water,M.Glass)
	round(model,"Peanha do astrolábio",center+UP*2.9,2.3,3.1,ivory,M.Limestone,true)
	for i=1,16 do
		local a=i*math.pi/8
		local frame=CFrame.new(center+UP*9)*CFrame.Angles(0,math.rad(27),math.rad(13))
		local r=4.1
		local here=frame:PointToWorldSpace(V(math.cos(a)*r,math.sin(a)*r,0))
		local prev=frame:PointToWorldSpace(V(math.cos(a-math.pi/8)*r,math.sin(a-math.pi/8)*r,0))
		part(model,"Órbita de latão",CFrame.lookAt((here+prev)/2,here),V(.4,.4,(here-prev).Magnitude+.12),brass,M.Metal)
	end
	crystal(model,CFrame.new(center+UP*8.7),4.2,jade:Lerp(water,.55))
	model.Parent=parent
	return model
end

return Plaza
