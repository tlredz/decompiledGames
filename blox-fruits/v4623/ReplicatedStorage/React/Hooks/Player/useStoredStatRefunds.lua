local IdMap = require(game.ReplicatedStorage.IdMap)
local use = require(game.ReplicatedStorage.React.Hooks.Item.Quantity.use)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
local refundPoints = IdMap.Redeemable["Refund Points"]
return function()
	local currentRefundPoints = use(refundPoints)
	local v = useMockState("StoredStatRefunds", 0)

	if v then
		return v:get()
	end

	return currentRefundPoints
end