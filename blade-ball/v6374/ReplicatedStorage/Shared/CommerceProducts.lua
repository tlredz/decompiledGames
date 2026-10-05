local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
return {
	["Sorry Ladies Hoodie"] = {
		CommerceProductId = "COM-3102072616297169135",
		ProductId = 3289055956,
		LimitedStockKey = "Merch - Sorry Ladies Hoodie",
		LimitedStockAmount = 1200,
		Reward = v.createSwordReward("Dragon's Omen")
	},
	["White Blade Ball Hoodie"] = {
		CommerceProductId = "COM-865472451354296609",
		ProductId = 3289055959,
		LimitedStockKey = "Merch - White Blade Ball Hoodie",
		LimitedStockAmount = 1200,
		Reward = v.createSwordReward("Retribution Guitar")
	},
	["Black Blade Ball Hoodie"] = {
		CommerceProductId = "COM-7493082252983402741",
		ProductId = 3289055957,
		LimitedStockKey = "Merch - Black Blade Ball Hoodie",
		LimitedStockAmount = 1200,
		Reward = v.createSwordReward("Void Guardian")
	},
	["B&W Hoodie"] = {
		CommerceProductId = "COM-379646641551704328",
		ProductId = 3289055958,
		LimitedStockKey = "Merch - B&W Hoodie",
		LimitedStockAmount = 1200,
		Reward = v.createSwordReward("Starscope Sniper")
	},
	["B&W Blade Ball Tee"] = {
		CommerceProductId = "COM-6596865927136673951",
		ProductId = 3289055962,
		LimitedStockKey = "Merch - B&W Blade Ball Tee",
		LimitedStockAmount = 3000,
		Reward = v.createSwordReward("Inksoul Brush")
	},
	["Black & Blue Blade Ball Tee"] = {
		CommerceProductId = "COM-5403412025883492615",
		ProductId = 3289055960,
		LimitedStockKey = "Merch - Black & Blue Blade Ball",
		LimitedStockAmount = 3000,
		Reward = v.createSwordReward("Dual Star Staffs")
	},
	["Blade Ball Gaming Mouse Pad"] = {
		CommerceProductId = "COM-2557137061385339057",
		ProductId = 3289055961,
		LimitedStockKey = "Merch - Blade Ball Gaming Mouse Pad",
		LimitedStockAmount = 1000,
		Reward = v.createSwordReward("Blackhole Set")
	},
	["Blade Ball Mouse Pad"] = {
		CommerceProductId = "COM-1441933203657719980",
		ProductId = 3289057797,
		LimitedStockKey = "Merch - Blade Ball Mouse Pad",
		LimitedStockAmount = 1000,
		Reward = v.createSwordReward("Blackhole Sword")
	},
	["Blade Ball Puppy"] = {
		CommerceProductId = "COM-6413554559574213058",
		ProductId = 3580468942,
		LimitedStockKey = "Merch - Blade Ball Plushie",
		LimitedStockAmount = 2000,
		Reward = v.createSwordReward("Puppy")
	}
}