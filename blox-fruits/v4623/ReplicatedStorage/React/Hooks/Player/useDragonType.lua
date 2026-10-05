local useDataInstance = require(game.ReplicatedStorage.React.Hooks.Player.useDataInstance)
local useMatchingChild = require(game.ReplicatedStorage.React.Hooks.Instance.useMatchingChild)
local useAttribute = require(game.ReplicatedStorage.React.Hooks.Instance.useAttribute)
return function()
	local v2 = useAttribute(useMatchingChild(useDataInstance(), function(stringValue)
		if stringValue:IsA("StringValue") and stringValue.Name == "DevilFruit" then
			return stringValue
		end

		return nil
	end), "DragonType")

	if v2 == "East" or v2 == "West" then
		return v2
	end

	return nil
end