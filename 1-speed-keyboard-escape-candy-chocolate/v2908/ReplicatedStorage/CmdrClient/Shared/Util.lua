local TextService = game:GetService("TextService")
local Util = {
	MakeDictionary = function(list)
		local result = {}

		for i = 1, #list do
			result[list[i]] = true
		end

		return result
	end,
	DictionaryKeys = function(items)
		local result = {}

		for k in pairs(items) do
			table.insert(result, k)
		end

		return result
	end
}

local function transformInstanceSet(list)
	local names = {}

	for i = 1, #list do
		names[i] = list[i].Name
	end

	return names, list
end

function Util.MakeFuzzyFinder(enumItems)
	local names = nil
	local children = {}

	if typeof(enumItems) == "Enum" then
		enumItems = enumItems:GetEnumItems()
	end

	if typeof(enumItems) == "Instance" then
		children = enumItems:GetChildren()
		names = {}

		for i = 1, #children do
			names[i] = children[i].Name
		end
	elseif typeof(enumItems) == "table" then
		if typeof(enumItems[1]) == "Instance" or typeof(enumItems[1]) == "EnumItem" or typeof(enumItems[1]) == "table" and typeof(enumItems[1].Name) == "string" then
			names = {}

			for i = 1, #enumItems do
				names[i] = enumItems[i].Name
			end

			children = enumItems
		elseif type(enumItems[1]) == "string" then
			names = enumItems
		elseif enumItems[1] == nil then
			names = {}
		else
			error("MakeFuzzyFinder only accepts tables of instances or strings.")
		end
	else
		error("MakeFuzzyFinder only accepts a table, Enum, or Instance.")
	end

	return function(value, p)
		local result = {}

		for k, v in pairs(names) do
			local v2

			if children then
				v2 = children[k] or v
			else
				v2 = v
			end

			if v:lower() == value:lower() then
				if p then
					return v2
				else
					table.insert(result, 1, v2)
				end
			elseif v:lower():find(value:lower(), 1, true) then
				result[#result + 1] = v2
			end
		end

		if p then
			return result[1]
		end

		return result
	end
end

function Util.GetNames(list)
	local names = {}

	for i = 1, #list do
		names[i] = list[i].Name or tostring(list[i])
	end

	return names
end

function Util.SplitStringSimple(value, p)
	local v = p == nil and "%s" or p
	local result = {}
	local v2 = 1

	for k in string.gmatch(value, "([^" .. v .. "]+)") do
		result[v2] = k
		v2 += 1
	end

	return result
end

local function charCode(p)
	return utf8.char((tonumber(p, 16)))
end

function Util.ParseEscapeSequences(value)
	return value:gsub("\\(.)", {
		t = "\t",
		n = "\n"
	}):gsub("\\u(%x%x%x%x)", charCode):gsub("\\x(%x%x)", charCode)
end

function Util.EncodeEscapedOperator(value, value2)
	local v = value2:sub(1, 1)
	local v2 = value2:gsub(".", "%%%1")
	return value:gsub("(" .. ("%" .. v) .. "+)(" .. v2 .. ")", function(value3, p)
		return (value3:sub(1, #value3 - 1) .. p):gsub(".", function(value4)
			return "\\u" .. string.format("%04x", string.byte(value4), 16)
		end)
	end)
end

local v = { "&&", "||", ";" }

function Util.EncodeEscapedOperators(p)
	for _, v2 in ipairs(v) do
		p = Util.EncodeEscapedOperator(p, v2)
	end

	return p
end

local function encodeControlChars(value)
	return (value:gsub("\\\\", "___!CMDR_ESCAPE!___"):gsub("\\\"", "___!CMDR_QUOTE!___"):gsub(
		"\\'",
		"___!CMDR_SQUOTE!___"
	):gsub(
		"\\\n",
		"___!CMDR_NL!___"
	))
end

local function decodeControlChars(value)
	return (value:gsub("___!CMDR_ESCAPE!___", "\\"):gsub("___!CMDR_QUOTE!___", "\""):gsub("___!CMDR_NL!___", "\n"))
end

function Util.SplitString(value, value2)
	local v2 = nil
	local v3 = nil
	local result = {}
	local v4 = value2 or 1e999

	for k in value:gsub("\\\\", "___!CMDR_ESCAPE!___"):gsub("\\\"", "___!CMDR_QUOTE!___"):gsub(
		"\\'",
		"___!CMDR_SQUOTE!___"
	):gsub(
		"\\\n",
		"___!CMDR_NL!___"
	):gmatch("[^ ]+") do
		local escapeSequences = Util.ParseEscapeSequences(k)
		local match = escapeSequences:match("^(['\"])")
		local match2 = escapeSequences:match("(['\"])$")
		local match3 = escapeSequences:match("(\\*)['\"]$")

		if match and not (v2 or match2) then
			v2 = match
			v3 = escapeSequences
		elseif v3 and match2 == v2 and #match3 % 2 == 0 then
			escapeSequences = v3 .. " " .. escapeSequences
			v3 = nil
			v2 = nil
		elseif v3 then
			v3 ..= " " .. escapeSequences
		end

		if not v3 then
			result[#result + (v4 < #result and 0 or 1)] = escapeSequences:gsub("^(['\"])", ""):gsub("(['\"])$", ""):gsub(
				"___!CMDR_ESCAPE!___",
				"\\"
			):gsub(
				"___!CMDR_QUOTE!___",
				"\""
			):gsub(
				"___!CMDR_NL!___",
				"\n"
			)
		end
	end

	if v3 then
		result[#result + (v4 < #result and 0 or 1)] = v3:gsub("___!CMDR_ESCAPE!___", "\\"):gsub(
			"___!CMDR_QUOTE!___",
			"\""
		):gsub(
			"___!CMDR_NL!___",
			"\n"
		)
	end

	return result
end

function Util.MashExcessArguments(list, p)
	local result = {}

	for i = 1, #list do
		if p < i then
			result[p] = ("%s %s"):format(result[p] or "", list[i])
		else
			result[i] = list[i]
		end
	end

	return result
end

function Util.TrimString(value)
	local _, v2 = string.find(value, "^%s*")

	if v2 == #value then
		return ""
	end

	return (string.match(value, ".*%S", v2 + 1))
end

function Util:GetTextSize(data, p2)
	return TextService:GetTextSize(self, data.TextSize, data.Font, p2 or Vector2.new(data.AbsoluteSize.X, 0))
end

function Util.MakeEnumType(p, p2)
	local fuzzyFinder = Util.MakeFuzzyFinder(p2)
	return {
		Validate = function(p3)
			return fuzzyFinder(p3, true) ~= nil, ("Value %q is not a valid %s."):format(p3, p)
		end,
		Autocomplete = function(p3)
			local v2 = fuzzyFinder(p3)

			if type(v2[1]) ~= "string" then
				return Util.GetNames(v2) or v2
			end

			return v2
		end,
		Parse = function(p3)
			return fuzzyFinder(p3, true)
		end
	}
end

function Util.ParsePrefixedUnionType(p, value)
	local splitStringSimple = Util.SplitStringSimple(p)
	local v2 = {}

	for i = 1, #splitStringSimple, 2 do
		v2[#v2 + 1] = {
			prefix = splitStringSimple[i - 1] or "",
			type = splitStringSimple[i]
		}
	end

	table.sort(v2, function(a, b)
		return #a.prefix > #b.prefix
	end)

	for i = 1, #v2 do
		local v3 = v2[i]

		if value:sub(1, #v3.prefix) == v3.prefix then
			return v3.type, value:sub(#v3.prefix + 1), v3.prefix
		end
	end
end

function Util.MakeListableType(data, items)
	local result = {
		Listable = true,
		Transform = data.Transform,
		Validate = data.Validate,
		ValidateOnce = data.ValidateOnce,
		Autocomplete = data.Autocomplete,
		Default = data.Default,
		ArgumentOperatorAliases = data.ArgumentOperatorAliases,
		Parse = function(...)
			return { data.Parse(...) }
		end
	}

	if items then
		for k, item in pairs(items) do
			result[k] = item
		end
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function encodeCommandEscape(value)
	return (value:gsub("\\%$", "___!CMDR_DOLLAR!___"))
end

local function decodeCommandEscape(value)
	return (value:gsub("___!CMDR_DOLLAR!___", "$"))
end

function Util.RunCommandString(object, p)
	local escapeSequences = Util.ParseEscapeSequences(p)
	local parts = Util.EncodeEscapedOperators(escapeSequences):split("&&")
	local v2 = ""

	for i, part in ipairs(parts) do
		local v3 = v2:gsub("%$", "\\x24"):gsub("%%", "%%%%")

		if v2:find("%s") then
			v3 = ("%q"):format(v3) or v3
		end

		local v5 = part:gsub("||", v3)
		v2 = tostring(object:EvaluateAndRun((Util.RunEmbeddedCommands(object, v5))))

		if i == #parts then
			return v2
		end
	end
end

function Util.RunEmbeddedCommands(p, value)
	local v2 = encodeCommandEscape(value) -- equivalent call inferred; original call site unknown
	local v3 = {}

	for k in v2:gmatch("$(%b{})") do
		local v4 = k:sub(2, #k - 1)
		local v5

		if v4:match("^{.+}$") then
			v4 = v4:sub(2, #v4 - 1)
			v5 = false
		else
			v5 = true
		end

		v3[k] = Util.RunCommandString(p, v4)

		if v5 and (v3[k]:find("%s") or v3[k] == "") then
			v3[k] = string.format("%q", v3[k])
		end
	end

	return (v2:gsub("$(%b{})", v3):gsub("___!CMDR_DOLLAR!___", "$"))
end

function Util.SubstituteArgs(value, list)
	local v2 = encodeCommandEscape(value) -- equivalent call inferred; original call site unknown

	if type(list) ~= "table" then
		return (v2:gsub("($%d+)%b{}", "%1"):gsub("$(%w+)", list):gsub("___!CMDR_DOLLAR!___", "$"))
	end

	for i = 1, #list do
		local v3 = tostring(i)
		list[v3] = list[i]

		if list[v3]:find("%s") then
			list[v3] = string.format("%q", list[v3])
		end
	end

	return (v2:gsub("($%d+)%b{}", "%1"):gsub("$(%w+)", list):gsub("___!CMDR_DOLLAR!___", "$"))
end

function Util.MakeAliasCommand(value, p)
	local name, v3 = unpack(value:split("|"))
	local encodeEscapedOperators = Util.EncodeEscapedOperators(p)
	local v4 = {}
	local args = {}

	for k in encodeEscapedOperators:gmatch("$(%d+)") do
		if v4[k] ~= nil then
			continue
		end

		v4[k] = true
		local match = encodeEscapedOperators:match((`${k}(%b\{})`))
		local v6, v7, v8

		if match then
			v6, v7, v8 = unpack(match:sub(2, #match - 1):split("|"))
		end

		local optional = v6 and (v6:match("%?$") and true or false)
		table.insert(args, {
			Type = not v6 and "string" or v6:match("^%w+"),
			Name = v7 or `Argument {k}`,
			Description = v8 or "",
			Optional = optional
		})
	end

	return {
		Name = name,
		Aliases = {},
		Description = `<Alias> {v3 or encodeEscapedOperators}`,
		Group = "UserAlias",
		Args = args,
		Run = function(p2)
			return Util.RunCommandString(p2.Dispatcher, Util.SubstituteArgs(encodeEscapedOperators, p2.RawArguments))
		end
	}
end

function Util.MakeSequenceType(options)
	local v2 = options or {}
	assert(v2.Parse ~= nil or v2.Constructor ~= nil, "MakeSequenceType: Must provide one of: Constructor, Parse")
	v2.TransformEach = v2.TransformEach or function(...)
		return ...
	end
	v2.ValidateEach = v2.ValidateEach or function()
		return true
	end
	return {
		Prefixes = v2.Prefixes,
		Transform = function(p)
			return Util.Map(Util.SplitPrioritizedDelimeter(p, { ",", "%s" }), function(p2)
				return v2.TransformEach(p2)
			end)
		end,
		Validate = function(list)
			if v2.Length and #list > v2.Length then
				return false, ("Maximum of %d values allowed in sequence"):format(v2.Length)
			end

			for i = 1, v2.Length or #list do
				local v3, v4 = v2.ValidateEach(list[i], i)

				if not v3 then
					return false, v4
				end
			end

			return true
		end,
		Parse = v2.Parse or function(list)
			return v2.Constructor(unpack(list))
		end
	}
end

function Util.SplitPrioritizedDelimeter(value, list)
	for i, v2 in ipairs(list) do
		if value:find(v2) or i == #list then
			return Util.SplitStringSimple(value, v2)
		end
	end
end

function Util.Map(list, callback)
	local result = {}

	for i, v2 in ipairs(list) do
		result[i] = callback(v2, i)
	end

	return result
end

function Util.Each(callback, ...)
	local v2 = {}

	for i, v3 in ipairs({ ... }) do
		v2[i] = callback(v3)
	end

	return unpack(v2)
end

function Util.EmulateTabstops(value, p)
	local count = #value
	local v2 = table.create(count)
	local total = 0

	for i = 1, count do
		local v3 = string.sub(value, i, i)

		if v3 == "\t" then
			local v4 = p - total % p
			table.insert(v2, string.rep(" ", v4))
			total += v4
		else
			table.insert(v2, v3)

			if v3 == "\n" then
				total = 0
			elseif v3 ~= "\r" then
				total += 1
			end
		end
	end

	return table.concat(v2)
end

function Util.Mutex()
	local threads = {}
	local flag = false
	return function()
		if flag then
			table.insert(threads, coroutine.running())
			coroutine.yield()
		else
			flag = true
		end

		return function()
			if #threads > 0 then
				coroutine.resume(table.remove(threads, 1))
			else
				flag = false
			end
		end
	end
end

return Util