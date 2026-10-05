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
		RootFFlagStartTime = "PermafrostPackRootStartTime",
		RootFFlagEndTime = "PermafrostPackRootEndTime",
		FFlagStartTime = "PermafrostBladeStartTime",
		FFlagEndTime = "PermafrostBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Permafrost Blade",
				Image = v2.Icons:GetSwordIcon("Dual Permafrost Blade"),
				ShowRoom = "PermafrostBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Permafrost Blade",
						GiftId = 3245805313,
						Item = v.createListReward({ v.createSwordReward("Permafrost Blade") }),
						ProductId = 3245805317
					},
					{
						GiftName = "Dual Permafrost Blade",
						GiftId = 3245805309,
						Item = v.createListReward({
							v.createSwordReward("Dual Permafrost Blade"),
							v.createExplosionReward("Frosted Stone"),
							v.createEmoteReward("Emote847")
						}),
						ProductId = 3245805315
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "PermafrostPackRootStartTime",
		RootFFlagEndTime = "PermafrostPackRootEndTime",
		FFlagStartTime = "PermafrostStaffStartTime",
		FFlagEndTime = "PermafrostStaffEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Permafrost Staff",
				Image = v2.Icons:GetSwordIcon("Permafrost Staff"),
				ShowRoom = "PermafrostStaffShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Permafrost Staff",
						GiftId = 3245805314,
						Item = v.createListReward({
							v.createSwordReward("Permafrost Staff"),
							v.createExplosionReward("Frosted Core"),
							v.createEmoteReward("Emote846")
						}),
						ProductId = 3245805312
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "PermafrostPackRootStartTime",
		RootFFlagEndTime = "PermafrostPackRootEndTime",
		FFlagStartTime = "PermafrostPackStartTime",
		FFlagEndTime = "PermafrostPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Permafrost Pack",
				Image = "rbxassetid://132138381588858",
				ShowRoom = "PermafrostPackShowRoom",
				Rewards = {
					{
						GiftName = "Permafrost Pack",
						GiftId = 3245805308,
						Item = v.createListReward({
							v.createSwordReward("Permafrost Blade"),
							v.createSwordReward("Permafrost Staff"),
							v.createExplosionReward("Frosted Stone"),
							v.createEmoteReward("Emote846")
						}),
						ProductId = 3245805316,
						DiscountedFrom = 2999
					},
					{
						GiftName = "Dual Permafrost Pack",
						GiftId = 3245805311,
						Item = v.createListReward({
							v.createSwordReward("Dual Permafrost Blade"),
							v.createSwordReward("Permafrost Staff"),
							v.createExplosionReward("Frosted Core"),
							v.createEmoteReward("Emote846"),
							v.createEmoteReward("Emote847")
						}),
						ProductId = 3245805307,
						DiscountedFrom = 3799
					}
				}
			}
		}
	}
}