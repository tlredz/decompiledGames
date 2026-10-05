local ColorPalette = require(game.ReplicatedStorage.Util.RichText.ColorPalette)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local v = {
	{
		v = 1000,
		s = "M"
	},
	{
		v = 900,
		s = "CM"
	},
	{
		v = 500,
		s = "D"
	},
	{
		v = 400,
		s = "CD"
	},
	{
		v = 100,
		s = "C"
	},
	{
		v = 90,
		s = "XC"
	},
	{
		v = 50,
		s = "L"
	},
	{
		v = 40,
		s = "XL"
	},
	{
		v = 10,
		s = "X"
	},
	{
		v = 9,
		s = "IX"
	},
	{
		v = 5,
		s = "V"
	},
	{
		v = 4,
		s = "IV"
	},
	{
		v = 1,
		s = "I"
	}
}
local v2 = {
	"I",
	"II",
	"III",
	"IV",
	"V",
	"VI",
	"VII",
	"VIII",
	"IX",
	"X",
	"XI",
	"XII"
}
local FormatUtil = {
	romanNumeral = function(p: number)
		assert(p == math.round(p), "roman numerals don't have decimals")
		assert(p > 0, "there is no roman numeral for 0")

		if v2[p] then
			return v2[p]
		end

		local v3 = ""

		for _, v4 in ipairs(v) do
			local v5 = v4.v
			local s = v4.s

			while v5 <= p do
				v3 ..= s
				p -= v5
			end
		end

		return v3
	end,
	arrowBracket = function(p: string, p2)
		local v4

		if typeof(p2) == "Color3" then
			v4 = p2:ToHex():upper()
		else
			v4 = ColorPalette[p2]:ToHex():upper()
		end

		return (`<font color="#{v4}">&lt;{p}&gt;</font>`)
	end,
	fromRichColor = function(p: string)
		return Color3.fromHex("#" .. ColorPalette[p]:ToHex():upper())
	end,
	innerArrowBracket = function(p: string, p2)
		local v4

		if typeof(p2) == "Color3" then
			v4 = p2:ToHex():upper()
		else
			v4 = ColorPalette[p2]:ToHex():upper()
		end

		return (`&lt;<font color="#{v4}">{p}</font>&gt;`)
	end,
	commaInteger = function(p: number)
		local v3

		if p < 10 then
			v3 = math.round(p * 100) / 100
		elseif p < 100 then
			v3 = math.round(p * 10) / 10
		else
			v3 = math.round(p)
		end

		local v4 = tostring(v3)

		repeat
			local v5
			v4, v5 = string.gsub(v4, "^(-?%d+)(%d%d%d)", "%1,%2")
		until v5 == 0

		return v4
	end,
	pascalCaseToTitle = function(value: string)
		if value == "" then
			return ""
		end

		local v3 = ""

		for i = 1, #value do
			local v4 = value:sub(i, i)

			if v4:match("[A-Z]") and i > 1 then
				v3 ..= " " .. v4
			else
				v3 ..= v4
			end
		end

		return v3
	end,
	stroke = function(value: string, data)
		if value:len() <= 0 then
			return value
		end

		local v3 = {}

		if data.color then
			table.insert(v3, (`color="#{data.color:ToHex():upper()}"`))
		end

		if data.thickness then
			table.insert(v3, (`thickness="{data.thickness}"`))
		end

		if data.transparency then
			table.insert(v3, (`transparency="{data.transparency}"`))
		end

		if data.joins then
			table.insert(v3, (`joins="{data.joins}"`))
		end

		if data.sizing then
			table.insert(v3, (`sizing="{data.sizing}"`))
		end

		if #v3 == 0 then
			return (`<stroke>{value}</stroke>`)
		end

		return (`<stroke {table.concat(v3, " ")}>{value}</stroke>`)
	end,
	italic = function(value: string)
		if value:len() <= 0 then
			return value
		end

		return (`<i>{value}</i>`)
	end,
	bold = function(value: string)
		if value:len() <= 0 then
			return value
		end

		return (`<b>{value}</b>`)
	end,
	underline = function(value: string)
		if value:len() <= 0 then
			return value
		end

		return (`<u>{value}</u>`)
	end,
	strikethrough = function(value: string)
		if value:len() <= 0 then
			return value
		end

		return (`<s>{value}</s>`)
	end,
	mark = function(value: string, color: Color3)
		if value:len() <= 0 then
			return value
		end

		return (`<mark color="#{color:ToHex():upper()}">{value}</mark>`)
	end,
	uppercase = function(value: string)
		if value:len() <= 0 then
			return value
		end

		return (`<uc>{value}</uc>`)
	end,
	smallcaps = function(value: string)
		if value:len() <= 0 then
			return value
		end

		return (`<sc>{value}</sc>`)
	end,
	font = function(p: string, data)
		local v3 = {}

		if data.color then
			table.insert(v3, (`color="#{data.color:ToHex():upper()}"`))
		end

		if data.size then
			table.insert(v3, (`size="{data.size}"`))
		end

		if type(data.weight) == "number" then
			table.insert(v3, (`weight="{data.weight}"`))
		elseif data.weight then
			table.insert(v3, (`weight="{data.weight.Name:lower()}"`))
		end

		if data.transparency then
			table.insert(v3, (`transparency="{data.transparency}"`))
		end

		if data.face then
			table.insert(v3, (`face="{data.face}"`))
		end

		if data.family then
			table.insert(v3, (`family="{data.family}"`))
		end

		if #v3 == 0 then
			return (`<font>{p}</font>`)
		end

		return (`<font {table.concat(v3, " ")}>{p}</font>`)
	end,
	clean = function(value: string)
		return (value:gsub("&", "&amp;"):gsub("\"", "&quot;"):gsub("'", "&apos;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
	end,
	ROBUX_ICON = "",
	FRAGMENT_COLOR = Color3.fromHex("#B079FD")
}
FormatUtil.FRAGMENT_SYMBOL = FormatUtil.font("ƒ", {
	weight = Enum.FontWeight.SemiBold,
	family = CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO
})
FormatUtil.ESCAPE_FORMS = {
	["<"] = "&lt;",
	[">"] = "&gt;",
	["&"] = "&amp;",
	["\""] = "&quot;",
	["'"] = "&apos;"
}
FormatUtil.LINE_BREAK = "<br/>"
return FormatUtil