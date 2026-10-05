local Teams = game:GetService("Teams")
local Util = require(script.Parent.Parent.Shared.Util)
local v = {
	Transform = function(p)
		return Util.MakeFuzzyFinder(Teams:GetTeams())(p)
	end,
	Validate = function(list)
		return #list > 0, "No team with that name could be found."
	end,
	Autocomplete = function(p)
		return Util.GetNames(p)
	end,
	Parse = function(list)
		return list[1]
	end
}
local v2 = {
	Listable = true,
	Transform = v.Transform,
	Validate = v.Validate,
	Autocomplete = v.Autocomplete,
	Parse = function(list)
		return list[1]:GetPlayers()
	end
}
local v3 = {
	Transform = v.Transform,
	Validate = v.Validate,
	Autocomplete = v.Autocomplete,
	Parse = function(list)
		return list[1].TeamColor
	end
}
return function(registry)
	registry:RegisterType("team", v)
	registry:RegisterType("teams", Util.MakeListableType(v))
	registry:RegisterType("teamPlayers", v2)
	registry:RegisterType("teamColor", v3)
	registry:RegisterType("teamColors", Util.MakeListableType(v3))
end