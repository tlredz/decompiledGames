local Util = require(script.Parent.Parent.Shared.Util)
local Players = game:GetService("Players")
local v = {}
local v2 = {}

local function getUserId(childName)
	if not childName or childName == "" then
		return nil
	end

	if v[childName] then
		return v[childName]
	end

	local child = Players:FindFirstChild(childName)

	if child then
		v[childName] = child.UserId
		return child.UserId
	end

	local success, result = pcall(function()
		return Players:GetUserIdFromNameAsync(childName)
	end)

	if not success then
		return nil
	end

	v[childName] = result
	return result
end

local function findPlayer(value)
	if not value or value == "" then
		return nil
	end

	local lower = value:lower()

	if v2[lower] and v2[lower].Parent == Players then
		return v2[lower]
	end

	for _, v3 in ipairs(Players:GetPlayers()) do
		if not (v3.Name:lower() == lower or v3.DisplayName:lower() == lower) then
			continue
		end

		v2[lower] = v3
		return v3
	end

	return nil
end

local v3 = {
	DisplayName = "Full Player Name",
	Prefixes = "# integer",
	Transform = function(value)
		local v4 = Util.MakeFuzzyFinder(Players:GetPlayers())(value)

		if v4 and #v4 ~= 0 then
			return value, v4
		end

		local parts = value:split("@")
		local v5 = parts[1] and parts[1]:match("^%s*(.-)%s*$")
		local v6 = parts[2] and parts[2]:match("^%s*(.-)%s*$")
		local v7 = v6 and v6 ~= "" and findPlayer(v6) or v5 and v5 ~= "" and findPlayer(v5) or findPlayer(value)
		v4 = v7 and { v7 } or v4
		return value, v4
	end,
	ValidateOnce = function(value: string)
		local parts = value:split("@")
		local v4 = parts[1] and parts[1]:match("^%s*(.-)%s*$")
		local v5 = parts[2] and parts[2]:match("^%s*(.-)%s*$")
		return
			(v5 and v5 ~= "" and findPlayer(v5) or v4 and v4 ~= "" and findPlayer(v4) or findPlayer(value)) ~= nil or (getUserId(v5 or value) ~= nil or tonumber(value)),
			"No player with that name or display name could be found."
	end,
	Autocomplete = function(_, list)
		local result = {}

		for _, v4 in ipairs(list) do
			table.insert(result, v4.DisplayName .. " @" .. v4.Name)
		end

		return result
	end,
	Parse = function(value)
		local parts = value:split("@")
		local v4 = parts[1] and parts[1]:match("^%s*(.-)%s*$")
		local v5 = parts[2] and parts[2]:match("^%s*(.-)%s*$")
		local v6 = v5 and v5 ~= "" and findPlayer(v5) or v4 and v4 ~= "" and findPlayer(v4) or findPlayer(value)
		return v6 and v6.UserId or getUserId(v5 or value) or tonumber(value)
	end,
	Default = function(p)
		return p.DisplayName .. " @" .. p.Name
	end,
	ArgumentOperatorAliases = {
		me = "."
	}
}
return function(registry)
	registry:RegisterType("playerId", v3)
	registry:RegisterType("playerIds", Util.MakeListableType(v3, {
		Prefixes = "# integers"
	}))
end