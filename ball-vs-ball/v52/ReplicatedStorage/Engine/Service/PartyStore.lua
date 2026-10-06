local RunService = game:GetService("RunService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local hashMap = MemoryStoreService:GetHashMap("PartySystemV1")
local v = {}
local PartyStore = {}
local copy

copy = function(items)
	if type(items) ~= "table" then
		return items
	end

	local result = {}

	for k, item in items do
		result[k] = copy(item)
	end

	return result
end

function PartyStore.get(p)
	if not RunService:IsStudio() then
		return hashMap:GetAsync(p)
	end

	local v2 = v[p]

	if v2 and v2.expires > os.time() then
		return (copy(v2.value))
	end

	return nil
end

function PartyStore.set(p, p2, p3)
	if RunService:IsStudio() then
		v[p] = {
			value = copy(p2),
			expires = os.time() + p3
		}
	else
		hashMap:SetAsync(p, p2, p3)
	end
end

function PartyStore.update(p, callback, p2)
	if not RunService:IsStudio() then
		return hashMap:UpdateAsync(p, callback, p2)
	end

	local v2 = callback(PartyStore.get(p))

	if v2 ~= nil then
		PartyStore.set(p, v2, p2)
	end

	return v2
end

return PartyStore