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
		RootFFlagStartTime = "PurityPackRootStartTime",
		RootFFlagEndTime = "PurityPackRootEndTime",
		FFlagStartTime = "PurityBladeStartTime",
		FFlagEndTime = "PurityBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Purity Blade",
				Image = v2.Icons:GetSwordIcon("Dual Purity Blade"),
				ShowRoom = "PurityBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Purity Blade",
						GiftId = 3296584279,
						Item = v.createListReward({ v.createSwordReward("Purity Blade") }),
						ProductId = 3296584278
					},
					{
						GiftName = "Dual Purity Blade",
						GiftId = 3296584280,
						Item = v.createListReward({
							v.createSwordReward("Dual Purity Blade"),
							v.createExplosionReward("Pure Power"),
							v.createEmoteReward("Emote930")
						}),
						ProductId = 3296584281
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "PurityPackRootStartTime",
		RootFFlagEndTime = "PurityPackRootEndTime",
		FFlagStartTime = "PurityBowStartTime",
		FFlagEndTime = "PurityBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Purity Bow",
				Image = v2.Icons:GetSwordIcon("Purity Bow"),
				ShowRoom = "PurityBowShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Purity Bow",
						GiftId = 3296584282,
						Item = v.createListReward({
							v.createSwordReward("Purity Bow"),
							v.createExplosionReward("Purity Foundation"),
							v.createEmoteReward("Emote931")
						}),
						ProductId = 3296584287
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "PurityPackRootStartTime",
		RootFFlagEndTime = "PurityPackRootEndTime",
		FFlagStartTime = "PurityPackStartTime",
		FFlagEndTime = "PurityPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Purity Pack",
				Image = "rbxassetid://109066858612278",
				ShowRoom = "PurityPackShowRoom",
				Rewards = {
					{
						GiftName = "Purity Pack",
						GiftId = 3296584283,
						Item = v.createListReward({
							v.createSwordReward("Purity Blade"),
							v.createSwordReward("Purity Bow"),
							v.createExplosionReward("Pure Power"),
							v.createEmoteReward("Emote931")
						}),
						ProductId = 3296584285,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Purity Pack",
						GiftId = 3296584284,
						Item = v.createListReward({
							v.createSwordReward("Dual Purity Blade"),
							v.createSwordReward("Purity Bow"),
							v.createExplosionReward("Purity Foundation"),
							v.createEmoteReward("Emote931"),
							v.createEmoteReward("Emote930")
						}),
						ProductId = 3296584286,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}