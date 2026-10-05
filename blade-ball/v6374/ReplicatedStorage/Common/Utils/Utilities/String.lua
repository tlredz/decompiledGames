local String = {
	Escape = function(value)
		return (value:gsub("([%.%$%^%(%)%[%]%+%-%*%?%%])", "%%%1"))
	end,
	Trim = function(value)
		return value:match("^%s*(.-)%s*$")
	end,
	TrimStart = function(value)
		return value:match("^%s*(.+)")
	end,
	TrimEnd = function(value)
		return value:match("(.-)%s*$")
	end,
	RemoveExcessWhitespace = function(value)
		return value:gsub("%s+", " ")
	end,
	RemoveWhitespace = function(value)
		return value:gsub("%s+", "")
	end
}

function String.EndsWith(value, p)
	return value:match(String.Escape(p) .. "$") ~= nil
end

function String.StartsWith(value, p)
	return value:match("^" .. String.Escape(p)) ~= nil
end

function String.Contains(value, p)
	return value:find(p) ~= nil
end

function String.StringBuilder()
	local v2 = {}
	local v = {
		Append = function(_, p)
			v2[#v2 + 1] = p
		end,
		Prepend = function(_, p)
			table.insert(v2, 1, p)
		end,
		ToString = function(_)
			return table.concat(v2, "")
		end
	}
	setmetatable(v, {
		__tostring = v.ToString
	})
	return v
end

function String.ToCharArray(value)
	local count = #value
	local result = table.create(count)

	for i = 1, count do
		result[i] = value:sub(i, i)
	end

	return result
end

function String.ToByteArray(value)
	local count = #value

	if count == 0 then
		return {}
	end

	if count <= 7997 then
		return table.pack(value:byte(1, #value))
	end

	local result = table.create(count)

	for i = 1, count do
		result[i] = value:sub(i, i):byte()
	end

	return result
end

function String.ByteArrayToString(list)
	local count = #list

	if count <= 7997 then
		return (string.char(table.unpack(list)))
	end

	local v = math.ceil(count / 7997)
	local v2 = table.create(v)

	for i = 1, v do
		v2[i] = string.char(table.unpack(list, (i - 1) * 7997 + 1, (math.min(count, (i - 1) * 7997 + 7997))))
	end

	return table.concat(v2, "")
end

function String.EqualsIgnoreCase(value, value2)
	return value:lower() == value2:lower()
end

function String.ToCamelCase(value)
	local v = value:gsub("[%-_]+([^%-_])", function(value2)
		return value2:upper()
	end)
	return v:sub(1, 1):lower() .. v:sub(2)
end

function String.ToPascalCase(p)
	local camelCase = String.ToCamelCase(p)
	return camelCase:sub(1, 1):upper() .. camelCase:sub(2)
end

function String.ToSnakeCase(value, p)
	local v = value:gsub("[%-_]+", "_"):gsub("([^%u%-_])(%u)", function(p2, value2)
		return p2 .. "_" .. value2:lower()
	end)

	if p then
		return (v:upper())
	end

	return (v:lower())
end

function String.ToKebabCase(value, p)
	local v = value:gsub("[%-_]+", "-"):gsub("([^%u%-_])(%u)", function(p2, value2)
		return p2 .. "-" .. value2:lower()
	end)

	if p then
		return (v:upper())
	end

	return (v:lower())
end

local v = ("abcdefghijklmnopqrstuvwxzyABCDEFGHIJKLMNOPQRSTUVWXZY0123456789-_*?/=()[]{}&%+^'\"`!#$,. £@<>:~"):len()

function String.Random(p)
	local v2 = ""

	for _ = 1, p do
		local v3 = math.random(0, v)
		v2 ..= string.sub(
			"abcdefghijklmnopqrstuvwxzyABCDEFGHIJKLMNOPQRSTUVWXZY0123456789-_*?/=()[]{}&%+^'\"`!#$,. £@<>:~",
			v3,
			v3
		)
	end

	return v2
end

function String.GetStringLayoutOrder(value: string, value2: number)
	local v2 = math.min(#value, value2 or 0)
	local total = 0

	for i = 1, v2 do
		local v3 = v2 - i
		total += value:sub(i, i):byte() * 10 ^ (v3 - 1)
	end

	return total
end

function String.AddSpacesToPascalCase(value)
	local v2 = value:gsub("%s+", "")
	local v3 = ""

	for i = 1, #v2 do
		local v4 = v2:sub(i, i)

		if i > 1 and v4:match("%u") then
			v3 ..= " "
		end

		v3 ..= v4
	end

	return v3
end

function String.ValidateAttributeName(value: string)
	if typeof(value) ~= "string" then
		return false, (`Invalid value "{value}" passed to attribute name validation`)
	end

	if #value < 0 then
		return false, "Attribute name needs to have at least 1 character"
	end

	if #value > 100 then
		return false, (`Attribute name "{value}" needs to be 100 characters or less ({#value} right now)`)
	end

	if string.match(value, "^RBX") then
		return false, (`Attribute name "{value}" can't start with "RBX"`)
	end

	local v2 = string.gsub(value, "[%w_]", "")

	if v2 == "" then
		return true, value
	end

	return false, (`Attribute name "{value}" can only have alphanumeric characters, invalid characters in string: {v2}`)
end

function String.AssertAttributeName(p: string)
	local v2, v3 = String.ValidateAttributeName(p)
	return assert(v2 and v3)
end

function String.Levenshtein(value: string, value2: string)
	local count = #value
	local count2 = #value2
	local v2 = {}

	if count == 0 then
		return count2
	end

	if count2 == 0 then
		return count
	end

	if value == value2 then
		return 0
	end

	for i = 0, count do
		v2[i] = {}
		v2[i][0] = i
	end

	for i = 0, count2 do
		v2[0][i] = i
	end

	for i = 1, count do
		for i2 = 1, count2 do
			local v3 = value:byte(i) == value2:byte(i2) and 0 or 1
			v2[i][i2] = math.min(v2[i - 1][i2] + 1, v2[i][i2 - 1] + 1, v2[i - 1][i2 - 1] + v3)
		end
	end

	return v2[count][count2]
end

setmetatable(String, {
	__index = string
})
return String