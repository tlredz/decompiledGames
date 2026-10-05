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
		RootFFlagStartTime = "SeaTurtleRootStartTime",
		RootFFlagEndTime = "SeaTurtleRoot2EndTime",
		FFlagStartTime = "SeaTurtleStartTime",
		FFlagEndTime = "SeaTurtleEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Sea Turtle",
				Image = "rbxassetid://139652100746425",
				ShowRoom = "SeaTurtleShowRoom",
				TemplateType = "Bundle",
				Stock = "Sea Turtle",
				Rewards = {
					{
						GiftName = "Sea Turtle",
						GiftId = 3604305463,
						Item = v.createListReward({
							v.createSwordReward("Sea Turtle"),
							v.createExplosionReward("Sea Turtle Explosion"),
							v.createEmoteReward("Emote1226")
						}),
						ProductId = 3604305481
					}
				}
			}
		}
	}
}