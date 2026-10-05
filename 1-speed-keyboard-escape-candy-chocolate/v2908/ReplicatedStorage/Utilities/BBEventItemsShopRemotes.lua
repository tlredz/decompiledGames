local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remo = require(ReplicatedStorage.Packages.remo)

local function isString(value)
	return type(value) == "string"
end

local function isNumber(value)
	return type(value) == "number"
end

local function isTable(p)
	return type(p) == "table"
end

return remo.createRemotes({
	BBEventItemsShop = remo.namespace({
		BuyWins = remo.remote(isString).middleware(remo.throttleMiddleware(0.3)),
		BuyRobux = remo.remote(isString).middleware(remo.throttleMiddleware(0.3)),
		BuyUgc = remo.remote(isNumber).middleware(remo.throttleMiddleware(0.3)),
		PurchaseFeedback = remo.remote(isTable)
	})
}).BBEventItemsShop