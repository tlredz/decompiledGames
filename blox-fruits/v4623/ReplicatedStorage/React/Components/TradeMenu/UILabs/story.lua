local Global = require(game.ReplicatedStorage.Global)
Global.__REACT_MICROPROFILER_LEVEL = 10
Global.IsUnitTest = true
local HttpService = game:GetService("HttpService")
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local UILabs = require(game.ReplicatedStorage.DevPackages.UILabs)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
require(game.ReplicatedStorage.Types.TradeTypes)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local parentModule = require(script.Parent)
local itemIdsByDebugLabel = {}

for _, v in ItemConfig.Query.select({
	Index = {
		IdType = "PhysicalMoveset"
	}
}) do
	if v.Quality.MoneyPrice and v.Index.StorageKey ~= "Dragon-Dragon" then
		itemIdsByDebugLabel[v.Index.DebugLabel] = v.Index.ItemId
	end
end

for _, v in ItemConfig.Query.select({
	Index = {
		IdType = "Redeemable"
	}
}) do
	if v.Economy and v.Economy.TradeReducer then
		itemIdsByDebugLabel[v.Index.DebugLabel] = v.Index.ItemId
	end
end

local v = {}

for k, _ in itemIdsByDebugLabel do
	table.insert(v, k)
end

local createElement = React.createElement

local function newTradeConfig(itemId: number)
	local unwrapped = ItemConfig.match(itemId):unwrap()

	if unwrapped.Index.IdType == "Redeemable" then
		return {
			Type = "EconomyItem",
			ItemId = itemId,
			Reducer = not (unwrapped.Economy and unwrapped.Economy.TradeReducer) and 0.01 or unwrapped.Economy.TradeReducer
		}
	end

	if unwrapped.Index.IdType == "PhysicalMoveset" and (unwrapped.Economy == nil or unwrapped.Economy.TradeReducer == nil) then
		return {
			Type = "PhysicalMoveset",
			ItemId = itemId,
			Price = not unwrapped.Quality.MoneyPrice and 1 or unwrapped.Quality.MoneyPrice
		}
	end

	return {
		Type = "SpecialPhysicalFruit",
		ItemId = itemId,
		Reducer = not (unwrapped.Economy and unwrapped.Economy.TradeReducer) and 0.01 or unwrapped.Economy.TradeReducer
	}
end

local function newTradeItem(itemId: number, amount: number)
	local v2 = newTradeConfig(itemId)

	if v2.Type == "EconomyItem" then
		return {
			Type = v2.Type,
			ItemId = v2.ItemId,
			Amount = amount,
			Reducer = v2.Reducer
		}
	end

	if v2.Type == "PhysicalMoveset" then
		return {
			Type = v2.Type,
			ItemId = v2.ItemId,
			Amount = amount,
			Price = v2.Price
		}
	end

	return {
		Type = v2.Type,
		ItemId = v2.ItemId,
		Amount = amount,
		Reducer = v2.Reducer
	}
end

