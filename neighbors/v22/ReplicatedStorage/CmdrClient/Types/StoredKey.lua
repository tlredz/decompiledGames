local Util = require(script.Parent.Parent.Shared.Util)
local v = {
	"^%a[%w_]*$",
	"^%$%a[%w_]*$",
	"^%.%a[%w_]*$",
	"^%$%.%a[%w_]*$"
}
return function(registry)
	local v2 = {
		Autocomplete = function(p)
			return registry.Cmdr.Util.MakeFuzzyFinder(registry.Cmdr.Util.DictionaryKeys(registry:GetStore("vars_used") or {}))(p)
		end,
		Validate = function(value)
			for _, v3 in ipairs(v) do
				if value:match(v3) then
					return true
				end
			end

			return false, "Key names must start with an optional modifier: . $ or $. and must begin with a letter."
		end,
		Parse = function(p)
			return p
		end
	}
	registry:RegisterType("storedKey", v2)
	registry:RegisterType("storedKeys", Util.MakeListableType(v2))
end