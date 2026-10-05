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
		RootFFlagStartTime = "AzurethornPackRootStartTime",
		RootFFlagEndTime = "AzurethornPackRootEndTime",
		FFlagStartTime = "AzurethornBladeStartTime",
		FFlagEndTime = "AzurethornBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Azurethorn Blade",
				Image = v2.Icons:GetSwordIcon("Dual Azurethorn Blade"),
				ShowRoom = "AzurethornBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Azurethorn Blade",
						GiftId = 2696754830,
						Item = v.createListReward({ v.createSwordReward("Azurethorn Blade") }),
						ProductId = 2696754835
					},
					{
						GiftName = "Dual Azurethorn Blade",
						GiftId = 2696754824,
						Item = v.createListReward({
							v.createSwordReward("Dual Azurethorn Blade"),
							v.createExplosionReward("Azurethorn Core"),
							v.createEmoteReward("Emote742")
						}),
						ProductId = 2696754828
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "AzurethornPackRootStartTime",
		RootFFlagEndTime = "AzurethornPackRootEndTime",
		FFlagStartTime = "AzurethornScytheStartTime",
		FFlagEndTime = "AzurethornScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Azurethorn Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Azurethorn Scythe"),
				ShowRoom = "AzurethornScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Azurethorn Scythe",
						GiftId = 2696754826,
						Item = v.createListReward({
							v.createSwordReward("Azurethorn Scythe"),
							v.createExplosionReward("Azurethorn Reflection"),
							v.createEmoteReward("Emote743")
						}),
						ProductId = 2696754825
					},
					{
						GiftName = "Dual Azurethorn Scythe",
						GiftId = 2696754823,
						Item = v.createListReward({
							v.createSwordReward("Dual Azurethorn Scythe"),
							v.createExplosionReward("Azurethorn Reflection"),
							v.createEmoteReward("Emote744")
						}),
						ProductId = 2696754822
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "AzurethornPackRootStartTime",
		RootFFlagEndTime = "AzurethornPackRootEndTime",
		FFlagStartTime = "AzurethornPackStartTime",
		FFlagEndTime = "AzurethornPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Azurethorn Pack",
				Image = "rbxassetid://99305562487688",
				ShowRoom = "AzurethornPackShowRoom",
				Rewards = {
					{
						GiftName = "Azurethorn Pack",
						GiftId = 2696754827,
						Item = v.createListReward({
							v.createSwordReward("Azurethorn Blade"),
							v.createSwordReward("Azurethorn Scythe"),
							v.createExplosionReward("Azurethorn Core"),
							v.createEmoteReward("Emote743")
						}),
						ProductId = 2696754821,
						DiscountedFrom = 2000
					},
					{
						GiftName = "Dual Azurethorn Pack",
						GiftId = 2696754834,
						Item = v.createListReward({
							v.createSwordReward("Dual Azurethorn Blade"),
							v.createSwordReward("Dual Azurethorn Scythe"),
							v.createExplosionReward("Azurethorn Reflection"),
							v.createEmoteReward("Emote742"),
							v.createEmoteReward("Emote744")
						}),
						ProductId = 2696754829,
						DiscountedFrom = 3500
					}
				}
			}
		}
	}
}