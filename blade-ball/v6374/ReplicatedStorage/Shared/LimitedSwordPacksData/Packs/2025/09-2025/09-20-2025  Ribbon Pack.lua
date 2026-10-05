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
		RootFFlagStartTime = "RibbonPackRootStartTime",
		RootFFlagEndTime = "RibbonPackRootEndTime",
		FFlagStartTime = "RibbonBladeStartTime",
		FFlagEndTime = "RibbonBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Ribbon Blade",
				Image = v2.Icons:GetSwordIcon("Dual Ribbon Blade"),
				ShowRoom = "RibbonBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Ribbon Blade",
						GiftId = 3409252090,
						Item = v.createListReward({ v.createSwordReward("Ribbon Blade") }),
						ProductId = 3409252086
					},
					{
						GiftName = "Dual Ribbon Blade",
						GiftId = 3409252097,
						Item = v.createListReward({
							v.createSwordReward("Dual Ribbon Blade"),
							v.createExplosionReward("Ribbon Obsession"),
							v.createEmoteReward("Emote1045")
						}),
						ProductId = 3409252099
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "RibbonPackRootStartTime",
		RootFFlagEndTime = "RibbonPackRootEndTime",
		FFlagStartTime = "RibbonShieldStartTime",
		FFlagEndTime = "RibbonShieldEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Ribbon Shield",
				Image = v2.Icons:GetSwordIcon("Ribbon Shield"),
				ShowRoom = "RibbonShieldShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Ribbon Shield",
						GiftId = 3409252093,
						Item = v.createListReward({
							v.createSwordReward("Ribbon Shield"),
							v.createExplosionReward("Ribbon Lover"),
							v.createEmoteReward("Emote1046")
						}),
						ProductId = 3409252091
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "RibbonPackRootStartTime",
		RootFFlagEndTime = "RibbonPackRootEndTime",
		FFlagStartTime = "RibbonPackStartTime",
		FFlagEndTime = "RibbonPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Ribbon Pack",
				Image = "rbxassetid://104661169621482",
				ShowRoom = "RibbonPackShowRoom",
				Rewards = {
					{
						GiftName = "Ribbon Pack",
						GiftId = 3409252094,
						Item = v.createListReward({
							v.createSwordReward("Ribbon Blade"),
							v.createSwordReward("Ribbon Shield"),
							v.createExplosionReward("Ribbon Obsession"),
							v.createEmoteReward("Emote1046")
						}),
						ProductId = 3409252100,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Ribbon Pack",
						GiftId = 3409252103,
						Item = v.createListReward({
							v.createSwordReward("Dual Ribbon Blade"),
							v.createSwordReward("Ribbon Shield"),
							v.createExplosionReward("Ribbon Lover"),
							v.createEmoteReward("Emote1046"),
							v.createEmoteReward("Emote1045")
						}),
						ProductId = 3409252102,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}