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
		RootFFlagStartTime = "PrismaticGemStartTime",
		RootFFlagEndTime = "PrismaticGemEndTime",
		FFlagStartTime = "PrismaticGemBladeStartTime",
		FFlagEndTime = "PrismaticGemBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Prismatic Gem Blade",
				Image = v2.Icons:GetSwordIcon("Dual Prismatic Gem Blade"),
				ShowRoom = "PrismaticGemBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Prismatic Gem Blade",
						GiftId = 3597162799,
						Item = v.createListReward({ v.createSwordReward("Prismatic Gem Blade") }),
						ProductId = 3597162804
					},
					{
						GiftName = "Dual Prismatic Gem Blade",
						GiftId = 3597162871,
						Item = v.createListReward({
							v.createSwordReward("Dual Prismatic Gem Blade"),
							v.createExplosionReward("Prismatic Rift Explosion"),
							v.createEmoteReward("Emote1220")
						}),
						ProductId = 3597162797
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "PrismaticGemStartTime",
		RootFFlagEndTime = "PrismaticGemEndTime",
		FFlagStartTime = "PrismaticGemScytheStartTime",
		FFlagEndTime = "PrismaticGemScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Prismatic Gem Scythe",
				Image = v2.Icons:GetSwordIcon("Prismatic Gem Scythe"),
				ShowRoom = "PrismaticGemScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Prismatic Gem Scythe",
						GiftId = 3597162872,
						Item = v.createListReward({
							v.createSwordReward("Prismatic Gem Scythe"),
							v.createExplosionReward("Pastel Prism Explosion"),
							v.createEmoteReward("Emote1218")
						}),
						ProductId = 3597162873
					},
					{
						GiftName = "Dual Prismatic Gem Scythe",
						GiftId = 3597162798,
						Item = v.createListReward({
							v.createSwordReward("Dual Prismatic Gem Scythe"),
							v.createExplosionReward("Pastel Prism Explosion"),
							v.createEmoteReward("Emote1219")
						}),
						ProductId = 3597162805
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "PrismaticGemStartTime",
		RootFFlagEndTime = "PrismaticGemEndTime",
		FFlagStartTime = "PrismaticGemPackStartTime",
		FFlagEndTime = "PrismaticGemPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Prismatic Gem Pack",
				Image = "rbxassetid://90664439537325",
				ShowRoom = "PrismaticGemPackShowRoom",
				Rewards = {
					{
						GiftName = "Prismatic Gem Pack",
						GiftId = 3597162834,
						Item = v.createListReward({
							v.createSwordReward("Prismatic Gem Blade"),
							v.createSwordReward("Prismatic Gem Scythe"),
							v.createExplosionReward("Prismatic Rift Explosion"),
							v.createEmoteReward("Emote1218")
						}),
						ProductId = 3597162836,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Prismatic Gem Pack",
						GiftId = 3597162835,
						Item = v.createListReward({
							v.createSwordReward("Dual Prismatic Gem Blade"),
							v.createSwordReward("Dual Prismatic Gem Scythe"),
							v.createExplosionReward("Pastel Prism Explosion"),
							v.createEmoteReward("Emote1220"),
							v.createEmoteReward("Emote1219")
						}),
						ProductId = 3597162806,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}