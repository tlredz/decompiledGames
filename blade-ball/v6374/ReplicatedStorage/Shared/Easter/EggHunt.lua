local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
require3(ReplicatedStorage2.Shared.Time)
local EggHunt = {
	EventEndTime = require3(ReplicatedStorage2.Shared.Easter.EasterEvent).EndTime.UnixTimestamp,
	PremiumRewardsProductId = 1788048493,
	Eggs = {
		{
			DisplayName = "Lava Egg",
			Icon = "rbxassetid://16932251485",
			Available = 6
		},
		{
			DisplayName = "Mushroom Egg",
			Icon = "rbxassetid://16932250908",
			Available = 10
		},
		{
			DisplayName = "Serpent Egg",
			Icon = "rbxassetid://16934967747",
			Available = 2
		},
		{
			DisplayName = "Warrior Egg",
			Icon = "rbxassetid://16934967499",
			Available = 7
		},
		{
			DisplayName = "Crossroads Egg",
			Icon = "rbxassetid://16934968689",
			Available = 8
		},
		{
			DisplayName = "Devil Egg",
			Icon = "rbxassetid://16932251869",
			Available = 5
		},
		{
			DisplayName = "Flower Egg",
			Icon = "rbxassetid://16934968556",
			Available = 9
		},
		{
			DisplayName = "Easter Bunny Egg",
			Icon = "rbxassetid://16932251667",
			Available = 8
		},
		{
			DisplayName = "Desert Egg",
			Icon = "rbxassetid://16932252009",
			Available = 8
		},
		{
			DisplayName = "Moon Egg",
			Icon = "rbxassetid://16932251283",
			Available = 6
		},
		{
			DisplayName = "Toxic Egg",
			Icon = "rbxassetid://16934967608",
			Available = 7
		},
		{
			DisplayName = "Heaven Egg",
			Icon = "rbxassetid://16934967886",
			Available = 4
		},
		{
			DisplayName = "Futuristic Egg",
			Icon = "rbxassetid://16934968130",
			Available = 3
		},
		{
			DisplayName = "Atlantic Egg",
			Icon = "rbxassetid://16934967391",
			Available = 7
		},
		{
			DisplayName = "Forest Egg",
			Icon = "rbxassetid://16934968363",
			Available = 10
		}
	},
	Milestones = {
		{
			Value = 5,
			Reward = v.createBunnyCurrencyReward(50)
		},
		{
			Value = 20,
			Reward = v.createBunnyCurrencyReward(200)
		},
		{
			Value = 40,
			Reward = v.createBunnyCurrencyReward(400)
		},
		{
			Value = 60,
			Reward = v.createBunnyCurrencyReward(600)
		},
		{
			Value = 80,
			Reward = v.createBunnyCurrencyReward(800)
		},
		{
			Value = 100,
			Reward = v.createBunnyCurrencyReward(1000)
		}
	}
}

function EggHunt.IsEggHuntActive(_)
	return DateTime.now().UnixTimestamp < EggHunt.EventEndTime
end

function EggHunt.GetEggDataFromDisplayName(_, p: string)
	for _, egg in ipairs(EggHunt.Eggs) do
		if egg.DisplayName == p then
			return egg
		end
	end
end

return EggHunt