local v = {
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	" ",
	"　",
	" ",
	"\r\n",
	"\t",
	"\n",
	"\11",
	"\f",
	"\r",
	" "
}

local function MAKE_LOOKUP(list)
	local result = {}

	for _, v2 in ipairs(list) do
		result[v2] = true
	end

	return result
end

local v2 = {}
local v3 = {
	" ",
	" ",
	"\r\n",
	"\r",
	"\n"
}

for _, v4 in ipairs(v) do
	v2[v4] = true
end

local v4 = {}

for _, v5 in ipairs(v3) do
	v4[v5] = true
end

local v5 = {
	["0"] = "\0",
	["'"] = "'",
	["\""] = "\"",
	["\\"] = "\\",
	b = "\8",
	f = "\f",
	n = "\n",
	r = "\r",
	t = "\t",
	v = "\11"
}

local function Q(p)
	return (string.format("%q", p):gsub("\r", "\\r"):gsub("\n", "\\n"))
end

local function formatError(p: string, list)
	return string.format("%s at line %d col %d", p, list[1], list[2])
end

local function advanceNewline(p: string, list)
	if not v4[p] then
		return false
	end

	list[1] += 1
	list[2] = 1
	return true
end

local function getNewline(value: string, list)
	for _, v6 in ipairs(v3) do
		if value:sub(1, #v6) ~= v6 then
			continue
		end

		local flag

		if v4[v6] then
			list[1] += 1
			list[2] = 1
			flag = true
		else
			flag = false
		end

		if flag then
			return v6
		end
	end

	return nil
end

local function getWhitespace(value: string, list)
	if #value == 0 then
		return nil
	end

	for _, v6 in ipairs(v) do
		if value:sub(1, #v6) ~= v6 then
			continue
		end

		list[2] += #v6

		if not v4[v6] then
			return v6
		end

		list[1] += 1
		list[2] = 1
		return v6
	end

	return nil
end

local function stripWhitespace(value: string, p)
	while true do
		local whitespace = getWhitespace(value, p)

		if whitespace == nil then
			break
		end

		value = value:sub(#whitespace + 1)
	end

	return value
end

local function stripInlineComments(value: string, list)
	while #value ~= 0 do
		local newline = getNewline(value, list)

		if newline then
			return (value:sub(#newline + 1))
		end

		value = value:sub(2)
		list[2] += 1
	end

	return value
end

local function stripBlockComments(value: string, list)
	while #value > 0 do
		if value:sub(1, 2) == "*/" then
			list[2] += 2
			return value:sub(3)
		end

		local newline = getNewline(value, list)

		if newline then
			value = value:sub(#newline + 1)
		else
			list[2] += 1
			value = value:sub(2)
		end
	end

	error(formatError("missing multiline comment close tag", list))
	return ""
end

local function codepointToutf8(p: number)
	if p <= 127 then
		return (string.char(p))
	end

	if p <= 2047 then
		return (string.char(math.floor(p / 64) + 192, p % 64 + 128))
	end

	if p <= 65535 then
		return (string.char(math.floor(p / 4096) + 224, math.floor(p % 4096 / 64) + 128, p % 64 + 128))
	end

	if p <= 1114111 then
		return (string.char(
			math.floor(p / 262144) + 240,
			math.floor(p % 262144 / 4096) + 128,
			math.floor(p % 4096 / 64) + 128,
			p % 64 + 128
		))
	end

	return nil, string.format("invalid unicode codepoint '%x'", p)
end

local function parseUnicodeImpl(value: string, list)
	local match = value:match("^\\u(%x%x%x%x)")

	if not match then
		error(formatError("invalid unicode hex escape sequence", list))
	end

	local v6 = tonumber(match, 16)

	if not v6 then
		error(formatError("invalid unicode hex escape sequence", list))
	end

	list[2] += 6
	return v6, value:sub(7)
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function getSurrogatePair(p: number, p2: number)
	return (p2 - 55296) * 1024 + (p - 56320) + 65536
end

local function parseUnicode(value: string, list)
	local v6 = list[1]
	local v7 = list[2]
	local v8, v9 = parseUnicodeImpl(value, list)

	if v8 >= 55296 and v8 < 56320 then
		local v10
		v10, v9 = parseUnicodeImpl(v9, list)

		if v10 and v10 >= 56320 and v10 <= 57343 then
			v8 = getSurrogatePair(v10, v8)
		end
	end

	local v10, v11 = codepointToutf8(v8)

	if not v10 then
		error(formatError(assert(v11), { v6, v7 }))
	end

	return v10, v9
end

local function parseStringImpl(value: string, callback, flag: boolean, list)
	local v6 = {}

	while not callback(value) do
		local v7 = value:sub(1, 1)

		if v7 == "\\" then
			local v8 = value:sub(2, 2)
			list[2] += 1

			if v5[v8] then
				list[2] += 1

				if flag then
					error(formatError("escape sequence not allowed", list))
				end

				v6[#v6 + 1] = v5[v8]
				value = value:sub(3)
			elseif v8 == "u" then
				local v9
				v9, value = parseUnicode(value, list)
				v6[#v6 + 1] = v9
			elseif v8 == "x" then
				if flag then
					error(formatError("hex escape sequence not allowed", list))
				end

				list[2] += 2
				local v9 = tonumber(value:sub(2, 3), 16)

				if not v9 then
					error(formatError("invalid hex escape sequence", list))
				end

				v6[#v6 + 1] = string.char(v9)
				list[2] += 2
				value = value:sub(5)
			else
				if flag then
					error(formatError("invalid escape sequence", list))
				end

				local newline = getNewline(value:sub(2), list)
				value = value:sub(not newline and 2 or #newline + 2)
			end
		elseif v7:byte(1, 1) < 32 then
			error(formatError("control character found", list))
		else
			v6[#v6 + 1] = v7
			value = value:sub(2)
			list[2] += 1
		end
	end

	return table.concat(v6), value
end

local function parseString(value: string, list)
	local v6 = value:sub(1, 1)

	local function stopCriterion(value2)
		return value2:sub(1, 1) == v6
	end

	local v7, v8 = parseStringImpl(value:sub(2), stopCriterion, false, list)
	list[2] += 1
	return v7, v8:sub(2)
end

local function parseNumber(value: string, list)
	local v6 = 1
	local v7 = value:sub(1, 1)
	local v8 = list[1]
	local v9 = list[2]

	if v7 == "+" then
		value = value:sub(2)
		list[2] += 1
		v6 = 1
	elseif v7 == "-" then
		value = value:sub(2)
		list[2] += 1
		v6 = -1
	end

	if value:sub(1, 3) == "NaN" then
		list[2] += 3
		return (0 / 0), value:sub(4)
	end

	if value:find("Infinity", 1, true) == 1 then
		list[2] += 8
		return 1e999 * v6, value:sub(9)
	end

	local v10 = value
	local count = 0

	while not getWhitespace(v10, list) do
		local v11 = v10:sub(1, 1)

		if v11 == "" or v11 == "," or v11 == "]" or v11 == "}" then
			break
		end

		count += 1
		v10 = v10:sub(2)
		list[2] += 1
	end

	local v11 = value:sub(1, count)
	local v12

	if not (v11:sub(1, 1) == "0" and v11:sub(2):find("^%d+$")) then
		v12 = tonumber(v11)
	end

	if v12 == nil then
		error(formatError(
			"invalid number sequence " .. string.format("%q", v11):gsub("\r", "\\r"):gsub("\n", "\\n"),
			{ v8, v9 }
		))
	end

	list[2] += count
	return v12 * v6, value:sub(count + 1)
end

local function parseNull(value: string, list, p)
	if value:sub(1, 4) ~= "null" then
		error(formatError("invalid null literal", list))
	end

	list[2] += 1
	return p, value:sub(5)
end

local function parseBoolean(value: string, list)
	if value:sub(1, 4) == "true" then
		list[2] += 4
		return true, value:sub(5)
	end

	if value:sub(1, 5) == "false" then
		list[2] += 5
		return false, value:sub(6)
	else
		error(formatError("invalid boolean literal", list))
	end
end

local function stripComments(value: string, list)
	local v6 = value:sub(1, 2)

	if v6 == "//" then
		list[2] += 2
		return (stripInlineComments(value:sub(3), list))
	end

	if v6 ~= "/*" then
		return value
	end

	list[2] += 2
	return stripBlockComments(value:sub(3), list)
end

local function stripWhitespaceAndComments(p: string, p2)
	while true do
		local v7 = stripComments(stripWhitespace(p, p2), p2)

		if v7 == p then
			break
		end

		p = v7
	end

	return p
end

local fn

local function parseArray(value: string, list, p)
	local v6 = value:sub(2)
	list[2] += 1
	local result = {}

	while true do
		local v7 = stripWhitespaceAndComments(v6, list)

		if v7:sub(1, 1) == "]" then
			list[2] += 1
			v6 = v7:sub(2)
			break
		end

		local v8, v9 = fn(v7, list, p)
		local v10 = stripWhitespaceAndComments(v9, list)
		result[#result + 1] = v8
		local v11 = v10:sub(1, 1)
		v6 = v10:sub(2)

		if v11 == "]" then
			list[2] += 1
			break
		end

		if v11 ~= "," then
			error(formatError(
				"expected comma got " .. string.format("%q", v11):gsub("\r", "\\r"):gsub("\n", "\\n"),
				list
			))
		end

		list[2] += 1
	end

	return result, v6
end

local function testIdentifier(value: string)
	local v6 = value:byte(1, 1)

	if v6 >= 48 and v6 <= 57 then
		return false
	end

	for i = 1, #value do
		local v7 = value:byte(i, i)

		if v7 < 36 or v7 >= 37 and v7 <= 47 or v7 >= 58 and v7 <= 64 or v7 >= 91 and v7 <= 94 then
			return false
		end

		if v7 == 96 or v7 >= 123 and v7 <= 128 then
			return false
		end
	end

	return true
end

local function stopIdentifier(value: string)
	return value:sub(1, 1) == ":" or getWhitespace(value, { 0, 0 }) ~= nil
end

local function parseIdentifier(value: string, list)
	local v6 = value:sub(1, 1)
	local v7, v8

	if v6 == "'" or v6 == "\"" then
		v7, v8 = parseString(value, list)
	else
		local v9 = list[1]
		local v10 = list[2]
		v7, v8 = parseStringImpl(value, stopIdentifier, true, list)

		if not testIdentifier(v7) then
			error(formatError(
				"invalid identifier " .. string.format("%q", v7):gsub("\r", "\\r"):gsub("\n", "\\n"),
				{ v9, v10 }
			))
		end
	end

	return v7, v8
end

local function parseObject(value: string, list, p)
	list[2] += 1
	local v6 = value:sub(2)
	local result = {}

	while true do
		local v7 = stripWhitespaceAndComments(v6, list)

		if v7:sub(1, 1) == "}" then
			list[2] += 1
			v6 = v7:sub(2)
			break
		end

		local v8, v9 = parseIdentifier(v7, list)
		local v10 = stripWhitespaceAndComments(v9, list)

		if v10:sub(1, 1) ~= ":" then
			local v12 = v10:sub(1, 1)
			error(formatError(
				"expected colon after identifier, got " .. string.format("%q", v12):gsub("\r", "\\r"):gsub("\n", "\\n"),
				list
			))
		end

		list[2] += 1
		local v12 = stripWhitespaceAndComments(v10:sub(2), list)
		local v13, v14 = fn(v12, list, p)
		local v15 = stripWhitespaceAndComments(v14, list)
		result[v8] = v13
		local v16 = v15:sub(1, 1)
		v6 = v15:sub(2)

		if v16 == "}" then
			list[2] += 1
			break
		end

		if v16 ~= "," then
			error(formatError(
				"expected comma got " .. string.format("%q", v16):gsub("\r", "\\r"):gsub("\n", "\\n"),
				list
			))
		end

		list[2] += 1
	end

	return result, v6
end

local function catchEOF(_: string, p)
	error(formatError("unexpected eof", p))
end

local v6 = {
	["-"] = parseNumber,
	["+"] = parseNumber,
	["."] = parseNumber,
	["0"] = parseNumber,
	["1"] = parseNumber,
	["2"] = parseNumber,
	["3"] = parseNumber,
	["4"] = parseNumber,
	["5"] = parseNumber,
	["6"] = parseNumber,
	["7"] = parseNumber,
	["8"] = parseNumber,
	["9"] = parseNumber,
	N = parseNumber,
	I = parseNumber,
	n = parseNull,
	t = parseBoolean,
	f = parseBoolean,
	["'"] = parseString,
	["\""] = parseString,
	["["] = parseArray,
	["{"] = parseObject,
	[""] = catchEOF
}

fn = function(p: string, p2, p3)
	local v7 = stripWhitespaceAndComments(p, p2)
	local v8 = v7:sub(1, 1)
	local v9 = v6[v8]

	if not v9 then
		error(formatError("invalid value literal " .. string.format("%q", v8):gsub("\r", "\\r"):gsub("\n", "\\n"), p2))
	end

	return v9(v7, p2, p3)
end

local v7 = {
	Null = newproxy(false),
	Decode = function(p: string, p2)
		local v8 = { 1, 1 }
		local v9 = stripWhitespaceAndComments(p, v8)
		local v10, v11 = fn(v9, v8, p2)

		if #stripWhitespaceAndComments(v11, v8) > 0 then
			error(formatError("trailing garbage", v8))
		end

		return v10
	end
}
return table.freeze(v7)