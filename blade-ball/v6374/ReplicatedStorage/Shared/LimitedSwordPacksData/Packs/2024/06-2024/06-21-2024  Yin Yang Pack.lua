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
		RootFFlagStartTime = "DualYinYangGreatswordRootStartTime",
		RootFFlagEndTime = "DualYinYangGreatswordRootEndTime",
		FFlagStartTime = "YinYangParasolStartTime",
		FFlagEndTime = "YinYangParasolEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Yin Yang Parasol",
				Image = v2.Icons:GetSwordIcon("Yin Yang Parasol"),
				ShowRoom = "YinYangParasolShowRoom",
				Stock = "Yin Yang Parasol",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Yin Yang Parasol",
						GiftId = 1855579235,
						Item = v.createListReward({
							v.createSwordReward("Yin Yang Parasol"),
							v.createExplosionReward("Yin Yang Parasol Explosion"),
							v.createEmoteReward("Emote392")
						}),
						ProductId = 1855579236
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "DualYinYangGreatswordRootStartTime",
		RootFFlagEndTime = "DualYinYangGreatswordRootEndTime",
		FFlagStartTime = "YinYangGreatswordStartTime",
		FFlagEndTime = "YinYangGreatswordEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Yin Yang Greatsword",
				Image = v2.Icons:GetSwordIcon("Yin Yang Greatsword"),
				ShowRoom = "YinYangGreatswordShowRoom",
				TemplateType = "Sword",
				Stock = "Yin Yang Greatsword",
				Rewards = {
					{
						GiftName = "Yin Yang Greatsword",
						GiftId = 1855579230,
						Item = v.createListReward({
							v.createSwordReward("Yin Yang Greatsword"),
							v.createExplosionReward("Yin Yang Greatsword Explosion"),
							v.createEmoteReward("Emote393")
						}),
						ProductId = 1855579231
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "DualYinYangGreatswordRootStartTime",
		RootFFlagEndTime = "DualYinYangGreatswordRootEndTime",
		FFlagStartTime = "DualYinYangGreatswordStartTime",
		FFlagEndTime = "DualYinYangGreatswordEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Dual Yin Yang Greatsword",
				Image = v2.Icons:GetSwordIcon("Dual Yin Yang Greatsword"),
				ShowRoom = "DualYinYangGreatswordShowRoom",
				TemplateType = "Sword",
				Stock = "Dual Yin Yang Greatsword",
				Rewards = {
					{
						GiftName = "Dual Yin Yang Greatsword",
						GiftId = 1855579232,
						Item = v.createListReward({
							v.createSwordReward("Dual Yin Yang Greatsword"),
							v.createExplosionReward("Dual Yin Yang Greatsword Explosion"),
							v.createEmoteReward("Emote394")
						}),
						ProductId = 1855579234
					}
				}
			}
		}
	}
}