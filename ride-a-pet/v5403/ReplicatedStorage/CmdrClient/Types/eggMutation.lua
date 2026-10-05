local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Mutations = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Mutations"))

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

	error("[eggMutation] could not locate Cmdr's Util module")
end

return function(registry)
	local util = GetUtil()
	local v2 = { "None" }

	for k, mutation in Mutations do
		if not (type(mutation) == "table" and (mutation.WeatherName or mutation.Source or Mutations.IsSpawned(k))) then
			continue
		end

		table.insert(v2, k)
	end

	table.sort(v2)
	local fuzzyFinder = util.MakeFuzzyFinder(v2)
	local v3 = {
		Transform = function(p)
			return fuzzyFinder(p)
		end,
		Validate = function(list)
			return
				#list > 0,
				"Unknown mutation - eggs can carry Shocked, Volted, Rage, Void, Eternal, Magma, Gold, Diamond or Rainbow."
		end,
		Autocomplete = function(p)
			return p
		end,
		Parse = function(list)
			return list[1]
		end
	}
	registry:RegisterType("eggMutation", v3)
	registry:RegisterType("eggMutations", util.MakeListableType(v3))
end