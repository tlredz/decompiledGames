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
		RootFFlagStartTime = "HollowOathKatanaRootStartTime",
		RootFFlagEndTime = "HollowOathKatanaRootEndTime",
		FFlagStartTime = "HollowOathKatanaStartTime",
		FFlagEndTime = "HollowOathKatanaEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Hollow Oath Katana",
				Image = "rbxassetid://139613929311052",
				ShowRoom = "HollowOathKatanaShowRoom",
				TemplateType = "Bundle",
				Stock = "Hollow Oath Katana",
				Rewards = {
					{
						GiftName = "Hollow Oath Katana",
						GiftId = 3283087785,
						Item = v.createListReward({
							v.createSwordReward("Hollow Oath Katana"),
							v.createExplosionReward("Hollow Oath Explosion"),
							v.createEmoteReward("Emote910")
						}),
						ProductId = 3283087786
					}
				}
			}
		}
	}
}