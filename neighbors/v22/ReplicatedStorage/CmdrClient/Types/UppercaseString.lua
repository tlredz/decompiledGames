local Util = require(script.Parent.Parent.Shared.Util)
local v = {
	Validate = function(value)
		return value ~= nil and value:upper() == value
	end,
	Parse = function(p)
		return tostring(p):upper()
	end
}
return function(registry)
	registry:RegisterType("upperstring", v)
	registry:RegisterType("upperstrings", Util.MakeListableType(v))
end