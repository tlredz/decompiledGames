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
		RootFFlagStartTime = "NOBATIDOStartTime",
		RootFFlagEndTime = "NOBATIDOEndTime",
		FFlagStartTime = "NOBATIDOStartTime",
		FFlagEndTime = "NOBATIDOEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "NO BATIDÃO",
				Image = v2.Icons:GetEmoteIcon("NO BATIDÃO"),
				ShowRoom = "NOBATIDOShowRoom",
				TemplateType = "Sword",
				Stock = "NO BATIDÃO",
				Color = Color3.fromRGB(255, 43, 43),
				Rewards = {
					{
						GiftName = "NO BATIDÃO",
						GiftId = 3711161762,
						Item = v.createListReward({ v.createEmoteReward("NO BATIDÃO") }),
						ProductId = 3711161766
					}
				}
			}
		}
	}
}