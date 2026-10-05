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
		RootFFlagStartTime = "Luv4PainRootStartTime",
		RootFFlagEndTime = "Luv4PainRoot2EndTime",
		FFlagStartTime = "Luv4PainBladeStartTime",
		FFlagEndTime = "Luv4PainBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Luv4Pain Blade",
				Image = v2.Icons:GetSwordIcon("Dual Luv4Pain Blade"),
				ShowRoom = "Luv4PainBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Luv4Pain Blade",
						GiftId = 3604305559,
						Item = v.createListReward({ v.createSwordReward("Luv4Pain Blade") }),
						ProductId = 3604305563
					},
					{
						GiftName = "Dual Luv4Pain Blade",
						GiftId = 3604305568,
						Item = v.createListReward({
							v.createSwordReward("Dual Luv4Pain Blade"),
							v.createExplosionReward("Luv4Pain Explosion"),
							v.createEmoteReward("Emote1229")
						}),
						ProductId = 3604305572
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "Luv4PainRootStartTime",
		RootFFlagEndTime = "Luv4PainRoot2EndTime",
		FFlagStartTime = "Luv4PainScytheStartTime",
		FFlagEndTime = "Luv4PainScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Luv4Pain Scythe",
				Image = v2.Icons:GetSwordIcon("Luv4Pain Scythe"),
				ShowRoom = "Luv4PainScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Luv4Pain Scythe",
						GiftId = 3604305586,
						Item = v.createListReward({
							v.createSwordReward("Luv4Pain Scythe"),
							v.createExplosionReward("Luv4Pain Quote"),
							v.createEmoteReward("Emote1230")
						}),
						ProductId = 3604305588
					},
					{
						GiftName = "Dual Luv4Pain Scythe",
						GiftId = 3604305590,
						Item = v.createListReward({
							v.createSwordReward("Dual Luv4Pain Scythe"),
							v.createExplosionReward("Luv4Pain Quote"),
							v.createEmoteReward("Emote1231")
						}),
						ProductId = 3604305607
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "Luv4PainRootStartTime",
		RootFFlagEndTime = "Luv4PainRoot2EndTime",
		FFlagStartTime = "Luv4PainPackStartTime",
		FFlagEndTime = "Luv4PainPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Luv4Pain Pack",
				Image = "rbxassetid://85671033460802",
				ShowRoom = "Luv4PainPackShowRoom",
				Rewards = {
					{
						GiftName = "Luv4Pain Pack",
						GiftId = 3604305611,
						Item = v.createListReward({
							v.createSwordReward("Luv4Pain Blade"),
							v.createSwordReward("Luv4Pain Scythe"),
							v.createExplosionReward("Luv4Pain Explosion"),
							v.createEmoteReward("Emote1230")
						}),
						ProductId = 3604305613,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Luv4Pain Pack",
						GiftId = 3604305617,
						Item = v.createListReward({
							v.createSwordReward("Dual Luv4Pain Blade"),
							v.createSwordReward("Dual Luv4Pain Scythe"),
							v.createExplosionReward("Luv4Pain Quote"),
							v.createEmoteReward("Emote1229"),
							v.createEmoteReward("Emote1231")
						}),
						ProductId = 3604305627,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}