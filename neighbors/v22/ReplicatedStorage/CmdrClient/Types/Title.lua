game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(script.Parent.Parent.Shared.Util)
local Titles = require(ReplicatedStorage.Assets.Data.Store.Titles)
local v = {
	Transform = function(p)
		local v2 = {}

		for _, title in Titles do
			table.insert(v2, (title.Display:gsub(" ", "_")))
		end

		return Util.MakeFuzzyFinder(v2)(p)
	end,
	Validate = function(list)
		return #list > 0, "No title with that name could be found."
	end,
	Autocomplete = function(p)
		return Util.GetNames(p)
	end,
	Parse = function(list)
		return list[1]
	end,
	Default = function(_)
		return "Troll"
	end,
	ArgumentOperatorAliases = {
		all = "*",
		random = "?"
	}
}
return function(registry)
	registry:RegisterType("title", v)
	registry:RegisterType("titles", Util.MakeListableType(v))
end