local Util = require(script.Parent.Parent.Shared.Util)
local v = {
	Validate = function(p)
		return p ~= nil
	end,
	Parse = function(p)
		return (tostring(p))
	end
}
local v2 = {
	Transform = function(p)
		return (tonumber(p))
	end,
	Validate = function(p)
		return p ~= nil
	end,
	Parse = function(p)
		return p
	end
}
local v3 = {
	Transform = function(p)
		return (tonumber(p))
	end,
	Validate = function(p)
		return p ~= nil and p == math.floor(p), "Only whole numbers are valid."
	end,
	Parse = function(p)
		return p
	end
}
local v4 = {
	Transform = function(p)
		return (tonumber(p))
	end,
	Validate = function(p)
		return p ~= nil and p == math.floor(p) and p > 0, "Only positive whole numbers are valid."
	end,
	Parse = function(p)
		return p
	end
}
local v5 = {
	Transform = function(p)
		return (tonumber(p))
	end,
	Validate = function(p)
		return p ~= nil and p == math.floor(p) and p >= 0, "Only non-negative whole numbers are valid."
	end,
	Parse = function(p)
		return p
	end
}
local v6 = {
	Transform = function(p)
		return (tonumber(p))
	end,
	Validate = function(p)
		return p ~= nil and p == math.floor(p) and p >= 0 and p <= 255, "Only bytes are valid."
	end,
	Parse = function(p)
		return p
	end
}
local v7 = {
	Transform = function(p)
		return (tonumber(p))
	end,
	Validate = function(p)
		return p ~= nil and p == math.floor(p) and p >= 0 and p <= 9, "Only digits are valid."
	end,
	Parse = function(p)
		return p
	end
}
local dictionary = Util.MakeDictionary({
	"true",
	"t",
	"yes",
	"y",
	"on",
	"enable",
	"enabled",
	"1",
	"+"
})
local dictionary2 = Util.MakeDictionary({
	"false",
	"f",
	"no",
	"n",
	"off",
	"disable",
	"disabled",
	"0",
	"-"
})
local v8 = {
	Transform = function(value)
		return value:lower()
	end,
	Validate = function(p)
		return dictionary[p] ~= nil or dictionary2[p] ~= nil, "Please use true/yes/on or false/no/off."
	end,
	Parse = function(p)
		if dictionary[p] then
			return true
		end

		if dictionary2[p] then
			return false
		end

		return nil
	end
}
return function(registry)
	registry:RegisterType("string", v)
	registry:RegisterType("number", v2)
	registry:RegisterType("integer", v3)
	registry:RegisterType("positiveInteger", v4)
	registry:RegisterType("nonNegativeInteger", v5)
	registry:RegisterType("byte", v6)
	registry:RegisterType("digit", v7)
	registry:RegisterType("boolean", v8)
	registry:RegisterType("strings", Util.MakeListableType(v))
	registry:RegisterType("numbers", Util.MakeListableType(v2))
	registry:RegisterType("integers", Util.MakeListableType(v3))
	registry:RegisterType("positiveIntegers", Util.MakeListableType(v4))
	registry:RegisterType("nonNegativeIntegers", Util.MakeListableType(v5))
	registry:RegisterType("bytes", Util.MakeListableType(v6))
	registry:RegisterType("digits", Util.MakeListableType(v7))
	registry:RegisterType("booleans", Util.MakeListableType(v8))
end