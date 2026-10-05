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
		RootFFlagStartTime = "EclipsePackRootStartTime",
		RootFFlagEndTime = "EclipsePackRootEndTime",
		FFlagStartTime = "EclipseGleamStartTime",
		FFlagEndTime = "EclipseGleamEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Eclipse Gleam",
				Image = v2.Icons:GetSwordIcon("Dual Eclipse Gleam"),
				ShowRoom = "EclipseGleamShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Eclipse Gleam",
						GiftId = 1839260545,
						Item = v.createListReward({ v.createSwordReward("Eclipse Gleam") }),
						ProductId = 1839260547
					},
					{
						GiftName = "Dual Eclipse Gleam",
						GiftId = 1839260554,
						Item = v.createListReward({
							v.createSwordReward("Dual Eclipse Gleam"),
							v.createExplosionReward("Void Beam"),
							v.createEmoteReward("Emote362")
						}),
						ProductId = 1839260553
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "EclipsePackRootStartTime",
		RootFFlagEndTime = "EclipsePackRootEndTime",
		FFlagStartTime = "EclipseBlasterStartTime",
		FFlagEndTime = "EclipseBlasterEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Eclipse Blaster",
				Image = v2.Icons:GetSwordIcon("Dual Eclipse Blaster"),
				ShowRoom = "EclipseBlasterShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Eclipse Blaster",
						GiftId = 1839260551,
						Item = v.createListReward({
							v.createSwordReward("Eclipse Blaster"),
							v.createExplosionReward("Penumbra Explosion"),
							v.createEmoteReward("Emote363")
						}),
						ProductId = 1839260552
					},
					{
						GiftName = "Dual Eclipse Blaster",
						GiftId = 1839260542,
						Item = v.createListReward({
							v.createSwordReward("Dual Eclipse Blaster"),
							v.createExplosionReward("Penumbra Explosion"),
							v.createEmoteReward("Emote364")
						}),
						ProductId = 1839260544
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "EclipsePackRootStartTime",
		RootFFlagEndTime = "EclipsePackRootEndTime",
		FFlagStartTime = "EclipsePackStartTime",
		FFlagEndTime = "EclipsePackEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Eclipse Pack",
				Image = "rbxassetid://17686345160",
				ShowRoom = "EclipsePackShowRoom",
				Rewards = {
					{
						GiftName = "Eclipse Pack",
						GiftId = 1839260543,
						Item = v.createListReward({
							v.createSwordReward("Eclipse Gleam"),
							v.createSwordReward("Eclipse Blaster"),
							v.createExplosionReward("Void Beam"),
							v.createEmoteReward("Emote363")
						}),
						ProductId = 1839260550,
						DiscountedFrom = 2000
					},
					{
						GiftName = "Dual Eclipse Pack",
						GiftId = 1839260549,
						Item = v.createListReward({
							v.createSwordReward("Dual Eclipse Gleam"),
							v.createSwordReward("Dual Eclipse Blaster"),
							v.createExplosionReward("Penumbra Explosion"),
							v.createEmoteReward("Emote362"),
							v.createEmoteReward("Emote364")
						}),
						ProductId = 1839260546,
						DiscountedFrom = 3000
					}
				}
			}
		}
	}
}