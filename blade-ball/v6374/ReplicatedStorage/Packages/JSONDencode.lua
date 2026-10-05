local byte = string.byte
local find = string.find
local format = string.format
local gsub = string.gsub
local sub = string.sub
local concat = table.concat
local create = table.create
local tonumber2 = tonumber
local tostring2 = tostring
local type2 = type
local pairs2 = pairs
local next2 = next
local getmetatable2 = getmetatable
local setmetatable2 = setmetatable
local char2 = utf8.char
local v = {
	["\""] = "\\\"",
	["\\"] = "\\\\",
	["\8"] = "\\b",
	["\f"] = "\\f",
	["\n"] = "\\n",
	["\r"] = "\\r",
	["\t"] = "\\t"
}
local v2 = {}
local v3 = {}

for i = 0, 31 do
	local v4 = string.char(i)

	if v[v4] == nil then
		v[v4] = format("\\u%04x", i)
	end
end

local v4 = {
	[34] = "\"",
	[47] = "/",
	[92] = "\\",
	[98] = "\8",
	[102] = "\f",
	[110] = "\n",
	[114] = "\r",
	[116] = "\t"
}

local function writeString(p, p2: number, p3: string)
	local v5 = p2 + 1

	if find(p3, "[%z\1-\31\\\"]") == nil then
		p[v5] = "\"" .. p3 .. "\""
		return v5
	end

	p[v5] = "\"" .. gsub(p3, "[%z\1-\31\\\"]", v) .. "\""
	return v5
end

local function encode(p)
	local v5 = create(64)
	local v6 = {}
	local fn

	fn = function(list, p2: number, p3: number)
		local typeName = type2(list)

		if typeName == "string" then
			local v7 = v5
			local v8 = p2 + 1

			if find(list, "[%z\1-\31\\\"]") == nil then
				v7[v8] = "\"" .. list .. "\""
				return v8
			end

			v7[v8] = "\"" .. gsub(list, "[%z\1-\31\\\"]", v) .. "\""
			return v8
		elseif typeName == "number" then
			local v7 = p2 + 1

			if list == list and list ~= 1e999 and list ~= -1e999 then
				v5[v7] = tostring2(list)
				return v7
			end

			v5[v7] = "null"
			return v7
		elseif typeName == "boolean" then
			local v7 = p2 + 1
			v5[v7] = list and "true" or "false"
			return v7
		elseif typeName == "nil" then
			local v7 = p2 + 1
			v5[v7] = "null"
			return v7
		else
			if typeName ~= "table" then
				error(format("JSON encode error: unsupported value type %q", typeName), 3)
			end

			if p3 >= 128 then
				error(format("JSON encode error: nesting exceeds %d levels", 128), 3)
			end

			if v6[list] then
				error("JSON encode error: circular table reference", 3)
			end

			v6[list] = true
			local v7 = getmetatable2(list) == v2
			local v8 = v7 and 0 or #list
			local v9

			if v8 > 0 then
				local v10 = p2 + 1
				v5[v10] = "["

				for i = 1, v8 do
					if i > 1 then
						v10 += 1
						v5[v10] = ","
					end

					v10 = fn(list[i], v10, p3 + 1)
				end

				v9 = v10 + 1
				v5[v9] = "]"
			elseif v7 or next2(list) ~= nil then
				local v10 = p2 + 1
				v5[v10] = "{"
				local flag = false

				for k, v11 in pairs2(list) do
					if type2(k) ~= "string" then
						v6[list] = nil
						error("JSON encode error: object keys must be strings", 3)
					end

					if flag then
						v10 += 1
						v5[v10] = ","
					else
						flag = true
					end

					local v12 = v5
					local v13 = v10 + 1

					if find(k, "[%z\1-\31\\\"]") == nil then
						v12[v13] = "\"" .. k .. "\""
					else
						v12[v13] = "\"" .. gsub(k, "[%z\1-\31\\\"]", v) .. "\""
					end

					local v14 = v13 + 1
					v5[v14] = ":"
					v10 = fn(v11, v14, p3 + 1)
				end

				v9 = v10 + 1
				v5[v9] = "}"
			else
				v9 = p2 + 1
				v5[v9] = "[]"
			end

			v6[list] = nil
			return v9
		end
	end

	return concat(v5, "", 1, (fn(p, 0, 0)))
end

