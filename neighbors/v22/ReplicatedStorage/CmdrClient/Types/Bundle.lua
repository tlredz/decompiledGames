game:GetService("ServerStorage")
game:GetService("ReplicatedStorage")
local Bundles = require(game.ReplicatedStorage.Assets.Data.Store.Bundles)
local Util = require(script.Parent.Parent.Shared.Util)
local v = {
	Transform = function(p)
		local v2 = {}

		for _, bundle in Bundles do
			table.insert(v2, (bundle.Name:gsub(" ", "_")))
		end

		return Util.MakeFuzzyFinder(v2)(p)
	end,
	Validate = function(list)
		return #list > 0, "No bundle with that name could be found."
	end,
	Autocomplete = function(p)
		return Util.GetNames(p)
	end,
	Parse = function(list)
		return list[1]
	end,
	Default = function(_)
		return "Valentines_Bundle"
	end,
	ArgumentOperatorAliases = {
		all = "*",
		random = "?"
	}
}
return function(registry)
	registry:RegisterType("bundle", v)
	registry:RegisterType("bundles", Util.MakeListableType(v))
end