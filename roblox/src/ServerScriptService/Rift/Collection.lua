local stages=require(game.ReplicatedStorage.Rift.Campaign).stages
local C={}
local sizes={{"Mini",.8,20},{"Normal",1,60},{"Grande",1.5,14},{"Gigante",2,5},{"Titânico",3,1}}
local mutations={{"Cósmico",12,.02},{"Eclipse",8,.10},{"Arco-íris",5,.5},{"Cristal",3,2},{"Dourado",2,5}}
local rng=Random.new()
local function pick(rows,roll,backup)
	for _,row in rows do
		roll-=row[3]
		if roll<=0 then return row end
	end
	return backup
end
function C.specimen(d,index,variant,name)
	local size=pick(sizes,rng:NextNumber(d.wins==0 and 20.001 or 0,100),sizes[2])
	local mutation=pick(mutations,rng:NextNumber(0,index==math.floor(os.time()/86400)%12+1 and 50 or 100),{"Normal",1})
	local rate=({Alfa=1000,Ancestral=5000,Secreto=25000})[variant]
	local mult=size[2]*mutation[2]*(rate and rate*(index>6 and 10 or 1)/stages[index].income or 1)
	return {name=name or stages[index].boss,size=size[1],mutation=mutation[1],variant=variant,mult=mult}
end
function C.add(d,index,record)
	local key=tostring(index)
	local list=d.specimens[key] or {}
	d.specimens[key]=list
	table.insert(list,record)
	table.sort(list,function(a,b) return a.mult>b.mult end)
end
function C.star(d,index) return d.speciesStars[tostring(index)] or 1 end
function C.fuse(d,index)
	local key=tostring(index)
	local level=C.star(d,index)
	local price=2^(level-1)
	if level>=5 or (d.collection[key] or 0)<=price then return false end
	d.collection[key]-=price
	d.speciesStars[key]=level+1
	local list=d.specimens[key] or {}
	while #list>d.collection[key] do table.remove(list) end
	local assigned=0
	for i=#d.lair,1,-1 do
		if d.lair[i]==index then
			assigned+=1
			if assigned>d.collection[key] then table.remove(d.lair,i) end
		end
	end
	return true
end
function C.style(model,record)
	if not record then return end
	local scale=({Mini=.8,Grande=1.15,Gigante=1.3,["Titânico"]=1.55})[record.size]
	if scale then model:ScaleTo(model:GetScale()*scale) end
	local tint=({Dourado="FFD65E",Cristal="83F0FC",Eclipse="9063D7",["Arco-íris"]="FF85CF",["Cósmico"]="729CFF"})[record.mutation]
	if tint then
		for _,part in model:GetChildren() do
			if part:IsA("BasePart") then part.Color=part.Color:Lerp(Color3.fromHex(tint),.65) end
		end
		local spark=Instance.new("Sparkles")
		spark.SparkleColor=Color3.fromHex(tint)
		spark.Parent=model.PrimaryPart
	end
end
return C
