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
		RootFFlagStartTime = "KrampusPackRootStartTime",
		RootFFlagEndTime = "KrampusPackRootEndTime",
		FFlagStartTime = "KrampusBladeStartTime",
		FFlagEndTime = "KrampusBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Krampus Blade",
				Image = v2.Icons:GetSwordIcon("Dual Krampus Blade"),
				ShowRoom = "KrampusBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Krampus Blade",
						GiftId = 2678251297,
						Item = v.createListReward({ v.createSwordReward("Krampus Blade") }),
						ProductId = 2678251303
					},
					{
						GiftName = "Dual Krampus Blade",
						GiftId = 2678251298,
						Item = v.createListReward({
							v.createSwordReward("Dual Krampus Blade"),
							v.createExplosionReward("Krampus Gifts"),
							v.createEmoteReward("Emote698")
						}),
						ProductId = 2678251300
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "KrampusPackRootStartTime",
		RootFFlagEndTime = "KrampusPackRootEndTime",
		FFlagStartTime = "KrampusScytheStartTime",
		FFlagEndTime = "KrampusScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Krampus Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Krampus Scythe"),
				ShowRoom = "KrampusScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Krampus Scythe",
						GiftId = 2678251299,
						Item = v.createListReward({
							v.createSwordReward("Krampus Scythe"),
							v.createExplosionReward("Krampus Horns"),
							v.createEmoteReward("Emote699")
						}),
						ProductId = 2678251307
					},
					{
						GiftName = "Dual Krampus Scythe",
						GiftId = 2678251308,
						Item = v.createListReward({
							v.createSwordReward("Dual Krampus Scythe"),
							v.createExplosionReward("Krampus Horns"),
							v.createEmoteReward("Emote700")
						}),
						ProductId = 2678251306
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "KrampusPackRootStartTime",
		RootFFlagEndTime = "KrampusPackRootEndTime",
		FFlagStartTime = "KrampusPackStartTime",
		FFlagEndTime = "KrampusPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Krampus Pack",
				Image = "rbxassetid://103805211908114",
				ShowRoom = "KrampusPackShowRoom",
				Rewards = {
					{
						GiftName = "Krampus Pack",
						GiftId = 2678251304,
						Item = v.createListReward({
							v.createSwordReward("Krampus Blade"),
							v.createSwordReward("Krampus Scythe"),
							v.createExplosionReward("Krampus Gifts"),
							v.createEmoteReward("Emote699")
						}),
						ProductId = 2678251305,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Krampus Pack",
						GiftId = 2678251301,
						Item = v.createListReward({
							v.createSwordReward("Dual Krampus Blade"),
							v.createSwordReward("Dual Krampus Scythe"),
							v.createExplosionReward("Krampus Horns"),
							v.createEmoteReward("Emote698"),
							v.createEmoteReward("Emote700")
						}),
						ProductId = 2678251302,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}