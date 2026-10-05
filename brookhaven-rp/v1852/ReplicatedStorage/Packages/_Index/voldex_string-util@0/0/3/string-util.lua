local StringUtil = {}
local HttpService = game:GetService("HttpService")
local MathUtil = require(script.Parent.MathUtil)
local v = {
	[1] = "One",
	[2] = "Two",
	[3] = "Three",
	[4] = "Four",
	[5] = "Five",
	[6] = "Six",
	[7] = "Seven",
	[8] = "Eight",
	[9] = "Nine",
	[10] = "Ten",
	[11] = "Eleven",
	[12] = "Twelve",
	[13] = "Thirteen",
	[14] = "Fourteen",
	[15] = "Fifteen",
	[16] = "Sixteen",
	[17] = "Seventeen",
	[18] = "Eighteen",
	[19] = "Nineteen",
	[20] = "Twenty",
	[30] = "Thirty",
	[40] = "Forty",
	[50] = "Fifty",
	[60] = "Sixty",
	[70] = "Seventy",
	[80] = "Eighty",
	[90] = "Ninety",
	[100] = "Hundred",
	[1000] = "Thousand",
	[1000000] = "Million",
	[1000000000] = "Billion",
	[1000000000000] = "Trillion",
	[1000000000000000] = "Quadrillion",
	[1e18] = "Quintillion",
	[1e21] = "Sextillion",
	[1e24] = "Septillion",
	[1e27] = "Octillion",
	[1e30] = "Nonillion"
}
local v2 = {
	"K",
	"M",
	"B",
	"T",
	"Q"
}

function StringUtil.toSuffixString(p: number)
	local v3 = math.floor((math.log(p, 1000)))
	return (("%.2f"):format(p / math.pow(10, v3 * 3))):gsub("%.?0+$", "") .. (v2[v3] or "")
end

function StringUtil.Commas(p, value)
	local v3 = tonumber(p)

	if not v3 then
		return nil
	end

	local v4 = v3 < 0
	local v5 = tostring((math.abs(v3)))
	return (v4 and "-" or "") .. (value or "") .. (#v5 % 3 == 0 and v5:reverse():gsub("(%d%d%d)", "%1,"):reverse():sub(2) or v5:reverse():gsub(
		"(%d%d%d)",
		"%1,"
	):reverse())
end

function StringUtil.CharacterLimit(value, p, p2)
	return string.sub(value, 1, p) .. (p < string.len(value) and p2 and "..." or "")
end

function StringUtil.IsEmpty(value)
	if string.match(value, "^%s*$") then
		return true
	end

	return false
end

function StringUtil.RemoveSpaces(value)
	return string.gsub(value, " ", "")
end

function StringUtil.HasNumbers(value)
	if string.match(value, "%d+") then
		return true
	end

	return false
end

function StringUtil.RemoveNumbers(value)
	return string.gsub(value, "%d+", "")
end

function StringUtil.EncodeJSON(p)
	local success, result = pcall(function()
		return HttpService:JSONEncode(p)
	end)
	return success, result
end

function StringUtil.DecodeJSON(json)
	local v3 = {}
	local v4

	if json == "" or json == "[]" or pcall(function()
		v3 = HttpService:JSONDecode(json)
	end) and type(v3) == "table" then
		v4 = true
	else
		v3 = {}
		v4 = false
	end

	return v4, v3
end

function StringUtil.writtenNumber(p: number)
	if p == 0 then
		return "Zero"
	end

	local v3 = math.round(p)
	local v4 = v3 < 0
	local v5 = math.abs(v3)
	local v6 = v4 and "Negative %s" or "%s"

	if v5 <= 20 then
		return v6:format(v[v5])
	end

	if v5 <= 99 then
		local _, v7 = MathUtil.getDigit(v5, 1)

		if v5 == v7 then
			return v6:format(v[v7])
		end

		return v6:format(("%s %s"):format(v[v7], v[v5 - v7]))
	elseif v5 <= 999 then
		local digit, v7 = MathUtil.getDigit(v5, 2)

		if v5 == v7 then
			return v6:format(("%s Hundred"):format(v[digit]))
		end

		return v6:format(("%s Hundred and %s"):format(v[digit], StringUtil.writtenNumber(v5 - v7)))
	else
		local v7 = nil

		for k, _ in pairs(v) do
			if not (k >= 1000 and k <= v5 and v5 < k * 1000) then
				continue
			end

			v7 = k
			break
		end

		if not v7 then
			return v6:format("Big Bucks")
		end

		local v9 = math.floor(v5 / v7)
		local v10 = v5 % v7

		if v10 == 0 then
			return v6:format(("%s %s"):format(StringUtil.writtenNumber(v9), v[v7]))
		end

		local v11 = v10 <= 99 and " and" or ", "
		return v6:format(("%s %s%s %s"):format(StringUtil.writtenNumber(v9), v[v7], v11, StringUtil.writtenNumber(v10)))
	end
end

function StringUtil.getFriendlyString(value: string)
	local v3 = value:sub(value:len())
	local v4 = ""

	for i = value:len() - 1, 1, -1 do
		local v5 = value:sub(i, i)

		if v5 == v5:lower() and v3 ~= v3:lower() then
			value = value:sub(1, i) .. "_" .. value:sub(i + 1)
		end

		v3 = v5
	end

	local parts = value:lower():split("_")

	for i, part in ipairs(parts) do
		local v5 = part:len()

		if not (v5 > 0) then
			continue
		end

		v4 ..= part:sub(1, 1):upper()

		if v5 > 1 then
			v4 ..= part:sub(2, v5)
		end

		if i < #parts then
			v4 ..= " "
		end
	end

	return v4
