local Players = game:GetService("Players")

local function trim(value)
	return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
end

local function isValidToken(value)
	if string.match(value, "^#?%d+$") then
		return true
	end

	return string.match(value, "^[%w_]+$") ~= nil and #value >= 3 and #value <= 20
end

local function matchOnline(value)
	local v = string.lower(value)
	local result = {}

	for _, v2 in Players:GetPlayers() do
		if not (v == "" or string.sub(string.lower(v2.Name), 1, #v) == v) then
			continue
		end

		table.insert(result, v2)
	end

	return result
end

local v = {
	DisplayName = "Username or #UserId",
	Listable = true,
	Transform = function(value)
		return string.gsub(value, "^%s*(.-)%s*$", "%1"), (matchOnline(string.gsub(value, "^%s*(.-)%s*$", "%1")))
	end,
	Validate = function(value)
		if #value == 0 then
			return false, "Give a username, or a user id prefixed with #."
		end

		local v2

		if string.match(value, "^#?%d+$") then
			v2 = true
		elseif string.match(value, "^[%w_]+$") == nil or not (#value >= 3) then
			v2 = false
		else
			v2 = #value <= 20
		end

		return v2, (`"{value}" is not a username or a #userid. Ids look like #3889785873.`)
	end,
	Autocomplete = function(_, items)
		local names = {}

		for _, item in items do
			table.insert(names, item.Name)
		end

		return names
	end,
	Parse = function(value, list)
		if #list == 1 and string.lower(list[1].Name) == string.lower(value) then
			return { list[1].Name }
		end

		return { value }
	end,
	Default = function(p)
		return p.Name
	end,
	ArgumentOperatorAliases = {
		me = ".",
		all = "*",
		others = "**"
	}
}
return function(registry)
	registry:RegisterType("banTargets", v)
end