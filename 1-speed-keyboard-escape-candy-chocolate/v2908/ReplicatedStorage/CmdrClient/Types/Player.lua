local Util = require(script.Parent.Parent.Shared.Util)
local Players = game:GetService("Players")
local v = {
	Transform = function(p)
		return Util.MakeFuzzyFinder(Players:GetPlayers())(p)
	end,
	Validate = function(list)
		return #list > 0, "No player with that name could be found."
	end,
	Autocomplete = function(p)
		return Util.GetNames(p)
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