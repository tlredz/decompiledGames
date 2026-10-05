local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
require3(ReplicatedStorage2.Shared.Trading.TradeInfo)
return table.freeze({
	{
		ProductId = 1871951388,
		Amount = 50
	},
	{
		ProductId = 1871951387,
		Amount = 250
	},
	{
		ProductId = 1871951390,
		Amount = 1000
	},
	{
		ProductId = 1871951389,
		Amount = 5000
	},
	{
		ProductId = 1871951391,
		Amount = 25000,
		Bonus = v.createSwordReward("Emperor Blade")
	}
})