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
		RootFFlagStartTime = "Y2KStartTime",
		RootFFlagEndTime = "Y2KEndTime",
		FFlagStartTime = "Y2KBladeStartTime",
		FFlagEndTime = "Y2KBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Y2K Blade",
				Image = v2.Icons:GetSwordIcon("Dual Y2K Blade"),
				ShowRoom = "Y2KBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Y2K Blade",
						GiftId = 3605753516,
						Item = v.createListReward({ v.createSwordReward("Y2K Blade") }),
						ProductId = 3605753518
					},
					{
						GiftName = "Dual Y2K Blade",
						GiftId = 3605753524,
						Item = v.createListReward({
							v.createSwordReward("Dual Y2K Blade"),
							v.createExplosionReward("Y2K Bling Explosion"),
							v.createEmoteReward("Emote1232")
						}),
						ProductId = 3605753528
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "Y2KStartTime",
		RootFFlagEndTime = "Y2KEndTime",
		FFlagStartTime = "Y2KBowStartTime",
		FFlagEndTime = "Y2KBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Y2K Bow",
				Image = v2.Icons:GetSwordIcon("Y2K Bow"),
				ShowRoom = "Y2KBowShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Y2K Bow",
						GiftId = 3605753537,
						Item = v.createListReward({
							v.createSwordReward("Y2K Bow"),
							v.createExplosionReward("Y2K Star Explosion"),
							v.createEmoteReward("Emote1233")
						}),
						ProductId = 3605753539
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "Y2KStartTime",
		RootFFlagEndTime = "Y2KEndTime",
		FFlagStartTime = "Y2KPackStartTime",
		FFlagEndTime = "Y2KPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Y2K Pack",
				Image = "rbxassetid://96632636415935",
				ShowRoom = "Y2KPackShowRoom",
				Rewards = {
					{
						GiftName = "Y2K Pack",
						GiftId = 3605753542,
						Item = v.createListReward({
							v.createSwordReward("Y2K Blade"),
							v.createSwordReward("Y2K Bow"),
							v.createExplosionReward("Y2K Bling Explosion"),
							v.createEmoteReward("Emote1233")
						}),
						ProductId = 3605753545,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Y2K Pack",
						GiftId = 3605753553,
						Item = v.createListReward({
							v.createSwordReward("Dual Y2K Blade"),
							v.createSwordReward("Y2K Bow"),
							v.createExplosionReward("Y2K Star Explosion"),
							v.createEmoteReward("Emote1232"),
							v.createEmoteReward("Emote1233")
						}),
						ProductId = 3605753558,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}