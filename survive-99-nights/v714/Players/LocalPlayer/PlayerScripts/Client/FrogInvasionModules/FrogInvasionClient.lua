local FrogInvasionClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = false
Client.Events.StartFrogInvasion:Connect(function()
	v = true
	task.spawn(function()
		Client.PopUpUI.AddPopUp("something is emerging from the ponds..", "alien")
		Client.Sound.Play("FrogEvent")
	end)
end)

function FrogInvasionClient.Init() end

return FrogInvasionClient