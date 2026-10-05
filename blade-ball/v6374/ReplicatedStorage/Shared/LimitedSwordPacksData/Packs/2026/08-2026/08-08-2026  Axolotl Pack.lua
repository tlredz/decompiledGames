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
		RootFFlagStartTime = "AxolotlStartTime",
		RootFFlagEndTime = "AxolotlEndTime",
		FFlagStartTime = "AxolotlBladeStartTime",
		FFlagEndTime = "AxolotlBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Axolotl Blade",
				Image = v2.Icons:GetSwordIcon("Dual Axolotl Blade"),
				ShowRoom = "AxolotlBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Axolotl Blade",
						GiftId = 3653208863,
						Item = v.createListReward({ v.createSwordReward("Axolotl Blade") }),
						ProductId = 3653209131
					},
					{
						GiftName = "Dual Axolotl Blade",
						GiftId = 3653209319,
						Item = v.createListReward({
							v.createSwordReward("Dual Axolotl Blade"),
							v.createExplosionReward("Shiny Coral Explosion"),
							v.createEmoteReward("Emote1259")
						}),
						ProductId = 3653209523
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "AxolotlStartTime",
		RootFFlagEndTime = "AxolotlEndTime",
		FFlagStartTime = "AxolotlScytheStartTime",
		FFlagEndTime = "AxolotlScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Axolotl Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Axolotl Scythe"),
				ShowRoom = "AxolotlScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Axolotl Scythe",
						GiftId = 3653209822,
						Item = v.createListReward({
							v.createSwordReward("Axolotl Scythe"),
							v.createExplosionReward("Shiny Coral Explosion"),
							v.createEmoteReward("Emote1260")
						}),
						ProductId = 3653210023
					},
					{
						GiftName = "Dual Axolotl Scythe",
						GiftId = 3653210713,
						Item = v.createListReward({
							v.createSwordReward("Dual Axolotl Scythe"),
							v.createExplosionReward("Shiny Axolotl Explosion"),
							v.createEmoteReward("Emote1261")
						}),
						ProductId = 3653210949
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "AxolotlStartTime",
		RootFFlagEndTime = "AxolotlEndTime",
		FFlagStartTime = "AxolotlPackStartTime",
		FFlagEndTime = "AxolotlPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Axolotl Pack",
				Image = "rbxassetid://101738396358720",
				ShowRoom = "AxolotlPackShowRoom",
				Rewards = {
					{
						GiftName = "Axolotl Pack",
						GiftId = 3653211226,
						Item = v.createListReward({
							v.createSwordReward("Axolotl Blade"),
							v.createSwordReward("Axolotl Scythe"),
							v.createExplosionReward("Shiny Coral Explosion"),
							v.createEmoteReward("Emote1260")
						}),
						ProductId = 3653211532
					},
					{
						GiftName = "Dual Axolotl Pack",
						GiftId = 3653211744,
						Item = v.createListReward({
							v.createSwordReward("Dual Axolotl Blade"),
							v.createSwordReward("Dual Axolotl Scythe"),
							v.createExplosionReward("Shiny Axolotl Explosion"),
							v.createEmoteReward("Emote1259"),
							v.createEmoteReward("Emote1261")
						}),
						ProductId = 3653211972
					}
				}
			}
		}
	}
}