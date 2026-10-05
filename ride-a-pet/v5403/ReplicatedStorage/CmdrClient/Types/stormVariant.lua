local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gameData = ReplicatedStorage:WaitForChild("GameData")
local Weather = require(gameData:WaitForChild("Weather"))
local Mutations = require(gameData:WaitForChild("Mutations"))

local function GetUtil()
	local cmdrClient = ReplicatedStorage:FindFirstChild("CmdrClient")

	if cmdrClient and cmdrClient:FindFirstChild("Shared") then
		return require(cmdrClient.Shared:WaitForChild("Util"))
	end

	local parent = script.Parent

	while parent do
		local shared = parent:FindFirstChild("Shared")

		if shared and shared:FindFirstChild("Util") then
			return require(shared.Util)
		else
			parent = parent.Parent
		end
	end

	error("[stormVariant] could not locate Cmdr's Util module")
end

return function(registry)
	local util = GetUtil()
	local v2 = {}
	local v3 = {}
	local stormRarity = Weather.StormRarity

	if type(stormRarity) == "table" then
		for k in stormRarity do
			if v3[k] then
				continue
			end

			v3[k] = true
			table.insert(v2, k)
		end
	end

	for k, mutation in Mutations do
		if type(mutation) ~= "table" or not mutation.WeatherName or v3[k] then
			continue
		end

		v3[k] = true
		table.insert(v2, k)
	end

	if type(Weather.Data) == "table" then
		for k in Weather.Data do
			if type(k) ~= "string" or v3[k] then
				continue
			end

			v3[k] = true
			table.insert(v2, k)
		end
	end

	table.sort(v2)
	local fuzzyFinder = util.MakeFuzzyFinder(v2)
	registry:RegisterType("stormVariant", {
		Transform = function(p)
			return fuzzyFinder(p)
		end,
		Validate = function(list)
			return
				#list > 0,
				"Unknown weather - storms are Thunder, Volt, Raging, Dreadful, Eternal (or the mutation name: Shocked, Volted, Rage, Void, Eternal); other weathers come from GameData.Weather.Data."
		end,
		Autocomplete = function(p)
			return p
		end,
		Parse = function(list)
			return list[1]
		end
	})
end