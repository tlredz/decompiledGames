local useAttribute = require(game.ReplicatedStorage.React.Hooks.Instance.useAttribute)
local useCharacter = require(game.ReplicatedStorage.React.Hooks.Player.useCharacter)
return function()
	return useAttribute(useCharacter(), "TransparencyMode") ~= nil
end