local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = require3(ReplicatedStorage2.Common.Utils)
require3(script:FindFirstAncestor("Packs").Parent.Types)
return {
	{
		RootFFlagStartTime = "MontagemMiauEmoteStartTime",
		RootFFlagEndTime = "MontagemMiauEmoteEndTime",
		FFlagStartTime = "MontagemMiauEmoteStartTime",
		FFlagEndTime = "MontagemMiauEmoteEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Montagem Miau",
				Image = v2.Icons:GetEmoteIcon("Montagem Miau"),
				ShowRoom = "MontagemMiauShowRoom",
				TemplateType = "Sword",
				Stock = "Montagem Miau",
				Rewards = {
					{
						GiftName = "Montagem Miau",
						GiftId = 3558390700,
						Item = v.createListReward({ v.createEmoteReward("Emote1185") }),
						ProductId = 3558390699
					}
				}
			}
		}
	}
}