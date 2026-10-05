local Players = game:GetService("Players")
local PreloadController = require(Players.LocalPlayer.PlayerScripts.Controllers.PreloadController)
return function(animator, p)
	animator:LoadAnimation(PreloadController:GetPreloadedAnimation(p)):Play()
end