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
		RootFFlagStartTime = "LunaBalaEmoteStartTime",
		RootFFlagEndTime = "LunaBalaEmoteEndTime",
		FFlagStartTime = "LunaBalaEmoteStartTime",
		FFlagEndTime = "LunaBalaEmoteEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Luna Bala",
				Image = v2.Icons:GetEmoteIcon("Luna Bala"),
				ShowRoom = "LunaBalaShowRoom",
				TemplateType = "Sword",
				Stock = "Luna Bala",
				Rewards = {
					{
						GiftName = "Luna Bala Emote",
						GiftId = 3421505013,
						Item = v.createListReward({ v.createEmoteReward("Emote1052") }),
						ProductId = 3421505014
					}
				}
			}
		}
	}
}