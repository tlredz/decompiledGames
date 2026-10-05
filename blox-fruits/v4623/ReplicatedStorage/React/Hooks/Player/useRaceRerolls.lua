local IdMap = require(game.ReplicatedStorage.IdMap)
local useDataInstance = require(game.ReplicatedStorage.React.Hooks.Player.useDataInstance)
local useMatchingChild = require(game.ReplicatedStorage.React.Hooks.Instance.useMatchingChild)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
local useProperty = require(game.ReplicatedStorage.React.Hooks.Instance.useProperty)
local use = require(game.ReplicatedStorage.React.Hooks.Item.Quantity.use)
local changeRace = IdMap.Redeemable["Change Race"]
return function(flag: boolean?)
	local v2 = useMatchingChild(useDataInstance(), function(intValue)
		if intValue:IsA("IntValue") and intValue.Name == "RaceRerolls" then
			return intValue
		end

		return nil
	end)
	local v3 = useMockState("RaceRerolls", 0)
	local v4 = useProperty(v2, function(p)
		return p and p.Value or nil
	end)
	local currentChangeRace = use(changeRace)

	if v3 then
		return v3:get()
	end

	if flag then
		return v4
	end

	if v4 == nil and currentChangeRace == nil then
		return nil
	end

	return (v4 or 0) + (currentChangeRace or 0)
end