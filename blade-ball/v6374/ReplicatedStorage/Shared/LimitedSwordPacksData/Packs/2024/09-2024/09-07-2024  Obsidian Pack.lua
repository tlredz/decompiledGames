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
		RootFFlagStartTime = "ObsidianPackRootStartTime",
		RootFFlagEndTime = "ObsidianPackRootEndTime",
		FFlagStartTime = "ObsidianSwordStartTime",
		FFlagEndTime = "ObsidianSwordEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Obsidian Blade",
				Image = v2.Icons:GetSwordIcon("Dual Obsidian Blade"),
				ShowRoom = "ObsidianBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Obsidian Blade",
						GiftId = 1928508667,
						Item = v.createListReward({ v.createSwordReward("Obsidian Blade") }),
						ProductId = 1928508668
					},
					{
						GiftName = "Dual Obsidian Blade",
						GiftId = 1928508666,
						Item = v.createListReward({
							v.createSwordReward("Dual Obsidian Blade"),
							v.createExplosionReward("Obsidian Shock"),
							v.createEmoteReward("Emote519")
						}),
						ProductId = 1928508674
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "ObsidianPackRootStartTime",
		RootFFlagEndTime = "ObsidianPackRootEndTime",
		FFlagStartTime = "ObsidianScytheStartTime",
		FFlagEndTime = "ObsidianScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Obsidian Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Obsidian Scythe"),
				ShowRoom = "ObsidianScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Obsidian Scythe",
						GiftId = 1928508665,
						Item = v.createListReward({
							v.createSwordReward("Obsidian Scythe"),
							v.createExplosionReward("Obsidian Chains"),
							v.createEmoteReward("Emote520")
						}),
						ProductId = 1928508662
					},
					{
						GiftName = "Dual Obsidian Scythe",
						GiftId = 1928508671,
						Item = v.createListReward({
							v.createSwordReward("Dual Obsidian Scythe"),
							v.createExplosionReward("Obsidian Chains"),
							v.createEmoteReward("Emote521")
						}),
						ProductId = 1928508669
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "ObsidianPackRootStartTime",
		RootFFlagEndTime = "ObsidianPackRootEndTime",
		FFlagStartTime = "ObsidianPackStartTime",
		FFlagEndTime = "ObsidianPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Obsidian Pack",
				Image = "rbxassetid://104041232976407",
				ShowRoom = "ObsidianPackShowRoom",
				Rewards = {
					{
						GiftName = "Obsidian Pack",
						GiftId = 1928508670,
						Item = v.createListReward({
							v.createSwordReward("Obsidian Blade"),
							v.createSwordReward("Obsidian Scythe"),
							v.createExplosionReward("Obsidian Shock"),
							v.createEmoteReward("Emote520")
						}),
						ProductId = 1928508663,
						DiscountedFrom = 2000
					},
					{
						GiftName = "Dual Obsidian Pack",
						GiftId = 1928508664,
						Item = v.createListReward({
							v.createSwordReward("Dual Obsidian Blade"),
							v.createSwordReward("Dual Obsidian Scythe"),
							v.createExplosionReward("Obsidian Chains"),
							v.createEmoteReward("Emote519"),
							v.createEmoteReward("Emote521")
						}),
						ProductId = 1928508673,
						DiscountedFrom = 3000
					}
				}
			}
		}
	}
}