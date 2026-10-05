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
		RootFFlagStartTime = "BlackCatPackRootStartTime",
		RootFFlagEndTime = "BlackCatPackRootEndTime",
		FFlagStartTime = "BlackCatBladeStartTime",
		FFlagEndTime = "BlackCatBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Black Cat Blade",
				Image = v2.Icons:GetSwordIcon("Dual Black Cat Blade"),
				ShowRoom = "BlackCatBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Black Cat Blade",
						GiftId = 3434148083,
						Item = v.createListReward({ v.createSwordReward("Black Cat Blade") }),
						ProductId = 3434148081
					},
					{
						GiftName = "Dual Black Cat Blade",
						GiftId = 3434148087,
						Item = v.createListReward({
							v.createSwordReward("Dual Black Cat Blade"),
							v.createExplosionReward("Meowplosion"),
							v.createEmoteReward("Emote1059")
						}),
						ProductId = 3434148082
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "BlackCatPackRootStartTime",
		RootFFlagEndTime = "BlackCatPackRootEndTime",
		FFlagStartTime = "BlackCatScytheStartTime",
		FFlagEndTime = "BlackCatScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Black Cat Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Black Cat Scythe"),
				ShowRoom = "BlackCatScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Black Cat Scythe",
						GiftId = 3434148089,
						Item = v.createListReward({
							v.createSwordReward("Black Cat Scythe"),
							v.createExplosionReward("Spooky Cat"),
							v.createEmoteReward("Emote1060")
						}),
						ProductId = 3434148090
					},
					{
						GiftName = "Dual Black Cat Scythe",
						GiftId = 3434148092,
						Item = v.createListReward({
							v.createSwordReward("Dual Black Cat Scythe"),
							v.createExplosionReward("Spooky Cat"),
							v.createEmoteReward("Emote1061")
						}),
						ProductId = 3434148088
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "BlackCatPackRootStartTime",
		RootFFlagEndTime = "BlackCatPackRootEndTime",
		FFlagStartTime = "BlackCatPackStartTime",
		FFlagEndTime = "BlackCatPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Black Cat Pack",
				Image = "rbxassetid://136338956570581",
				ShowRoom = "BlackCatPackShowRoom",
				Rewards = {
					{
						GiftName = "Black Cat Pack",
						GiftId = 3434148084,
						Item = v.createListReward({
							v.createSwordReward("Black Cat Blade"),
							v.createSwordReward("Black Cat Scythe"),
							v.createExplosionReward("Meowplosion"),
							v.createEmoteReward("Emote1060")
						}),
						ProductId = 3434155176,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Black Cat Pack",
						GiftId = 3434148091,
						Item = v.createListReward({
							v.createSwordReward("Dual Black Cat Blade"),
							v.createSwordReward("Dual Black Cat Scythe"),
							v.createExplosionReward("Spooky Cat"),
							v.createEmoteReward("Emote1059"),
							v.createEmoteReward("Emote1061")
						}),
						ProductId = 3434148085,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}