local Util = require(script.Parent.Parent.Shared.Util)
local Players = game:GetService("Players")
local v = {}

local function getUserId(childName)
	if v[childName] then
		return v[childName]
	end

	if Players:FindFirstChild(childName) then
		v[childName] = Players[childName].UserId
		return Players[childName].UserId
	end

	local success, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, Players, childName)

	if not success then
		return nil
	end

	v[childName] = userIdFromNameAsync
	return userIdFromNameAsync
end

local v2 = {
	DisplayName = "Full Player Name",
	Prefixes = "# integer",
	Transform = function(p)
		return p, Util.MakeFuzzyFinder(Players:GetPlayers())(p)
	end,
	ValidateOnce = function(childName)
		local userIdFromNameAsync

		if v[childName] then
			userIdFromNameAsync = v[childName]
		elseif Players:FindFirstChild(childName) then
			v[childName] = Players[childName].UserId
			userIdFromNameAsync = Players[childName].UserId
		else
			local success
			success, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, Players, childName)

			if success then
				v[childName] = userIdFromNameAsync
			else
				userIdFromNameAsync = nil
			end
		end

		return userIdFromNameAsync ~= nil, "No player with that name could be found."
	end,
	Autocomplete = function(_, p)
		return Util.GetNames(p)
	end,
	Parse = function(childName)
		if v[childName] then
			return v[childName]
		end

		if Players:FindFirstChild(childName) then
			v[childName] = Players[childName].UserId
			return Players[childName].UserId
		end

		local success, userIdFromNameAsync = pcall(Players.GetUserIdFromNameAsync, Players, childName)

		if not success then
			return nil
		end

		v[childName] = userIdFromNameAsync
		return userIdFromNameAsync
	end,
	Default = function(p)
		return p.Name
	end,
	ArgumentOperatorAliases = {
		me = ".",
		all = "*",
		others = "**",
		random = "?"
	}
}
return function(registry)
	registry:RegisterType("playerId", v2)
	registry:RegisterType("playerIds", Util.MakeListableType(v2, {
		Prefixes = "# integers"
	}))
end