game:GetService("ServerStorage")
game:GetService("ReplicatedStorage")
local WeeklyStore = require(game.ReplicatedStorage.Assets.Data.WeeklyStore)
local Util = require(script.Parent.Parent.Shared.Util)
local v = {
	Transform = function(p)
		local v2 = {}

		for k in WeeklyStore.EventBanners do
			table.insert(v2, (k:gsub(" ", "_")))
		end

		return Util.MakeFuzzyFinder(v2)(p)
	end,
	Validate = function(list)
		return #list > 0, "No banner with that name could be found."
	end,
	Autocomplete = function(p)
		return Util.GetNames(p)
	end,
	Parse = function(list)
		return list[1]
	end,
	Default = function(_)
		return "Halloween"
	end,
	ArgumentOperatorAliases = {
		all = "*",
		random = "?"
	}
}
return function(registry)
	registry:RegisterType("banner", v)
	registry:RegisterType("banners", Util.MakeListableType(v))
end