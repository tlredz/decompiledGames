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
		RootFFlagStartTime = "ShadowMonarchPackRootStartTime",
		RootFFlagEndTime = "ShadowMonarchPackRootEndTime",
		FFlagStartTime = "ShadowMonarchBladeStartTime",
		FFlagEndTime = "ShadowMonarchBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Shadow Monarch Blade",
				Image = v2.Icons:GetSwordIcon("Dual Shadow Monarch Blade"),
				ShowRoom = "ShadowMonarchBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Shadow Monarch Blade",
						GiftId = 3278373819,
						Item = v.createListReward({ v.createSwordReward("Shadow Monarch Blade") }),
						ProductId = 3278373818
					},
					{
						GiftName = "Dual Shadow Monarch Blade",
						GiftId = 3278373824,
						Item = v.createListReward({
							v.createSwordReward("Dual Shadow Monarch Blade"),
							v.createExplosionReward("Rising Monarch"),
							v.createEmoteReward("Emote898")
						}),
						ProductId = 3278373828
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "ShadowMonarchPackRootStartTime",
		RootFFlagEndTime = "ShadowMonarchPackRootEndTime",
		FFlagStartTime = "ShadowMonarchBowStartTime",
		FFlagEndTime = "ShadowMonarchBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Shadow Monarch Bow",
				Image = v2.Icons:GetSwordIcon("Shadow Monarch Bow"),
				ShowRoom = "ShadowMonarchBowShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Shadow Monarch Bow",
						GiftId = 3278373821,
						Item = v.createListReward({
							v.createSwordReward("Shadow Monarch Bow"),
							v.createExplosionReward("Monarch's Star"),
							v.createEmoteReward("Emote899")
						}),
						ProductId = 3278373820
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "ShadowMonarchPackRootStartTime",
		RootFFlagEndTime = "ShadowMonarchPackRootEndTime",
		FFlagStartTime = "ShadowMonarchPackStartTime",
		FFlagEndTime = "ShadowMonarchPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Shadow Monarch Pack",
				Image = "rbxassetid://109109080681205",
				ShowRoom = "ShadowMonarchPackShowRoom",
				Rewards = {
					{
						GiftName = "Shadow Monarch Pack",
						GiftId = 3278373826,
						Item = v.createListReward({
							v.createSwordReward("Shadow Monarch Blade"),
							v.createSwordReward("Shadow Monarch Bow"),
							v.createExplosionReward("Rising Monarch"),
							v.createEmoteReward("Emote899")
						}),
						ProductId = 3278373831,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Shadow Monarch Pack",
						GiftId = 3278373825,
						Item = v.createListReward({
							v.createSwordReward("Dual Shadow Monarch Blade"),
							v.createSwordReward("Shadow Monarch Bow"),
							v.createExplosionReward("Monarch's Star"),
							v.createEmoteReward("Emote899"),
							v.createEmoteReward("Emote898")
						}),
						ProductId = 3278373823,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}