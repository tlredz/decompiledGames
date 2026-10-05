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
		RootFFlagStartTime = "LoveForYouEmoteStartTime",
		RootFFlagEndTime = "LoveForYouEmoteEndTime",
		FFlagStartTime = "LoveForYouEmoteStartTime",
		FFlagEndTime = "LoveForYouEmoteEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Love For You",
				Image = v2.Icons:GetEmoteIcon("Love For You"),
				ShowRoom = "LoveForYouShowRoom",
				TemplateType = "Sword",
				Stock = "Love For You",
				Rewards = {
					{
						GiftName = "Love For You Emote",
						GiftId = 3537218363,
						Item = v.createListReward({ v.createEmoteReward("Emote1167") }),
						ProductId = 3537218361
					}
				}
			}
		}
	}
}