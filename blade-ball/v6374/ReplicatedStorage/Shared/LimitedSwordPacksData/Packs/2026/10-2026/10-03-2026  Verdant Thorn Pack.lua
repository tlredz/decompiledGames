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
		RootFFlagStartTime = "VerdantThornStartTime",
		RootFFlagEndTime = "VerdantThornEndTime",
		FFlagStartTime = "VerdantThornBladeStartTime",
		FFlagEndTime = "VerdantThornBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Verdant Thorn Blade",
				TemplateType = "Sword",
				Image = v2.Icons:GetSwordIcon("Dual Verdant Thorn Blade"),
				Color = Color3.new(0.35, 0.5, 0.1),
				ShowRoom = "VerdantThornBladeShowRoom",
				Rewards = {
					{
						GiftName = "Verdant Thorn Blade",
						GiftId = 3715337877,
						Item = v.createListReward({ v.createSwordReward("Verdant Thorn Blade") }),
						ProductId = 3715337879
					},
					{
						GiftName = "Dual Verdant Thorn Blade",
						GiftId = 3715337884,
						Item = v.createListReward({
							v.createSwordReward("Dual Verdant Thorn Blade"),
							v.createExplosionReward("Thorns Vines"),
							v.createEmoteReward("Emote1285")
						}),
						ProductId = 3715337885
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "VerdantThornStartTime",
		RootFFlagEndTime = "VerdantThornEndTime",
		FFlagStartTime = "VerdantThornLanceStartTime",
		FFlagEndTime = "VerdantThornLanceEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Verdant Thorn Lance",
				TemplateType = "Sword",
				Image = v2.Icons:GetSwordIcon("Verdant Thorn Lance"),
				Color = Color3.new(0.35, 0.5, 0.1),
				ShowRoom = "VerdantThornLanceShowRoom",
				Rewards = {
					{
						GiftName = "Verdant Thorn Lance",
						GiftId = 3715337889,
						Item = v.createListReward({
							v.createSwordReward("Verdant Thorn Lance"),
							v.createExplosionReward("Verdant Anomaly Explosion"),
							v.createEmoteReward("Emote1284")
						}),
						ProductId = 3715337903
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "VerdantThornStartTime",
		RootFFlagEndTime = "VerdantThornEndTime",
		FFlagStartTime = "VerdantThornPackStartTime",
		FFlagEndTime = "VerdantThornPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Verdant Thorn Pack",
				Image = "rbxassetid://73777366385224",
				Color = Color3.new(0.35, 0.5, 0.1),
				ShowRoom = "VerdantThornPackShowRoom",
				Rewards = {
					{
						GiftName = "Verdant Thorn Pack",
						GiftId = 3715337907,
						Item = v.createListReward({
							v.createSwordReward("Verdant Thorn Blade"),
							v.createSwordReward("Verdant Thorn Lance"),
							v.createExplosionReward("Verdant Anomaly Explosion"),
							v.createEmoteReward("Emote1284")
						}),
						ProductId = 3715337908
					},
					{
						GiftName = "Dual Verdant Thorn Pack",
						GiftId = 3715337912,
						Item = v.createListReward({
							v.createSwordReward("Dual Verdant Thorn Blade"),
							v.createSwordReward("Verdant Thorn Lance"),
							v.createExplosionReward("Verdant Anomaly Explosion"),
							v.createEmoteReward("Emote1285"),
							v.createEmoteReward("Emote1284")
						}),
						ProductId = 3715337915
					}
				}
			}
		}
	}
}