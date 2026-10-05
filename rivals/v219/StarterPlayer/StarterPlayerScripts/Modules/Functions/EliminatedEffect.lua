local Players = game:GetService("Players")
local EliminatedEffect = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.EliminatedEffect)
return function(...)
	EliminatedEffect:Play(...)
end