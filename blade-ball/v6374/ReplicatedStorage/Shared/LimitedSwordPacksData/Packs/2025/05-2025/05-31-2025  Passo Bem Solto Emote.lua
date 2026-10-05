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
		RootFFlagStartTime = "PassoBemSoltoEmoteStartTime",
		RootFFlagEndTime = "PassoBemSoltoEmoteEndTime",
		FFlagStartTime = "PassoBemSoltoEmoteStartTime",
		FFlagEndTime = "PassoBemSoltoEmoteEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Passo Bem Solto",
				Image = v2.Icons:GetEmoteIcon("Passo Bem Solto"),
				ShowRoom = "PassoBemSoltoShowRoom",
				TemplateType = "Sword",
				Stock = "Passo Bem Solto",
				Rewards = {
					{
						GiftName = "Passo Bem Solto Emote",
						GiftId = 3296340380,
						Item = v.createListReward({ v.createEmoteReward("Emote915") }),
						ProductId = 3296340379
					}
				}
			}
		}
	}
}