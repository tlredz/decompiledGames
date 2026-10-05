local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Notification = require(game.ReplicatedStorage.Notification)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("UI"):tag("Controller"):tag("FruitShop"):display():traceback():build()
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local commF_ = remotes:WaitForChild("CommF_")
local StateUtil = {
	CommRemoteFunc = commF_,
	CommRemoteEvent = remotes:WaitForChild("CommE"),
	getIfTransformed = function(instance)
		return instance:GetAttribute("TransparencyMode") ~= nil
	end
}

function StateUtil.tryEquipFruit(p: string, p2: string?)
	local extended = v.extend(".tryEquipFruit")
	extended.info((`call fn: (fruitName="{p}", dragonType="{p2}")`))
	local character = Players.LocalPlayer.Character

	if character and StateUtil.getIfTransformed(character) then
		extended.trace("You can't equip a new fruit while transformed")
		Notification.new("You can't equip a new fruit while transformed", 5):Display()
		return false
	else
		local Global = require(game.ReplicatedStorage.Global)
		Global.fruitSwapTimeLockout = tick() + 5
		local v2, v3 = commF_:InvokeServer("SwitchFruit", p, p2)
		extended.trace((`success: {v2}, err: {v3}`))
		local Global2 = require(game.ReplicatedStorage.Global)
		Global2.fruitSwapTimeLockout = tick() + 1
		assert(typeof(v2) == "boolean" or typeof(v2) == "nil", (`bad success value: {v2}`))
		assert(typeof(v3) == "string" or typeof(v3) == "nil", (`bad error value: {v3}`))
		return v2, v3
	end
end

function StateUtil.tryInvokeTemporaryPurchaseAsync(p: string, p2: string, p3: string?)
	local extended = v.extend(".tryInvokeTemporaryPurchaseAsync")
	extended.info((`call fn: (fruitName="{p}", shopContextType="{p2}", dragonType={p3})`))
	local v2 = commF_:InvokeServer("PurchaseRawFruit", p, p2 == "AdvancedFruitDealer", p3)
	extended.trace((`out: {v2}`))
	return v2
end

function StateUtil.getDragonTypeAsync()
	local extended = v.extend(".getDragonTypeAsync")
	extended.info("call fn: ()")
	local v2 = commF_:InvokeServer("DragonType")
	extended.trace((`out: {v2}`))
	return v2
end

function StateUtil.notifyError(p: string, p2: number?)
	v.extend(".notifyError").info((`call fn: (message={p}, duration={p2})`))
	Notification.new(`<Color=Red><{p}><Color=/>`, p2):Display()
end

return StateUtil