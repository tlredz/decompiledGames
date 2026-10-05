local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shop = require(ReplicatedStorage:WaitForChild("GameData"):WaitForChild("Shop"))

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

	error("[shopItem] could not locate Cmdr's Util module")
end

return function(registry)
	local util = GetUtil()
	local v2 = {}
	local v3 = {}

	for _, category in Shop.Categories do
		if type(category) ~= "table" then
			continue
		end

		for k, v4 in category do
			if type(k) ~= "string" or type(v4) ~= "table" or v2[k] then
				continue
			end

			v2[k] = true
			table.insert(v3, k)
		end
	end

	table.sort(v3)
	local fuzzyFinder = util.MakeFuzzyFinder(v3)
	registry:RegisterType("shopItem", {
		Transform = function(p)
			return fuzzyFinder(p)
		end,
		Validate = function(list)
			return #list > 0, "No shop item by that name - must be a radar, lantern or food in GameData.Shop."
		end,
		Autocomplete = function(p)
			return p
		end,
		Parse = function(list)
			return list[1]
		end
	})
end