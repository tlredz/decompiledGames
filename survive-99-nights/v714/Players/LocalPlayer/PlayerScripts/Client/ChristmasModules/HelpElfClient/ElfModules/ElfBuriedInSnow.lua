local ElfBuriedInSnow = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local _ = script.Name
game:GetService("CollectionService")
Client.Events.Elf_RescueFromSnow:Connect(function(p)
	Client.HelpElfClient.PlayAnimation(p, "GetUp")
	task.delay(3, function()
		Client.Sound.Play("ChristmasHit1")
		Client.HelpElfClient.PlayAnimation(p, "Celebrate")
	end)
	task.delay(1, function()
		Client.HelpElfClient.StopAnimation(p, "Idle")
	end)
	task.delay(6, function()
		Client.HelpElfClient.FadeOutElf(p)
	end)
end)

function ElfBuriedInSnow.AttemptHelpElf(_) end

function ElfBuriedInSnow.Init() end

return ElfBuriedInSnow