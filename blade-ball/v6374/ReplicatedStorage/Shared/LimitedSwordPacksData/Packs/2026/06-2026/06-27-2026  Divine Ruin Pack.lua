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
		RootFFlagStartTime = "DivineRuinStartTime",
		RootFFlagEndTime = "DivineRuinEndTime",
		FFlagStartTime = "DivineRuinBladeStartTime",
		FFlagEndTime = "DivineRuinBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Divine Ruin Blade",
				Image = v2.Icons:GetSwordIcon("Dual Divine Ruin Blade"),
				ShowRoom = "DivineRuinBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Divine Ruin Blade",
						GiftId = 3606847205,
						Item = v.createListReward({ v.createSwordReward("Divine Ruin Blade") }),
						ProductId = 3606847207
					},
					{
						GiftName = "Dual Divine Ruin Blade",
						GiftId = 3606847208,
						Item = v.createListReward({
							v.createSwordReward("Dual Divine Ruin Blade"),
							v.createExplosionReward("Divine Ruin Scroll"),
							v.createEmoteReward("Emote1234")
						}),
						ProductId = 3606847210
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "DivineRuinStartTime",
		RootFFlagEndTime = "DivineRuinEndTime",
		FFlagStartTime = "DivineRuinBowStartTime",
		FFlagEndTime = "DivineRuinBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Divine Ruin Bow",
				Image = v2.Icons:GetSwordIcon("Divine Ruin Bow"),
				ShowRoom = "DivineRuinBowShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Divine Ruin Bow",
						GiftId = 3606847211,
						Item = v.createListReward({
							v.createSwordReward("Divine Ruin Bow"),
							v.createExplosionReward("Divine Ruin Lore"),
							v.createEmoteReward("Emote1235")
						}),
						ProductId = 3606847216
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "DivineRuinStartTime",
		RootFFlagEndTime = "DivineRuinEndTime",
		FFlagStartTime = "DivineRuinPackStartTime",
		FFlagEndTime = "DivineRuinPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Divine Ruin Pack",
				Image = "rbxassetid://97165204479304",
				ShowRoom = "DivineRuinPackShowRoom",
				Rewards = {
					{
						GiftName = "Divine Ruin Pack",
						GiftId = 3606847220,
						Item = v.createListReward({
							v.createSwordReward("Divine Ruin Blade"),
							v.createSwordReward("Divine Ruin Bow"),
							v.createExplosionReward("Divine Ruin Scroll"),
							v.createEmoteReward("Emote1235")
						}),
						ProductId = 3606847223,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Divine Ruin Pack",
						GiftId = 3606847224,
						Item = v.createListReward({
							v.createSwordReward("Dual Divine Ruin Blade"),
							v.createSwordReward("Divine Ruin Bow"),
							v.createExplosionReward("Divine Ruin Lore"),
							v.createEmoteReward("Emote1234"),
							v.createEmoteReward("Emote1235")
						}),
						ProductId = 3606847225,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}