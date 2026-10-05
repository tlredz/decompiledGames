local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Config)
local ServerBoostConfig = {
	SHUTDOWN_SCHEDULE_DISALLOW_PURCHASE_TIME = 960,
	GetSettings = function()
		return Config.SERVER_BOOSTS
	end,
	GetProducts = function()
		return Config.SERVER_BOOSTS.PRODUCTS
	end,
	GetAddTime = function()
		return Config.SERVER_BOOSTS.ADD_TIME
	end
}

function ServerBoostConfig.GetProductConfigByProductId(p: number)
	for _, v in ServerBoostConfig.GetProducts() do
		if v.ProductId == p then
			return v
		end
	end

	return nil
end

return ServerBoostConfig