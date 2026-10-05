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
		RootFFlagStartTime = "StrawberryCakeStartTime",
		RootFFlagEndTime = "StrawberryCakeEndTime",
		FFlagStartTime = "StrawberryCakeBladeStartTime",
		FFlagEndTime = "StrawberryCakeBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Strawberry Cake Blade",
				Image = v2.Icons:GetSwordIcon("Dual Strawberry Cake Blade"),
				ShowRoom = "StrawberryCakeBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Strawberry Cake Blade",
						GiftId = 3602994111,
						Item = v.createListReward({ v.createSwordReward("Strawberry Cake Blade") }),
						ProductId = 3602994112
					},
					{
						GiftName = "Dual Strawberry Cake Blade",
						GiftId = 3602994134,
						Item = v.createListReward({
							v.createSwordReward("Dual Strawberry Cake Blade"),
							v.createExplosionReward("Red Strawberry Garden"),
							v.createEmoteReward("Emote1227")
						}),
						ProductId = 3602994124
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "StrawberryCakeStartTime",
		RootFFlagEndTime = "StrawberryCakeEndTime",
		FFlagStartTime = "StrawberryCakeLanceStartTime",
		FFlagEndTime = "StrawberryCakeLanceEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Strawberry Cake Lance",
				Image = v2.Icons:GetSwordIcon("Strawberry Cake Lance"),
				ShowRoom = "StrawberryCakeLanceShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Strawberry Cake Lance",
						GiftId = 3602994116,
						Item = v.createListReward({
							v.createSwordReward("Strawberry Cake Lance"),
							v.createExplosionReward("Crystal Strawberry Explosion"),
							v.createEmoteReward("Emote1228")
						}),
						ProductId = 3602994117
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "StrawberryCakeStartTime",
		RootFFlagEndTime = "StrawberryCakeEndTime",
		FFlagStartTime = "StrawberryCakePackStartTime",
		FFlagEndTime = "StrawberryCakePackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Strawberry Cake Pack",
				Image = "rbxassetid://108749095252401",
				ShowRoom = "StrawberryCakePackShowRoom",
				Rewards = {
					{
						GiftName = "Strawberry Cake Pack",
						GiftId = 3602994118,
						Item = v.createListReward({
							v.createSwordReward("Strawberry Cake Blade"),
							v.createSwordReward("Strawberry Cake Lance"),
							v.createExplosionReward("Red Strawberry Garden"),
							v.createEmoteReward("Emote1228")
						}),
						ProductId = 3602994110,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Strawberry Cake Pack",
						GiftId = 3602994123,
						Item = v.createListReward({
							v.createSwordReward("Dual Strawberry Cake Blade"),
							v.createSwordReward("Strawberry Cake Lance"),
							v.createExplosionReward("Crystal Strawberry Explosion"),
							v.createEmoteReward("Emote1227"),
							v.createEmoteReward("Emote1228")
						}),
						ProductId = 3602994122,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}