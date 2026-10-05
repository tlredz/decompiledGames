local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)(script.Parent.Parent.RewardInfo)
return {
	Rewards = {
		v.createCoinsReward(30, "Small"),
		v.createCoinsReward(40, "Small"),
		v.createCoinsReward(50, "Small"),
		v.createCoinsReward(100, "Med"),
		v.createCoinsReward(150, "Med"),
		v.createCoinsReward(250, "Big"),
		v.createSwordReward("Gladiator Sword"),
		v.createCoinsReward(80, "Small"),
		v.createCoinsReward(150, "Small"),
		v.createCoinsReward(200, "Med"),
		v.createCoinsReward(300, "Big"),
		v.createCoinsReward(500, "Big"),
		v.createBoostReward("Coins2x", 30),
		v.createCrateReward("BigChestOfCoins", "Coins", "Big Chest of Coins", "rbxassetid://15326928319"),
		v.createCoinsReward(100, "Big"),
		v.createCoinsReward(200, "Big"),
		v.createCoinsReward(300, "Huge"),
		v.createCoinsReward(400, "Huge"),
		v.createCoinsReward(500, "Huge"),
		v.createCoinsReward(1000, "Massive"),
		(v.createEmoteReward("Emote24"))
	}
}