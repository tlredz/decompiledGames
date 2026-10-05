local React = require(game.ReplicatedStorage.Packages.React)
local RaceStatDefinitions = require(game.ReplicatedStorage.Util.RaceStatDefinitions)
local useRace = require(game.ReplicatedStorage.React.Hooks.Player.useRace)
local useDataInstance = require(game.ReplicatedStorage.React.Hooks.Player.useDataInstance)
local useProperty = require(game.ReplicatedStorage.React.Hooks.Instance.useProperty)
local useMatchingChild = require(game.ReplicatedStorage.React.Hooks.Instance.useMatchingChild)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
require(game.ReplicatedStorage.Types.StatTypes)
return function()
	local v = useRace()
	local v3 = useMatchingChild(useDataInstance(), function(stringValue)
		if stringValue:IsA("StringValue") and stringValue.Name == "Race" then
			return stringValue
		end

		return nil
	end)
	local v4 = useMatchingChild(v3, function(intValue)
		if intValue:IsA("IntValue") and intValue.Name == "A" then
			return intValue
		end

		return nil
	end)
	local v5 = useMatchingChild(v3, function(intValue)
		if intValue:IsA("IntValue") and intValue.Name == "B" then
			return intValue
		end

		return nil
	end)
	local v6 = useMatchingChild(v3, function(intValue)
		if intValue:IsA("IntValue") and intValue.Name == "C" then
			return intValue
		end

		return nil
	end)
	local v7 = useProperty(v4, function(p)
		return p and p.Value or nil
	end)
	local v8 = useMockState("RaceAGears", 1)

	if v8 then
		v7 = v8:get()
	end

	local v9 = useProperty(v5, function(p)
		return p and p.Value or nil
	end)
	local v10 = useMockState("RaceBGears", 1)

	if v10 then
		v9 = v10:get()
	end

	local v11 = useProperty(v6, function(p)
		return p and p.Value or nil
	end)
	local v12 = useMockState("RaceCGears", 1)

	if v12 then
		v11 = v12:get()
	end

	local useMemo = React.useMemo

	local function fn()
		if v and v7 and v9 and v11 then
			return RaceStatDefinitions.solve(v.ItemId, v.Level, v7, v9, v11)
		end

		return table.freeze({})
	end

	local v14

	if v then
		v14 = v.ItemId or nil
	end

	return useMemo(fn, {
		v14,
		v and v.Level or nil,
		v7,
		v9,
		v11
	})
end