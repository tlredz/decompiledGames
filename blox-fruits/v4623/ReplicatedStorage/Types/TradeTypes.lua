local Players = game:GetService("Players")
local Type = require(game.ReplicatedStorage.Packages.Type)
local TypeUtil = require(game.ReplicatedStorage.Util.TypeUtil)
local Shop = require(game.ReplicatedStorage.Shop)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local intersection = Type.intersection(Type.integer, Type.numberConstrained(1, 4))
local intersection2 = Type.intersection(Type.integer, Type.numberConstrained(1, 2))
local betterUnion = TypeUtil.Types.BetterUnion
local strictInterface = Type.strictInterface
local v2 = {
	Type = Type.literal("EconomyItem"),
	ItemId = 0,
	Reducer = 0,
	Amount = 0
}
local v3 = "Redeemable"

function v2.ItemId(value)
	if type(value) ~= "number" then
		return (`item-id must be a number, received "{typeof(value)}"`)
	end

	local dataFromId = ItemId.getDataFromId(value)

	if dataFromId:isErr() then
		return false, (`item-id #{value} is not a valid item id `)
	end

	local unwrapped = dataFromId:unwrap()

	if unwrapped.Type == v3 then
		return true
	end

	return false, (`expected item-id #{value} to be type "{v3}", got "{unwrapped.Type}"`)
end

v2.Reducer = Type.numberConstrained(0, 1)
v2.Amount = intersection
local v = {
	EconomyItem = strictInterface(v2),
	PhysicalMoveset = 0,
	SpecialPhysicalFruit = 0
}
local strictInterface2 = Type.strictInterface
local v4 = {
	Type = Type.literal("PhysicalMoveset"),
	ItemId = 0,
	Price = 0,
	Amount = 0
}
local v5 = "PhysicalMoveset"

function v4.ItemId(value)
	if type(value) ~= "number" then
		return (`item-id must be a number, received "{typeof(value)}"`)
	end

	local dataFromId = ItemId.getDataFromId(value)

	if dataFromId:isErr() then
		return false, (`item-id #{value} is not a valid item id `)
	end

	local unwrapped = dataFromId:unwrap()

	if unwrapped.Type == v5 then
		return true
	end

	return false, (`expected item-id #{value} to be type "{v5}", got "{unwrapped.Type}"`)
end

v4.Price = Type.intersection(Type.integer, Type.numberMin(1))
v4.Amount = intersection
v.PhysicalMoveset = strictInterface2(v4)
local strictInterface3 = Type.strictInterface
local v6 = {
	Type = Type.literal("SpecialPhysicalFruit"),
	ItemId = 0,
	Reducer = 0,
	Amount = 0
}
local v7 = "PhysicalMoveset"

function v6.ItemId(value)
	if type(value) ~= "number" then
		return (`item-id must be a number, received "{typeof(value)}"`)
	end

	local dataFromId = ItemId.getDataFromId(value)

	if dataFromId:isErr() then
		return false, (`item-id #{value} is not a valid item id `)
	end

	local unwrapped = dataFromId:unwrap()

	if unwrapped.Type == v7 then
		return true
	end

	return false, (`expected item-id #{value} to be type "{v7}", got "{unwrapped.Type}"`)
end

v6.Reducer = Type.numberConstrained(0, 1)
v6.Amount = intersection
v.SpecialPhysicalFruit = strictInterface3(v6)
local v8 = betterUnion(v)

local function fn(data)
	local v9, v10 = v8(data)

	if not v9 then
		return false, v10
	end

	local unwrapped = ItemConfig.match(data.ItemId):unwrap()

	if data.Type == "EconomyItem" and Shop.match(data.ItemId):isErr() then
		return false, (`Item "{unwrapped.Index.DebugLabel}" is not a product.`)
	end

	if data.Type == "EconomyItem" or data.Type == "SpecialPhysicalFruit" then
		local reducer = data.Reducer

		if (unwrapped.Economy and unwrapped.Economy.TradeReducer) ~= reducer then
			return
				false,
				(`Expected "{unwrapped.Index.DebugLabel}" to have a reducer of "{unwrapped.Economy and unwrapped.Economy.TradeReducer}", received "{reducer}"`)
		end
	end

	if data.Type == "PhysicalMoveset" then
		local price = data.Price

		if unwrapped.Quality.MoneyPrice ~= price then
			return
				false,
				(`Expected "{unwrapped.Index.DebugLabel}" to have a price of "{unwrapped.Quality.MoneyPrice}", received "{price}"`)
		end
	end

	return true
end

local strictInterface4 = Type.strictInterface({
	SlotsFilled = Type.intersection(Type.integer, Type.numberConstrained(0, 4)),
	Items = Type.map(Type.string, fn)
})

local function fn2(p)
	local v9, v10 = strictInterface4(p)

	if not v9 then
		return v9, v10
	end

	local total = 0

	for k, item in p.Items do
		if tostring(ItemConfig.match(item.ItemId):unwrap().Index.ItemId) ~= k then
			return false, (`Items map entry item with id #{item.ItemId} does not match the key of "{k}"`)
		end

		total += item.Amount
	end

	if total == p.SlotsFilled then
		return true
	end

	return false, "SlotsFilled does not match summed amounts"
end

local strictInterface5 = Type.strictInterface({
	Trader = Type.map(intersection2, function(value)
		if typeof(value) ~= "number" then
			return false, (`received type "{typeof(value)}", expected type "Instance"`)
		end

		if Players:GetPlayerByUserId(value) == nil then
			return false, (`Player with user id #{value} not found under Players`)
		end

		return true
	end),
	Offer = Type.map(Type.intersection(Type.integer, Type.numberConstrained(1, 2)), fn2),
	State = TypeUtil.Types.BetterUnion({
		Countdown = Type.strictInterface({
			Type = Type.literal("Countdown"),
			UID = function(value)
				if type(value) ~= "string" then
					return false, (`expected type "string", received type "{type(value)}"`)
				end

				if value:len() ~= 36 then
					return false, (`expected UID to be 36 characters long, received {value:len()}`)
				end

				if #value:split("-") == 5 then
					return true
				end

				return false, (`expected UID to have 5 hyphens, received {#value:split("-")}`)
			end,
			StartTime = function(p)
				if typeof(p) ~= "DateTime" then
					return false, (`expected StartTime to be type "number", got a "{typeof(p)}"`)
				end

				if DateTime.now().UnixTimestamp - 600 > p.UnixTimestamp then
					return false, (`StartTime can't be farther than {10} minutes in the past`)
				end

				if p.UnixTimestamp > DateTime.now().UnixTimestamp + 1 then
					return false, "StartTime can't be in the future"
				end

				return true
			end
		}),
		NotReady = Type.strictInterface({
			Type = Type.literal("NotReady"),
			Ready = Type.map(intersection2, Type.boolean)
		}),
		Processing = Type.strictInterface({
			Type = Type.literal("Processing")
		})
	})
})
return {
	Types = {
		TradeItem = fn,
		Offer = fn2,
		Trade = Type.intersection(strictInterface5, function(p)
			local v9, v10 = strictInterface5(p)

			if not v9 then
				return false, v10
			end

			if p.Trader[1] == p.Trader[2] then
				return false, "Player1 and Player2 have the same UserId"
			end

			return true
		end)
	}
}