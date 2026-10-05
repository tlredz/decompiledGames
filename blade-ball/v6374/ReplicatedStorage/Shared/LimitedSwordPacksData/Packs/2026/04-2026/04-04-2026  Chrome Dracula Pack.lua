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
		RootFFlagStartTime = "ChromeDraculaStartTime",
		RootFFlagEndTime = "ChromeDraculaEndTime",
		FFlagStartTime = "ChromeDraculaBladeStartTime",
		FFlagEndTime = "ChromeDraculaBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Chrome Dracula Blade",
				Image = v2.Icons:GetSwordIcon("Dual Chrome Dracula Blade"),
				ShowRoom = "ChromeDraculaBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Chrome Dracula Blade",
						GiftId = 3569728267,
						Item = v.createListReward({ v.createSwordReward("Chrome Dracula Blade") }),
						ProductId = 3569728272
					},
					{
						GiftName = "Dual Chrome Dracula Blade",
						GiftId = 3569728278,
						Item = v.createListReward({
							v.createSwordReward("Dual Chrome Dracula Blade"),
							v.createExplosionReward("Chrome Dracula"),
							v.createEmoteReward("Emote1195")
						}),
						ProductId = 3569728268
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "ChromeDraculaStartTime",
		RootFFlagEndTime = "ChromeDraculaEndTime",
		FFlagStartTime = "ChromeDraculaSpearStartTime",
		FFlagEndTime = "ChromeDraculaSpearEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Chrome Dracula Spear",
				Image = v2.Icons:GetSwordIcon("Chrome Dracula Spear"),
				ShowRoom = "ChromeDraculaSpearShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Chrome Dracula Spear",
						GiftId = 3569728271,
						Item = v.createListReward({
							v.createSwordReward("Chrome Dracula Spear"),
							v.createExplosionReward("Dracula's Bite"),
							v.createEmoteReward("Emote1196")
						}),
						ProductId = 3569728266
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "ChromeDraculaStartTime",
		RootFFlagEndTime = "ChromeDraculaEndTime",
		FFlagStartTime = "ChromeDraculaPackStartTime",
		FFlagEndTime = "ChromeDraculaPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Chrome Dracula Pack",
				Image = "rbxassetid://134610420101316",
				ShowRoom = "ChromeDraculaPackShowRoom",
				Rewards = {
					{
						GiftName = "Chrome Dracula Pack",
						GiftId = 3569728274,
						Item = v.createListReward({
							v.createSwordReward("Chrome Dracula Blade"),
							v.createSwordReward("Chrome Dracula Spear"),
							v.createExplosionReward("Chrome Dracula"),
							v.createEmoteReward("Emote1196")
						}),
						ProductId = 3569728269,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Chrome Dracula Pack",
						GiftId = 3569728273,
						Item = v.createListReward({
							v.createSwordReward("Dual Chrome Dracula Blade"),
							v.createSwordReward("Chrome Dracula Spear"),
							v.createExplosionReward("Dracula's Bite"),
							v.createEmoteReward("Emote1195"),
							v.createEmoteReward("Emote1196")
						}),
						ProductId = 3569728270,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}