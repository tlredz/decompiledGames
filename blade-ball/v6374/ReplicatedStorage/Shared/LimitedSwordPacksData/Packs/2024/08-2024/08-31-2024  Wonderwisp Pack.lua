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
		RootFFlagStartTime = "DualWonderwispGreatswordRootStartTime",
		RootFFlagEndTime = "DualWonderwispGreatswordRootEndTime",
		FFlagStartTime = "WonderwispGreatswordStartTime",
		FFlagEndTime = "WonderwispGreatswordEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Wonderwisp Greatsword",
				Image = v2.Icons:GetSwordIcon("Wonderwisp Greatsword"),
				ShowRoom = "WonderwispGreatswordShowRoom",
				TemplateType = "Sword",
				Stock = "Wonderwisp Greatsword",
				Rewards = {
					{
						GiftName = "Wonderwisp Greatsword",
						GiftId = 1922479636,
						Item = v.createListReward({
							v.createSwordReward("Wonderwisp Greatsword"),
							v.createExplosionReward("Ghostwisp"),
							v.createEmoteReward("Emote514")
						}),
						ProductId = 1922479639
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "DualWonderwispGreatswordRootStartTime",
		RootFFlagEndTime = "DualWonderwispGreatswordRootEndTime",
		FFlagStartTime = "DualWonderwispGreatswordStartTime",
		FFlagEndTime = "DualWonderwispGreatswordEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Dual Wonderwisp Greatsword",
				Image = v2.Icons:GetSwordIcon("Dual Wonderwisp Greatsword"),
				ShowRoom = "DualWonderwispGreatswordShowRoom",
				TemplateType = "Sword",
				Stock = "Dual Wonderwisp Greatsword",
				Rewards = {
					{
						GiftName = "Dual Wonderwisp Greatsword",
						GiftId = 1922479642,
						Item = v.createListReward({
							v.createSwordReward("Dual Wonderwisp Greatsword"),
							v.createExplosionReward("Dual Ghostwisp"),
							v.createEmoteReward("Emote515")
						}),
						ProductId = 1922479645
					}
				}
			}
		}
	}
}