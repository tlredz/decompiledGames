local Util = require(script.Parent.Parent.Shared.Util)
local Players = game:GetService("Players")

local function GetDisplayNamePair(items)
	local result = {}

	for _, item in items do
		table.insert(result, (`{item.DisplayName} @{item.Name}`))
	end

	return result
end

local v = {
	Transform = function(p)
		local result = Util.MakeFuzzyFinder(Players:GetPlayers())(p)

		if result and #result ~= 0 then
			return result
		end

		local displayNamePair = GetDisplayNamePair(Players:GetPlayers())
		local v3 = Util.MakeFuzzyFinder(displayNamePair)(p)
		result = {}

		for _, v4 in v3 do
			table.insert(result, Players:FindFirstChild(v4:split("@")[2]))
		end

		return result
	end,
	Validate = function(list)
		return #list > 0, "No player with that name could be found."
	end,
	Autocomplete = function(p)
		return (GetDisplayNamePair(p))
	end,
	Parse = function(list)
		return list[1]
	end,
	Default = function(p)
		return p.Name
	end,
	ArgumentOperatorAliases = {
		me = ".",
		all = "*",
		others = "**",
		random = "?"
	}
}
return function(registry)
	registry:RegisterType("player", v)
	registry:RegisterType("players", Util.MakeListableType(v, {
		Prefixes = "% teamPlayers"
	}))
end