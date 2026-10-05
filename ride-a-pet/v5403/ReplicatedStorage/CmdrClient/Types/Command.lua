local Util = require(script.Parent.Parent.Shared.Util)
return function(registry)
	local v = {
		Transform = function(p)
			return Util.MakeFuzzyFinder(registry:GetCommandNames())(p)
		end,
		Validate = function(list)
			return #list > 0, "No command with that name could be found."
		end,
		Autocomplete = function(p)
			return p
		end,
		Parse = function(list)
			return list[1]
		end
	}
	registry:RegisterType("command", v)
	registry:RegisterType("commands", Util.MakeListableType(v))
end