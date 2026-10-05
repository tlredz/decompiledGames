local Players = game:GetService("Players")
local useHasTag = require(game.ReplicatedStorage.React.Hooks.Instance.useHasTag)
return function()
	return useHasTag("DiscountedDragonEnabled", Players.LocalPlayer)
end