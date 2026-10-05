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
		RootFFlagStartTime = "VampirePackRootStartTime",
		RootFFlagEndTime = "VampirePackRootEndTime",
		FFlagStartTime = "VampireSawStartTime",
		FFlagEndTime = "VampireSawEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Vampire Saw",
				Image = v2.Icons:GetSwordIcon("Dual Vampire Saw"),
				ShowRoom = "VampireSawShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Vampire Saw",
						GiftId = 2270213805,
						Item = v.createListReward({ v.createSwordReward("Vampire Saw") }),
						ProductId = 2270213782
					},
					{
						GiftName = "Dual Vampire Saw",
						GiftId = 2270213827,
						Item = v.createListReward({
							v.createSwordReward("Dual Vampire Saw"),
							v.createExplosionReward("Scarlet Sawblade"),
							v.createEmoteReward("Emote579")
						}),
						ProductId = 2270213807
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "VampirePackRootStartTime",
		RootFFlagEndTime = "VampirePackRootEndTime",
		FFlagStartTime = "VampireSickleStartTime",
		FFlagEndTime = "VampireSickleEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Vampire Sickle",
				Image = v2.Icons:GetSwordIcon("Dual Vampire Sickle"),
				ShowRoom = "VampireSickleShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Vampire Sickle",
						GiftId = 2270213814,
						Item = v.createListReward({
							v.createSwordReward("Vampire Sickle"),
							v.createExplosionReward("Bloodshot Sight"),
							v.createEmoteReward("Emote580")
						}),
						ProductId = 2270213798
					},
					{
						GiftName = "Dual Vampire Sickle",
						GiftId = 2270213795,
						Item = v.createListReward({
							v.createSwordReward("Dual Vampire Sickle"),
							v.createExplosionReward("Bloodshot Sight"),
							v.createEmoteReward("Emote581")
						}),
						ProductId = 2270213811
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "VampirePackRootStartTime",
		RootFFlagEndTime = "VampirePackRootEndTime",
		FFlagStartTime = "VampirePackStartTime",
		FFlagEndTime = "VampirePackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Vampire Pack",
				Image = "rbxassetid://86592500288686",
				ShowRoom = "VampirePackShowRoom",
				Rewards = {
					{
						GiftName = "Vampire Pack",
						GiftId = 2270213804,
						Item = v.createListReward({
							v.createSwordReward("Vampire Saw"),
							v.createSwordReward("Vampire Sickle"),
							v.createExplosionReward("Scarlet Sawblade"),
							v.createEmoteReward("Emote580")
						}),
						ProductId = 2270213791,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Vampire Pack",
						GiftId = 2270213818,
						Item = v.createListReward({
							v.createSwordReward("Dual Vampire Saw"),
							v.createSwordReward("Dual Vampire Sickle"),
							v.createExplosionReward("Bloodshot Sight"),
							v.createEmoteReward("Emote579"),
							v.createEmoteReward("Emote581")
						}),
						ProductId = 2270213809,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}