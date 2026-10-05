local TextPlusUtility = {}
local Storage = require(script.Parent.Storage)
local sub = string.sub
local lower = string.lower
local typeof2 = typeof
local find = string.find
local insert = table.insert
local find2 = table.find

function TextPlusUtility.splitWordsAndSpaces(value: string)
	local total = 1
	local result = {}
	local count = 0

	while total <= #value do
		local match = value:match("^%s+", total)

		if match then
			table.insert(result, match)
			count += 1
			total += #match
		else
			local match2 = value:match("^%S+", total)

			if not match2 then
				break
			end

			table.insert(result, match2)
			count += 1
			total += #match2
		end
	end

	return result, count
end

local function tonumbfunc(p: string)
	return (tonumber(p))
end

local function smartSplit(list, p)
	local v = 0
	local v2 = ""
	local result = {}
	local count = 0

	for i = 1, #list do
		local v3 = sub(list, i, i)

		if v3 == "(" then
			v += 1
			v2 ..= "("
		elseif v3 == ")" then
			v -= 1
			v2 ..= ")"
		elseif v3 == p and v == 0 then
			local match = v2:match("^%s*(.-)%s*$")

			if #match > 0 then
				table.insert(result, match)
				count += 1
			end

			v2 = ""
		else
			v2 ..= v3
		end
	end

	local match = v2:match("^%s*(.-)%s*$")

	if #match > 0 then
		table.insert(result, match)
		count += 1
	end

	return result, count
end

local function fn(p)
	return lower(p) == "true"
end

local function fn2(value: string)
	if value == nil then
		return
	end

	if string.find(value, "%(") == nil then
		return Color3.fromHex(value)
	end

	local v, v2, v3, v4 = string.match(
		value,
		"^(.-)%((%s*[+-]?%d*%.?%d+)%s*,%s*([+-]?%d*%.?%d+)%s*,%s*([+-]?%d*%.?%d+)%s*%)"
	)

	if not v then
		v, v2, v3, v4 = string.match(value, "^(%a+)%s*([+-]?%d*%.?%d+)%s*,%s*([+-]?%d*%.?%d+)%s*,%s*([+-]?%d*%.?%d+)")
	end

	if v == nil then
		return
	end

	local v5 = tonumber(v2)
	local v6 = tonumber(v3)
	local v7 = tonumber(v4)

	if v5 == nil or v6 == nil or v7 == nil then
		return
	end

	local v8 = string.match(lower(v), "(%w+)")

	if v8 == nil then
		if v5 ~= nil and v6 ~= nil and v7 ~= nil then
			return Color3.new(v5, v6, v7)
		end
	elseif v8 == "rgb" then
		if v5 ~= nil and v6 ~= nil and v7 ~= nil then
			return Color3.fromRGB(v5, v6, v7)
		end
	elseif v8 == "hsv" and v5 ~= nil and v6 ~= nil and v7 ~= nil then
		return Color3.fromHSV(v5, v6, v7)
	end

	return nil
end

local v = nil
v = {
	color = fn2,
	strokecolor = fn2,
	looped = fn,
	reverse = fn,
	["repeat"] = tonumbfunc,
	delaytime = tonumbfunc,
	transparency = tonumbfunc,
	chunks = tonumbfunc,
	textsize = tonumbfunc,
	amplitude = tonumbfunc,
	step = tonumbfunc,
	size = tonumbfunc,
	stroketransparency = tonumbfunc,
	fontface = function(value: string)
		if value == nil then
			return
		end

		if string.find(value, "%(") == nil then
			local match = value:match("^%s*(.-)%s*$")

			if match and match ~= "" then
				return Font.fromName(string.gsub(match, " ", "_"), Enum.FontWeight.Regular, Enum.FontStyle.Normal)
			end
		else
			local v2, v3, v4, v5 = string.match(value, "^(.-)%((%s*[^,]+)%s*,?%s*([^,]*)%s*,?%s*([^,)]*)%s*%)")

			if v3 ~= nil and v3 ~= "" then
				local match = v3:match("^%s*(.-)%s*$")
				local v6 = (not v4 or v4 == "") and "Regular" or v4:match("^%s*(.-)%s*$") or "Regular"
				local v7 = (not v5 or v5 == "") and "Normal" or v5:match("^%s*(.-)%s*$") or "Normal"
				local v8 = v2 and string.match(lower(v2), "(%w+)") or nil

				if v8 == "name" then
					return Font.fromName(string.gsub(match, " ", "_"), Enum.FontWeight[v6], Enum.FontStyle[v7])
				elseif v8 == "id" then
					return Font.fromId(string.gsub(match, " ", "_"), Enum.FontWeight[v6], Enum.FontStyle[v7])
				elseif v8 == nil then
					return Font.new(string.gsub(match, " ", "_"), Enum.FontWeight[v6], Enum.FontStyle[v7])
				end
			end
		end

		return nil
	end,
	style = function(value)
		if value == nil then
			return
		end

		if string.find(value, "%(") == nil then
			return value
		end

		local v2 = string.match(value, "%((.+)%)")

		if not string.find(v2, "%(") then
			return (string.split(v2, ","))
		end

		local result, v3 = smartSplit(v2, ",")

		for i = 1, v3 do
			if not string.find(result[i], "%(") then
				continue
			end

			local v4 = string.split(string.match(result[i], "%((.+)%)"))

			for i2 = #v4, 1, -1 do
				if string.find(v4[i2], "%=") == nil then
					v4.Style = string.match(v4[i2], "^%s*(.-)%s*$")
				else
					local v5, v6 = string.match(v4[i2], "^%s*([^=]-)%s*=%s*(.-)%s*$")
					local v7 = lower(v5)

					if v[v7] then
						v6 = v[v7](v6) or v6
					end

					v4[v7] = v6
				end

				v4[i2] = nil
			end

			result[i] = v4
		end

		return result
	end
}

