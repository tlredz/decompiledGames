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
		RootFFlagStartTime = "MalicePackRootStartTime",
		RootFFlagEndTime = "MalicePackRootEndTime",
		FFlagStartTime = "MaliceBladeStartTime",
		FFlagEndTime = "MaliceBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Malice Blade",
				Image = v2.Icons:GetSwordIcon("Dual Malice Blade"),
				ShowRoom = "MaliceBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Malice Blade",
						GiftId = 2147058745,
						Item = v.createListReward({ v.createSwordReward("Malice Blade") }),
						ProductId = 2147058748
					},
					{
						GiftName = "Dual Malice Blade",
						GiftId = 2147058746,
						Item = v.createListReward({
							v.createSwordReward("Dual Malice Blade"),
							v.createExplosionReward("Malice Beam"),
							v.createEmoteReward("Emote559")
						}),
						ProductId = 2147058756
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "MalicePackRootStartTime",
		RootFFlagEndTime = "MalicePackRootEndTime",
		FFlagStartTime = "MaliceParasolStartTime",
		FFlagEndTime = "MaliceParasolEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Malice Parasol",
				Image = v2.Icons:GetSwordIcon("Malice Parasol"),
				ShowRoom = "MaliceParasolShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Malice Parasol",
						GiftId = 2147058747,
						Item = v.createListReward({
							v.createSwordReward("Malice Parasol"),
							v.createExplosionReward("Malice Flare"),
							v.createEmoteReward("Emote560")
						}),
						ProductId = 2147058749
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "MalicePackRootStartTime",
		RootFFlagEndTime = "MalicePackRootEndTime",
		FFlagStartTime = "MalicePackStartTime",
		FFlagEndTime = "MalicePackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Malice Pack",
				Image = "rbxassetid://96756603579493",
				ShowRoom = "MalicePackShowRoom",
				Rewards = {
					{
						GiftName = "Malice Pack",
						GiftId = 2147058754,
						Item = v.createListReward({
							v.createSwordReward("Malice Blade"),
							v.createSwordReward("Malice Parasol"),
							v.createExplosionReward("Malice Flare"),
							v.createEmoteReward("Emote560")
						}),
						ProductId = 2147058752,
						DiscountedFrom = 2799
					},
					{
						GiftName = "Dual Malice Pack",
						GiftId = 2147058750,
						Item = v.createListReward({
							v.createSwordReward("Dual Malice Blade"),
							v.createSwordReward("Malice Parasol"),
							v.createExplosionReward("Malice Flare"),
							v.createEmoteReward("Emote559"),
							v.createEmoteReward("Emote560")
						}),
						ProductId = 2147058751,
						DiscountedFrom = 3500
					}
				}
			}
		}
	}
}