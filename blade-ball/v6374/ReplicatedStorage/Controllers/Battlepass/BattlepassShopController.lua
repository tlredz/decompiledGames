local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Common.Utils)
local v3 = require3(ReplicatedStorage2.Packages.Net)
local v4 = require3(ReplicatedStorage2.Packages.Trove)
local v5 = require3(ReplicatedStorage2.Shared.Battlepass.BattlepassShopData)
require3(ReplicatedStorage2.Common.RewardInfo)
local v6 = require3(script.Parent.BattlepassViewController)
local v7 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v8 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v9 = require3(ReplicatedStorage2.Controllers.Trading.IndexController)
local v10 = require3(ReplicatedStorage2.Shared.BattlepassUIType)
local v11 = require3(ReplicatedStorage2.ServerInfo)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v12 = require3("@game/ReplicatedStorage/Shared/InfiniteBattlepass/InfiniteBattlepassData")
local season = v12.Season
local playerGui = Players.LocalPlayer.PlayerGui
local battlepass = playerGui:WaitForChild("Battlepass")
local battlepassMerchant

if v10 == "Window" then
	battlepassMerchant = playerGui:WaitForChild("BattlepassMerchant")
else
	battlepassMerchant = nil
end

local main

if v10 == "Window" then
	main = battlepassMerchant.Main
else
	main = battlepass.Main.Background.Views.Merchant
end

local battlepassCurrencyShop = playerGui:WaitForChild("BattlepassCurrencyShop")
local battlepassPlaytimeRewards = playerGui:WaitForChild("BattlepassPlaytimeRewards")
local preview = main.Content.Preview
local buy = preview.Buy
local soldOut = preview.SoldOut
local slots = main.Content.Items.Slots
local limitedSlot = main.Content.Items.LimitedSlot
local button = limitedSlot.Button
local v13 = (v11.isDevPlaceGame() or v11.isTestGame()) and 300 or 86400
buy.Info.Icon.Image = v12.SeasonData.Currency.Icon
local v14 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function UTC()
	return DateTime.now().UnixTimestamp
end

local BattlepassShopController = {
	_previewTrove = v4.new(),
	_selectedSlot = nil
}

local function _ownsItem(reward)
	local v15 = false

	if reward.Type == "Emote" then
		local v16 = v14:Get("Emotes.Unlocked")
		return v16 and v16[reward.Value] == true
	end

	if reward.Type == "Sword" or reward.Type == "Ability" or reward.Type == "Explosion" then
		return #client:FindItems(reward.Type, reward.Value) > 0
	end

	return v15
end

