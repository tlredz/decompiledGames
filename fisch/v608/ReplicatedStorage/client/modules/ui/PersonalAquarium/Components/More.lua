local ReplicatedStorage = game:GetService("ReplicatedStorage")
local legacy = ReplicatedStorage.client.legacy
local legacyUiLoader = require(legacy.legacyUiLoader)
require("../Types")
local packages = ReplicatedStorage.packages
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local utils = ReplicatedStorage.shared.utils
local NumberUtils = require(utils.NumberUtils)
local TimeUtils = require(utils.TimeUtils)
local modules = ReplicatedStorage.shared.modules
local library = require(modules.library)
local sharedPersonalAquarium = modules.SharedPersonalAquarium
require(sharedPersonalAquarium.SharedTypes)
local sharedData = sharedPersonalAquarium.SharedData
local FishFoodData = require(sharedData.FishFoodData)
local RewardData = require(sharedData.RewardData)
local sharedFunctions = sharedPersonalAquarium.SharedFunctions
local FishFoodFunctions = require(sharedFunctions.FishFoodFunctions)
local remoteEvent = Net:RemoteEvent("PersonalAquarium/ClaimRewards")
local remoteEvent2 = Net:RemoteEvent("PersonalAquarium/ActivateFishFood")
local remoteEvent3 = Net:RemoteEvent("PersonalAquarium/PurchaseFishFood")
local personalAquarium = legacyUiLoader.PlayerGui.hud.safezone.PersonalAquarium
local fishFood = personalAquarium.More.FishFood
local profit = personalAquarium.More.Profit
local More = {}

function More.Start(_, dependencies)
	More.Dependencies = dependencies
	More.Trove = Trove.new()
	More.FishFoodTemplate = dependencies.Instance.FishFood.FoodList.ScrollingFrame.Food:Clone()
	More.RewardItemTemplate = dependencies.Instance.Profit.ItemList.ScrollingFrame.Item:Clone()
	dependencies.Instance.Profit.ItemList.ScrollingFrame.Item:Destroy()
	dependencies.Instance.FishFood.FoodList.ScrollingFrame.Food:Destroy()
	dependencies.Shared.HandleButtonFn(dependencies.Instance.Profit.Header.Claim, function()
		remoteEvent:FireServer()
	end, false)
	dependencies.Shared.PersonalAquariumController.ProfileCacheChangedSignal:Connect(function(_)
		More.Closed()
		More.Opened()
	end)
end

function More.Opened()
	More._ReloadPage(More.Dependencies.Instance.FishFood.FoodList, More._ReloadFishFoodUniqueness)
	More._ReloadPage(More.Dependencies.Instance.Profit.ItemList, More._ReloadProfitUniqueness)
end

function More.Closed()
	More.Trove:Clean()
end

function More._ReloadPage(_, callback)
	callback()
end

function More._ReloadProfitUniqueness()
	local profit2 = More.Dependencies.Instance.Profit
	local cache = More.Dependencies.Shared.PersonalAquariumController.Cache

	if not cache then
		return
	end

	local _ = cache.LastRewardStamp
	local v = workspace:GetServerTimeNow() - cache.LastRewardStamp
	local v2 = RewardData.RewardInterval - v
	More.Trove:Add(task.spawn(function()
		while true do
			profit2.Header.Info.Text = `Next: {TimeUtils:B(v2)}`
			local v3 = task.wait(1)
			v2 -= v3
		end
	end))
	local accumulatedRewards = cache.AccumulatedRewards
	local softCurrency = accumulatedRewards.SoftCurrency
	local experience = accumulatedRewards.Experience
	local rewardItems = accumulatedRewards.RewardItems
	local profit3 = More.Dependencies.Instance.Profit
	local _ = profit3.Header.Claim
	local earnings = profit3.Unclaimed.Earnings
	local string = NumberUtils:ToString(softCurrency)
	local string2 = NumberUtils:ToString(experience)
	earnings["C$"].Text = `{string} C$`
	earnings.XP.Text = `{string2} XP`
	local scrollingFrame = profit.ItemList.ScrollingFrame

	for _, rewardItem in rewardItems do
		local v3 = More.Trove:Add(More.RewardItemTemplate:Clone())
		More._BuildRewardItemFrame(v3, rewardItem)
		v3.Parent = scrollingFrame
	end
