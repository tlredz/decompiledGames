local Util = require(script.Parent.Parent.Shared.Util)
local v = {
	Validate = function(value)
		if value:match("^https?://.+$") then
			return true
		end

		return false, "URLs must begin with http:// or https://"
	end,
	Parse = function(p)
		return p
	end
}
return function(registry)
	registry:RegisterType("url", v)
	registry:RegisterType("urls", Util.MakeListableType(v))
end