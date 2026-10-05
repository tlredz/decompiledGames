game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.Assets.Data.Store.Items)
local Util = require(script.Parent.Parent.Shared.Util)
local v = {
	Transform = function(p)
		local v2 = {}

		for _, item in Items do
			table.insert(v2, (item.Display:gsub(" ", "_")))
		end

		return Util.MakeFuzzyFinder(v2)(p)
	end,
	Validate = function(list)
		return #list > 0, "No tool with that name could be found."
	end,
	Autocomplete = function(p)
		return Util.GetNames(p)
	end,
	Parse = function(list)
		return list[1]
	end,
	Default = function(_)
		return "Bloxy_Cola"
	end,
	ArgumentOperatorAliases = {
		all = "*",
		random = "?"
	}
}
return function(registry)
	registry:RegisterType("tool", v)
	registry:RegisterType("tools", Util.MakeListableType(v))
end