local function getCurrentDayItem()
	local v15 = math.floor(UTC() / v13)
	local limitedStockSlot = v5.LimitedStockSlot
	return limitedStockSlot[v15 % #limitedStockSlot + 1], v15
end

function BattlepassShopController:SelectSlot(selectedSlot)
	local itemID = nil
	local v15 = nil
	local purchased = false

	if selectedSlot == "Limited" then
		local v16 = math.floor(UTC() / v13)
		local limitedStockSlot = v5.LimitedStockSlot
		v15 = limitedStockSlot[v16 % #limitedStockSlot + 1]
		itemID = v15.ItemID
		local formatted = `{v15.ItemID}_{season}_{v16}`
		purchased = v14:Get((`BattlepassShop.LimitedSlot.{formatted}`))
	elseif typeof(selectedSlot) == "number" then
		itemID = slots:WaitForChild(selectedSlot):GetAttribute("ItemID")

		if not itemID then
			return
		end

		v15 = v5.Slots[selectedSlot][itemID]
		local v16 = v14:Get("BattlepassShop.Items")

		if v16 then
			purchased = v16[selectedSlot] and v16[selectedSlot].Purchased
		end
	end

	if not v15 then
		warn((`Failed to find ItemData for Battlepass Shop item {itemID}`))
		return
	end

	preview.Icon.Image = v15.Reward.Icon or ""
	preview.Item.ItemName.Text = v15.Reward.DisplayName
	buy.Info.Amount.Text = v2.ValueConvertor:AddCommas(v15.Cost)
	local v16 = _ownsItem(v15.Reward)
	buy.Visible = not (purchased or v16)
	soldOut.Label.Text = purchased and "Sold Out!" or "Already Owned!"
	soldOut.Visible = not buy.Visible

	if self._selectedSlot ~= selectedSlot then
		preview.Inspect.Visible = v9:CanPreview(v15.Reward)
		self._selectedSlot = selectedSlot
		self._previewTrove:Clean()
		self._previewTrove:Add(buy.Activated:Connect(function()
			buy.Active = false
			local v17, v18 = v3:Invoke("BuyBattlepassShopItem", selectedSlot, itemID)

			if v17 then
				ReplicatedStorage2.Misc.BattlepassReward:Play()
			else
				ReplicatedStorage2.Misc.error:Play()
			end

			if v18 and _G.SendNotification then
				_G.SendNotification(v18, nil, true)
			end

			task.wait(0.25)
			buy.Active = true
		end))
	end
end

function BattlepassShopController:_createItemButtons()
	for _, button2 in main.Content.Items.Slots:GetChildren() do
		if not button2:IsA("GuiButton") then
			continue
		end

		local name = tonumber(button2.Name)

		if name then
			local v15 = name
			button2.Activated:Connect(function()
				self:SelectSlot(v15)
			end)
		else
			button2:Destroy()
		end
	end

	button.Activated:Connect(function()
		self:SelectSlot("Limited")
	end)
end

local maid = v4.new()

local function updateLimitedStock(formatted, p)
	maid:Clean()
	local v15 = v.Client:WaitReplion("LimitedStockItems")

	if not v15 then
		return
	end

	limitedSlot.Visible = true
	local v16 = v15:Get({ "Stock", formatted }) or 0
	local v17 = v15:Get({ "InitialStock", formatted }) or 100
	button.Stock.Text = `STOCK: {v16}/{v17}`

	local function updateOwnerPurchased()
		v16 = v15:Get({ "Stock", formatted }) or 0
		local v18 = _ownsItem(p.Reward)
		local v19 = v14:Get((`BattlepassShop.LimitedSlot.{formatted}`))
		button.Locked.Visible = v19 or v18 or v16 <= 0
		button.Locked.Label.Text = v16 <= 0 and "Out of Stock!" or v19 and "Purchased!" or "Owned!"
	end

	maid:Add(v15:OnChange({ "Stock", formatted }, function(p2: number?)
		v17 = v15:Get({ "InitialStock", formatted }) or 100
		button.Stock.Text = `STOCK: {p2}/{v17}`
		updateOwnerPurchased()
	end), "Disconnect")
	task.defer(updateOwnerPurchased)
	maid:Add(v14:OnChange(`BattlepassShop.LimitedSlot.{formatted}`, function()
		updateOwnerPurchased()
	end), "Disconnect")
end

function BattlepassShopController:_updateLimitedSlot()
	limitedSlot.Visible = false
	v8:Remove(button)
	local v15 = math.floor(UTC() / v13)
	local limitedStockSlot = v5.LimitedStockSlot
	local v16 = limitedStockSlot[v15 % #limitedStockSlot + 1]

	if not v16 then
		return false
	end

	updateLimitedStock(`{v16.ItemID}_{season}_{v15}`, v16)
	button.ItemName.Text = v16.Reward.DisplayName
	button.Icon.Image = v16.Reward.Icon or ""
	button.Info.Amount.Text = v2.ValueConvertor:AddCommas(v16.Cost)

	if v8:CanShowRewardInfo(v16.Reward) then
		v8:AddFromRewardInfo(button, v16.Reward)
	end

	if self._selectedSlot == "Limited" then
		self:SelectSlot("Limited")
	end
end

function BattlepassShopController:_updateItems()
	local slots2 = main.Content.Items.Slots
	local battlepassShop = v14:Get("BattlepassShop")

	if not (battlepassShop and battlepassShop.Items) then
		return
	end

	for childName, item in battlepassShop.Items do
		local child = slots2:WaitForChild(childName)
		local v15 = v5.Slots[childName][item.ItemID]

		if v15 then
			local locked = child:FindFirstChild("Locked")
			local v16 = _ownsItem(v15.Reward)
			locked.Visible = item.Purchased or v16
			local label = locked:FindFirstChild("Label")
			label.Text = item.Purchased and "Sold Out!" or "Owned!"
			local icon = child:FindFirstChild("Icon")
			icon.Image = v15.Reward.Icon or ""
			local itemName = child:FindFirstChild("ItemName")
			itemName.Text = v15.Reward.DisplayName
			local amount = child:FindFirstChild("Info"):FindFirstChild("Amount")
			amount.Text = v2.ValueConvertor:AddCommas(v15.Cost)
			child:SetAttribute("ItemID", item.ItemID)

			if v8:CanShowRewardInfo(v15.Reward) then
				v8:AddFromRewardInfo(child, v15.Reward)
			else
				v8:Remove(child)
			end
		else
			child:Destroy()
			warn((`Failed to find ItemData for Battlepass Shop item {item.ItemID}`))
		end
	end

	if self._selectedSlot then
		self:SelectSlot(self._selectedSlot)
	end
end

function BattlepassShopController:_updateTimer()
	if self._refreshing then
		return
	end

	local restock = main.Restock
	local v15 = v14:Get("BattlepassShop.LastRefresh") or 0
	local v16 = workspace:GetServerTimeNow() - v15
	local v17 = math.max(0, v12.ShopRefreshTime - v16)

	if v17 ~= 0 then
		restock.Text = `Restocks in: {v2.ValueConvertor:FormatTime(v17)}`
		return
	end

	restock.Text = "Restocking now..."
	self._refreshing = true
	v3:Invoke("RequestBattlepassShopRefresh")
	self._refreshing = false
end

function BattlepassShopController:_updateLimitedSlotTimer()
	if not limitedSlot.Visible then
		return
	end

	local v16 = v13 - UTC() % v13
	button.Timer.Text = `Resets in: {v2.ValueConvertor:FormatTime(v16)}`
end

function BattlepassShopController:Start()
	v6:CreateView("Merchant", battlepassMerchant or main)
	v14 = v.Client:WaitReplion("Data")
	self:_createItemButtons()

	if battlepassMerchant then
		local counter = battlepassMerchant:FindFirstChild("Counter", true)

		if counter and counter:FindFirstChild("Amount") then
			if counter:FindFirstChild("Add") then
				counter.Add.Activated:Connect(function()
					if v10 == "ShowRoom" then
						battlepassCurrencyShop.Enabled = true
					else
						v7:Open(battlepassCurrencyShop.Name, nil, true)
					end
				end)
			end

			local function updateCurrency()
				local v15 = v14:Get("InfiniteBattlepass.Currency") or 0
				counter.Amount.Text = v2.ValueConvertor:AddCommas(v15)
				counter.Icon.Image = v12.SeasonData.Currency.Icon
			end

			v14:OnChange("InfiniteBattlepass.Currency", updateCurrency)
			task.spawn(updateCurrency)
		end

		local close = battlepassMerchant.Main:FindFirstChild("Close")

		if close then
			close.Activated:Connect(function()
				v6:CloseView("Merchant")
			end)
		end
	end

	preview.Inspect.Activated:Connect(function()
		if not self._selectedSlot then
			return
		end

		local itemID = nil
		local v15 = nil

		if self._selectedSlot == "Limited" then
			local v16 = math.floor(UTC() / v13)
			local limitedStockSlot = v5.LimitedStockSlot
			v15 = limitedStockSlot[v16 % #limitedStockSlot + 1]
			itemID = "Limited"
		elseif typeof(self._selectedSlot) == "number" then
			local child = slots:WaitForChild(self._selectedSlot)
			itemID = child and child:GetAttribute("ItemID")

			if not itemID then
				return
			end

			v15 = v5.Slots[self._selectedSlot][itemID]
		end

		if not v15 then
			warn((`Failed to find ItemData for Battlepass Shop item {itemID}`))
			return
		end

		if not v9:CanPreview(v15.Reward) then
			return
		end

		v6:Close()
		v9:PreviewReward(v15.Reward, nil, function()
			v6:OpenView(main.Name)
			v6:Open()
		end)
	end)
	self:_updateItems()
	v14:OnChange("BattlepassShop", function()
		self:_updateItems()
	end)
	self:SelectSlot(1)
	local lastTime = os.clock()
	local v15 = false
	v3:Connect("BattlepassShopRefreshed", function()
		if _G.SendNotification and os.clock() - lastTime > 30 and not v15 then
			_G.SendNotification("Battlepass Shop has restocked!")
			v15 = true
		end

		self._refreshing = false
		self:_updateTimer()
		self:_updateLimitedSlotTimer()
		self:_updateItems()
	end)
	v2.Thread.Every(1, function()
		self:_updateTimer()
		self:_updateLimitedSlotTimer()
	end)
	main.FreeGifts.Activated:Connect(function()
		battlepassPlaytimeRewards.Enabled = true
	end)
	local v16 = 0

	while true do
		local v17 = math.floor(UTC() / v13)

		if v16 ~= v17 then
			self:_updateLimitedSlot()
			v16 = v17
		end

		local v18 = math.floor(UTC() / v13)
		local limitedStockSlot = v5.LimitedStockSlot
		local v19 = limitedStockSlot[v18 % #limitedStockSlot + 1]

		if v19 then
			updateLimitedStock(`{v19.ItemID}_{season}_{v18}`, v19)
		end

		task.wait(2)
	end
end

return BattlepassShopController