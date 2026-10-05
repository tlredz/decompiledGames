game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Skins = require(ReplicatedStorage.Assets.Data.Store.Skins)
local Util = require(script.Parent.Parent.Shared.Util)
local v = {
	Transform = function(p)
		local v2 = {}

		for _, skin in Skins do
			table.insert(v2, (skin.Display:gsub(" ", "_")))
		end

		return Util.MakeFuzzyFinder(v2)(p)
	end,
	Validate = function(list)
		return #list > 0, "No skin with that name could be found."
	end,
	Autocomplete = function(p)
		return Util.GetNames(p)
	end,
	Parse = function(list)
		return list[1]
	end,
	Default = function(_)
		return "Spiked_Bat"
	end,
	ArgumentOperatorAliases = {
		all = "*",
		random = "?"
	}
}
return function(registry)
	registry:RegisterType("skin", v)
	registry:RegisterType("skins", Util.MakeListableType(v))
end