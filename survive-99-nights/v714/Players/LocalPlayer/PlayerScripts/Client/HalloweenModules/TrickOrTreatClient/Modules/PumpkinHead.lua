local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Client.Events.EnablePumpkinCover:Connect(function(duration)
	Client.Interface.PumpkinOverlay.Visible = true
	task.wait(duration)
	Client.Interface.PumpkinOverlay.Visible = false
end)
return {}