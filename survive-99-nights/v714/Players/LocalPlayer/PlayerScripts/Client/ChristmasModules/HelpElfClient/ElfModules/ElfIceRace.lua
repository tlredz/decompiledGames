local ElfIceRace = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local _ = script.Name
game:GetService("CollectionService")
Client.Events.IceSkatingLapsComplete:Connect(function(instance)
	local elf = instance:FindFirstChild("Elf")

	if elf and elf:GetAttribute("ElfType") == "ElfIceRace" and not elf:GetAttribute("Rescued") then
		Client.Events.Elf_IceRace:FireServer(elf, instance)
		Client.Sound.Play("ChristmasHit1")
		Client.HelpElfClient.PlayAnimation(elf, "Celebrate")
		task.delay(5, function()
			Client.HelpElfClient.FadeOutElf(elf)
		end)
	end
end)

function ElfIceRace.AttemptHelpElf(instance)
	if instance:GetAttribute("RaceCompleted") then
		Client.HelpElfClient.AddElfMessage("nice! you did it!", instance)
	else
		Client.HelpElfClient.AddElfMessage("skate 3 laps without stopping and i'll give you a present!", instance)
	end
end

function ElfIceRace.Init() end

return ElfIceRace