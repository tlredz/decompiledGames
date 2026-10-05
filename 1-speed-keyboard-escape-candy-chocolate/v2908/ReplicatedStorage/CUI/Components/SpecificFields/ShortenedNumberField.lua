local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Numbers = require(ReplicatedStorage.Utilities.Numbers)
local Suffixes = require(ReplicatedStorage.Utilities.Numbers.Suffixes)
local FieldValueUtils = require(script.Parent.FieldValueUtils)
local v = {}

for _, SUFFIX in Suffixes.SUFFIXES do
	v[string.lower(SUFFIX[2])] = SUFFIX[1]
end

local function ParseShortenedNumber(value: string)
	local v2 = string.gsub(value, "[%s,_]", "")
	local v3 = tonumber(v2)

	if v3 ~= nil then
		return v3
	end

	local v4, v5 = string.match(v2, "^([%+%-]?%d*%.?%d+)([%a]+)$")
	local v6 = v5 and v[string.lower(v5)]
	local v7 = v4 and tonumber(v4)

	if v7 == nil or v6 == nil then
		return nil
	end

	return v7 * v6
end

return function(_, _, object)
	local extended = object:extend("ShortenedNumberField")

	function extended.TextToValue(object2, p: string)
		if p == object2.CurText and object2:GetValue() ~= nil then
			return object2:GetValue()
		end

		return ParseShortenedNumber(p) or object2:GetValue() or 0
	end

	function extended.ValueToText(_, p: number)
		local v2 = tonumber(p) or 0

		if math.abs(v2) < 1000 then
			return FieldValueUtils.FormatNumber(v2)
		end

		return (v2 < 0 and "-" or "") .. Numbers.formatNumber((math.abs(v2)))
	end

	function extended:SetNumberFilter(value: number?, value2: number?)
		function self.Filter(p)
			return (tostring((math.clamp(
				ParseShortenedNumber(p) or self:GetValue() or 0,
				value or -1e999,
				value2 or 1e999
			))))
		end

		return self
	end

	return extended
end