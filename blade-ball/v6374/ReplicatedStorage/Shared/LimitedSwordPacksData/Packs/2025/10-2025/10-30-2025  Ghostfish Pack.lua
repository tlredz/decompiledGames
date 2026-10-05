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
		RootFFlagStartTime = "GhostfishPackRootStartTime",
		RootFFlagEndTime = "GhostfishPackRootEndTime",
		FFlagStartTime = "GhostfishBladeStartTime",
		FFlagEndTime = "GhostfishBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Ghostfish Blade",
				Image = v2.Icons:GetSwordIcon("Dual Ghostfish Blade"),
				ShowRoom = "GhostfishBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Ghostfish Blade",
						GiftId = 3444321040,
						Item = v.createListReward({ v.createSwordReward("Ghostfish Blade") }),
						ProductId = 3444320986
					},
					{
						GiftName = "Dual Ghostfish Blade",
						GiftId = 3444321047,
						Item = v.createListReward({
							v.createSwordReward("Dual Ghostfish Blade"),
							v.createExplosionReward("Ghostly Vengeance"),
							v.createEmoteReward("Emote1077")
						}),
						ProductId = 3444321046
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "GhostfishPackRootStartTime",
		RootFFlagEndTime = "GhostfishPackRootEndTime",
		FFlagStartTime = "GhostfishBowStartTime",
		FFlagEndTime = "GhostfishBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Ghostfish Bow",
				Image = v2.Icons:GetSwordIcon("Ghostfish Bow"),
				ShowRoom = "GhostfishBowShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Ghostfish Bow",
						GiftId = 3444321044,
						Item = v.createListReward({
							v.createSwordReward("Ghostfish Bow"),
							v.createExplosionReward("Souls Capture"),
							v.createEmoteReward("Emote1078")
						}),
						ProductId = 3444321041
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "GhostfishPackRootStartTime",
		RootFFlagEndTime = "GhostfishPackRootEndTime",
		FFlagStartTime = "GhostfishPackStartTime",
		FFlagEndTime = "GhostfishPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Ghostfish Pack",
				Image = "rbxassetid://127689371719799",
				ShowRoom = "GhostfishPackShowRoom",
				Rewards = {
					{
						GiftName = "Ghostfish Pack",
						GiftId = 3444321049,
						Item = v.createListReward({
							v.createSwordReward("Ghostfish Blade"),
							v.createSwordReward("Ghostfish Bow"),
							v.createExplosionReward("Ghostly Vengeance"),
							v.createEmoteReward("Emote1078")
						}),
						ProductId = 3444321050,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Ghostfish Pack",
						GiftId = 3444321048,
						Item = v.createListReward({
							v.createSwordReward("Dual Ghostfish Blade"),
							v.createSwordReward("Ghostfish Bow"),
							v.createExplosionReward("Souls Capture"),
							v.createEmoteReward("Emote1077"),
							v.createEmoteReward("Emote1078")
						}),
						ProductId = 3444321045,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}