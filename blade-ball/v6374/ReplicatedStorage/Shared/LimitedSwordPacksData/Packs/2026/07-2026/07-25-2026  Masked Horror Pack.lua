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
		RootFFlagStartTime = "MaskedHorrorStartTime",
		RootFFlagEndTime = "MaskedHorrorEndTime",
		FFlagStartTime = "MaskedHorrorBladeStartTime",
		FFlagEndTime = "MaskedHorrorBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Masked Horror Blade",
				Image = v2.Icons:GetSwordIcon("Dual Masked Horror Blade"),
				ShowRoom = "MaskedHorrorBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Masked Horror Blade",
						GiftId = 3611654575,
						Item = v.createListReward({ v.createSwordReward("Masked Horror Blade") }),
						ProductId = 3611654586
					},
					{
						GiftName = "Dual Masked Horror Blade",
						GiftId = 3611654588,
						Item = v.createListReward({
							v.createEmoteReward("Emote1254"),
							v.createExplosionReward("Masked Horror Light"),
							v.createSwordReward("Dual Masked Horror Blade")
						}),
						ProductId = 3611654592
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "MaskedHorrorStartTime",
		RootFFlagEndTime = "MaskedHorrorEndTime",
		FFlagStartTime = "MaskedHorrorScytheStartTime",
		FFlagEndTime = "MaskedHorrorScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Masked Horror Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Masked Horror Scythe"),
				ShowRoom = "MaskedHorrorScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Masked Horror Scythe",
						GiftId = 3611654611,
						Item = v.createListReward({
							v.createSwordReward("Masked Horror Scythe"),
							v.createEmoteReward("Emote1255"),
							v.createExplosionReward("Masked Horror Light")
						}),
						ProductId = 3611654614
					},
					{
						GiftName = "Dual Masked Horror Scythe",
						GiftId = 3611654618,
						Item = v.createListReward({
							v.createSwordReward("Dual Masked Horror Scythe"),
							v.createEmoteReward("Emote1256"),
							v.createExplosionReward("Masked Horror Explosion")
						}),
						ProductId = 3611654621
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "MaskedHorrorStartTime",
		RootFFlagEndTime = "MaskedHorrorEndTime",
		FFlagStartTime = "MaskedHorrorPackStartTime",
		FFlagEndTime = "MaskedHorrorPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Masked Horror Pack",
				Image = "rbxassetid://120027948110581",
				ShowRoom = "MaskedHorrorPackShowRoom",
				Rewards = {
					{
						GiftName = "Masked Horror Pack",
						GiftId = 3611654624,
						Item = v.createListReward({
							v.createSwordReward("Masked Horror Scythe"),
							v.createSwordReward("Masked Horror Blade"),
							v.createEmoteReward("Emote1255"),
							v.createExplosionReward("Masked Horror Light")
						}),
						ProductId = 3611654638
					},
					{
						GiftName = "Dual Masked Horror Pack",
						GiftId = 3611654643,
						Item = v.createListReward({
							v.createSwordReward("Dual Masked Horror Scythe"),
							v.createSwordReward("Dual Masked Horror Blade"),
							v.createEmoteReward("Emote1256"),
							v.createEmoteReward("Emote1254"),
							v.createExplosionReward("Masked Horror Explosion")
						}),
						ProductId = 3611654648
					}
				}
			}
		}
	}
}