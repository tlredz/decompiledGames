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
		RootFFlagStartTime = "ElectroPackRootStartTime",
		RootFFlagEndTime = "ElectroPackRootEndTime",
		FFlagStartTime = "ElectroKatanaStartTime",
		FFlagEndTime = "ElectroKatanaEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Electro Katana",
				Image = v2.Icons:GetSwordIcon("Dual Electro Katana"),
				ShowRoom = "ElectroKatanaShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Electro Katana",
						GiftId = 3546906931,
						Item = v.createListReward({ v.createSwordReward("Electro Katana") }),
						ProductId = 3546906934
					},
					{
						GiftName = "Dual Electro Katana",
						GiftId = 3546906936,
						Item = v.createListReward({
							v.createSwordReward("Dual Electro Katana"),
							v.createExplosionReward("Electro Shock"),
							v.createEmoteReward("Emote1171")
						}),
						ProductId = 3546906930
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "ElectroPackRootStartTime",
		RootFFlagEndTime = "ElectroPackRootEndTime",
		FFlagStartTime = "ElectroBowStartTime",
		FFlagEndTime = "ElectroBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Electro Bow",
				Image = v2.Icons:GetSwordIcon("Electro Bow"),
				ShowRoom = "ElectroBowShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Electro Bow",
						GiftId = 3546906937,
						Item = v.createListReward({
							v.createSwordReward("Electro Bow"),
							v.createExplosionReward("Electro Consumption"),
							v.createEmoteReward("Emote1172")
						}),
						ProductId = 3546906933
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "ElectroPackRootStartTime",
		RootFFlagEndTime = "ElectroPackRootEndTime",
		FFlagStartTime = "ElectroPackStartTime",
		FFlagEndTime = "ElectroPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Electro Pack",
				Image = "rbxassetid://93623482598908",
				ShowRoom = "ElectroPackShowRoom",
				Rewards = {
					{
						GiftName = "Electro Pack",
						GiftId = 3546906938,
						Item = v.createListReward({
							v.createSwordReward("Electro Katana"),
							v.createSwordReward("Electro Bow"),
							v.createExplosionReward("Electro Shock"),
							v.createEmoteReward("Emote1172")
						}),
						ProductId = 3546906944,
						DiscountedFrom = 2499
					},
					{
						GiftName = "Dual Electro Pack",
						GiftId = 3546906932,
						Item = v.createListReward({
							v.createSwordReward("Dual Electro Katana"),
							v.createSwordReward("Electro Bow"),
							v.createExplosionReward("Electro Consumption"),
							v.createEmoteReward("Emote1171"),
							v.createEmoteReward("Emote1172")
						}),
						ProductId = 3546906935,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}