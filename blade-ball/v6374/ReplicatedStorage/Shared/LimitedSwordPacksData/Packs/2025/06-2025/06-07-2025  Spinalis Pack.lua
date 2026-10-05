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
		RootFFlagStartTime = "SpinalisRootStartTime",
		RootFFlagEndTime = "SpinalisRootEndTime",
		FFlagStartTime = "SpinalisShowRoomStartTime",
		FFlagEndTime = "SpinalisShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Spinalis",
				Image = "rbxassetid://126815045865648",
				ShowRoom = "SpinalisShowRoom",
				TemplateType = "Bundle",
				Stock = "Spinalis",
				Rewards = {
					{
						GiftName = "Spinalis",
						GiftId = 3302235589,
						Item = v.createListReward({
							v.createSwordReward("Spinalis"),
							v.createExplosionReward("Spinalis Explosion"),
							v.createEmoteReward("Emote951")
						}),
						ProductId = 3302235592
					}
				}
			}
		}
	}
}