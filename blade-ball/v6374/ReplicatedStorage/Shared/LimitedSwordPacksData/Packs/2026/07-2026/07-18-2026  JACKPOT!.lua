local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = require3(ReplicatedStorage2.Common.Utils)
require3(script:FindFirstAncestor("Packs").Parent.Types)
return {
	{
		RootFFlagStartTime = "JACKPOTRootStartTime",
		RootFFlagEndTime = "JACKPOTRootEndTime",
		FFlagStartTime = "JACKPOTStartTime",
		FFlagEndTime = "JACKPOTEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "JACKPOT!",
				Image = v2.Icons:GetEmoteIcon("JACKPOT!"),
				ShowRoom = "JACKPOTShowRoom",
				TemplateType = "Sword",
				Stock = "JACKPOT!",
				Rewards = {
					{
						GiftName = "JACKPOT!",
						GiftId = 3610475415,
						Item = v.createListReward({ v.createEmoteReward("Emote1249") }),
						ProductId = 3610475417
					}
				}
			}
		}
	}
}