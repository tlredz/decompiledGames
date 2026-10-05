local useCharacter = require(game.ReplicatedStorage.React.Hooks.Player.useCharacter)
local useMatchingChild = require(game.ReplicatedStorage.React.Hooks.Instance.useMatchingChild)
local useAttribute = require(game.ReplicatedStorage.React.Hooks.Instance.useAttribute)
return function()
	local v2 = useMatchingChild(useCharacter(), function(tool)
		if tool:IsA("Tool") then
			return tool
		end

		return nil
	end)
	local v3 = useAttribute(v2, "ItemId")

	if type(v3) == "number" then
		return v2, v3
	end

	return v2, nil
end