require("../SharedTypes")
local module = require("../SharedData/FishFoodData")
local FishFoodFunctions = {}

function FishFoodFunctions.collectSoldFoods()
	local result = {}

	for k, v in module do
		if FishFoodFunctions.isObtainedThroughPurchase(v) then
			result[k] = v
		end
	end

	return result
end

function FishFoodFunctions.getOwnedFishFoodCounts(p)
	if not p then
		return
	end

	local result = {}

	for k, _ in module do
		result[k] = 0
	end

	for _, v in p.FishFoodInventory.Inventory do
		local name = v.Name
		result[name] += 1
	end

	return result
end

function FishFoodFunctions.isObtainedThroughPurchase(p)
	return p.PurchaseCost ~= nil
end

function FishFoodFunctions.isPurchasedThisHour(p)
	local now = DateTime.now()
	local _ = p.ReceivedStamp
	return now.UnixTimestamp - p.ReceivedStamp <= 3600
end

function FishFoodFunctions.getRemainingStocks(p)
	if not p then
		return
	end

	local soldFoods = FishFoodFunctions.collectSoldFoods()
	local result = {}

	for k, soldFood in soldFoods do
		local count = 0

		for _, v in p.FishFoodInventory.Inventory do
			if v.Name == k and FishFoodFunctions.isPurchasedThisHour(v) then
				count += 1
			end
		end

		for _, v in p.FishFoodInventory.Active do
			if v.Name == k and FishFoodFunctions.isPurchasedThisHour(v) then
				count += 1
			end
		end

		table.insert(result, {
			Stock = 2 - count,
			FishFood = soldFood,
			Name = k
		})
	end

	return result
end

return FishFoodFunctions