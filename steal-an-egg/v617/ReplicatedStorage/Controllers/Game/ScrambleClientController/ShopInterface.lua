local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GUI = require(ReplicatedStorage.Client.GUI)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Numbers = require(ReplicatedStorage.Shared.Utils.Numbers)
local addCommas = Numbers.AddCommas
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)

-- equivalent calls inferred from this helper; original call sites unknown
local function toast(text: string)
	Toast.Show({
		Text = text,
		Seconds = 3,
		SingleLine = true,
		Unique = true
	})
end

return {
	new = function(callback)
		local v = {}
		local maid = Trove.new()
		local maid2 = Trove.new()
		maid:Add(maid2)
		local drScrambleEvent = GUI.Get("DrScrambleEvent")
		local dRScrambleEventUIMain = drScrambleEvent.DRScrambleEventUIMain
		local scrollingFrame = dRScrambleEventUIMain.ContentFrame.ScrollingFrame
		local shopItem = scrollingFrame:WaitForChild("ShopItem")
		local shopItem_Rare = scrollingFrame:WaitForChild("ShopItem_Rare")
		local shopItemLeavesTimer = scrollingFrame:WaitForChild("ShopItemLeavesTimer")
		local currencyHolder = dRScrambleEventUIMain.CurrencyHolder
		local buyMore = currencyHolder:FindFirstChild("BuyMore")

		if buyMore then
			buyMore:Destroy()
		end

		local v2 = nil
		local v3 = false
		local fn
		local v4 = true
		local v5 = {}
		local v6 = ""
		local v7 = false

		for _, guiObject in scrollingFrame:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject.Visible = false
			end
		end

		drScrambleEvent:SetAttribute("ImmediateClose", true)
		drScrambleEvent.Enabled = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function available()
			return v2 ~= nil and v2.Ready == true and v2.Enabled == true and v2.WorldReady == true and workspace:GetServerTimeNow() < (v2.EventEndsAt or 0)
		end

		local function purchased(p)
			if not v2 or workspace:GetServerTimeNow() >= (v2.ShopRestockAt or 0) then
				return 0
			end

			local v8 = v2.State and (v2.State.ShopPurchases or {})[p.Id]

			if v8 and v8.Period == v2.ShopPeriod then
				return v8.Count
			end

			return 0
		end

		local function send(p: string, id, p2)
			if not v3 then
				local v8

				if v2 == nil or v2.Ready ~= true or v2.Enabled ~= true or v2.WorldReady ~= true then
					v8 = false
				else
					v8 = workspace:GetServerTimeNow() < (v2.EventEndsAt or 0)
				end

				if v8 then
					v3 = true
					fn()
					local success, result = pcall(callback, p, id, p2)
					v3 = false

					if not v4 then
						return
					end

					fn()

					if success and result then
						if not result.Ok and (result.Reason == "Busy" or result.Reason == "ProfileUnavailable") then
							toast("Please wait a moment and try again.") -- equivalent call inferred; original call site unknown
						end
					else
						toast("Could not confirm the request. Reopen the shop to refresh.") -- equivalent call inferred; original call site unknown
					end
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function clearCards()
			maid2:Clean()
			table.clear(v5)
		end

		local function fn2()
			local shop = v2.Shop or {}
			local v8 = { "Shop" }

			for _, v9 in shop do
				table.insert(v8, v9.Quote .. ":" .. tostring(v9.LeavesAtEventEnd))
			end

			local joined = table.concat(v8, "\n")

			if joined == v6 then
				return
			end

			v6 = joined
			clearCards() -- equivalent call inferred; original call site unknown

			for k, offer in shop do
				local v10

				if offer.Rare then
					v10 = shopItem_Rare
				elseif offer.LeavesAtEventEnd then
					v10 = shopItemLeavesTimer
				else
					v10 = shopItem
				end

				local clone = v10:Clone()
				clone.Name = "Offer_" .. offer.Id
				clone.LayoutOrder = k
				local card = clone.Card
				local imageButton = Instance.new("ImageButton")

				for _, v11 in {
					"Name",
					"AnchorPoint",
					"Position",
					"Size",
					"Rotation",
					"BackgroundColor3",
					"BackgroundTransparency",
					"BorderColor3",
					"BorderSizePixel",
					"BorderMode",
					"ClipsDescendants",
					"LayoutOrder",
					"ZIndex",
					"Visible",
					"SizeConstraint",
					"AutomaticSize"
				} do
					imageButton[v11] = card[v11]
				end

				imageButton.ImageTransparency = 1
				imageButton.AutoButtonColor = false
				imageButton.Selectable = false

				for _, child in card:GetChildren() do
					child.Parent = imageButton
				end

				card:Destroy()
				imageButton.Parent = clone
				imageButton.EggName.Text = offer.Label
				imageButton.EggName.RichText = false
				local itemIcon = imageButton:FindFirstChild("ItemIcon") or imageButton:FindFirstChild("OutputEgg")
				assert(itemIcon and itemIcon:IsA("ImageLabel"), "Scramble shop card requires ItemIcon or OutputEgg")
				itemIcon.Image = offer.Icon
				imageButton.Quantity.QuantityLabel.Text = offer.QuantityText or "x" .. addCommas(offer.Quantity)
				imageButton.Buy.PriceHolder.Icon.Visible = true
				imageButton.Buy.PriceHolder.Icon:RemoveTag("ICON")
				imageButton.Buy.PriceHolder.Icon:SetAttribute("IconId", nil)
				imageButton.Buy.PriceHolder.Icon.Image = currencyHolder.CurrencyIcon.Image
				imageButton.SoldOut.Visible = false
				imageButton.Buy.Visible = true
				clone.Visible = true
				clone.Parent = scrollingFrame
				maid2:Add(clone)
				local leaveTimer = clone:FindFirstChild("LeaveTimer", true)

				if offer.LeavesAtEventEnd then
					assert(leaveTimer and leaveTimer:IsA("TextLabel"), "Limited Scramble shop card requires LeaveTimer")
				end

				if not (leaveTimer and leaveTimer:IsA("TextLabel")) then
					leaveTimer = nil
				end

				table.insert(v5, {
					Offer = offer,
					Card = imageButton,
					LeaveTimer = leaveTimer
				})
				maid2:Add(ButtonFX(imageButton, 1.04, nil, true))
				local v14 = offer
				maid2:Add(ButtonFX(imageButton.Buy, nil, function()
					if imageButton.Buy.Interactable and not v3 then
						local v15

						if v2 == nil or v2.Ready ~= true or v2.Enabled ~= true or v2.WorldReady ~= true then
							v15 = false
						else
							v15 = workspace:GetServerTimeNow() < (v2.EventEndsAt or 0)
						end

						if v15 then
							if v14.PurchaseLimit and purchased(v14) + v14.Quantity > v14.PurchaseLimit then
								toast("Sold out for today. Check the restock timer!") -- equivalent call inferred; original call site unknown
							elseif v2.State and not (v2.State.Samples < v14.Price) then
								send("Shop", v14.Id, {
									Quote = v14.Quote,
									Sequence = v2.State.ShopSequence
								})
							else
								toast("Not enough Samples. Defeat Dr. Scramble to earn more.") -- equivalent call inferred; original call site unknown
							end
						end
					end
				end))
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function resize()
			local currentCamera = workspace.CurrentCamera

			if not currentCamera then
				return
			end

			local viewportSize = currentCamera.ViewportSize
			local aspectRatio = dRScrambleEventUIMain.UIAspectRatioConstraint.AspectRatio
			local v8 = math.min(viewportSize.X * 0.6, viewportSize.Y * 0.74 * aspectRatio)
			dRScrambleEventUIMain.UISizeConstraint.MinSize = Vector2.zero
			dRScrambleEventUIMain.Size = UDim2.fromOffset(v8, v8 / aspectRatio)
		end

		fn = function()
			if not v4 then
				return
			end

			if v2 and v2.State then
				currencyHolder.QuantityLabel.Text = addCommas(v2.State.Samples)
			else
				currencyHolder.QuantityLabel.Text = "0"
			end

			local v8 = math.max(0, (math.floor((not v2 and 0 or v2.EventEndsAt or 0) - workspace:GetServerTimeNow()))) // 3600
			local text = string.format("LEAVES IN: %dD %dHR", v8 // 24, v8 % 24)

			if not (v7 and v2) then
				return
			end

			fn2()

			for _, v10 in v5 do
				local offer = v10.Offer
				local card = v10.Card

				if v10.LeaveTimer then
					v10.LeaveTimer.Text = text
				end

				local v11 = purchased(offer)
				local visible

				if offer.PurchaseLimit == nil then
					visible = false
				else
					visible = v11 + offer.Quantity > offer.PurchaseLimit
				end

				card.SoldOut.Visible = visible
				card.Buy.Visible = not visible

				if offer.PurchaseLimit then
					card.Quantity.QuantityLabel.Text = tostring((math.max(0, offer.PurchaseLimit - v11))) .. "/" .. offer.PurchaseLimit .. " LEFT"
				end

				local stocksInLabel = card:FindFirstChild("StocksInLabel")

				if stocksInLabel and stocksInLabel:IsA("TextLabel") then
					stocksInLabel.Visible = offer.PurchaseLimit ~= nil and v11 > 0

					if stocksInLabel.Visible then
						local v14 = math.max(
							1,
							(math.ceil(((v2.ShopRestockAt or 0) - workspace:GetServerTimeNow()) / 60))
						)
						stocksInLabel.Text = string.format("Stocks In:\n%dhr %dm", v14 // 60, v14 % 60)
					end
				end

				local v14 = available() and not v3

				if v14 then
					if v2.State == nil then
						v14 = false
					else
						v14 = not visible
					end
				end

				local v15 = v14 and v2.State.Samples >= offer.Price
				card.Buy.PriceHolder.Price.Text = addCommas(offer.Price)
				card.Active = v14
				card.Interactable = v14
				local buy = card.Buy
				local buy2 = card.Buy
				local buy3 = card.Buy
				buy.Active = v14
				buy2.Interactable = v14
				buy3.Selectable = v14
				local buy4 = card.Buy
				local imageColor

				if v15 then
					imageColor = Color3.new(1, 1, 1)
				else
					imageColor = Color3.fromRGB(140, 140, 140)
				end

				buy4.ImageColor3 = imageColor
				local price = card.Buy.PriceHolder.Price
				local textColor

				if v15 then
					textColor = Color3.new(1, 1, 1)
				else
					textColor = Color3.fromRGB(255, 64, 64)
				end

				price.TextColor3 = textColor
			end
		end

		maid:Add(drScrambleEvent:GetAttributeChangedSignal("Open"):Connect(function()
			if drScrambleEvent:GetAttribute("Open") == false and Tabs.IsActive("DrScrambleEvent") then
				Tabs.Deactivate()
			end
		end))
		maid:Add(Tabs.Activated:Connect(function(p)
			if p == "DrScrambleEvent" then
				resize() -- equivalent call inferred; original call site unknown
				fn()
			end
		end))

		if scrollingFrame:IsA("ScrollingFrame") then
			local uIGridLayout = scrollingFrame.UIGridLayout

			-- equivalent calls inferred from this helper; original call sites unknown
			local function canvas()
				scrollingFrame.CanvasSize = UDim2.fromOffset(0, uIGridLayout.AbsoluteContentSize.Y)
			end

			maid:Add(uIGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(canvas))
			canvas() -- equivalent call inferred; original call site unknown
		end

		if workspace.CurrentCamera then
			maid:Add(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize))
		end

		resize() -- equivalent call inferred; original call site unknown

		function v.Update(p)
			v2 = p
			local v8

			if v2 == nil or v2.Ready ~= true or v2.Enabled ~= true or v2.WorldReady ~= true then
				v8 = false
			else
				v8 = workspace:GetServerTimeNow() < (v2.EventEndsAt or 0)
			end

			if not v8 then
				v.Close()
			end

			fn()
		end

		function v.Show()
			local v8

			if v2 == nil or v2.Ready ~= true or v2.Enabled ~= true or v2.WorldReady ~= true then
				v8 = false
			else
				v8 = workspace:GetServerTimeNow() < (v2.EventEndsAt or 0)
			end

			if not v8 then
				return
			end

			v7 = true
			fn()

			if #v5 == 0 then
				toast("The Sample shop has no available offers yet.") -- equivalent call inferred; original call site unknown
				return
			end

			if scrollingFrame:IsA("ScrollingFrame") then
				scrollingFrame.CanvasPosition = Vector2.zero
			end

			Tabs.Activate("DrScrambleEvent")
		end

		function v.Close()
			if Tabs.IsActive("DrScrambleEvent") then
				Tabs.Deactivate()
			end
		end

		local v8 = -1

		function v.Tick(p: number)
			if Tabs.IsActive("DrScrambleEvent") then
				local v9

				if v2 == nil or v2.Ready ~= true or v2.Enabled ~= true or v2.WorldReady ~= true then
					v9 = false
				else
					v9 = workspace:GetServerTimeNow() < (v2.EventEndsAt or 0)
				end

				if not v9 then
					v.Close()
				elseif math.floor(p) ~= v8 then
					v8 = math.floor(p)
					fn()
				end
			end
		end

		function v.Destroy()
			v4 = false
			maid:Destroy()
		end

		return v
	end
}