end

function StringUtil:split(value2: string, value3: number?)
	local result = {}
	local v3 = 1
	local v4 = value3 or -1

	for k in string.gmatch(self, "([^" .. (value2 or "%s") .. "]+)") do
		result[v3] = k
		v3 += 1

		if v4 >= 0 and v4 < v3 then
			break
		end
	end

	return result
end

function StringUtil.escape(value: string)
	return (value:gsub("([%.%$%^%(%)%[%]%+%-%*%?%%])", "%%%1"))
end

function StringUtil.trim(value: string)
	return value:match("^%s*(.-)%s*$")
end

function StringUtil.trimStart(value: string)
	return value:match("^%s*(.+)")
end

function StringUtil.trimEnd(value: string)
	return value:match("(.-)%s*$")
end

function StringUtil.removeExcessWhitespace(value: string)
	return value:gsub("%s+", " ")
end

function StringUtil.removeWhitespace(value: string)
	return value:gsub("%s+", "")
end

function StringUtil.startsWith(value: string, p: string)
	return value:match("^" .. StringUtil.escape(p)) ~= nil
end

function StringUtil.endsWith(value: string, p: string)
	return value:match(StringUtil.escape(p) .. "$") ~= nil
end

function StringUtil.contains(value: string, p: string)
	return value:find(p) ~= nil
end

function StringUtil.chopStart(value: string, value2: string)
	if value:sub(1, value2:len()) == value2 then
		return value:sub(value2:len() + 1)
	end

	return nil
end

function StringUtil.chopEnd(value: string, value2: string)
	if value:sub(value:len() - value2:len() + 1) == value2 then
		return value:sub(1, value:len() - value2:len())
	end

	return nil
end

function StringUtil.toCharArray(value: string)
	local count = #value
	local result = table.create(count)

	for i = 1, count do
		result[i] = value:sub(i, 1)
	end

	return result
end

function StringUtil.toByteArray(value: string)
	local count = #value

	if count == 0 then
		return {}
	end

	if count <= 7997 then
		return table.pack(value:byte(1, #value))
	end

	local result = table.create(count)

	for i = 1, count do
		result[i] = value:sub(i, 1):byte()
	end

	return result
end

function StringUtil.byteArrayToString(list)
	local count = #list

	if count <= 7997 then
		return (string.char(table.unpack(list)))
	end

	local v3 = math.ceil(count / 7997)
	local v4 = table.create(v3)

	for i = 1, v3 do
		v4[i] = string.char(table.unpack(list, (i - 1) * 7997 + 1, (math.min(count, (i - 1) * 7997 + 7997))))
	end

	return table.concat(v4, "")
end

function StringUtil.equalsIgnoreCase(value: string, value2: string)
	return value:lower() == value2:lower()
end

function StringUtil.toCamelCase(value: string)
	local v3 = value:gsub("%s+", ""):gsub("[%-_]+([^%-_])", function(value2)
		return value2:upper()
	end)
	return v3:sub(1, 1):lower() .. v3:sub(2)
end

function StringUtil.toPascalCase(p: string)
	local camelCase = StringUtil.toCamelCase(p)
	return camelCase:sub(1, 1):upper() .. camelCase:sub(2)
end

function StringUtil.toSnakeCase(value: string, flag: boolean)
	local v3 = value:gsub("[%-_]+", "_"):gsub("([^%u%-_])(%u)", function(p, value2)
		return p .. "_" .. value2:lower()
	end)

	if flag then
		return (v3:upper())
	end

	return (v3:lower())
end

function StringUtil.toKebabCase(value: string, flag: boolean)
	local v3 = value:gsub("[%-_]+", "-"):gsub("([^%u%-_])(%u)", function(p, value2)
		return p .. "-" .. value2:lower()
	end)

	if flag then
		return (v3:upper())
	end

	return (v3:lower())
end

function StringUtil:possessiveName()
	if StringUtil.endsWith(self:upper(), "S") then
		return ("%s'"):format(self)
	end

	return ("%s's"):format(self)
end

function StringUtil:upper()
	if not self:find("<") then
		return self:upper()
	end

	local v3 = self:find("<")
	local v4 = self:find(">")

	if not (v4 and v3 < v4) then
		return self:upper()
	end

	local v5 = self:sub(0, v3 - 1)
	local v6 = self:sub(v3, v4)
	local v7 = self:sub(v4 + 1, self:len())
	return v5 .. v6 .. StringUtil.upper(v7)
end

function StringUtil.listWords(list)
	local count = #list
	local v3 = count > 2 and "," or ""
	local v4 = ""

	for i = 1, count do
		local v5 = list[i]
		local v7 = i == count

		if i == 1 then
			v4 = v5
		elseif v7 then
			v4 = ("%s%s and %s"):format(v4, v3, v5)
		else
			v4 = ("%s%s %s"):format(v4, v3, v5)
		end
	end

	return v4
end

function StringUtil.getOrdinalSuffix(p: number)
	local v3 = math.floor(p % 10)

	if v3 >= 4 or p >= 11 and p <= 19 or v3 == 0 then
		return "th"
	end

	if v3 == 1 then
		return "st"
	elseif v3 == 2 then
		return "nd"
	elseif v3 == 3 then
		return "rd"
	end
end

function StringUtil.alphanumericOnly(value: string)
	return value:gsub("%W", "")
end

return StringUtil