function TextPlusUtility.Phase2(value: string?, _)
	if value == nil then
		return
	end

	local result = {}

	while value and #value > 0 do
		local v2, v3 = string.match(value, "^%s*(%w+)%s*=%s*(.*)")

		if not v2 then
			break
		end

		local v4 = string.match(v3, "^%s*([%w_]*%b())")

		if v4 then
			local v5 = string.gsub(v4, "([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
			value = string.match(v3, "^%s*" .. v5 .. "%s*,%s*(.*)") or string.match(v3, "^%s*" .. v5 .. "%s*(.*)")
		else
			local count = #v3
			local v5 = count
			local v6 = 1
			local v7 = 0

			while v6 <= count do
				local v8 = v3:sub(v6, v6)

				if v8 == "(" then
					v7 += 1
				elseif v8 == ")" and v7 > 0 then
					v7 -= 1
				elseif v8 == "," and v7 == 0 then
					v5 = v6 - 1
					break
				end

				v6 += 1
			end

			v4 = v3:sub(1, v5):match("^%s*(.-)%s*$")
			local v8 = v5 + 1

			if v3:sub(v8, v8) == "," then
				v8 += 1

				while v8 <= count and v3:sub(v8, v8):match("%s") do
					v8 += 1
				end
			end

			value = v3:sub(v8)
		end

		if not v4 then
			continue
		end

		local v5 = lower(v2)
		local v6 = Storage.IdsStorage[v4]
		local v7

		if v6 == nil then
			v7 = v4
		else
			v7 = v6(v2) or v4
		end

		if v[v5] ~= nil then
			v4 = v[v5](v7) or v4
		end

		result[v5] = v4
	end

	return result
end

local translatewrapper = require(script.Parent.Parent.translatewrapper)

function TextPlusUtility.Phase1(value: string?, p)
	if value == nil then
		return
	end

	local count = #value
	local v2 = 1
	local result = {
		n = 1
	}

	while v2 <= count do
		if value:sub(v2, v2) == "[" then
			v2 += 1
			local v3 = v2
			local v4 = 1

			while v2 <= count and v4 > 0 do
				local v5 = value:sub(v2, v2)

				if v5 == "[" then
					v4 += 1
				elseif v5 == "]" then
					v4 -= 1
				end

				v2 += 1
			end

			local v5

			if v3 <= v2 - 2 then
				v5 = v2 - 2 or v3
			else
				v5 = v3
			end

			local v6 = value:sub(v3, v5)
			local v7 = nil

			if v2 <= count and value:sub(v2, v2) == "<" then
				local v8 = v2 + 1

				while v8 <= count and value:sub(v8, v8) ~= ">" do
					v8 += 1
				end

				if v8 <= count then
					v7 = value:sub(v2 + 1, v8 - 1)
					v2 = v8 + 1
				end
			end

			local params

			if v7 ~= nil then
				params = TextPlusUtility.Phase2(v7, p)
			end

			if find(v6, "%<") or find(v6, "%[") then
				local phase1 = TextPlusUtility.Phase1(v6, p)

				for i = 1, phase1.n do
					local v9 = phase1[i]

					if v9 == nil then
						continue
					end

					if typeof2(v9) == "table" then
						if params ~= nil then
							for k, list in params do
								if v9.Params[k] == nil then
									v9.Params[k] = list
								elseif typeof2(list) == "table" then
									if typeof2(v9.Params[k]) ~= "table" then
										v9.Params[k] = { v9.Params[k] }
									end

									for _, v10 in ipairs(list) do
										if find2(v9.Params[k], v10) == nil then
											insert(v9.Params[k], v10)
										end
									end
								end
							end
						end
					elseif params ~= nil then
						v9 = {
							Text = translatewrapper.Translate(v9),
							Params = params
						}
					end

					result[result.n] = v9
					result.n += 1
				end
			else
				if params then
					result[result.n] = {
						Text = translatewrapper.Translate(v6),
						Params = params
					}
				else
					result[result.n] = translatewrapper.Translate(v6)
				end

				result.n += 1
			end
		else
			local v3 = ""

			while v2 <= count do
				local v4 = value:sub(v2, v2)
				local v5 = value:sub(v2 + 1, v2 + 1)

				if v4 == "\\" and v5 == "[" then
					v3 ..= "["
					v2 += 2
				else
					if v4 == "[" then
						break
					end

					v3 ..= v4
					v2 += 1
				end
			end

			if #v3 > 0 then
				result[result.n] = translatewrapper.Translate(v3)
				result.n += 1
			end
		end
	end

	return result
end

return TextPlusUtility