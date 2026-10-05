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
		RootFFlagStartTime = "OniKatanaPackRootStartTime",
		RootFFlagEndTime = "OniKatanaPackRootEndTime",
		FFlagStartTime = "OniKatanaPackShowRoomStartTime",
		FFlagEndTime = "OniKatanaPackShowRoomEndTime",
		Rewards = {
			{
				Type = "SelectColors",
				Name = "Oni Katana Pack",
				Image = "rbxassetid://115223691467050",
				ShowRoom = "BlackOniKatanaShowRoom",
				TemplateType = "Bundle",
				Rewards = {
					{
						Color = "Black",
						Stock = "Black Oni Katana",
						ShowRoom = "BlackOniKatanaShowRoom",
						GiftName = "Black Oni Katana",
						GiftId = 3325188280,
						Item = v.createListReward({
							v.createSwordReward("Black Oni Katana"),
							v.createExplosionReward("Black Oni Katana Explosion"),
							v.createEmoteReward("Emote971")
						}),
						ProductId = 3325188284
					},
					{
						Color = "Red",
						Stock = "Red Oni Katana",
						ShowRoom = "RedOniKatanaShowRoom",
						GiftName = "Red Oni Katana",
						GiftId = 3325188283,
						Item = v.createListReward({
							v.createSwordReward("Red Oni Katana"),
							v.createExplosionReward("Red Oni Katana Explosion"),
							v.createEmoteReward("Emote970")
						}),
						ProductId = 3325188288
					},
					{
						Color = "Purple",
						Stock = "Purple Oni Katana",
						ShowRoom = "PurpleOniKatanaShowRoom",
						GiftName = "Purple Oni Katana",
						GiftId = 3325188286,
						Item = v.createListReward({
							v.createSwordReward("Purple Oni Katana"),
							v.createExplosionReward("Purple Oni Katana Explosion"),
							v.createEmoteReward("Emote969")
						}),
						ProductId = 3325188290
					},
					{
						Color = "Blue",
						Stock = "Blue Oni Katana",
						ShowRoom = "BlueOniKatanaShowRoom",
						GiftName = "Blue Oni Katana",
						GiftId = 3325188287,
						Item = v.createListReward({
							v.createSwordReward("Blue Oni Katana"),
							v.createExplosionReward("Blue Oni Katana Explosion"),
							v.createEmoteReward("Emote968")
						}),
						ProductId = 3325188282
					},
					{
						Color = "Pink",
						Stock = "Pink Oni Katana",
						ShowRoom = "PinkOniKatanaShowRoom",
						GiftName = "Pink Oni Katana",
						GiftId = 3325188291,
						Item = v.createListReward({
							v.createSwordReward("Pink Oni Katana"),
							v.createExplosionReward("Pink Oni Katana Explosion"),
							v.createEmoteReward("Emote967")
						}),
						ProductId = 3325188285
					},
					{
						Color = "Chroma",
						ShowRoom = "ChromaOniKatanaShowRoom",
						Item = v.createListReward({
							v.createSwordReward("Chroma Oni Katana"),
							v.createExplosionReward("Chroma Oni Katana Explosion"),
							v.createEmoteReward("Emote966")
						}),
						IgnoreMarket = true
					}
				}
			}
		}
	}
}