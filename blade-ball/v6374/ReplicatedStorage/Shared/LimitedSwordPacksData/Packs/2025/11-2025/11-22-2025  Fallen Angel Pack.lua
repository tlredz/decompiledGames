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
		RootFFlagStartTime = "FallenAngelRootStartTime",
		RootFFlagEndTime = "FallenAngelRootEndTime",
		FFlagStartTime = "FallenAngelShowRoomStartTime",
		FFlagEndTime = "FallenAngelShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Fallen Angel",
				Image = "rbxassetid://108187686966562",
				ShowRoom = "FallenAngelShowRoom",
				TemplateType = "Bundle",
				Stock = "Fallen Angel",
				Rewards = {
					{
						GiftName = "Fallen Angel",
						GiftId = 3462326325,
						Item = v.createListReward({
							v.createSwordReward("Fallen Angel"),
							v.createExplosionReward("Fallen Angel Explosion"),
							v.createEmoteReward("Emote1085")
						}),
						ProductId = 3462326321
					}
				}
			}
		}
	}
}