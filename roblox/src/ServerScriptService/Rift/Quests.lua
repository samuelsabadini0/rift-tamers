local Quests={}
local tasks={
	{"kills","Derrote 60 inimigos",60},{"wins","Vença 3 fendas",3},{"skills","Use 15 habilidades",15},
	{"captures","Capture 2 chefes",2},{"bank","Recolha o cofre 3 vezes",3},{"train","Treine 3 níveis",3},
	{"elite","Derrube 3 elites",3},{"perfect","Faça uma captura perfeita",1},
}
function Quests.list(d,now)
	local day=math.floor(now/86400)
	if d.questDay~=day then d.questDay=day d.quests={} end
	local list={}
	for i=0,2 do
		local row=tasks[(day+i*3)%#tasks+1]
		local n=d.quests[row[1]] or 0
		table.insert(list,{id=row[1],title=row[2],goal=row[3],count=n,done=n>=row[3]})
	end
	return list
end
function Quests.advance(d,event,income)
	local list=Quests.list(d,os.time())
	for _,q in list do
		if q.id==event and not q.done then
			d.quests[event]=q.count+1
			if d.quests[event]==q.goal then
				d.gold+=math.floor(300*income)
				d.gems+=10
				local completed=true
				for _,other in list do if other.id~=event and not other.done then completed=false end end
				if completed then d.gems+=10 end
			end
			return true
		end
	end
	return false
end
return Quests
