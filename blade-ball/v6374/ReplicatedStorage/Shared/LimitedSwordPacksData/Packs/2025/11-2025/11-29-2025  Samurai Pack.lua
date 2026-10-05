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
		RootFFlagStartTime = "SamuraiPackRootStartTime",
		RootFFlagEndTime = "SamuraiPackRootEndTime",
		FFlagStartTime = "SamuraiBladeStartTime",
		FFlagEndTime = "SamuraiBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Samurai Blade",
				Image = v2.Icons:GetSwordIcon("Dual Samurai Katana"),
				ShowRoom = "SamuraiBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Samurai Blade",
						GiftId = 3467219506,
						Item = v.createListReward({ v.createSwordReward("Samurai Katana") }),
						ProductId = 3467219500
					},
					{
						GiftName = "Dual Samurai Blade",
						GiftId = 3467219499,
						Item = v.createListReward({
							v.createSwordReward("Dual Samurai Katana"),
							v.createExplosionReward("Samurai Tsujigiri"),
							v.createEmoteReward("Emote1090")
						}),
						ProductId = 3467219501
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "SamuraiPackRootStartTime",
		RootFFlagEndTime = "SamuraiPackRootEndTime",
		FFlagStartTime = "SamuraiBowStartTime",
		FFlagEndTime = "SamuraiBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Samurai Bow",
				Image = v2.Icons:GetSwordIcon("Samurai Bow"),
				ShowRoom = "SamuraiBowShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Samurai Bow",
						GiftId = 3467219507,
						Item = v.createListReward({
							v.createSwordReward("Samurai Bow"),
							v.createExplosionReward("Samurai Rampage"),
							v.createEmoteReward("Emote1091")
						}),
						ProductId = 3467219502
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "SamuraiPackRootStartTime",
		RootFFlagEndTime = "SamuraiPackRootEndTime",
		FFlagStartTime = "SamuraiPackStartTime",
		FFlagEndTime = "SamuraiPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Samurai Pack",
				Image = "rbxassetid://97869568316790",
				ShowRoom = "SamuraiPackShowRoom",
				Rewards = {
					{
						GiftName = "Samurai Pack",
						GiftId = 3467219505,
						Item = v.createListReward({
							v.createSwordReward("Samurai Katana"),
							v.createSwordReward("Samurai Bow"),
							v.createExplosionReward("Samurai Tsujigiri"),
							v.createEmoteReward("Emote1091")
						}),
						ProductId = 3467219503,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Samurai Pack",
						GiftId = 3467219508,
						Item = v.createListReward({
							v.createSwordReward("Dual Samurai Katana"),
							v.createSwordReward("Samurai Bow"),
							v.createExplosionReward("Samurai Rampage"),
							v.createEmoteReward("Emote1090"),
							v.createEmoteReward("Emote1091")
						}),
						ProductId = 3467219504,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}