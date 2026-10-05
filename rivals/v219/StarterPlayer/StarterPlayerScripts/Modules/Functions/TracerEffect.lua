local Players = game:GetService("Players")
local TracerEffect = require(Players.LocalPlayer.PlayerScripts.Modules.TracerEffect)
return function(...)
	TracerEffect:Play(...)
end