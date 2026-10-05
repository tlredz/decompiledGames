local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
require3(ReplicatedStorage2.Common.Utils)
require3(script:FindFirstAncestor("Packs").Parent.Types)
return {
	{
		RootFFlagStartTime = "NinjaKatanaPackRootStartTime",
		RootFFlagEndTime = "NinjaKatanaPackRootEndTime",
		FFlagStartTime = "NinjaKatanaPackShowRoomStartTime",
		FFlagEndTime = "NinjaKatanaPackShowRoomEndTime",
		Rewards = {
			{
				Type = "SelectColors",
				Name = "Ninja Katana Pack",
				Image = "rbxassetid://18682107296",
				ShowRoom = "BlackNinjaKatanaShowRoom",
				TemplateType = "Bundle",
				Rewards = {
					{
						Color = "Black",
						Stock = "Black Ninja Katana",
						ShowRoom = "BlackNinjaKatanaShowRoom",
						GiftName = "Black Ninja Katana",
						GiftId = 1888967611,
						Item = v.createListReward({
							v.createSwordReward("Black Ninja Katana"),
							v.createExplosionReward("Katana Black Explosion"),
							v.createEmoteReward("Emote449")
						}),
						ProductId = 1888967614
					},
					{
						Color = "Red",
						Stock = "Red Ninja Katana",
						ShowRoom = "RedNinjaKatanaShowRoom",
						GiftName = "Red Ninja Katana",
						GiftId = 1888967615,
						Item = v.createListReward({
							v.createSwordReward("Red Ninja Katana"),
							v.createExplosionReward("Katana Red Explosion"),
							v.createEmoteReward("Emote450")
						}),
						ProductId = 1888967608
					},
					{
						Color = "Green",
						Stock = "Green Ninja Katana",
						ShowRoom = "GreenNinjaKatanaShowRoom",
						GiftName = "Green Ninja Katana",
						GiftId = 1888967613,
						Item = v.createListReward({
							v.createSwordReward("Green Ninja Katana"),
							v.createExplosionReward("Katana Green Explosion"),
							v.createEmoteReward("Emote451")
						}),
						ProductId = 1888967609
					},
					{
						Color = "Blue",
						Stock = "Blue Ninja Katana",
						ShowRoom = "BlueNinjaKatanaShowRoom",
						GiftName = "Blue Ninja Katana",
						GiftId = 1888967607,
						Item = v.createListReward({
							v.createSwordReward("Blue Ninja Katana"),
							v.createExplosionReward("Katana Blue Explosion"),
							v.createEmoteReward("Emote452")
						}),
						ProductId = 1888967612
					},
					{
						Color = "Pink",
						Stock = "Pink Ninja Katana",
						ShowRoom = "PinkNinjaKatanaShowRoom",
						GiftName = "Pink Ninja Katana",
						GiftId = 1888967616,
						Item = v.createListReward({
							v.createSwordReward("Pink Ninja Katana"),
							v.createExplosionReward("Katana Pink Explosion"),
							v.createEmoteReward("Emote453")
						}),
						ProductId = 1888967610
					},
					{
						Color = "Chroma",
						ShowRoom = "ChromaNinjaKatanaShowRoom",
						Item = v.createListReward({
							v.createSwordReward("Chroma Ninja Katana"),
							v.createExplosionReward("Katana Chroma Explosion"),
							v.createEmoteReward("Emote454")
						}),
						IgnoreMarket = true
					}
				}
			}
		}
	}
}