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
		RootFFlagStartTime = "NinjaStarPackRootStartTime",
		RootFFlagEndTime = "NinjaStarPackRootEndTime",
		FFlagStartTime = "NinjaStarPackShowRoomStartTime",
		FFlagEndTime = "NinjaStarPackShowRoomEndTime",
		Rewards = {
			{
				Type = "SelectColors",
				Name = "Ninja Star Pack",
				Image = "rbxassetid://79451127047464",
				ShowRoom = "BlackNinjaStarShowRoom",
				TemplateType = "Bundle",
				Rewards = {
					{
						Color = "Black",
						Stock = "Black Ninja Star",
						ShowRoom = "BlackNinjaStarShowRoom",
						GiftName = "Black Ninja Star",
						GiftId = 1922608521,
						Item = v.createListReward({
							v.createSwordReward("Black Ninja Star"),
							v.createExplosionReward("Black Ninja Star Explosion"),
							v.createEmoteReward("Emote512")
						}),
						ProductId = 1922608518
					},
					{
						Color = "Red",
						Stock = "Red Ninja Star",
						ShowRoom = "RedNinjaStarShowRoom",
						GiftName = "Red Ninja Star",
						GiftId = 1922608526,
						Item = v.createListReward({
							v.createSwordReward("Red Ninja Star"),
							v.createExplosionReward("Red Ninja Star Explosion"),
							v.createEmoteReward("Emote510")
						}),
						ProductId = 1922608514
					},
					{
						Color = "Green",
						Stock = "Green Ninja Star",
						ShowRoom = "GreenNinjaStarShowRoom",
						GiftName = "Green Ninja Star",
						GiftId = 1922608523,
						Item = v.createListReward({
							v.createSwordReward("Green Ninja Star"),
							v.createExplosionReward("Green Ninja Star Explosion"),
							v.createEmoteReward("Emote508")
						}),
						ProductId = 1922608517
					},
					{
						Color = "Blue",
						Stock = "Blue Ninja Star",
						ShowRoom = "BlueNinjaStarShowRoom",
						GiftName = "Blue Ninja Star",
						GiftId = 1922608515,
						Item = v.createListReward({
							v.createSwordReward("Blue Ninja Star"),
							v.createExplosionReward("Blue Ninja Star Explosion"),
							v.createEmoteReward("Emote509")
						}),
						ProductId = 1922608520
					},
					{
						Color = "Pink",
						Stock = "Pink Ninja Star",
						ShowRoom = "PinkNinjaStarShowRoom",
						GiftName = "Pink Ninja Star",
						GiftId = 1922608516,
						Item = v.createListReward({
							v.createSwordReward("Pink Ninja Star"),
							v.createExplosionReward("Pink Ninja Star Explosion"),
							v.createEmoteReward("Emote511")
						}),
						ProductId = 1922608519
					},
					{
						Color = "Chroma",
						ShowRoom = "ChromaNinjaStarShowRoom",
						Item = v.createListReward({
							v.createSwordReward("Chroma Ninja Star"),
							v.createExplosionReward("Chroma Ninja Star Explosion"),
							v.createEmoteReward("Emote513")
						}),
						IgnoreMarket = true
					}
				}
			}
		}
	}
}