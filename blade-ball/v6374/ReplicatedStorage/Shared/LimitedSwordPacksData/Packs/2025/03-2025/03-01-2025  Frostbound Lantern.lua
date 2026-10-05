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
		RootFFlagStartTime = "FrostboundLanternShowRoomRootStartTime",
		RootFFlagEndTime = "FrostboundLanternShowRoomRootEndTime",
		FFlagStartTime = "FrostboundLanternShowRoomStartTime",
		FFlagEndTime = "FrostboundLanternShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Frostbound Lantern",
				Image = "rbxassetid://96095056085899",
				ShowRoom = "FrostboundLanternShowRoom",
				TemplateType = "Bundle",
				Stock = "Frostbound Lantern",
				Rewards = {
					{
						GiftName = "Frostbound Lantern",
						GiftId = 3228233107,
						Item = v.createListReward({
							v.createSwordReward("Frostbound Lantern"),
							v.createExplosionReward("Frostbound Enlightenment"),
							v.createEmoteReward("Emote812")
						}),
						ProductId = 3228233104
					}
				}
			}
		}
	}
}