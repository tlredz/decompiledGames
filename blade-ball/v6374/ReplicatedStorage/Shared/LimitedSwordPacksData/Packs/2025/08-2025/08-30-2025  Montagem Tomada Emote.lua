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
		RootFFlagStartTime = "MontagemTomadaEmoteStartTime",
		RootFFlagEndTime = "MontagemTomadaEmoteEndTime",
		FFlagStartTime = "MontagemTomadaEmoteStartTime",
		FFlagEndTime = "MontagemTomadaEmoteEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Montagem Tomada",
				Image = v2.Icons:GetEmoteIcon("Montagem Tomada"),
				ShowRoom = "MontagemTomadaShowRoom",
				TemplateType = "Sword",
				Stock = "Montagem Tomada",
				Rewards = {
					{
						GiftName = "Montagem Tomada Emote",
						GiftId = 3389598950,
						Item = v.createListReward({ v.createEmoteReward("Emote1017") }),
						ProductId = 3389598947
					}
				}
			}
		}
	}
}