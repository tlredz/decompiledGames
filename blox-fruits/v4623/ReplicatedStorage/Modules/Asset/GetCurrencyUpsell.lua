local Shop = require(game.ReplicatedStorage.Shop)
local PlayerDataUtil = require(game.ReplicatedStorage.Modules.Player.PlayerDataUtil)
local TextUtil = require(game.ReplicatedStorage.Modules.Util.TextUtil)
local Notification = require(game.ReplicatedStorage.Notification)
local Error = require(game.ReplicatedStorage.Packages.Error)
local v = {}
local v2 = {}
local flag = false

local function _init()
	if flag then
		return
	end

	flag = true
	local assetIds = {}

	for _, v3 in Shop.mapToLegacy(Shop.LIBRARY.PRODUCT.ALL) do
		if not ((v3.subtype == "Fragment Product" or v3.subtype == "Cash Product") and v3.modifiers and v3.storageName and v3.assetId) then
			continue
		end

		if v3.assetId < 0 then
			continue
		end

		assert(table.find(assetIds, v3.assetId) == nil)

		if v3.subtype == "Fragment Product" then
			local modifiers = v3.modifiers

			if not modifiers.Fragments then
				continue
			end

			table.insert(v, {
				AssetId = v3.assetId,
				Amount = modifiers.Fragments,
				StorageName = v3.storageName
			})
		elseif v3.subtype == "Cash Product" then
			local modifiers = v3.modifiers

			if not modifiers.Beli then
				continue
			end

			table.insert(v2, {
				AssetId = v3.assetId,
				Amount = modifiers.Beli,
				StorageName = v3.storageName
			})
		end

		table.insert(assetIds, v3.assetId)
	end

	table.sort(v, function(a, b)
		return a.Amount < b.Amount
	end)
	table.sort(v2, function(a, b)
		return a.Amount < b.Amount
	end)
	table.freeze(v)
	table.freeze(v2)
end

local function getAmountRequired(p: number, p2: string)
	local value = 0

	if p2 == "Fragments" then
		local fragmentsInstance = PlayerDataUtil.getFragmentsInstance(game.Players.LocalPlayer)

		if fragmentsInstance then
			value = fragmentsInstance.Value
		end
	elseif p2 == "Beli" then
		local beliInstance = PlayerDataUtil.getBeliInstance(game.Players.LocalPlayer)

		if beliInstance then
			value = beliInstance.Value
		end
	end

	if value < p then
		return p - value
	end

	return nil
end

local function getProduct(p: number, list)
	for i = 1, #list do
		local v3 = list[i]

		if p <= v3.Amount then
			return v3
		end
	end

	return list[#list]
end

return function(p: number, p2: string)
	local RunService = game:GetService("RunService")
	assert(RunService:IsClient())
	assert(p)
	assert(p2)
	assert(p2 == "Fragments" or p2 == "Beli")
	local value = 0

	if p2 == "Fragments" then
		local fragmentsInstance = PlayerDataUtil.getFragmentsInstance(game.Players.LocalPlayer)

		if fragmentsInstance then
			value = fragmentsInstance.Value
		end
	elseif p2 == "Beli" then
		local beliInstance = PlayerDataUtil.getBeliInstance(game.Players.LocalPlayer)

		if beliInstance then
			value = beliInstance.Value
		end
	end

	local amountRequired

	if value < p then
		amountRequired = p - value
	end

	if not amountRequired then
		return nil
	end

	_init()
	local v4 = p2 == "Fragments" and v or v2
	local flag2 = true
	local product

	for i = 1, #v4 do
		product = v4[i]

		if not (amountRequired <= product.Amount) then
			continue
		end

		flag2 = false
		break
	end

	if flag2 then
		product = v4[#v4]
	end

	return {
		Product = product,
		AmountRequired = amountRequired,
		Notify = function(p3)
			Notification.new(p3 or `You need <Color=Purple>ƒ{TextUtil.commaValue(p)}<Color=/>`):Display()
		end,
		Upsell = function()
			print("Prompt purchase for", Error.displayAsJson(product, 4, true))
		end
	}
end