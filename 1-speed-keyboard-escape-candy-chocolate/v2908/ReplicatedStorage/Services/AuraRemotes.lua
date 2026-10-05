local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remo = require(ReplicatedStorage.Packages.remo)

local function isString(value)
	return type(value) == "string"
end

local function optionalString(value)
	return value == nil or type(value) == "string"
end

return remo.createRemotes({
	BuyAura = remo.remote(isString, isString).returns(),
	EquipAura = remo.remote(isString, optionalString).middleware(remo.throttleMiddleware(0.3))
})