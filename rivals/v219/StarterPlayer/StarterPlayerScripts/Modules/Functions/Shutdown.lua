local Players = game:GetService("Players")
local Shutdown = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Shutdown)
return function(p)
	Shutdown:Enable(p)
end