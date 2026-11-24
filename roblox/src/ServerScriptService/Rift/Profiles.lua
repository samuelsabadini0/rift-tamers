local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Profiles = {}
local store
if game.GameId ~= 0 then
	store = DataStoreService:GetDataStore(RunService:IsStudio() and "RiftTamers_Playtest_1" or "RiftTamers_1")
end

function Profiles.new()
	return {version=1, starter="", gold=0, gems=0, fragments=0, bank=0, level=1, xp=0, stars=1,
		slots=4,fountain=0,specimens={},speciesStars={},large=0,master=0,supreme=0, quests={},questDay=0,ascension=0, stage=1, difficulty=1, unlocked=1, collection={}, equipped={}, lair={},
		cleared={}, marks={}, dailyDay=0, dailyCount=0, wins=0, lastSeen=os.time()}
end
function Profiles.open(userId,backend)
	backend=backend or store
	local token=HttpService:GenerateGUID(false)
	local data = Profiles.new()
	if not backend then return data, false, "Sessão local" end
	local locked = false
	local ok, result = pcall(function()
		return backend:UpdateAsync(tostring(userId), function(old)
			local now = os.time()
			if old and old.owner ~= token and (old.lease or 0)>now then
				locked=true
				return nil
			end
			old = old or data
			old.owner, old.lease=token,now+180
			return old
		end)
	end)
	if locked then return nil,false,"Seu progresso ainda está aberto em outro servidor." end
	if not ok or not result then
		if RunService:IsStudio() then return data,false,"Playtest em memória" end
		return nil,false,"Não foi possível carregar seu progresso. Tente entrar novamente."
	end
	for key,value in data do if result[key]==nil then result[key]=value end end
	return result,true,"Salvo"
end
function Profiles.save(userId,data,release,backend)
	backend=backend or store
	local copy=HttpService:JSONDecode(HttpService:JSONEncode(data))
	copy.lastSeen=os.time()
	copy.lease=release and 0 or os.time()+180
	local ok, result=pcall(function()
		return backend:UpdateAsync(tostring(userId),function(old)
			if not old or old.owner~=data.owner then return nil end
			return copy
		end)
	end)
	return ok and result~=nil
end
return Profiles
