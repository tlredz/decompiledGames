local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local useRobuxPrice = require(game.ReplicatedStorage.React.Hooks.Item.useRobuxPrice)
local unwrapped = ItemConfig.match(ItemId.getId("Discounted Permanent Dragon", "Redeemable"):unwrap()):unwrap()
local economy = unwrapped.Economy
assert(economy and economy.RobuxPrice, "bad product for Discounted Dragon")
return function()
	return useRobuxPrice(unwrapped.Index.ItemId) or economy.RobuxPrice
end