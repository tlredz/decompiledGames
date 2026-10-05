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
		RootFFlagStartTime = "PhantomPactRootStartTime",
		RootFFlagEndTime = "PhantomPactRootEndTime",
		FFlagStartTime = "PhantomPactStartTime",
		FFlagEndTime = "PhantomPactEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Phantom Pact",
				Image = "rbxassetid://72550389120900",
				ShowRoom = "PhantomPactShowRoom",
				TemplateType = "Bundle",
				Stock = "Phantom Pact",
				Rewards = {
					{
						GiftName = "Phantom Pact",
						GiftId = 3551336795,
						Item = v.createListReward({
							v.createSwordReward("Phantom Pact"),
							v.createExplosionReward("Phantom Pact"),
							v.createEmoteReward("Emote1175")
						}),
						ProductId = 3551336797
					}
				}
			}
		}
	}
}