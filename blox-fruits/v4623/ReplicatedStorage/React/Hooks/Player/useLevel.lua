local useDataInstance = require(game.ReplicatedStorage.React.Hooks.Player.useDataInstance)
local useMatchingChild = require(game.ReplicatedStorage.React.Hooks.Instance.useMatchingChild)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
local useProperty = require(game.ReplicatedStorage.React.Hooks.Instance.useProperty)
return function()
	local v = useMatchingChild(useDataInstance(), function(intValue)
		if intValue:IsA("IntValue") and intValue.Name == "Level" then
			return intValue
		end

		return nil
	end)
	local v2 = useMockState("Level", 1)

	if v2 then
		return v2:get()
	end

	return useProperty(v, function(p)
		return p and p.Value or nil
	end)
end