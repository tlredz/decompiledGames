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
		RootFFlagStartTime = "BlueBunnyPackRootStartTime",
		RootFFlagEndTime = "BlueBunnyPackRootEndTime",
		FFlagStartTime = "BlueBunnyKatanaStartTime",
		FFlagEndTime = "BlueBunnyKatanaEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Blue Bunny Katana",
				Image = v2.Icons:GetSwordIcon("Dual Blue Bunny Katana"),
				ShowRoom = "BlueBunnyKatanaShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Blue Bunny Katana",
						GiftId = 3555120444,
						Item = v.createListReward({ v.createSwordReward("Blue Bunny Katana") }),
						ProductId = 3555120442
					},
					{
						GiftName = "Dual Blue Bunny Katana",
						GiftId = 3555120447,
						Item = v.createListReward({
							v.createSwordReward("Dual Blue Bunny Katana"),
							v.createExplosionReward("Blue Strawberry Garden"),
							v.createEmoteReward("Emote1184")
						}),
						ProductId = 3555120446
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "BlueBunnyPackRootStartTime",
		RootFFlagEndTime = "BlueBunnyPackRootEndTime",
		FFlagStartTime = "BlueBunnyScytheStartTime",
		FFlagEndTime = "BlueBunnyScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Blue Bunny Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Blue Bunny Scythe"),
				ShowRoom = "BlueBunnyScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Blue Bunny Scythe",
						GiftId = 3555120440,
						Item = v.createListReward({
							v.createSwordReward("Blue Bunny Scythe"),
							v.createExplosionReward("Blueberry Guardian"),
							v.createEmoteReward("Emote1182")
						}),
						ProductId = 3555120443
					},
					{
						GiftName = "Dual Blue Bunny Scythe",
						GiftId = 3555120438,
						Item = v.createListReward({
							v.createSwordReward("Dual Blue Bunny Scythe"),
							v.createExplosionReward("Blueberry Guardian"),
							v.createEmoteReward("Emote1183")
						}),
						ProductId = 3555120448
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "BlueBunnyPackRootStartTime",
		RootFFlagEndTime = "BlueBunnyPackRootEndTime",
		FFlagStartTime = "BlueBunnyPackStartTime",
		FFlagEndTime = "BlueBunnyPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Blue Bunny Pack",
				Image = "rbxassetid://136621231325029",
				ShowRoom = "BlueBunnyPackShowRoom",
				Rewards = {
					{
						GiftName = "Blue Bunny Pack",
						GiftId = 3555120445,
						Item = v.createListReward({
							v.createSwordReward("Blue Bunny Katana"),
							v.createSwordReward("Blue Bunny Scythe"),
							v.createExplosionReward("Blue Strawberry Garden"),
							v.createEmoteReward("Emote1182")
						}),
						ProductId = 3555120439,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Blue Bunny Pack",
						GiftId = 3555120441,
						Item = v.createListReward({
							v.createSwordReward("Dual Blue Bunny Katana"),
							v.createSwordReward("Dual Blue Bunny Scythe"),
							v.createExplosionReward("Blueberry Guardian"),
							v.createEmoteReward("Emote1184"),
							v.createEmoteReward("Emote1183")
						}),
						ProductId = 3555120449,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}