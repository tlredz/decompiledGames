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
		RootFFlagStartTime = "DeathCallStartTime",
		RootFFlagEndTime = "DeathCallEndTime",
		FFlagStartTime = "DeathCallBladeStartTime",
		FFlagEndTime = "DeathCallBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Death Call Blade",
				Image = v2.Icons:GetSwordIcon("Dual Death Call Blade"),
				ShowRoom = "DeathCallBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Death Call Blade",
						GiftId = 3560498356,
						Item = v.createListReward({ v.createSwordReward("Death Call Blade") }),
						ProductId = 3560498365
					},
					{
						GiftName = "Dual Death Call Blade",
						GiftId = 3560498363,
						Item = v.createListReward({
							v.createSwordReward("Dual Death Call Blade"),
							v.createExplosionReward("Reaper Summon"),
							v.createEmoteReward("Emote1186")
						}),
						ProductId = 3560498361
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "DeathCallStartTime",
		RootFFlagEndTime = "DeathCallEndTime",
		FFlagStartTime = "DeathCallScytheStartTime",
		FFlagEndTime = "DeathCallScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Death Call Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Death Call Scythe"),
				ShowRoom = "DeathCallScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Death Call Scythe",
						GiftId = 3560498366,
						Item = v.createListReward({
							v.createSwordReward("Death Call Scythe"),
							v.createExplosionReward("Death Call Timer"),
							v.createEmoteReward("Emote1187")
						}),
						ProductId = 3560498360
					},
					{
						GiftName = "Dual Death Call Scythe",
						GiftId = 3560498359,
						Item = v.createListReward({
							v.createSwordReward("Dual Death Call Scythe"),
							v.createExplosionReward("Death Call Timer"),
							v.createEmoteReward("Emote1188")
						}),
						ProductId = 3560498364
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "DeathCallStartTime",
		RootFFlagEndTime = "DeathCallEndTime",
		FFlagStartTime = "DeathCallPackStartTime",
		FFlagEndTime = "DeathCallPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Death Call Pack",
				Image = "rbxassetid://126228606550644",
				ShowRoom = "DeathCallPackShowRoom",
				Rewards = {
					{
						GiftName = "Death Call Pack",
						GiftId = 3560498362,
						Item = v.createListReward({
							v.createSwordReward("Death Call Blade"),
							v.createSwordReward("Death Call Scythe"),
							v.createExplosionReward("Reaper Summon"),
							v.createEmoteReward("Emote1187")
						}),
						ProductId = 3560498367,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Death Call Pack",
						GiftId = 3560498358,
						Item = v.createListReward({
							v.createSwordReward("Dual Death Call Blade"),
							v.createSwordReward("Dual Death Call Scythe"),
							v.createExplosionReward("Death Call Timer"),
							v.createEmoteReward("Emote1186"),
							v.createEmoteReward("Emote1188")
						}),
						ProductId = 3560498357,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}