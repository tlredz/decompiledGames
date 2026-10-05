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
		FFlagStartTime = "CrystalHammerStartTime",
		FFlagEndTime = "CrystalHammerEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Crystal Hammer",
				Image = v2.Icons:GetSwordIcon("Dual Crystal Hammer"),
				ShowRoom = "CrystalHammerShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Crystal Hammer",
						Item = v.createListReward({ v.createSwordReward("Crystal Hammer") }),
						ProductId = 1761768258
					},
					{
						GiftName = "Dual Crystal Hammer",
						Item = v.createListReward({
							v.createSwordReward("Dual Crystal Hammer"),
							v.createExplosionReward("Crystal Reveal")
						}),
						ProductId = 1761768732
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "CrystalScissorsStartTime",
		FFlagEndTime = "CrystalScissorsEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Crystal Scissors",
				Image = v2.Icons:GetSwordIcon("Crystal Scissors"),
				ShowRoom = "CrystalScissorsShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Crystal Scissors",
						Item = v.createListReward({
							v.createSwordReward("Crystal Scissors"),
							v.createEmoteReward("Emote158"),
							v.createExplosionReward("Crystal Reveal")
						}),
						ProductId = 1761768971
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "CrystalsPackStartTime",
		FFlagEndTime = "CrystalsPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Crystal Pack",
				Image = "rbxassetid://16499084489",
				ShowRoom = "CrystalsPackShowRoom",
				Rewards = {
					{
						GiftName = "Crystal Pack",
						Item = v.createListReward({
							v.createSwordReward("Crystal Scissors"),
							v.createSwordReward("Dual Crystal Hammer"),
							v.createEmoteReward("Emote158"),
							v.createExplosionReward("Crystal Reveal")
						}),
						ProductId = 1761769444,
						DiscountedFrom = 5000
					}
				}
			}
		}
	}
}