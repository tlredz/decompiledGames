local TextUtil = {}
require(game.ReplicatedStorage.Util.RichText.ColorPalette)
local RichText = require(game.ReplicatedStorage.Util.RichText)

function TextUtil.toRoman(p: number)
	local v = {
		"I",
		"II",
		"III",
		"IV",
		"V"
	}
	return v[p] or p == 0 and v[1] or v[#v]
end

function TextUtil.separateWordsInPascalCase(value: string)
	local v = value:gsub("%s+", "")
	local v2 = ""

	for i = 1, #v do
		local v3 = v:sub(i, i)

		if i > 1 and v3:match("%u") then
			v2 ..= " "
		end

		v2 ..= v3
	end

	return v2
end

function TextUtil.notifColor(p: string, p2)
	if RichText.ColorShortcuts[p2] then
		return (`<Color={p2}>{p}<Color=/>`)
	end

	warn((`No color shortcut for {p2}`))
	return p
end

function TextUtil.richColor(value: string, value2)
	local color = nil

	if typeof(value2) == "Color3" then
		color = value2
	elseif typeof(value2) == "string" then
		if value2:sub(1, 1) == "#" then
			color = Color3.fromHex(value2)
		else
			color = RichText.ColorShortcuts[value2]

			if not color then
				warn((`No shortcut found for {value2}`))
			end
		end
	end

	assert(color, (`Color not passed: {value2}`))
	local formatted = `<font color="#{color:ToHex():upper()}">`

	for k, v in pairs({
		["<"] = "&lt;",
		[">"] = "&gt;"
	}) do
		value = value:gsub(k, v)
	end

	return (`{formatted}{value}</font>`)
end

function TextUtil.sanitizeStringForSave(value: string?)
	if not value then
		return nil
	end

	local v = ""

	for i = 1, string.len(value) do
		local v2 = value:sub(i, i)
		local v3 = string.byte(v2)

		if v3 < 32 or v3 > 127 then
			v ..= ""
		else
			v ..= v2
		end
	end

	return v
end

function TextUtil.stripSpecialCharacters(value: string)
	return value:gsub("[^%w%s_]+", ""):gsub(" ", "")
end

function TextUtil.commaValue(p: number)
	local v = tostring(p)

	repeat
		local v2
		v, v2 = string.gsub(v, "^(-?%d+)(%d%d%d)", "%1,%2")
	until v2 == 0

	return v
end

local v = {
	"K",
	"M",
	"B",
	"T"
}

function TextUtil.shortValue(p: number, value: number?)
	local formatted = ("%%.%df"):format(value or 2)

	if not p then
		return (tostring(0))
	end

	if p >= 1000000000000 then
		return formatted:format(p / 1000000000000) .. "T"
	end

	if p >= 1000000000 then
		return formatted:format(p / 1000000000) .. "B"
	end

	if p >= 1000000 then
		return formatted:format(p / 1000000) .. "M"
	end

	if p >= 1000 then
		return formatted:format(p / 1000) .. "K"
	end

	return (tostring(p))
end

function TextUtil.longValue(p)
	local v2 = tonumber(p)

	if v2 then
		return v2
	end

	local v3 = tostring(p)
	local v4 = tonumber((string.sub(v3, 1, -2)))
	local v5 = string.sub(v3, -1)
	local index = table.find(v, v5)
	return assert(v4) * 10 ^ (3 * assert(index))
end

return TextUtil