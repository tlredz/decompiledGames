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
		RootFFlagStartTime = "HiddenBeastStartTime",
		RootFFlagEndTime = "HiddenBeastEndTime",
		FFlagStartTime = "HiddenBeastBladeStartTime",
		FFlagEndTime = "HiddenBeastBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Hidden Beast Blade",
				Image = v2.Icons:GetSwordIcon("Dual Hidden Beast Blade"),
				ShowRoom = "HiddenBeastBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Hidden Beast Blade",
						GiftId = 3708267297,
						Item = v.createListReward({ v.createSwordReward("Hidden Beast Blade") }),
						ProductId = 3708267299
					},
					{
						GiftName = "Dual Hidden Beast Blade",
						GiftId = 3708267301,
						Item = v.createListReward({
							v.createSwordReward("Dual Hidden Beast Blade"),
							v.createExplosionReward("Hidden Beast Bite"),
							v.createEmoteReward("Emote1262")
						}),
						ProductId = 3708267303
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "HiddenBeastStartTime",
		RootFFlagEndTime = "HiddenBeastEndTime",
		FFlagStartTime = "HiddenBeastScytheStartTime",
		FFlagEndTime = "HiddenBeastScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Hidden Beast Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Hidden Beast Scythe"),
				ShowRoom = "HiddenBeastScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Hidden Beast Scythe",
						GiftId = 3708267306,
						Item = v.createListReward({
							v.createSwordReward("Hidden Beast Scythe"),
							v.createExplosionReward("Hidden Beast Bite"),
							v.createEmoteReward("Emote1263")
						}),
						ProductId = 3708267312
					},
					{
						GiftName = "Dual Hidden Beast Scythe",
						GiftId = 3708267316,
						Item = v.createListReward({
							v.createSwordReward("Dual Hidden Beast Scythe"),
							v.createExplosionReward("Hidden Beast Gate"),
							v.createEmoteReward("Emote1264")
						}),
						ProductId = 3708267320
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "HiddenBeastStartTime",
		RootFFlagEndTime = "HiddenBeastEndTime",
		FFlagStartTime = "HiddenBeastPackStartTime",
		FFlagEndTime = "HiddenBeastPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Hidden Beast Pack",
				Image = "rbxassetid://77485002005347",
				ShowRoom = "HiddenBeastPackShowRoom",
				Rewards = {
					{
						GiftName = "Hidden Beast Pack",
						GiftId = 3708267329,
						Item = v.createListReward({
							v.createSwordReward("Hidden Beast Blade"),
							v.createSwordReward("Hidden Beast Scythe"),
							v.createExplosionReward("Hidden Beast Bite"),
							v.createEmoteReward("Emote1263")
						}),
						ProductId = 3708267332
					},
					{
						GiftName = "Dual Hidden Beast Pack",
						GiftId = 3708267334,
						Item = v.createListReward({
							v.createSwordReward("Dual Hidden Beast Blade"),
							v.createSwordReward("Dual Hidden Beast Scythe"),
							v.createExplosionReward("Hidden Beast Gate"),
							v.createEmoteReward("Emote1262"),
							v.createEmoteReward("Emote1264")
						}),
						ProductId = 3708267335
					}
				}
			}
		}
	}
}