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
		RootFFlagStartTime = "GothicHeartpiercerStartTime",
		RootFFlagEndTime = "GothicHeartpiercerEndTime",
		FFlagStartTime = "GothicHeartpiercerBladeStartTime",
		FFlagEndTime = "GothicHeartpiercerBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Gothic Heartpiercer Blade",
				TemplateType = "Sword",
				Image = v2.Icons:GetSwordIcon("Dual Gothic Heartpiercer Blade"),
				Color = Color3.new(0.2, 0.15, 0.65),
				ShowRoom = "GothicHeartpiercerBladeShowRoom",
				Rewards = {
					{
						GiftName = "Gothic Heartpiercer Blade",
						GiftId = 3713500716,
						Item = v.createListReward({ v.createSwordReward("Gothic Heartpiercer Blade") }),
						ProductId = 3713500719
					},
					{
						GiftName = "Dual Gothic Heartpiercer Blade",
						GiftId = 3713500723,
						Item = v.createListReward({
							v.createSwordReward("Dual Gothic Heartpiercer Blade"),
							v.createExplosionReward("Mindset Mess Explosion"),
							v.createEmoteReward("Emote1279")
						}),
						ProductId = 3713500726
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "GothicHeartpiercerStartTime",
		RootFFlagEndTime = "GothicHeartpiercerEndTime",
		FFlagStartTime = "GothicHeartpiercerBowStartTime",
		FFlagEndTime = "GothicHeartpiercerBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Gothic Heartpiercer Bow",
				TemplateType = "Sword",
				Image = v2.Icons:GetSwordIcon("Gothic Heartpiercer Bow"),
				Color = Color3.new(0.2, 0.15, 0.65),
				ShowRoom = "GothicHeartpiercerBowShowRoom",
				Rewards = {
					{
						GiftName = "Gothic Heartpiercer Bow",
						GiftId = 3713500728,
						Item = v.createListReward({
							v.createSwordReward("Gothic Heartpiercer Bow"),
							v.createExplosionReward("Gothic Heartpier Explosion"),
							v.createEmoteReward("Emote1280")
						}),
						ProductId = 3713500731
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "GothicHeartpiercerStartTime",
		RootFFlagEndTime = "GothicHeartpiercerEndTime",
		FFlagStartTime = "GothicHeartpiercerPackStartTime",
		FFlagEndTime = "GothicHeartpiercerPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Gothic Heartpiercer Pack",
				Image = "rbxassetid://95617242852926",
				Color = Color3.new(0.2, 0.15, 0.65),
				ShowRoom = "GothicHeartpiercerPackShowRoom",
				Rewards = {
					{
						GiftName = "Gothic Heartpiercer Pack",
						GiftId = 3713500736,
						Item = v.createListReward({
							v.createSwordReward("Gothic Heartpiercer Blade"),
							v.createSwordReward("Gothic Heartpiercer Bow"),
							v.createExplosionReward("Mindset Mess Explosion"),
							v.createEmoteReward("Emote1280")
						}),
						ProductId = 3713500737
					},
					{
						GiftName = "Dual Gothic Heartpiercer Pack",
						GiftId = 3713500739,
						Item = v.createListReward({
							v.createSwordReward("Dual Gothic Heartpiercer Blade"),
							v.createSwordReward("Gothic Heartpiercer Bow"),
							v.createExplosionReward("Gothic Heartpier Explosion"),
							v.createEmoteReward("Emote1279"),
							v.createEmoteReward("Emote1280")
						}),
						ProductId = 3713500740
					}
				}
			}
		}
	}
}