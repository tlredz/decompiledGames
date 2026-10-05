local Players = game:GetService("Players")
local PingEffect = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.PingEffect)
return function(...)
	PingEffect:Play(...)
end