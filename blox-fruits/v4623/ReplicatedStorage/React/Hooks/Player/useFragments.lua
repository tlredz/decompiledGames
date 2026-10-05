local useDataInstance = require(game.ReplicatedStorage.React.Hooks.Player.useDataInstance)
local useMatchingChild = require(game.ReplicatedStorage.React.Hooks.Instance.useMatchingChild)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
local useProperty = require(game.ReplicatedStorage.React.Hooks.Instance.useProperty)
return function()
	local v2 = useMatchingChild(useDataInstance(), function(intValue)
		if intValue:IsA("IntValue") and intValue.Name == "Fragments" then
			return intValue
		end

		return nil
	end)
	local v3 = useMockState("Fragments", 0)

	if v3 then
		return v3:get()
	end

	return useProperty(v2, function(p)
		return p and p.Value or nil
	end)
end