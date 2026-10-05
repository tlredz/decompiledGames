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
		RootFFlagStartTime = "IronrosePackRootStartTime",
		RootFFlagEndTime = "IronrosePackRootEndTime",
		FFlagStartTime = "IronroseBladeStartTime",
		FFlagEndTime = "IronroseBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Ironrose Blade",
				Image = v2.Icons:GetSwordIcon("Dual Ironrose Blade"),
				ShowRoom = "IronroseBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Ironrose Blade",
						GiftId = 3462318412,
						Item = v.createListReward({ v.createSwordReward("Ironrose Blade") }),
						ProductId = 3462318411
					},
					{
						GiftName = "Dual Ironrose Blade",
						GiftId = 3462318413,
						Item = v.createListReward({
							v.createSwordReward("Dual Ironrose Blade"),
							v.createExplosionReward("Rose Gas"),
							v.createEmoteReward("Emote1088")
						}),
						ProductId = 3462318416
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "IronrosePackRootStartTime",
		RootFFlagEndTime = "IronrosePackRootEndTime",
		FFlagStartTime = "IronroseLanceStartTime",
		FFlagEndTime = "IronroseLanceEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Ironrose Lance",
				Image = v2.Icons:GetSwordIcon("Ironrose Lance"),
				ShowRoom = "IronroseLanceShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Ironrose Lance",
						GiftId = 3462318418,
						Item = v.createListReward({
							v.createSwordReward("Ironrose Lance"),
							v.createExplosionReward("Dimension of the Forgotten"),
							v.createEmoteReward("Emote1089")
						}),
						ProductId = 3462318419
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "IronrosePackRootStartTime",
		RootFFlagEndTime = "IronrosePackRootEndTime",
		FFlagStartTime = "IronrosePackStartTime",
		FFlagEndTime = "IronrosePackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Ironrose Pack",
				Image = "rbxassetid://73110001986265",
				ShowRoom = "IronrosePackShowRoom",
				Rewards = {
					{
						GiftName = "Ironrose Pack",
						GiftId = 3462318417,
						Item = v.createListReward({
							v.createSwordReward("Ironrose Blade"),
							v.createSwordReward("Ironrose Lance"),
							v.createExplosionReward("Rose Gas"),
							v.createEmoteReward("Emote1089")
						}),
						ProductId = 3462318420,
						DiscountedFrom = 2999
					},
					{
						GiftName = "Dual Ironrose Pack",
						GiftId = 3462318415,
						Item = v.createListReward({
							v.createSwordReward("Dual Ironrose Blade"),
							v.createSwordReward("Ironrose Lance"),
							v.createExplosionReward("Dimension of the Forgotten"),
							v.createEmoteReward("Emote1089"),
							v.createEmoteReward("Emote1088")
						}),
						ProductId = 3462318414,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}