local import = _G.import("commandsCollection")
_G.import("cmdrTextUtil")
local import2 = _G.import("stringUtil")

local function push(list, p)
	list[#list + 1] = p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isSpace(p)
	return p == " " or p == "\n" or p == "\t" or p == "\r"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unescapeChar(p)
	if p == "n" then
		return "\n"
	elseif p == "t" then
		return "\t"
	elseif p == "r" then
		return "\r"
	elseif p == "\"" then
		return "\""
	elseif p == "\\" then
		return "\\"
	end

	return p
end

local function tokenize(value)
	local v = tostring(value or "")
	local result = {}
	local v2 = {}
	local v3 = #v

	local function flush()
		if #v2 > 0 then
			local values = result
			local joined = table.concat(v2)
			values[#values + 1] = joined
			table.clear(v2)
		end
	end

	local v4 = 1
	local flag = false
	local flag2 = false

	while v4 <= v3 do
		local v5 = v:sub(v4, v4)

		if flag then
			local v6 = unescapeChar(v5) -- equivalent call inferred; original call site unknown
			v2[#v2 + 1] = v6
			v4 += 1
			flag = false
		elseif flag2 then
			if v5 == "\\" then
				v4 += 1
				flag = true
			elseif v5 == "\"" then
				v4 += 1
				flag2 = false
			else
				v2[#v2 + 1] = v5
				v4 += 1
			end
		elseif isSpace(v5) then
			if #v2 > 0 then
				local joined = table.concat(v2)
				result[#result + 1] = joined
				table.clear(v2)
			end

			v4 += 1
		elseif v5 == "\"" then
			v4 += 1
			flag2 = true
		else
			v2[#v2 + 1] = v5
			v4 += 1
		end
	end

	if flag then
		v2[#v2 + 1] = "\\"
	end

	if #v2 > 0 then
		local joined = table.concat(v2)
		result[#result + 1] = joined
		table.clear(v2)
	end

	return result, {
		UnterminatedQuote = flag2
	}
end

local function parseInput(p)
	local v, v2 = tokenize(p)
	local v3 = v[1]

	if not v3 or v3 == "" then
		return nil, {}, v2
	end

	local result = {}

	for i = 2, #v do
		result[#result + 1] = v[i]
	end

	return v3, result, v2
end

local CmdrService = {}
CmdrService.tokenize = tokenize
CmdrService.parseInput = parseInput

function CmdrService.getCommandPrefix(p)
	return tokenize(p)[1] or ""
end

function CmdrService.getCommandByName(p)
	if not p then
		return
	end

	local id = import:resolveId(p)

	if id then
		return import.Data[id]
	end
end

function CmdrService.getSuggestions(value)
	local lower = value:lower()

	if lower == "" then
		return {}
	end

	local names = {}

	for _, v in pairs(import.Data) do
		local name = v and v.Name

		if name and import2.startsWith(name:lower(), lower) then
			names[#names + 1] = name
		end
	end

	table.sort(names)
	return names
end

function CmdrService.parseToId(p)
	local v, v2, v3 = parseInput(p)

	if v then
		return import:resolveId(v), v2, v3
	end

	return nil, {}, v3
end

return CmdrService