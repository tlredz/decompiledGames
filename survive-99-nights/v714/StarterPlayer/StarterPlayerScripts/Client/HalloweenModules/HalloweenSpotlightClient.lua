local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local halloweenKeyPopUp = Client.Interface.HalloweenKeyPopUp
Client.Events.ShowHalloweenSpotlightCount:Connect(function(value, value2)
	halloweenKeyPopUp.Key.Coins.Text = (value or 0) .. "/" .. (value2 or 5)
	halloweenKeyPopUp.Visible = true
	task.wait(6)
	halloweenKeyPopUp.Visible = false
end)
return {}