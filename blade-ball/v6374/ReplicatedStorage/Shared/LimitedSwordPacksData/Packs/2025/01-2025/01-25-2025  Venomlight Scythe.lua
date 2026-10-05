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
		RootFFlagStartTime = "VenomlightScytheRootStartTime",
		RootFFlagEndTime = "VenomlightScytheRootEndTime",
		FFlagStartTime = "VenomlightScytheShowRoomStartTime",
		FFlagEndTime = "VenomlightScytheShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Venomlight Scythe",
				Image = "rbxassetid://99083501291736",
				ShowRoom = "VenomlightScytheShowRoom",
				TemplateType = "Bundle",
				Stock = "Venomlight Scythe",
				Rewards = {
					{
						GiftName = "Venomlight Scythe",
						GiftId = 2708243458,
						Item = v.createListReward({
							v.createSwordReward("Venomlight Scythe"),
							v.createExplosionReward("Lunar Lantern"),
							v.createEmoteReward("Emote757")
						}),
						ProductId = 2708243459
					}
				}
			}
		}
	}
}