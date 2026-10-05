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
		RootFFlagStartTime = "WitheredPackRootStartTime",
		RootFFlagEndTime = "WitheredPackRootEndTime",
		FFlagStartTime = "WitheredBladeStartTime",
		FFlagEndTime = "WitheredBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Withered Blade",
				Image = v2.Icons:GetSwordIcon("Dual Withered Blade"),
				ShowRoom = "WitheredBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Withered Blade",
						GiftId = 3373381417,
						Item = v.createListReward({ v.createSwordReward("Withered Blade") }),
						ProductId = 3373381422
					},
					{
						GiftName = "Dual Withered Blade",
						GiftId = 3373381415,
						Item = v.createListReward({
							v.createSwordReward("Dual Withered Blade"),
							v.createExplosionReward("Withered Starship"),
							v.createEmoteReward("Emote1020")
						}),
						ProductId = 3373381420
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "WitheredPackRootStartTime",
		RootFFlagEndTime = "WitheredPackRootEndTime",
		FFlagStartTime = "WitheredChakramStartTime",
		FFlagEndTime = "WitheredChakramEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Withered Chakram",
				Image = v2.Icons:GetSwordIcon("Withered Chakram"),
				ShowRoom = "WitheredChakramShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Withered Chakram",
						GiftId = 3373381425,
						Item = v.createListReward({
							v.createSwordReward("Withered Chakram"),
							v.createExplosionReward("Withered Reality"),
							v.createEmoteReward("Emote1021")
						}),
						ProductId = 3373381426
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "WitheredPackRootStartTime",
		RootFFlagEndTime = "WitheredPackRootEndTime",
		FFlagStartTime = "WitheredPackStartTime",
		FFlagEndTime = "WitheredPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Withered Pack",
				Image = "rbxassetid://98749184388878",
				ShowRoom = "WitheredPackShowRoom",
				Rewards = {
					{
						GiftName = "Withered Pack",
						GiftId = 3373381421,
						Item = v.createListReward({
							v.createSwordReward("Withered Blade"),
							v.createSwordReward("Withered Chakram"),
							v.createExplosionReward("Withered Starship"),
							v.createEmoteReward("Emote1021")
						}),
						ProductId = 3373381423,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Withered Pack",
						GiftId = 3373381413,
						Item = v.createListReward({
							v.createSwordReward("Dual Withered Blade"),
							v.createSwordReward("Withered Chakram"),
							v.createExplosionReward("Withered Reality"),
							v.createEmoteReward("Emote1021"),
							v.createEmoteReward("Emote1020")
						}),
						ProductId = 3373381416,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}