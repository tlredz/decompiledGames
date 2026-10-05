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
		RootFFlagStartTime = "NeoNekoStartTime",
		RootFFlagEndTime = "NeoNekoEndTime",
		FFlagStartTime = "NeoNekoKatanaStartTime",
		FFlagEndTime = "NeoNekoKatanaEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Neo-Neko Katana",
				Image = v2.Icons:GetSwordIcon("Dual Neo-Neko Katana"),
				ShowRoom = "NeoNekoKatanaShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Neo-Neko Katana",
						GiftId = 3589409958,
						Item = v.createListReward({ v.createSwordReward("Neo-Neko Katana") }),
						ProductId = 3589409965
					},
					{
						GiftName = "Dual Neo-Neko Katana",
						GiftId = 3589409957,
						Item = v.createListReward({
							v.createSwordReward("Dual Neo-Neko Katana"),
							v.createExplosionReward("WiFi Pop Explosion"),
							v.createEmoteReward("Emote1212")
						}),
						ProductId = 3589410026
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "NeoNekoStartTime",
		RootFFlagEndTime = "NeoNekoEndTime",
		FFlagStartTime = "NeoNekoNeedleStartTime",
		FFlagEndTime = "NeoNekoNeedleEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Neo-Neko Needle",
				Image = v2.Icons:GetSwordIcon("Neo-Neko Needle"),
				ShowRoom = "NeoNekoNeedleShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Neo-Neko Needle",
						GiftId = 3589409966,
						Item = v.createListReward({
							v.createSwordReward("Neo-Neko Needle"),
							v.createExplosionReward("Needle Connection Explosion"),
							v.createEmoteReward("Emote1213")
						}),
						ProductId = 3589410025
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "NeoNekoStartTime",
		RootFFlagEndTime = "NeoNekoEndTime",
		FFlagStartTime = "NeoNekoPackStartTime",
		FFlagEndTime = "NeoNekoPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Neo-Neko Pack",
				Image = "rbxassetid://84046807792778",
				ShowRoom = "NeoNekoPackShowRoom",
				Rewards = {
					{
						GiftName = "Neo-Neko Pack",
						GiftId = 3589409981,
						Item = v.createListReward({
							v.createSwordReward("Neo-Neko Katana"),
							v.createSwordReward("Neo-Neko Needle"),
							v.createExplosionReward("WiFi Pop Explosion"),
							v.createEmoteReward("Emote1213")
						}),
						ProductId = 3589409982,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Neo-Neko Pack",
						GiftId = 3589409980,
						Item = v.createListReward({
							v.createSwordReward("Dual Neo-Neko Katana"),
							v.createSwordReward("Neo-Neko Needle"),
							v.createExplosionReward("Needle Connection Explosion"),
							v.createEmoteReward("Emote1212"),
							v.createEmoteReward("Emote1213")
						}),
						ProductId = 3589410024,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}