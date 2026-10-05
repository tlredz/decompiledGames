local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Eggs = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Eggs"))

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

	error("[eggName] could not locate Cmdr's Util module")
end

return function(registry)
	local util = GetUtil()
	local v2 = {}

	for k, egg in Eggs do
		if not (type(k) == "string" and type(egg) == "table") then
			continue
		end

		table.insert(v2, k)
	end

	table.sort(v2)
	local fuzzyFinder = util.MakeFuzzyFinder(v2)
	registry:RegisterType("eggName", {
		Transform = function(p)
			return fuzzyFinder(p)
		end,
		Validate = function(list)
			return #list > 0, "No egg by that name in GameData.Eggs."
		end,
		Autocomplete = function(p)
			return p
		end,
		Parse = function(list)
			return list[1]
		end
	})
end