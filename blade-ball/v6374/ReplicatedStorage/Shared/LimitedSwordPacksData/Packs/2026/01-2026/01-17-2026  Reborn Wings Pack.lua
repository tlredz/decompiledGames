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
		RootFFlagStartTime = "RebornWingsPackRootStartTime",
		RootFFlagEndTime = "RebornWingsPackRootEndTime",
		FFlagStartTime = "RebornWingsSwordStartTime",
		FFlagEndTime = "RebornWingsSwordEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Reborn Wings Blade",
				Image = v2.Icons:GetSwordIcon("Dual Reborn Wings Blade"),
				ShowRoom = "RebornWingsBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Reborn Wings Blade",
						GiftId = 3511637342,
						Item = v.createListReward({ v.createSwordReward("Reborn Wings Blade") }),
						ProductId = 3511637339
					},
					{
						GiftName = "Dual Reborn Wings Blade",
						GiftId = 3511637346,
						Item = v.createListReward({
							v.createSwordReward("Dual Reborn Wings Blade"),
							v.createExplosionReward("Wings Of Hope"),
							v.createEmoteReward("Emote1125")
						}),
						ProductId = 3511637344
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "RebornWingsPackRootStartTime",
		RootFFlagEndTime = "RebornWingsPackRootEndTime",
		FFlagStartTime = "RebornWingsBowStartTime",
		FFlagEndTime = "RebornWingsBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Reborn Wings Bow",
				Image = v2.Icons:GetSwordIcon("Reborn Wings Bow"),
				ShowRoom = "RebornWingsBowShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Reborn Wings Bow",
						GiftId = 3511637345,
						Item = v.createListReward({
							v.createSwordReward("Reborn Wings Bow"),
							v.createExplosionReward("Reborn Memories"),
							v.createEmoteReward("Emote1126")
						}),
						ProductId = 3511637341
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "RebornWingsPackRootStartTime",
		RootFFlagEndTime = "RebornWingsPackRootEndTime",
		FFlagStartTime = "RebornWingsPackStartTime",
		FFlagEndTime = "RebornWingsPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Reborn Wings Pack",
				Image = "rbxassetid://126032524906323",
				ShowRoom = "RebornWingsPackShowRoom",
				Rewards = {
					{
						GiftName = "Reborn Wings Pack",
						GiftId = 3511637337,
						Item = v.createListReward({
							v.createSwordReward("Reborn Wings Blade"),
							v.createSwordReward("Reborn Wings Bow"),
							v.createExplosionReward("Wings Of Hope"),
							v.createEmoteReward("Emote1126")
						}),
						ProductId = 3511637338,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Reborn Wings Pack",
						GiftId = 3511637343,
						Item = v.createListReward({
							v.createSwordReward("Dual Reborn Wings Blade"),
							v.createSwordReward("Reborn Wings Bow"),
							v.createExplosionReward("Reborn Memories"),
							v.createEmoteReward("Emote1125"),
							v.createEmoteReward("Emote1126")
						}),
						ProductId = 3511637340,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}