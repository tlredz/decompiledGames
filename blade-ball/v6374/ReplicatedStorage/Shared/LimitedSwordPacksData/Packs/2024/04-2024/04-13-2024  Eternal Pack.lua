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
		FFlagStartTime = "HeavenlySwordStartTime",
		RootFFlagStartTime = "EternalPackStartTime",
		FFlagEndTime = "HeavenlySwordEndTime",
		RootFFlagEndTime = "EternalPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Heavenly Sword",
				Image = v2.Icons:GetSwordIcon("Dual Heavenly Sword"),
				ShowRoom = "HeavenlySwordShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Heavenly Sword",
						Item = v.createListReward({ v.createSwordReward("Heavenly Sword") }),
						ProductId = 1805232941
					},
					{
						GiftName = "Dual Heavenly Sword",
						Item = v.createListReward({
							v.createSwordReward("Dual Heavenly Sword"),
							v.createEmoteReward("Emote268"),
							v.createExplosionReward("Heavenly Explosion")
						}),
						ProductId = 1805232950
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "HeavenlyChakramStartTime",
		RootFFlagStartTime = "EternalPackStartTime",
		FFlagEndTime = "HeavenlyChakramEndTime",
		RootFFlagEndTime = "EternalPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Heavenly Chakram",
				Image = v2.Icons:GetSwordIcon("Heavenly Chakram"),
				ShowRoom = "HeavenlyChakramShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Heavenly Chakram",
						Item = v.createListReward({
							v.createSwordReward("Heavenly Chakram"),
							v.createEmoteReward("Emote253"),
							v.createExplosionReward("Heavenly Explosion")
						}),
						ProductId = 1805232934
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "HeavenlyPackStartTime",
		RootFFlagStartTime = "EternalPackStartTime",
		FFlagEndTime = "HeavenlyPackEndTime",
		RootFFlagEndTime = "EternalPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Heavenly Pack",
				Image = "rbxassetid://17122177995",
				ShowRoom = "HeavenlyPackShowRoom",
				Rewards = {
					{
						GiftName = "Heavenly Pack",
						Item = v.createListReward({
							v.createSwordReward("Heavenly Sword"),
							v.createSwordReward("Heavenly Chakram"),
							v.createExplosionReward("Heavenly Explosion"),
							v.createEmoteReward("Emote253")
						}),
						ProductId = 1805232935,
						DiscountedFrom = 3000
					},
					{
						GiftName = "Dual Heavenly Pack",
						Item = v.createListReward({
							v.createSwordReward("Dual Heavenly Sword"),
							v.createSwordReward("Heavenly Chakram"),
							v.createExplosionReward("Heavenly Explosion"),
							v.createEmoteReward("Emote268"),
							v.createEmoteReward("Emote253")
						}),
						ProductId = 1805232936,
						DiscountedFrom = 5000
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "DevilGreatswordStartTime",
		RootFFlagStartTime = "EternalPackStartTime",
		FFlagEndTime = "DevilGreatswordEndTime",
		RootFFlagEndTime = "EternalPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Devil Greatsword",
				Image = v2.Icons:GetSwordIcon("Devil Greatsword"),
				ShowRoom = "DevilGreatswordShowRoom",
				TemplateType = "Sword",
				Stock = "Devil Greatsword",
				Rewards = {
					{
						GiftName = "Devil Greatsword",
						Item = v.createListReward({
							v.createSwordReward("Devil Greatsword"),
							v.createEmoteReward("Emote269"),
							v.createExplosionReward("Devil's Curse")
						}),
						ProductId = 1805232945
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "AngelGreatswordStartTime",
		RootFFlagStartTime = "EternalPackStartTime",
		FFlagEndTime = "AngelGreatswordEndTime",
		RootFFlagEndTime = "EternalPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Angel Greatsword",
				Image = v2.Icons:GetSwordIcon("Angel Greatsword"),
				ShowRoom = "AngelGreatswordShowRoom",
				TemplateType = "Sword",
				Stock = "Angel Greatsword",
				Rewards = {
					{
						GiftName = "Angel Greatsword",
						Item = v.createListReward({
							v.createSwordReward("Angel Greatsword"),
							v.createEmoteReward("Emote270"),
							v.createExplosionReward("Judgement")
						}),
						ProductId = 1805232946
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "DualEternalGreatswordStartTime",
		RootFFlagStartTime = "EternalPackStartTime",
		FFlagEndTime = "DualEternalGreatswordEndTime",
		RootFFlagEndTime = "EternalPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Dual Eternal Greatsword",
				Image = v2.Icons:GetSwordIcon("Dual Eternal Greatsword"),
				ShowRoom = "DualEternalGreatswordShowRoom",
				TemplateType = "Sword",
				Stock = "Dual Eternal Greatsword",
				Rewards = {
					{
						GiftName = "Dual Eternal Greatsword",
						Item = v.createListReward({
							v.createSwordReward("Dual Eternal Greatsword"),
							v.createEmoteReward("Emote271"),
							v.createExplosionReward("Eternal")
						}),
						ProductId = 1805232943
					}
				}
			}
		}
	}
}