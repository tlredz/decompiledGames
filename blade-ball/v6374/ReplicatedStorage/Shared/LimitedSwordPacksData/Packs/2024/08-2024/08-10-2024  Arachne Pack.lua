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
		RootFFlagStartTime = "ArachnePackRootStartTime",
		RootFFlagEndTime = "ArachnePackRootEndTime",
		FFlagStartTime = "ArachneSwordStartTime",
		FFlagEndTime = "ArachneSwordEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Arachne Blade",
				Image = v2.Icons:GetSwordIcon("Dual Arachne Blade"),
				ShowRoom = "ArachneBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Arachne Blade",
						GiftId = 1903817274,
						Item = v.createListReward({ v.createSwordReward("Arachne Blade") }),
						ProductId = 1903817287
					},
					{
						GiftName = "Dual Arachne Blade",
						GiftId = 1903817278,
						Item = v.createListReward({
							v.createSwordReward("Dual Arachne Blade"),
							v.createExplosionReward("Web Slinger"),
							v.createEmoteReward("Emote480")
						}),
						ProductId = 1903817280
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "ArachnePackRootStartTime",
		RootFFlagEndTime = "ArachnePackRootEndTime",
		FFlagStartTime = "ArachneScytheStartTime",
		FFlagEndTime = "ArachneScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Arachne Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Arachne Scythe"),
				ShowRoom = "ArachneScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Arachne Scythe",
						GiftId = 1903817286,
						Item = v.createListReward({
							v.createSwordReward("Arachne Scythe"),
							v.createExplosionReward("Spider's Prey"),
							v.createEmoteReward("Emote478")
						}),
						ProductId = 1903817277
					},
					{
						GiftName = "Dual Arachne Scythe",
						GiftId = 1903817275,
						Item = v.createListReward({
							v.createSwordReward("Dual Arachne Scythe"),
							v.createExplosionReward("Spider's Prey"),
							v.createEmoteReward("Emote479")
						}),
						ProductId = 1903817276
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "ArachnePackRootStartTime",
		RootFFlagEndTime = "ArachnePackRootEndTime",
		FFlagStartTime = "ArachnePackStartTime",
		FFlagEndTime = "ArachnePackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Arachne Pack",
				Image = "rbxassetid://18888539143",
				ShowRoom = "ArachnePackShowRoom",
				Rewards = {
					{
						GiftName = "Arachne Pack",
						GiftId = 1903817279,
						Item = v.createListReward({
							v.createSwordReward("Arachne Blade"),
							v.createSwordReward("Arachne Scythe"),
							v.createExplosionReward("Web Slinger"),
							v.createEmoteReward("Emote478")
						}),
						ProductId = 1903817283,
						DiscountedFrom = 2000
					},
					{
						GiftName = "Dual Arachne Pack",
						GiftId = 1903817284,
						Item = v.createListReward({
							v.createSwordReward("Dual Arachne Blade"),
							v.createSwordReward("Dual Arachne Scythe"),
							v.createExplosionReward("Spider's Prey"),
							v.createEmoteReward("Emote480"),
							v.createEmoteReward("Emote479")
						}),
						ProductId = 1903817282,
						DiscountedFrom = 3250
					}
				}
			}
		}
	}
}