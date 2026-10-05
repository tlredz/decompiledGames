local Players = game:GetService("Players")
local Requests = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Lobby.Requests)
return function(...)
	Requests:PartyRequest(...)
end