end

function More._ReloadFishFoodUniqueness()
	local _ = More.Dependencies.Instance.FishFood
	local cache = More.Dependencies.Shared.PersonalAquariumController.Cache

	if not cache then
		return
	end

	local ownedFishFoodCounts = FishFoodFunctions.getOwnedFishFoodCounts(cache)
	local remainingStocks = FishFoodFunctions.getRemainingStocks(cache)
	local _ = cache.FishFoodInventory.Inventory

	if not ownedFishFoodCounts then
		warn("Failed to grab owned fish food info locally")
		return
	end

	if not remainingStocks then
		warn("Failed to grab remaining fish food stock locally")
		return
	end

	local handleButtonFn = More.Dependencies.Shared.HandleButtonFn
	local v = {}

	for k in FishFoodData do
		table.insert(v, k)
	end

	table.sort(v)

	for _, v2 in v do
		if ownedFishFoodCounts[v2] == 0 then
			continue
		end

		local v3 = FishFoodData[v2]
		local v4 = More.Trove:Add(More.FishFoodTemplate:Clone())
		v4.Amount.Text = `x{ownedFishFoodCounts[v2]}`
		More._BuildFishFoodFrame(v4, v3, "Owned")
		v4.Buy.Label.Text = "Use"
		local v5 = v2
		handleButtonFn(v4.Buy, function()
			remoteEvent2:FireServer(v5)
		end)
		v4.Parent = fishFood.FoodList.ScrollingFrame
	end

	for _, remainingStock in remainingStocks do
		local name = remainingStock.Name
		local stock = remainingStock.Stock
		local v2 = More.Trove:Add(More.FishFoodTemplate:Clone())
		More._BuildFishFoodFrame(v2, remainingStock.FishFood, "Buying")
		v2.Amount.Text = stock == 0 and "SOLD OUT" or `×{stock}`
		v2.Buy.Label.Text = stock == 0 and "SOLD OUT" or "Buy" .. ": " .. (FishFoodData[name].PurchaseCost or "err") .. "C$"

		if stock ~= 0 then
			local name2 = name
			handleButtonFn(v2.Buy, function()
				remoteEvent3:FireServer(name2)
			end)
		end

		v2.Parent = fishFood.FoodList.ScrollingFrame
	end
end

function More._BuildFishFoodFrame(data, data2, p)
	local multipliers = data2.Multipliers
	local experienceMultiplier = multipliers.ExperienceMultiplier
	local rewardItemsMultiplier = multipliers.RewardItemsMultiplier
	local softCurrencyMultiplier = multipliers.SoftCurrencyMultiplier
	data.FoodName.Text = data2.DisplayName
	data.Icon.Image = data2.Icon or "rbxassetid://95325449128822"
	data.Earnings["C$"].Text = `{softCurrencyMultiplier} C$/Hr. `
	data.Earnings.XP.Text = `{experienceMultiplier} XP/Hr. `
	data.Earnings.Items.Label.Text = `{rewardItemsMultiplier} Items/Hr.`
	local corner = data.Buy.corner
	local imageColor

	if p == "Buying" then
		imageColor = Color3.new(0, 1, 0.498039)
	else
		imageColor = Color3.new(1, 1, 0.498039)
	end

	corner.ImageColor3 = imageColor
	local uIStroke = data.Buy.UIStroke
	local color

	if p == "Buying" then
		color = Color3.new(0, 1, 0.498039)
	else
		color = Color3.new(1, 1, 0.498039)
	end

	uIStroke.Color = color
end

function More._BuildRewardItemFrame(p, p2)
	local itemName = p2.ItemName
	local count = p2.Count
	p.ItemName.Text = NumberUtils:ToString(count) .. "× " .. itemName
	p.Icon.Image = library.fish[itemName] and library.fish[itemName].Icon or library.items[itemName] and library.items[itemName].Icon or library.bait[itemName] and library.bait[itemName].Icon or ""
end

return More