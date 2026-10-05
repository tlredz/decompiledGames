local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remo = require(ReplicatedStorage.Packages.remo)

local function isString(value)
	return type(value) == "string"
end

local function isTable(p)
	return type(p) == "table"
end

return remo.createRemotes({
	BuyWins = remo.remote(isString).middleware(remo.throttleMiddleware(0.3)),
	BuyRobux = remo.remote(isString).middleware(remo.throttleMiddleware(0.3)),
	PromptRestock = remo.remote().middleware(remo.throttleMiddleware(0.3)),
	RequestState = remo.remote(),
	ShopUpdate = remo.remote(isTable)
})