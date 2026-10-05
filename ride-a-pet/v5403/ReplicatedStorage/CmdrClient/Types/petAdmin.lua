local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Pets = require(ReplicatedStorage.GameData.Pets)
local Mutations = require(ReplicatedStorage.GameData.Mutations)

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

	error("Cmdr Util is unavailable")
end

return function(registry)
	local util = GetUtil()
	local v2 = {}
	local v3 = { "None" }
	local v4 = {
		None = true
	}
	local v5 = { "None" }

	for k, pet in pairs(Pets) do
		if not (type(k) == "string" and type(pet) == "table") then
			continue
		end

		table.insert(v2, k)
	end

	for k, mutation in pairs(Mutations) do
		if type(mutation) ~= "table" then
			continue
		end

		if Mutations.IsSpawned(k) then
			table.insert(v3, k)
		elseif mutation.WeatherName then
			for _, v6 in ipairs({ k, mutation.WeatherName }) do
				if v4[v6] then
					continue
				end

				v4[v6] = true
				table.insert(v5, v6)
			end
		elseif mutation.Source and not v4[k] then
			v4[k] = true
			table.insert(v5, k)
		end
	end

	table.sort(v2)
	table.sort(v3)
	table.sort(v5)
	registry:RegisterType("petName", util.MakeEnumType("pet", v2))
	registry:RegisterType("petSpawnMutation", util.MakeEnumType("hatch mutation", v3))
	registry:RegisterType("petWeatherTrait", util.MakeEnumType("weather trait", v5))
	registry:RegisterType("petDestination", util.MakeEnumType("pet destination", { "base", "inventory" }))
end