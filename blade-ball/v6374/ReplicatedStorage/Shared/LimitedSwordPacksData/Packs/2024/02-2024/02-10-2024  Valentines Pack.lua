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
		FFlagStartTime = "LoveBladeStartTime",
		FFlagEndTime = "LoveBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Love Blade",
				Image = v2.Icons:GetSwordIcon("Dual Love Blade"),
				ShowRoom = "LoveBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Love Blade",
						Item = v.createListReward({ v.createSwordReward("Love Blade") }),
						ProductId = 1751516719
					},
					{
						GiftName = "Dual Love Blade",
						Item = v.createListReward({
							v.createSwordReward("Dual Love Blade"),
							v.createExplosionReward("Heart Blast")
						}),
						ProductId = 1751517172
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "CupidsBowStartTime",
		FFlagEndTime = "CupidsBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Cupid's Bow",
				Image = v2.Icons:GetSwordIcon("Cupid's Bow"),
				ShowRoom = "CupidsBowShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Cupid's Bow",
						Item = v.createListReward({
							v.createSwordReward("Cupid's Bow"),
							v.createEmoteReward("Emote142")
						}),
						ProductId = 1751517436
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "ValentinesPackStartTime",
		FFlagEndTime = "ValentinesPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Valentine's Pack",
				Image = "rbxassetid://16312165945",
				ShowRoom = "ValentinesPackShowRoom",
				Rewards = {
					{
						GiftName = "Single Valentine's Pack",
						Item = v.createListReward({
							v.createSwordReward("Love Blade"),
							v.createSwordReward("Cupid's Bow"),
							v.createExplosionReward("Heart Blast"),
							v.createEmoteReward("Emote142")
						}),
						DiscountedFrom = 2500,
						ProductId = 1751517806
					},
					{
						GiftName = "Dual Valentine's Pack",
						Item = v.createListReward({
							v.createSwordReward("Dual Love Blade"),
							v.createSwordReward("Cupid's Bow"),
							v.createExplosionReward("Heart Blast"),
							v.createEmoteReward("Emote142")
						}),
						DiscountedFrom = 3500,
						ProductId = 1751518283
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "LunarParasolStartTime",
		FFlagEndTime = "LunarParasolEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Lunar Parasol",
				Image = v2.Icons:GetSwordIcon("Lunar Parasol"),
				ShowRoom = "LunarParasolShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Lunar Parasol",
						Item = v.createListReward({
							v.createSwordReward("Lunar Parasol"),
							v.createEmoteReward("Emote141"),
							v.createExplosionReward("Lunar Burst")
						}),
						ProductId = 1751518579,
						DiscountedFrom = 5000
					}
				}
			}
		}
	}
}