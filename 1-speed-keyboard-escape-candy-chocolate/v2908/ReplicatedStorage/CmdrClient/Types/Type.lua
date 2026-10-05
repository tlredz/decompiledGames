local Util = require(script.Parent.Parent.Shared.Util)
return function(registry)
	local v = {
		Transform = function(p)
			return Util.MakeFuzzyFinder(registry:GetTypeNames())(p)
		end,
		Validate = function(list)
			return #list > 0, "No type with that name could be found."
		end,
		Autocomplete = function(p)
			return p
		end,
		Parse = function(list)
			return list[1]
		end
	}
	registry:RegisterType("type", v)
	registry:RegisterType("types", Util.MakeListableType(v))
end