local PetsConfig = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
local PetConstants = require(ReplicatedStorage.Modules.Shared.Pets.PetConstants)
PetsConfig.remoteConfigDirectory = "Pets/Config"
PetsConfig.isPublic = true
PetsConfig.isLoaded = false
PetsConfig.cache = nil

function PetsConfig.GetConfig()
	while not PetsConfig.isLoaded do
		task.wait()
	end

	return PetsConfig.cache
end

function PetsConfig.FindEntry(p: string)
	if PetsConfig.cache == nil then
		return nil
	end

	local v = PetsConfig.cache[p]

	if typeof(v) == "table" and v.Name ~= nil then
		return v
	end

	return nil
end

function PetsConfig.GetPetTypesByCategory(p: string, p2)
	local config = PetsConfig.GetConfig()
	local result = {}

	for k, v in config do
		if not (typeof(v) == "table" and v.Category == p) then
			continue
		end

		if p2 ~= nil then
			local v2

			if PetsConfig.RequiresGamepass(v) == false then
				v2 = PetConstants.PetTier.Free
			else
				v2 = PetConstants.PetTier.Premium
			end

			if v2 ~= p2 then
				continue
			end
		end

		table.insert(result, k)
	end

	return result
end

function PetsConfig.RequiresGamepass(p)
	return p.Gamepass ~= nil and typeof(p.Gamepass) == "string"
end

function PetsConfig.GetRequiredGamepass(p)
	if p.Gamepass == nil or typeof(p.Gamepass) ~= "string" then
		return nil
	end

	return Gamepasses.All[p.Gamepass]
end

return PetsConfig