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
		RootFFlagStartTime = "SnowballLauncherRootStartTime",
		RootFFlagEndTime = "SnowballLauncherRootEndTime",
		FFlagStartTime = "SnowballLauncherStartTime",
		FFlagEndTime = "SnowballLauncherEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Snowball Launcher",
				Image = "rbxassetid://82504084043431",
				ShowRoom = "SnowballLauncherShowRoom",
				TemplateType = "Bundle",
				Stock = "Snowball Launcher",
				Rewards = {
					{
						GiftName = "Snowball Launcher",
						GiftId = 2680479861,
						Item = v.createListReward({
							v.createSwordReward("Snowball Launcher"),
							v.createExplosionReward("Rocket Tree"),
							v.createEmoteReward("Snowball Launcher Emote")
						}),
						ProductId = 2680479845
					}
				}
			}
		}
	}
}