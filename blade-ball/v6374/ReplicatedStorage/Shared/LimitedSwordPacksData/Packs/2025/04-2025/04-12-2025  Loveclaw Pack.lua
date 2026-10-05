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
		RootFFlagStartTime = "LoveclawPackRootStartTime",
		RootFFlagEndTime = "LoveclawPackRootEndTime",
		FFlagStartTime = "LoveclawBladeStartTime",
		FFlagEndTime = "LoveclawBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Loveclaw Blade",
				Image = v2.Icons:GetSwordIcon("Dual Loveclaw Blade"),
				ShowRoom = "LoveclawBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Loveclaw Blade",
						GiftId = 3263710492,
						Item = v.createListReward({ v.createSwordReward("Loveclaw Blade") }),
						ProductId = 3263710479
					},
					{
						GiftName = "Dual Loveclaw Blade",
						GiftId = 3263710486,
						Item = v.createListReward({
							v.createSwordReward("Dual Loveclaw Blade"),
							v.createExplosionReward("Meowstruck"),
							v.createEmoteReward("Emote874")
						}),
						ProductId = 3263710480
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "LoveclawPackRootStartTime",
		RootFFlagEndTime = "LoveclawPackRootEndTime",
		FFlagStartTime = "LoveclawScytheStartTime",
		FFlagEndTime = "LoveclawScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Loveclaw Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Loveclaw Scythe"),
				ShowRoom = "LoveclawScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Loveclaw Scythe",
						GiftId = 3263710481,
						Item = v.createListReward({
							v.createSwordReward("Loveclaw Scythe"),
							v.createExplosionReward("Catalyzer"),
							v.createEmoteReward("Emote875")
						}),
						ProductId = 3263710478
					},
					{
						GiftName = "Dual Loveclaw Scythe",
						GiftId = 3263710487,
						Item = v.createListReward({
							v.createSwordReward("Dual Loveclaw Scythe"),
							v.createExplosionReward("Catalyzer"),
							v.createEmoteReward("Emote876")
						}),
						ProductId = 3263710489
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "LoveclawPackRootStartTime",
		RootFFlagEndTime = "LoveclawPackRootEndTime",
		FFlagStartTime = "LoveclawPackStartTime",
		FFlagEndTime = "LoveclawPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Loveclaw Pack",
				Image = "rbxassetid://90476485255652",
				ShowRoom = "LoveclawPackShowRoom",
				Rewards = {
					{
						GiftName = "Loveclaw Pack",
						GiftId = 3263710484,
						Item = v.createListReward({
							v.createSwordReward("Loveclaw Blade"),
							v.createSwordReward("Loveclaw Scythe"),
							v.createExplosionReward("Meowstruck"),
							v.createEmoteReward("Emote875")
						}),
						ProductId = 3263710485,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Loveclaw Pack",
						GiftId = 3263710482,
						Item = v.createListReward({
							v.createSwordReward("Dual Loveclaw Blade"),
							v.createSwordReward("Dual Loveclaw Scythe"),
							v.createExplosionReward("Catalyzer"),
							v.createEmoteReward("Emote874"),
							v.createEmoteReward("Emote876")
						}),
						ProductId = 3263710483,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}