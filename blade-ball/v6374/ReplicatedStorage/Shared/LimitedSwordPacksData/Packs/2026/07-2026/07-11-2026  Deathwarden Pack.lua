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
		RootFFlagStartTime = "DeathwardenStartTime",
		RootFFlagEndTime = "DeathwardenEndTime",
		FFlagStartTime = "DeathwardenBladeStartTime",
		FFlagEndTime = "DeathwardenBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Deathwarden Blade",
				Image = v2.Icons:GetSwordIcon("Dual Deathwarden Blade"),
				ShowRoom = "DeathwardenBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Deathwarden Blade",
						GiftId = 3609289389,
						Item = v.createListReward({ v.createSwordReward("Deathwarden Blade") }),
						ProductId = 3609289393
					},
					{
						GiftName = "Dual Deathwarden Blade",
						GiftId = 3609289397,
						Item = v.createListReward({
							v.createSwordReward("Dual Deathwarden Blade"),
							v.createExplosionReward("Deathwarden Flame Explosion"),
							v.createEmoteReward("Emote1246")
						}),
						ProductId = 3609289401
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "DeathwardenStartTime",
		RootFFlagEndTime = "DeathwardenEndTime",
		FFlagStartTime = "DeathwardenLanceStartTime",
		FFlagEndTime = "DeathwardenLanceEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Deathwarden Lance",
				Image = v2.Icons:GetSwordIcon("Deathwarden Lance"),
				ShowRoom = "DeathwardenLanceShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Deathwarden Lance",
						GiftId = 3609289413,
						Item = v.createListReward({
							v.createSwordReward("Deathwarden Lance"),
							v.createExplosionReward("Deathwarden Star Explosion"),
							v.createEmoteReward("Emote1245")
						}),
						ProductId = 3609289415
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "DeathwardenStartTime",
		RootFFlagEndTime = "DeathwardenEndTime",
		FFlagStartTime = "DeathwardenPackStartTime",
		FFlagEndTime = "DeathwardenPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Deathwarden Pack",
				Image = "rbxassetid://78877170450547",
				ShowRoom = "DeathwardenPackShowRoom",
				Rewards = {
					{
						GiftName = "Deathwarden Pack",
						GiftId = 3609289419,
						Item = v.createListReward({
							v.createSwordReward("Deathwarden Blade"),
							v.createSwordReward("Deathwarden Lance"),
							v.createExplosionReward("Deathwarden Flame Explosion"),
							v.createEmoteReward("Emote1245")
						}),
						ProductId = 3609289434,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Deathwarden Pack",
						GiftId = 3609289446,
						Item = v.createListReward({
							v.createSwordReward("Dual Deathwarden Blade"),
							v.createSwordReward("Deathwarden Lance"),
							v.createExplosionReward("Deathwarden Star Explosion"),
							v.createEmoteReward("Emote1246"),
							v.createEmoteReward("Emote1245")
						}),
						ProductId = 3609289450,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}