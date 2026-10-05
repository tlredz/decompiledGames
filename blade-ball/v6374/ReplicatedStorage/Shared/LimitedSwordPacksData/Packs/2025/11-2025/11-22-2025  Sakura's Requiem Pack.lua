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
		RootFFlagStartTime = "SakurasRequiemRootStartTime",
		RootFFlagEndTime = "SakurasRequiemRootEndTime",
		FFlagStartTime = "SakurasRequiemShowRoomStartTime",
		FFlagEndTime = "SakurasRequiemShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Sakura's Requiem",
				Image = "rbxassetid://100969822118581",
				ShowRoom = "SakurasRequiemShowRoom",
				TemplateType = "Bundle",
				Stock = "Sakura's Requiem",
				Rewards = {
					{
						GiftName = "Sakura's Requiem",
						GiftId = 3462326326,
						Item = v.createListReward({
							v.createSwordReward("Sakura's Requiem"),
							v.createExplosionReward("Sakura's Requiem Explosion"),
							v.createEmoteReward("Emote1087")
						}),
						ProductId = 3462326323
					}
				}
			}
		}
	}
}