local function decode(list: string)
	if type2(list) ~= "string" then
		error(format("JSON decode error: expected string, got %s", (type2(list))), 2)
	end

	local count = #list

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fail(p: number, p2: string)
		error(format("JSON decode error at byte %d: %s", p, p2), 0)
	end

	local function skipWhitespace(count2: number)
		while count2 <= count do
			local v5 = byte(list, count2)

			if v5 ~= 32 and v5 ~= 9 and v5 ~= 10 and v5 ~= 13 then
				break
			end

			count2 += 1
		end

		return count2
	end

	local function hexDigit(p: number)
		local v5 = byte(list, p)

		if v5 == nil then
			fail(p, "incomplete Unicode escape") -- equivalent call inferred; original call site unknown
		else
			if v5 >= 48 and v5 <= 57 then
				return v5 - 48
			end

			if v5 >= 65 and v5 <= 70 then
				return v5 - 55
			end

			if v5 >= 97 and v5 <= 102 then
				return v5 - 87
			end
		end

		fail(p, "invalid hexadecimal digit") -- equivalent call inferred; original call site unknown
	end

	local function hexCodeUnit(p: number)
		return hexDigit(p) * 4096 + hexDigit(p + 1) * 256 + hexDigit(p + 2) * 16 + hexDigit(p + 3)
	end

	local function parseString(p: number)
		local v5 = p + 1
		local v6 = v5

		while v6 <= count do
			local v7 = byte(list, v6)

			if v7 == 34 then
				return sub(list, v5, v6 - 1), v6 + 1
			else
				if v7 == 92 then
					break
				end

				if v7 < 32 then
					fail(v6, "unescaped control character in string") -- equivalent call inferred; original call site unknown
				end

				v6 += 1
			end
		end

		if count < v6 then
			fail(v6, "unterminated string") -- equivalent call inferred; original call site unknown
		end

		local v7 = create(4)
		local count2 = 0

		while v6 <= count do
			local v8 = byte(list, v6)

			if v8 == 34 then
				local v9 = count2 + 1
				v7[v9] = sub(list, v5, v6 - 1)
				return concat(v7, "", 1, v9), v6 + 1
			elseif v8 == 92 then
				count2 += 1
				v7[count2] = sub(list, v5, v6 - 1)
				local v13 = byte(list, v6 + 1)

				if v13 == nil then
					fail(v6, "unterminated escape sequence") -- equivalent call inferred; original call site unknown
				end

				local v14 = v4[v13]

				if v14 == nil then
					if v13 == 117 then
						local v15 = v6 + 2
						local v16 = hexDigit(v15) * 4096 + hexDigit(v15 + 1) * 256 + hexDigit(v15 + 2) * 16 + hexDigit(v15 + 3)
						v6 += 6

						if v16 >= 55296 and v16 <= 56319 then
							if byte(list, v6) == 92 then
								if byte(list, v6 + 1) ~= 117 then
									fail(v6, "high surrogate must be followed by a low surrogate") -- equivalent call inferred; original call site unknown
								end
							else
								fail(v6, "high surrogate must be followed by a low surrogate") -- equivalent call inferred; original call site unknown
							end

							local v17 = v6 + 2
							local v18 = hexDigit(v17) * 4096 + hexDigit(v17 + 1) * 256 + hexDigit(v17 + 2) * 16 + hexDigit(v17 + 3)

							if v18 < 56320 or v18 > 57343 then
								fail(v6 + 2, "invalid low surrogate") -- equivalent call inferred; original call site unknown
							end

							v16 = (v16 - 55296) * 1024 + 65536 + (v18 - 56320)
							v6 += 6
						elseif v16 >= 56320 and v16 <= 57343 then
							fail(v6 - 4, "unexpected low surrogate") -- equivalent call inferred; original call site unknown
						end

						count2 += 1
						v7[count2] = char2(v16)
					else
						fail(v6 + 1, "invalid escape sequence") -- equivalent call inferred; original call site unknown
					end
				else
					count2 += 1
					v7[count2] = v14
					v6 += 2
				end

				v5 = v6
			elseif v8 < 32 then
				fail(v6, "unescaped control character in string") -- equivalent call inferred; original call site unknown
			else
				v6 += 1
			end
		end

		fail(v6, "unterminated string") -- equivalent call inferred; original call site unknown
	end

	local function parseNumber(p: number)
		local v5 = byte(list, p)
		local v6

		if v5 == 45 then
			v6 = p + 1
			v5 = byte(list, v6)
		else
			v6 = p
		end

		if v5 == 48 then
			v6 += 1
			v5 = byte(list, v6)

			if v5 ~= nil and v5 >= 48 and v5 <= 57 then
				fail(v6, "leading zero in number") -- equivalent call inferred; original call site unknown
			end
		elseif v5 == nil or not (v5 >= 49 and v5 <= 57) then
			fail(v6, "invalid number") -- equivalent call inferred; original call site unknown
		else
			repeat
				v6 += 1
				v5 = byte(list, v6)
			until v5 == nil or v5 < 48 or v5 > 57
		end

		if v5 == 46 then
			v6 += 1
			local v7 = byte(list, v6)

			if v7 == nil or v7 < 48 or v7 > 57 then
				fail(v6, "expected digit after decimal point") -- equivalent call inferred; original call site unknown
			end

			repeat
				v6 += 1
				v5 = byte(list, v6)
			until v5 == nil or v5 < 48 or v5 > 57
		end

		if v5 == 69 or v5 == 101 then
			v6 += 1
			local v7 = byte(list, v6)

			if v7 == 43 or v7 == 45 then
				v6 += 1
				v7 = byte(list, v6)
			end

			if v7 == nil or v7 < 48 or v7 > 57 then
				fail(v6, "expected exponent digits") -- equivalent call inferred; original call site unknown
			end

			repeat
				v6 += 1
				local v8 = byte(list, v6)
			until v8 == nil or v8 < 48 or v8 > 57
		end

		local v10 = tonumber2((sub(list, p, v6 - 1)))

		if v10 == nil or v10 == 1e999 or v10 == -1e999 then
			fail(p, "number is outside the supported range") -- equivalent call inferred; original call site unknown
		end

		return v10, v6
	end

	local fn

	fn = function(p: number, p2: number)
		local v5 = skipWhitespace(p)
		local v6 = byte(list, v5)

		if v6 == 34 then
			return parseString(v5)
		end

		if v6 == 45 or v6 ~= nil and v6 >= 48 and v6 <= 57 then
			return parseNumber(v5)
		end

		if v6 == 116 and sub(list, v5, v5 + 3) == "true" then
			return true, v5 + 4
		end

		if v6 == 102 and sub(list, v5, v5 + 4) == "false" then
			return false, v5 + 5
		end

		if v6 == 110 and sub(list, v5, v5 + 3) == "null" then
			return nil, v5 + 4
		end

		if v6 == 91 then
			if p2 >= 128 then
				fail(v5, format("nesting exceeds %d levels", 128)) -- equivalent call inferred; original call site unknown
			end

			local result = create(8)
			local v7 = skipWhitespace(v5 + 1)

			if byte(list, v7) == 93 then
				return result, v7 + 1
			end

			local count2 = 0
			local v8

			while true do
				count2 += 1
				local v9, v10 = fn(v7, p2 + 1)
				result[count2] = v9
				v8 = skipWhitespace(v10)
				local v11 = byte(list, v8)

				if v11 == 93 then
					break
				end

				if v11 ~= 44 then
					fail(v8, "expected comma or closing bracket") -- equivalent call inferred; original call site unknown
				end

				v7 = skipWhitespace(v8 + 1)
			end

			return result, v8 + 1
		elseif v6 == 123 then
			if p2 >= 128 then
				fail(v5, format("nesting exceeds %d levels", 128)) -- equivalent call inferred; original call site unknown
			end

			local result = setmetatable2({}, v2)
			local v7 = skipWhitespace(v5 + 1)

			if byte(list, v7) == 125 then
				return result, v7 + 1
			end

			while true do
				if byte(list, v7) ~= 34 then
					fail(v7, "expected a string property name") -- equivalent call inferred; original call site unknown
				end

				local v8, v9 = parseString(v7)
				local v10 = skipWhitespace(v9)

				if byte(list, v10) ~= 58 then
					fail(v10, "expected colon after property name") -- equivalent call inferred; original call site unknown
				end

				local v11, v12 = fn(v10 + 1, p2 + 1)
				result[v8] = v11
				local v13 = skipWhitespace(v12)
				local v14 = byte(list, v13)

				if v14 == 125 then
					return result, v13 + 1
				end

				if v14 ~= 44 then
					fail(v13, "expected comma or closing brace") -- equivalent call inferred; original call site unknown
				end

				v7 = skipWhitespace(v13 + 1)
			end
		else
			if v6 == nil then
				fail(v5, "expected a value") -- equivalent call inferred; original call site unknown
			end

			fail(v5, "unexpected token") -- equivalent call inferred; original call site unknown
		end
	end

	local v5, v6 = fn(1, 0)
	local v7 = skipWhitespace(v6)

	if v7 <= count then
		fail(v7, "trailing content") -- equivalent call inferred; original call site unknown
	end

	return v5
end

function v3.Object(options)
	local v5 = options or {}

	if type2(v5) ~= "table" then
		error("JSONDencode.Object expects a table or nil", 2)
	end

	return (setmetatable2(v5, v2))
end

function v3.IsObject(p)
	return type2(p) == "table" and getmetatable2(p) == v2
end

v3.Encode = encode
v3.Decode = decode

function v3.JSONEncode(p, p2)
	if p == v3 then
		return encode(p2)
	end

	return encode(p)
end

function v3.JSONDecode(p, p2: string?)
	if p == v3 then
		return (decode(p2))
	end

	return (decode(p))
end

return table.freeze(v3)