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
		RootFFlagStartTime = "SilkDivinityStartTime",
		RootFFlagEndTime = "SilkDivinityEndTime",
		FFlagStartTime = "SilkDivinityBladeStartTime",
		FFlagEndTime = "SilkDivinityBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Silk Divinity Blade",
				Image = v2.Icons:GetSwordIcon("Dual Silk Divinity Blade"),
				ShowRoom = "SilkDivinityBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Silk Divinity Blade",
						GiftId = 3599830893,
						Item = v.createListReward({ v.createSwordReward("Silk Divinity Blade") }),
						ProductId = 3599830900
					},
					{
						GiftName = "Dual Silk Divinity Blade",
						GiftId = 3599830945,
						Item = v.createListReward({
							v.createSwordReward("Dual Silk Divinity Blade"),
							v.createExplosionReward("Pure Silk Explosion"),
							v.createEmoteReward("Emote1224")
						}),
						ProductId = 3599830944
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "SilkDivinityStartTime",
		RootFFlagEndTime = "SilkDivinityEndTime",
		FFlagStartTime = "SilkDivinityBowStartTime",
		FFlagEndTime = "SilkDivinityBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Silk Divinity Bow",
				Image = v2.Icons:GetSwordIcon("Silk Divinity Bow"),
				ShowRoom = "SilkDivinityBowShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Silk Divinity Bow",
						GiftId = 3599830917,
						Item = v.createListReward({
							v.createSwordReward("Silk Divinity Bow"),
							v.createExplosionReward("Silk Divinity Explosion"),
							v.createEmoteReward("Emote1223")
						}),
						ProductId = 3599830894
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "SilkDivinityStartTime",
		RootFFlagEndTime = "SilkDivinityEndTime",
		FFlagStartTime = "SilkDivinityPackStartTime",
		FFlagEndTime = "SilkDivinityPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Silk Divinity Pack",
				Image = "rbxassetid://132258904164810",
				ShowRoom = "SilkDivinityPackShowRoom",
				Rewards = {
					{
						GiftName = "Silk Divinity Pack",
						GiftId = 3599830943,
						Item = v.createListReward({
							v.createSwordReward("Silk Divinity Blade"),
							v.createSwordReward("Silk Divinity Bow"),
							v.createExplosionReward("Pure Silk Explosion"),
							v.createEmoteReward("Emote1223")
						}),
						ProductId = 3599830902,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Silk Divinity Pack",
						GiftId = 3599830916,
						Item = v.createListReward({
							v.createSwordReward("Dual Silk Divinity Blade"),
							v.createSwordReward("Silk Divinity Bow"),
							v.createExplosionReward("Silk Divinity Explosion"),
							v.createEmoteReward("Emote1224"),
							v.createEmoteReward("Emote1223")
						}),
						ProductId = 3599830901,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}