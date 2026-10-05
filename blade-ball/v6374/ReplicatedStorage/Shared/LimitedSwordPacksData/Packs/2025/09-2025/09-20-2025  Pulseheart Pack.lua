local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
require3(ReplicatedStorage2.Common.Utils)
require3(script:FindFirstAncestor("Packs").Parent.Types)
return {
	{
		RootFFlagStartTime = "PulseheartSetRootStartTime",
		RootFFlagEndTime = "PulseheartSetRootEndTime",
		FFlagStartTime = "PulseheartSetShowRoomStartTime",
		FFlagEndTime = "PulseheartSetShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Pulseheart Set",
				Image = "rbxassetid://129480608520496",
				ShowRoom = "PulseheartSetShowRoom",
				TemplateType = "Bundle",
				Stock = "Pulseheart Set",
				Rewards = {
					{
						GiftName = "Pulseheart Set",
						GiftId = 3409252092,
						Item = v.createListReward({
							v.createSwordReward("Pulseheart Set"),
							v.createExplosionReward("Medic Waveform"),
							v.createEmoteReward("Emote1047")
						}),
						ProductId = 3409252095
					}
				}
			}
		}
	}
}