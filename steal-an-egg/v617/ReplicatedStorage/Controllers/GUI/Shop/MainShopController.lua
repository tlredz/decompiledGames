local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local CashPacks = require(ReplicatedStorage.Data.CashPacks)
local Message = require(ReplicatedStorage.Client.Message)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local GUI = require(ReplicatedStorage.Client.GUI)
local Gamepasses = require(ReplicatedStorage.Data.Gamepasses)
local Gamepasses2 = require(ReplicatedStorage.Client.Gamepasses)
local Gifting = require(ReplicatedStorage.Client.Gifting)
local Marketplace = require(ReplicatedStorage.Shared.Utils.Marketplace)
local price = Marketplace.Price
local Hud = require(ReplicatedStorage.Client.Hud)
local Products = require(ReplicatedStorage.Data.Products)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Save = require(ReplicatedStorage.Shared.Save)
local ShopNavigation = require(ReplicatedStorage.Client.ShopNavigation)
local Storefront = require(ReplicatedStorage.Client.Functions.Storefront)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local TryLock = require(ReplicatedStorage.Shared.Utils.TryLock)
local t = require(ReplicatedStorage.Packages.t)
local v = {
	Owned = "OWNED",
	Pending = "Loading..."
}
return {
	Start = function()
		local localPlayer = Players.LocalPlayer
		local scrollingFrame = GUI.Shop().Frame.ScrollingFrame
		local money = scrollingFrame.Money
		local passes = scrollingFrame.Passes
		local tryLock = TryLock()

		local function mapProductEntry(frame, p2)
			t.strict(t.table)(p2)
			t.strict(t.number)(p2.ProductId)
			local buy = frame.Btns.Buy
			local price2 = buy.Price
			assert(buy and buy:IsA("GuiButton"), "Expected Btns.Buy to be a GuiButton")
			assert(price2 and price2:IsA("TextLabel"), "Expected Buy.Price to be a TextLabel")
			return {
				frame = frame,
				button = buy,
				priceLabel = price2,
				productId = p2.ProductId,
				giftButton = frame.Btns.Gift
			}
		end

		local v3 = {
			mapProductEntry(money.c1, Products.Directory.CashPack1),
			mapProductEntry(money.c2, Products.Directory.CashPack2),
			mapProductEntry(money.c3, Products.Directory.CashPack3),
			mapProductEntry(money.c4, Products.Directory.CashPack4),
			(mapProductEntry(money.c5, Products.Directory.CashPack5))
		}

		local function mapGamepassEntry(guiObject, p)
			local buy = guiObject.Btns.Buy
			local price2 = buy.Price
			assert(guiObject and guiObject:IsA("GuiObject"), "Expected a pass card GuiObject")
			assert(price2 and price2:IsA("TextLabel"), "Expected card.Btns.Buy.Price to be a TextLabel")
			t.strict(t.table)(p)
			t.strict(t.string)(p.Name)
			t.strict(t.number)(p.ProductId)
			return {
				card = guiObject,
				button = buy,
				giftButton = guiObject.Btns.Gift,
				priceLabel = price2,
				gamepassId = p.Name,
				productId = p.ProductId
			}
		end

		local v4 = {
			mapGamepassEntry(passes.Money, Gamepasses.Directory.X2Money),
			(mapGamepassEntry(passes.Growth, Gamepasses.Directory.X2Growth))
		}

		local function ownsProduct(p: number)
			local v5 = Save.Await()
			local products

			if v5 ~= nil then
				products = v5.Products
			end

			return products ~= nil and products[tostring(p)] == true
		end

		local function renderPrice(p, p2: number, p3, callback)
			local v5 = price(p2, p3)
			p.Text = v5 == nil and "Loading..." or callback() and "OWNED" or "" .. tostring(v5)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateGamepassPrice(data)
			local priceLabel = data.priceLabel
			local v5 = price(data.productId, Enum.InfoType.GamePass)
			local pending = v.Pending

			if v5 ~= nil then
				if Gamepasses2.Owns(data.gamepassId) then
					pending = v.Owned
				else
					pending = "" .. tostring(v5)
				end
			end

			priceLabel.Text = pending
		end

		local function updatePrice(data)
			local slot = CashPacks.FindSlot(data.productId)

			if slot then
				local shownAmount = CashPacks.GetShownAmount(localPlayer, slot)
				local title = data.frame:FindFirstChild("Title")

				if title and title:IsA("TextLabel") then
					title.Text = not shownAmount and "Loading..." or "$" .. Simple.FormatCompact(shownAmount, ".#")
				end
			end

			local priceLabel = data.priceLabel
			local v5 = price(data.productId, Enum.InfoType.Product)
			local pending = v.Pending

			if v5 ~= nil then
				local productId2 = data.productId
				local v6 = Save.Await()
				local products

				if v6 ~= nil then
					products = v6.Products
				end

				local v7

				if products == nil then
					v7 = false
				else
					v7 = products[tostring(productId2)] == true
				end

				if v7 then
					pending = v.Owned
				else
					pending = "" .. tostring(v5)
				end
			end

			priceLabel.Text = pending
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function bindBuyButton(button, productId: number, flag: boolean, callback)
			ButtonFX(button, nil, function()
				tryLock(function()
					if callback == nil or not callback() then
						Storefront.Prompt(productId, flag)
					else
						Message.Notice("You already own this item!")
					end
				end)
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateAllProducts()
			for _, v5 in v3 do
				task.spawn(updatePrice, v5)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateAllGamepasses()
			for _, v5 in v4 do
				task.spawn(updateGamepassPrice, v5)
			end
		end

		for _, v5 in v3 do
			Gifting.Bind(v5.giftButton, "Product", v5.productId)
			local v6 = v5
			task.spawn(function()
				updatePrice(v6)

				local function fn()
					local productId2 = v6.productId
					local v7 = Save.Await()
					local products

					if v7 ~= nil then
						products = v7.Products
					end

					return products ~= nil and products[tostring(productId2)] == true
				end

				bindBuyButton(v6.button, v6.productId, true, fn) -- equivalent call inferred; original call site unknown
			end)
		end

		for _, v5 in v4 do
			Gifting.Bind(v5.giftButton, "Gamepass", v5.productId)
			local v6 = v5
			task.spawn(function()
				updateGamepassPrice(v6) -- equivalent call inferred; original call site unknown
				bindBuyButton(v6.button, v6.productId, false, nil) -- equivalent call inferred; original call site unknown
			end)
		end

		for _, v5 in Hud.Every("ShopButton") do
			ButtonFX(v5, 1.08, function()
				if Tabs.IsActive("Shop") then
					Tabs.Deactivate()
				else
					ShopNavigation.Open("Featured")
				end
			end)
		end

		Tabs.Activated:Connect(function(p: string)
			if p == "Shop" then
				updateAllProducts() -- equivalent call inferred; original call site unknown
				updateAllGamepasses() -- equivalent call inferred; original call site unknown
			end
		end)

		if Save.IsLoaded() then
			task.spawn(function()
				updateAllProducts() -- equivalent call inferred; original call site unknown
				updateAllGamepasses() -- equivalent call inferred; original call site unknown
			end)
		end

		Save.Loaded:Connect(function(p)
			if p ~= localPlayer then
				return
			end

			updateAllProducts() -- equivalent call inferred; original call site unknown
		end)
		localPlayer:GetAttributeChangedSignal(CashPacks.RevisionAttribute):Connect(updateAllProducts)
		Save.WatchFields("Products", updateAllProducts)
		Save.WatchFields("Gamepasses", updateAllGamepasses)
		Remotes.PassGrants.Awarded.OnClientEvent:Connect(updateAllGamepasses)
	end
}