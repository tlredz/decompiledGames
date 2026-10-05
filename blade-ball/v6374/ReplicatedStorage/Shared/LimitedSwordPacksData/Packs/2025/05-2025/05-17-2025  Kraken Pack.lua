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
		RootFFlagStartTime = "KrakenPackRootStartTime",
		RootFFlagEndTime = "KrakenPackRootEndTime",
		FFlagStartTime = "KrakenBladeStartTime",
		FFlagEndTime = "KrakenBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Kraken Blade",
				Image = v2.Icons:GetSwordIcon("Dual Kraken Blade"),
				ShowRoom = "KrakenBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Kraken Blade",
						GiftId = 3287093130,
						Item = v.createListReward({ v.createSwordReward("Kraken Blade") }),
						ProductId = 3287093127
					},
					{
						GiftName = "Dual Kraken Blade",
						GiftId = 3287093138,
						Item = v.createListReward({
							v.createSwordReward("Dual Kraken Blade"),
							v.createExplosionReward("Kraken Sighting"),
							v.createEmoteReward("Emote912")
						}),
						ProductId = 3287093131
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "KrakenPackRootStartTime",
		RootFFlagEndTime = "KrakenPackRootEndTime",
		FFlagStartTime = "KrakenScytheStartTime",
		FFlagEndTime = "KrakenScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Kraken Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Kraken Scythe"),
				ShowRoom = "KrakenScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Kraken Scythe",
						GiftId = 3287093133,
						Item = v.createListReward({
							v.createSwordReward("Kraken Scythe"),
							v.createExplosionReward("Kraken Pit"),
							v.createEmoteReward("Emote913")
						}),
						ProductId = 3287093132
					},
					{
						GiftName = "Dual Kraken Scythe",
						GiftId = 3287093134,
						Item = v.createListReward({
							v.createSwordReward("Dual Kraken Scythe"),
							v.createExplosionReward("Kraken Pit"),
							v.createEmoteReward("Emote914")
						}),
						ProductId = 3287093136
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "KrakenPackRootStartTime",
		RootFFlagEndTime = "KrakenPackRootEndTime",
		FFlagStartTime = "KrakenPackStartTime",
		FFlagEndTime = "KrakenPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Kraken Pack",
				Image = "rbxassetid://84523690528758",
				ShowRoom = "KrakenPackShowRoom",
				Rewards = {
					{
						GiftName = "Kraken Pack",
						GiftId = 3287093129,
						Item = v.createListReward({
							v.createSwordReward("Kraken Blade"),
							v.createSwordReward("Kraken Scythe"),
							v.createExplosionReward("Kraken Sighting"),
							v.createEmoteReward("Emote913")
						}),
						ProductId = 3287093137,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Kraken Pack",
						GiftId = 3287093135,
						Item = v.createListReward({
							v.createSwordReward("Dual Kraken Blade"),
							v.createSwordReward("Dual Kraken Scythe"),
							v.createExplosionReward("Kraken Pit"),
							v.createEmoteReward("Emote912"),
							v.createEmoteReward("Emote914")
						}),
						ProductId = 3287093128,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}