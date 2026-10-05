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
		RootFFlagStartTime = "JollyScytheSetRootStartTime",
		RootFFlagEndTime = "JollyScytheSetRootEndTime",
		FFlagStartTime = "JollyScytheSetShowRoomStartTime",
		FFlagEndTime = "JollyScytheSetShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Jolly Scythe Set",
				Image = "rbxassetid://109959163262841",
				ShowRoom = "JollyScytheSetShowRoom",
				TemplateType = "Bundle",
				Stock = "Jolly Scythe Set",
				Rewards = {
					{
						GiftName = "Jolly Scythe Set",
						GiftId = 2680479856,
						Item = v.createListReward({
							v.createSwordReward("Jolly Scythe Set"),
							v.createExplosionReward("Bell Light"),
							v.createEmoteReward("Jolly Scythe Set Emote")
						}),
						ProductId = 2680479858
					}
				}
			}
		}
	}
}