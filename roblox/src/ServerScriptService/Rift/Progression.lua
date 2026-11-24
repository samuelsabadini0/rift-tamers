local Rules = require(game.ReplicatedStorage.Rift.Rules)
local stages = require(game.ReplicatedStorage.Rift.Campaign).stages
local Collection=require(script.Parent.Collection)
local P = {}
function P.power(d)
	local base = (d.unlocked>=7 and 60 or 12)*(1+0.2*(d.stars-1))
	for _,index in d.equipped do base += stages[index].basePower*(1+.2*(Collection.star(d,index)-1)) end
	return base*(1+0.08*(d.level-1))
end
function P.income(d,fighting)
	local value = 0
	local copies={}
	for _,index in d.lair do
		copies[index]=(copies[index] or 0)+1
		local group=d.specimens[tostring(index)]
		local record=group and group[copies[index]]
		local efficiency=fighting and copies[index]==1 and table.find(d.equipped,index) and .25 or 1
		value+=efficiency*stages[index].income*(record and record.mult or 1)*(1+.1*(Collection.star(d,index)-1))
	end
	return value*2^d.ascension*(1+.1*d.fountain)
end
function P.accrue(d,seconds,fighting)
	local rate=P.income(d,fighting)
	if rate>0 then d.bank=math.max(d.bank,math.min(d.bank+seconds*rate,P.income(d)*7200)) end
end
function P.difficulty(d,index,difficulty)
	if not stages[index] or index>d.unlocked then return false end
	local clear=d.cleared[tostring(index)] or 0
	return difficulty==1 or difficulty==2 and clear>=1 or difficulty==3 and clear>=2 and (d.cleared[index<=6 and "6" or "12"] or 0)>0
end
function P.capture(d,index,rank,caught)
	local stage,key=stages[index],tostring(index)
	local first=d.wins==0
	local gold=first and 500 or math.floor(stage.income*60*1.5^(rank-1))
	d.gold+=gold
	d.fragments+=first and 10 or math.floor(stage.fragments*1.5^(rank-1))
	if not d.cleared[key] then d.gems+=stage.king and 50 or 10 end
	d.cleared[key]=math.max(rank,d.cleared[key] or 0)
	d.unlocked=math.max(d.unlocked,math.min(#stages,index+1))
	d.wins+=1
	if caught then
		if not d.collection[key] then d.gems+=5 end
		d.collection[key]=(d.collection[key] or 0)+1
		d.marks[key]=nil
		if #d.equipped<2 and not table.find(d.equipped,index) then table.insert(d.equipped,index) end
	else d.marks[key]=(d.marks[key] or 0)+1 end
	return gold
end
function P.equip(d,index)
	if not d.collection[tostring(index)] then return end
	local found=table.find(d.equipped,index)
	if found then table.remove(d.equipped,found)
	else
		if #d.equipped==2 then table.remove(d.equipped,1) end
		table.insert(d.equipped,index)
	end
end
function P.train(d)
	local cost=Rules.price(d.level)
	if d.level>=100 or d.gold<cost then return false end
	d.gold-=cost
	d.level+=1
	return true
end
return P
