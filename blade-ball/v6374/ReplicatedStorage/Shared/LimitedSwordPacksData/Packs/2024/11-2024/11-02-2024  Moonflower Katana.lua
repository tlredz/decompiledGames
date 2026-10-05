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
		RootFFlagStartTime = "MoonflowerKatanaRootStartTime",
		RootFFlagEndTime = "MoonflowerKatanaRootEndTime",
		FFlagStartTime = "MoonflowerKatanaShowRoomStartTime",
		FFlagEndTime = "MoonflowerKatanaShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Moonflower Katana",
				Image = "rbxassetid://111870960316983",
				ShowRoom = "MoonflowerKatanaShowRoom",
				TemplateType = "Bundle",
				Stock = "Moonflower Katana",
				Rewards = {
					{
						GiftName = "Moonflower Katana",
						GiftId = 2319193574,
						Item = v.createListReward({
							v.createSwordReward("Moonflower Katana"),
							v.createExplosionReward("Moon Discovery"),
							v.createEmoteReward("Emote600")
						}),
						ProductId = 2319193581
					}
				}
			}
		}
	}
}