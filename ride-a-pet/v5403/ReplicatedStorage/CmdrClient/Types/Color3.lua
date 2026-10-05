local Util = require(script.Parent.Parent.Shared.Util)
local sequenceType = Util.MakeSequenceType({
	Prefixes = "# hexColor3 ! brickColor3",
	ValidateEach = function(p, p2)
		if p == nil then
			return false, ("Invalid or missing number at position %d in Color3 type."):format(p2)
		end

		if p < 0 or p > 255 then
			return false, ("Number out of acceptable range 0-255 at position %d in Color3 type."):format(p2)
		end

		if p % 1 == 0 then
			return true
		end

		return false, ("Number is not an integer at position %d in Color3 type."):format(p2)
	end,
	TransformEach = tonumber,
	Constructor = Color3.fromRGB,
	Length = 3
})

local function parseHexDigit(list)
	if #list == 1 then
		list ..= list
	end

	return (tonumber(list, 16))
end

local v = {
	Transform = function(value)
		local match, v2, v3 = value:match("^#?(%x%x?)(%x%x?)(%x%x?)$")
		return Util.Each(parseHexDigit, match, v2, v3)
	end,
	Validate = function(p, p2, p3)
		return p ~= nil and p2 ~= nil and p3 ~= nil, "Invalid hex color"
	end,
	Parse = function(...)
		return Color3.fromRGB(...)
	end
}
return function(registry)
	registry:RegisterType("color3", sequenceType)
	registry:RegisterType("color3s", Util.MakeListableType(sequenceType, {
		Prefixes = "# hexColor3s ! brickColor3s"
	}))
	registry:RegisterType("hexColor3", v)
	registry:RegisterType("hexColor3s", Util.MakeListableType(v))
end