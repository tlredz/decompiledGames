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
		RootFFlagStartTime = "CrabRaveEmoteStartTime",
		RootFFlagEndTime = "CrabRaveEmoteEndTime",
		FFlagStartTime = "CrabRaveEmoteStartTime",
		FFlagEndTime = "CrabRaveEmoteEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Crab Rave",
				Image = v2.Icons:GetEmoteIcon("Crab Rave"),
				ShowRoom = "CrabRaveShowRoom",
				TemplateType = "Sword",
				Stock = "Crab Rave",
				Rewards = {
					{
						GiftName = "Crab Rave",
						GiftId = 3596391656,
						Item = v.createListReward({ v.createEmoteReward("Emote1217") }),
						ProductId = 3596391655
					}
				}
			}
		}
	}
}