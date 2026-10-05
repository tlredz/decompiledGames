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
		RootFFlagStartTime = "FlutterPackRootStartTime",
		RootFFlagEndTime = "FlutterPackRootEndTime",
		FFlagStartTime = "FlutterBladeStartTime",
		FFlagEndTime = "FlutterBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Flutter Blade",
				Image = v2.Icons:GetSwordIcon("Dual Flutter Blade"),
				ShowRoom = "FlutterBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Flutter Blade",
						GiftId = 3319129297,
						Item = v.createListReward({ v.createSwordReward("Flutter Blade") }),
						ProductId = 3319129289
					},
					{
						GiftName = "Dual Flutter Blade",
						GiftId = 3319129296,
						Item = v.createListReward({
							v.createSwordReward("Dual Flutter Blade"),
							v.createExplosionReward("Radiant Butterflies"),
							v.createEmoteReward("Emote963")
						}),
						ProductId = 3319129290
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "FlutterPackRootStartTime",
		RootFFlagEndTime = "FlutterPackRootEndTime",
		FFlagStartTime = "FlutterBowStartTime",
		FFlagEndTime = "FlutterBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Flutter Bow",
				Image = v2.Icons:GetSwordIcon("Flutter Bow"),
				ShowRoom = "FlutterBowShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Flutter Bow",
						GiftId = 3319129293,
						Item = v.createListReward({
							v.createSwordReward("Flutter Bow"),
							v.createExplosionReward("Pink Butterflies"),
							v.createEmoteReward("Emote964")
						}),
						ProductId = 3319129292
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "FlutterPackRootStartTime",
		RootFFlagEndTime = "FlutterPackRootEndTime",
		FFlagStartTime = "FlutterPackStartTime",
		FFlagEndTime = "FlutterPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Flutter Pack",
				Image = "rbxassetid://101086197594122",
				ShowRoom = "FlutterPackShowRoom",
				Rewards = {
					{
						GiftName = "Flutter Pack",
						GiftId = 3319129295,
						Item = v.createListReward({
							v.createSwordReward("Flutter Blade"),
							v.createSwordReward("Flutter Bow"),
							v.createExplosionReward("Radiant Butterflies"),
							v.createEmoteReward("Emote964")
						}),
						ProductId = 3319129291,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Flutter Pack",
						GiftId = 3319129298,
						Item = v.createListReward({
							v.createSwordReward("Dual Flutter Blade"),
							v.createSwordReward("Flutter Bow"),
							v.createExplosionReward("Pink Butterflies"),
							v.createEmoteReward("Emote964"),
							v.createEmoteReward("Emote963")
						}),
						ProductId = 3319129294,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}