function getInventory(p: number, p2: number)
	local random = Random.new(p)
	local result = {}

	for _ = 1, p2 do
		local v2 = v[random:NextInteger(1, #v)]
		result[v2] = result[v2] or 0
		result[v2] += 1
	end

	return result
end

return UILabs.CreateReactStory({
	react = React,
	reactRoblox = ReactRoblox,
	controls = {
		YourTradeSeed = UILabs.Slider(450, 150, 1050, 100),
		YourInventorySize = UILabs.Slider(10, 1, 30, 1),
		OtherTradeSeed = UILabs.Slider(300, 100, 1000, 100),
		OtherInventorySize = UILabs.Slider(10, 1, 30, 1),
		OtherOfferAmount = UILabs.Slider(2, 0, 4, 1),
		OtherIsReady = true,
		IsTradeNull = false,
		TradeState = UILabs.Choose({ "NotReady", "Countdown", "Processing" }, 1)
	}
}, function(p)
	local v2 = React.useMemo(function()
		return getInventory(p.controls.OtherTradeSeed, p.controls.OtherInventorySize)
	end, { p.controls.OtherTradeSeed, p.controls.OtherInventorySize })
	local state, setState = React.useState(false)
	local v3 = React.useMemo(function()
		local random = Random.new(p.controls.OtherTradeSeed + 1)
		local v4 = {}

		for k, _ in v2 do
			table.insert(v4, k)
		end

		TableUtil.randomize(v4, p.controls.OtherTradeSeed + 2)
		local result = {
			SlotsFilled = 0,
			Items = {}
		}

		for i = 1, p.controls.OtherOfferAmount do
			if result.SlotsFilled >= 4 then
				break
			end

			local v5 = v4[i]
			local v6 = v2[v5]
			local itemId = itemIdsByDebugLabel[v5]

			if v6 == 1 then
				result.SlotsFilled += 1
				result.Items[tostring(itemId)] = newTradeItem(itemId, 1)
			else
				local integer = random:NextInteger(1, v6)
				local amount = result.SlotsFilled + integer > 4 and 1 or integer
				result.SlotsFilled += amount
				result.Items[tostring(itemId)] = newTradeItem(itemId, amount)
			end
		end

		return result
	end, { v2, p.controls.OtherTradeSeed, p.controls.OtherOfferAmount })
	local owned = React.useMemo(function()
		local inventory = getInventory(p.controls.YourTradeSeed, p.controls.YourInventorySize)
		local result = {}

		for k, v5 in inventory do
			local itemId = itemIdsByDebugLabel[k]
			table.insert(result, (newTradeItem(itemId, v5)))
		end

		return result
	end, { p.controls.YourTradeSeed, p.controls.YourInventorySize })
	local tradeState = p.controls.TradeState
	local state2, setState2 = React.useState({})
	local v5 = React.useMemo(function()
		local result = {
			SlotsFilled = 0,
			Items = {}
		}

		for k, v6 in state2 do
			assert(v6, "bad amount")
			result.SlotsFilled += v6
			local itemId = itemIdsByDebugLabel[k]
			result.Items[tostring(itemId)] = newTradeItem(itemId, v6)
		end

		return result
	end, { state2 })
	local trade = React.useMemo(function()
		local v7 = {
			Trader = { 123, 456 },
			Offer = { v5, v3 },
			State = 0
		}
		local state3

		if tradeState == "NotReady" then
			state3 = {
				Type = "NotReady",
				Ready = { state, p.controls.OtherIsReady }
			}
		else
			state3 = tradeState == "Countdown" and {
				Type = "Countdown",
				UID = HttpService:GenerateGUID(false),
				StartTime = DateTime.now()
			} or {
				Type = "Processing"
			}
		end

		v7.State = state3
		return v7
	end, {
		v3,
		v5,
		p.controls.OtherIsReady,
		state,
		tradeState
	})

	if p.controls.IsTradeNull then
		trade = nil
	end

	return createElement(parentModule, {
		Owned = owned,
		Trade = trade,
		OnItemAction = function(p2: number, p3: string)
			local v10 = nil

			for k, v12 in itemIdsByDebugLabel do
				if v12 ~= p2 then
					continue
				end

				v10 = k
				break
			end

			if v10 then
				local clone = table.clone(state2)

				if p3 == "Add" then
					if v5.SlotsFilled < 4 then
						clone[v10] = (clone[v10] or 0) + 1
					end
				else
					clone[v10] = (clone[v10] or 1) - 1

					if clone[v10] <= 0 then
						clone[v10] = nil
					end
				end

				setState2(clone)
			end
		end,
		OnAction = function(p2: string)
			if p2 == "Accept" then
				setState(true)
			elseif p2 == "Cancel" then
				setState(false)
			end
		end
	})
end)