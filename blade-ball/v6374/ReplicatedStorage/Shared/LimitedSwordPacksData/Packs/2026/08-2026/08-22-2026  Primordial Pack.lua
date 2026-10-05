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
		RootFFlagStartTime = "PrimordialStartTime",
		RootFFlagEndTime = "PrimordialEndTime",
		FFlagStartTime = "PrimordialBladeStartTime",
		FFlagEndTime = "PrimordialBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Primordial Blade",
				TemplateType = "Sword",
				Image = v2.Icons:GetSwordIcon("Dual Primordial Blade"),
				ShowRoom = "PrimordialBladeShowRoom",
				Rewards = {
					{
						GiftName = "Primordial Blade",
						GiftId = 3709303647,
						Item = v.createListReward({ v.createSwordReward("Primordial Blade") }),
						ProductId = 3709303651
					},
					{
						GiftName = "Dual Primordial Blade",
						GiftId = 3709303654,
						Item = v.createListReward({
							v.createSwordReward("Dual Primordial Blade"),
							v.createExplosionReward("Primordial Loop Explosion"),
							v.createEmoteReward("Emote1265")
						}),
						ProductId = 3709303657
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "PrimordialStartTime",
		RootFFlagEndTime = "PrimordialEndTime",
		FFlagStartTime = "PrimordialLanceStartTime",
		FFlagEndTime = "PrimordialLanceEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Primordial Lance",
				TemplateType = "Sword",
				Image = v2.Icons:GetSwordIcon("Primordial Lance"),
				ShowRoom = "PrimordialLanceShowRoom",
				Rewards = {
					{
						GiftName = "Primordial Lance",
						GiftId = 3709303666,
						Item = v.createListReward({
							v.createSwordReward("Primordial Lance"),
							v.createExplosionReward("Primordial Dust Explosion"),
							v.createEmoteReward("Emote1266")
						}),
						ProductId = 3709303672
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "PrimordialStartTime",
		RootFFlagEndTime = "PrimordialEndTime",
		FFlagStartTime = "PrimordialPackStartTime",
		FFlagEndTime = "PrimordialPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Primordial Pack",
				Image = "rbxassetid://79030464073399",
				ShowRoom = "PrimordialPackShowRoom",
				Rewards = {
					{
						GiftName = "Primordial Pack",
						GiftId = 3709303674,
						Item = v.createListReward({
							v.createSwordReward("Primordial Blade"),
							v.createSwordReward("Primordial Lance"),
							v.createExplosionReward("Primordial Loop Explosion"),
							v.createEmoteReward("Emote1266")
						}),
						ProductId = 3709303676
					},
					{
						GiftName = "Dual Primordial Pack",
						GiftId = 3709303682,
						Item = v.createListReward({
							v.createSwordReward("Dual Primordial Blade"),
							v.createSwordReward("Primordial Lance"),
							v.createExplosionReward("Primordial Dust Explosion"),
							v.createEmoteReward("Emote1265"),
							v.createEmoteReward("Emote1266")
						}),
						ProductId = 3709303685
					}
				}
			}
		}
	}
}