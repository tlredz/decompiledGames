local Floor0ShopClient = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

-- equivalent calls inferred from this helper; original call sites unknown
local function isGamepadPreferred()
	return UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
end

local Floor0Shop = require(ReplicatedStorage.Modules.Floor0.Floor0Shop)
local tweens = require(ReplicatedStorage.Modules.Utils.tweens)
local InputService = require(ReplicatedStorage.SharedUtils.InputService)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local floor0ShopFunction = nil
local readyUpEvent = nil
local flag = false
local v = {}
local v2 = nil
local v3 = {}
local fn

-- equivalent calls inferred from this helper; original call sites unknown
local function setupKeyBindings(items, p, p2, p3)
	local v4 = InputService:OnAction("ShopPurchase", function()
		if InputService:IsTyping() or not v2.SelectionFrame.Visible then
			return
		end

		for k, item in pairs(items) do
			if v[k] then
				continue
			end

			fn(k, item.data, p, p2)
			break
		end
	end)
	v3[p3] = v4
end

local function createShopItemFrame(k, data, frame)
	local frame2 = Instance.new("Frame")
	frame2.Name = k .. "Frame"
	frame2.Size = UDim2.new(0.3, -10, 0.8, 0)
	frame2.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	frame2.BorderColor3 = Color3.fromRGB(255, 255, 255)
	frame2.BorderSizePixel = 2
	frame2.Parent = frame
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "ItemImage"
	imageLabel.Size = UDim2.new(0.6, 0, 0.4, 0)
	imageLabel.Position = UDim2.new(0.2, 0, 0.05, 0)
	imageLabel.Image = data.icon
	imageLabel.BackgroundTransparency = 1
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.Parent = frame2
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "ItemLabel"
	textLabel.Size = UDim2.new(0.9, 0, 0.15, 0)
	textLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
	textLabel.Text = data.name
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextSize = 18
	textLabel.Font = Enum.Font.GothamBold
	textLabel.BackgroundTransparency = 1
	textLabel.TextScaled = true
	textLabel.Parent = frame2
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "DescLabel"
	textLabel2.Size = UDim2.new(0.9, 0, 0.2, 0)
	textLabel2.Position = UDim2.new(0.05, 0, 0.65, 0)
	textLabel2.Text = data.description
	textLabel2.TextColor3 = Color3.fromRGB(200, 200, 200)
	textLabel2.TextSize = 12
	textLabel2.Font = Enum.Font.Gotham
	textLabel2.BackgroundTransparency = 1
	textLabel2.TextScaled = true
	textLabel2.TextWrapped = true
	textLabel2.Parent = frame2
	local textButton = Instance.new("TextButton")
	textButton.Name = "BuyButton"
	textButton.Size = UDim2.new(0.9, 0, 0.12, 0)
	textButton.Position = UDim2.new(0.05, 0, 0.87, 0)
	textButton.Text = isGamepadPreferred() and "PRESS X TO BUY" or "PRESS E TO BUY"
	textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	textButton.TextSize = 14
	textButton.Font = Enum.Font.GothamBold
	textButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
	textButton.TextScaled = true
	textButton.Parent = frame2
	local frame3 = Instance.new("Frame")
	frame3.Name = "CostFrame"
	frame3.Size = UDim2.new(0.9, 0, 0.08, 0)
	frame3.Position = UDim2.new(0.05, 0, 0.78, 0)
	frame3.BackgroundTransparency = 1
	frame3.Parent = frame2
	local textLabel3 = Instance.new("TextLabel")
	textLabel3.Name = "CostLabel"
	textLabel3.Size = UDim2.new(1, 0, 1, 0)
	textLabel3.Text = data.ichorCost .. " Ichor OR " .. data.tokenCost .. " Tokens"
	textLabel3.TextColor3 = Color3.fromRGB(255, 215, 0)
	textLabel3.TextSize = 12
	textLabel3.Font = Enum.Font.Gotham
	textLabel3.BackgroundTransparency = 1
	textLabel3.TextScaled = true
	textLabel3.Parent = frame3
	return frame2, textButton
end

local function createPurchaseDialogOLD(_, data, parent)
	local frame = Instance.new("Frame")
	frame.Name = "PurchaseDialog"
	frame.Size = UDim2.new(0.4, 0, 0.3, 0)
	frame.Position = UDim2.new(0.3, 0, 0.35, 0)
	frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
	frame.BorderSizePixel = 3
	frame.Parent = parent
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(0.9, 0, 0.25, 0)
	textLabel.Position = UDim2.new(0.05, 0, 0.05, 0)
	textLabel.Text = "Purchase " .. data.name .. "?"
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextSize = 18
	textLabel.Font = Enum.Font.GothamBold
	textLabel.BackgroundTransparency = 1
	textLabel.TextScaled = true
	textLabel.Parent = frame
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Size = UDim2.new(0.9, 0, 0.15, 0)
	textLabel2.Position = UDim2.new(0.05, 0, 0.3, 0)
	textLabel2.Text = "This purchase is only valid for this round."
	textLabel2.TextColor3 = Color3.fromRGB(200, 200, 200)
	textLabel2.TextSize = 14
	textLabel2.Font = Enum.Font.Gotham
	textLabel2.BackgroundTransparency = 1
	textLabel2.TextScaled = true
	textLabel2.Parent = frame
	local textButton = Instance.new("TextButton")
	textButton.Name = "IchorButton"
	textButton.Size = UDim2.new(0.35, 0, 0.2, 0)
	textButton.Position = UDim2.new(0.1, 0, 0.55, 0)
	textButton.Text = data.ichorCost .. " Ichor"
	textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	textButton.TextSize = 14
	textButton.Font = Enum.Font.GothamBold
	textButton.BackgroundColor3 = Color3.fromRGB(120, 60, 200)
	textButton.TextScaled = true
	textButton.Parent = frame
	local textButton2 = Instance.new("TextButton")
	textButton2.Name = "TokenButton"
	textButton2.Size = UDim2.new(0.35, 0, 0.2, 0)
	textButton2.Position = UDim2.new(0.55, 0, 0.55, 0)
	textButton2.Text = data.tokenCost .. " Tokens"
	textButton2.TextColor3 = Color3.fromRGB(255, 255, 255)
	textButton2.TextSize = 14
	textButton2.Font = Enum.Font.GothamBold
	textButton2.BackgroundColor3 = Color3.fromRGB(215, 120, 0)
	textButton2.TextScaled = true
	textButton2.Parent = frame
	local textButton3 = Instance.new("TextButton")
	textButton3.Name = "CancelButton"
	textButton3.Size = UDim2.new(0.2, 0, 0.15, 0)
	textButton3.Position = UDim2.new(0.4, 0, 0.8, 0)
	textButton3.Text = "X"
	textButton3.TextColor3 = Color3.fromRGB(255, 255, 255)
	textButton3.TextSize = 16
	textButton3.Font = Enum.Font.GothamBold
	textButton3.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
	textButton3.TextScaled = true
	textButton3.Parent = frame
	return frame, textButton, textButton2, textButton3
end

local function createPurchaseDialog(_, data, parent)
	local purchaseDialogTemplate = parent:FindFirstChild("PurchaseDialogTemplate")
	local clone = purchaseDialogTemplate and purchaseDialogTemplate:Clone()
	clone.Name = "PurchaseDialog"
	clone.Parent = parent
	local title = clone:FindFirstChild("Title") or clone:FindFirstChild("TitleLabel")

	if title then
		title.Text = "Purchase " .. data.name .. "?"
	end

	local itemImage = clone:FindFirstChild("ItemImage") or clone:FindFirstChild("ItemFrame") and clone.ItemFrame:FindFirstChild("ItemImage")

	if itemImage then
		itemImage.Image = data.icon
	end

	local description = clone:FindFirstChild("Description") or clone:FindFirstChild("ItemDescription")

	if description then
		description.Text = data.description
	end

	local ichorButton = clone.IchorButton
	ichorButton.PriceFrame.PriceWithDrop.Text = data.ichorCost
	ichorButton.PriceFrame.PriceWithDrop.PriceTop.Text = data.ichorCost
	local tokenButton = clone.TokenButton
	local cancelButton = clone.CancelButton
	local exit = clone.Exit
	GuiService.SelectedObject = isGamepadPreferred() and ichorButton or nil
	clone.Visible = true
	return clone, ichorButton, tokenButton, cancelButton, exit
end

local function setupShopInNewUI(p, p2, p3, _)
	local shopData = Floor0Shop.GetShopData()
	local v4 = {}
	local margin = p.SelectionFrame:FindFirstChild("Margin")

	if not margin then
		warn("[Floor0ShopClient] Margin frame not found!")
		return
	end

	local shopFrame = margin:FindFirstChild("ShopFrame")

	if not shopFrame then
		warn("[Floor0ShopClient] ShopFrame not found in Margin!")
		return
	end

	for _, _ in pairs(shopFrame:GetChildren()) do

	end

	local frames = {}

	for _, frame in pairs(shopFrame:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		if not (frame.Name == "Item" or frame.Name == "Floor0Frame1" or frame.Name == "Floor0Frame2" or frame.Name == "Floor0Frame3" or frame.Name == "BandageFrame" or frame.Name == "MedkitFrame" or frame.Name == "ValveFrame" or frame.Name == "Health KitFrame") then
			continue
		end

		table.insert(frames, frame)
	end

	if #frames == 0 then
		for _, frame in pairs(shopFrame:GetChildren()) do
			if frame:IsA("Frame") then
				table.insert(frames, frame)
			end
		end
	end

	for k, v5 in pairs({ "Bandage", "HealthKit", "Valve" }) do
		local frame = frames[k]
		local v7 = shopData[v5]

		if frame and v7 then
			local displayFrame = frame:FindFirstChild("DisplayFrame")

			if displayFrame then
				local itemImage = displayFrame:FindFirstChild("ItemImage")

				if itemImage then
					itemImage.Image = v7.icon
				else
					warn("[Floor0ShopClient] ItemImage not found in DisplayFrame for", v5)
				end
			else
				warn("[Floor0ShopClient] DisplayFrame not found for", v5)
			end

			local count = 0

			for _, label in pairs(frame:GetChildren()) do
				if not label:IsA("TextLabel") then
					continue
				end

				if label.Name == "Title" then
					count += 1
					label.Text = v7.name
				elseif label.Name == "Description" or label.Name == "Desc" then
					label.Text = v7.description
				end
			end

			if displayFrame then
				local description = displayFrame:FindFirstChild("Description")

				if description and description:IsA("TextLabel") then
					description.Text = v7.description
				end
			end

			local frame2 = frame
			frame.MouseEnter:Connect(function()
				Audio:PlayOne("Sounds.UI.SkillCheck.Ticks.TinyTick")
				tweens:playTween(frame2.DisplayFrame.Glow2, TweenInfo.new(0.1), {
					ImageTransparency = 0
				})
			end)
			local frame3 = frame
			frame.MouseLeave:Connect(function()
				tweens:playTween(frame3.DisplayFrame.Glow2, TweenInfo.new(0.1), {
					ImageTransparency = 1
				})
			end)
			local purchase = frame:FindFirstChild("Purchase")

			if purchase then
				local priceFrame = purchase:FindFirstChild("PriceFrame")

				if priceFrame then
					local priceWithDrop = priceFrame:FindFirstChild("PriceWithDrop")

					if priceWithDrop then
						priceWithDrop.Text = tostring(v7.ichorCost)
						local priceTop = priceWithDrop:FindFirstChild("PriceTop")

						if priceTop then
							priceTop.Text = tostring(v7.ichorCost)
						end
					else
						warn("[Floor0ShopClient] PriceWithDrop not found for", v5)
					end

					local robuxColor = priceFrame:FindFirstChild("RobuxColor")

					if robuxColor then
						robuxColor.Text = v7.tokenCost .. " Tokens"
					else
						warn("[Floor0ShopClient] RobuxColor not found for", v5)
					end
				else
					warn("[Floor0ShopClient] PriceFrame not found for", v5)
				end

				local v10 = v5
				local v11 = v7
				local v12 = purchase
				purchase.Activated:Connect(function()
					if not v[v10] then
						fn(v10, v11, p2, p3)
						Audio:PlayOne("Sounds.UI.Buttons.Click")
						task.spawn(function()
							tweens:playTween(v12, TweenInfo.new(0.1), {
								AnchorPoint = Vector2.new(0.5, 0.4)
							})
							wait(0.1)
							tweens:playTween(v12, TweenInfo.new(0.1), {
								AnchorPoint = Vector2.new(0.5, 0.5)
							})
						end)
					end
				end)
				local button = purchase
				purchase.MouseEnter:Connect(function()
					tweens:playTween(button.UIScale, TweenInfo.new(0.1), {
						Scale = 1.04
					})
				end)
				local button2 = purchase
				purchase.MouseLeave:Connect(function()
					tweens:playTween(button2.UIScale, TweenInfo.new(0.1), {
						Scale = 1
					})
				end)
				v4[v5] = {
					frame = frame,
					button = purchase,
					data = v7
				}
			else
				warn("[Floor0ShopClient] Purchase button not found for", v5)
			end
		else
			if not frame then
				warn("[Floor0ShopClient] Missing item frame for", v5, "at index", k, "- only", #frames, "frames found")
			end

			if not v7 then
				warn("[Floor0ShopClient] Missing shop data for", v5)
			end
		end
	end

	setupKeyBindings(v4, p2, p3, shopFrame) -- equivalent call inferred; original call site unknown
end

local function setupShopInFloor0Frame(floor0, p, p2, p3, callback)
	for _, guiObject in pairs(floor0:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(0.9, 0, 0.1, 0)
	textLabel.Position = UDim2.new(0.05, 0, 0.02, 0)
	textLabel.Text = "Floor 0 Shop"
	textLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
	textLabel.TextSize = 20
	textLabel.Font = Enum.Font.GothamBold
	textLabel.BackgroundTransparency = 1
	textLabel.TextScaled = true
	textLabel.Parent = floor0
	local frame = Instance.new("Frame")
	frame.Name = "ItemsContainer"
	frame.Size = UDim2.new(0.95, 0, 0.8, 0)
	frame.Position = UDim2.new(0.025, 0, 0.15, 0)
	frame.BackgroundTransparency = 1
	frame.Parent = floor0
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.FillDirection = Enum.FillDirection.Horizontal
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	uIListLayout.Padding = UDim.new(0, 10)
	uIListLayout.Parent = frame
	local shopData = Floor0Shop.GetShopData()
	local v4 = {}

	for k, v5 in pairs(shopData) do
		local shopItemFrame, button = createShopItemFrame(k, v5, frame)
		v4[k] = {
			frame = shopItemFrame,
			button = button,
			data = v5
		}
		local v7 = k
		local v8 = v5
		button.Activated:Connect(function()
			if not v[v7] then
				fn(v7, v8, p2, p3)
			end
		end)
	end

	local textButton = Instance.new("TextButton")
	textButton.Name = "ReadyUpButton"
	textButton.Size = UDim2.new(0.2, 0, 0.06, 0)
	textButton.Position = UDim2.new(0.4, 0, 0.02, 0)
	textButton.Text = ""
	textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	textButton.TextSize = 16
	textButton.Font = Enum.Font.GothamBold
	textButton.BorderSizePixel = 2
	textButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
	textButton.TextScaled = true
	textButton.Parent = p.SelectionFrame
	textButton.Activated:Connect(function()
		if flag then
			flag = false
			textButton.Text = "READY UP"
			readyUpEvent:FireServer("UnReady")
		else
			flag = true
			textButton.Text = "READY!"
			readyUpEvent:FireServer("ReadyUp")
		end

		callback()
	end)
	setupKeyBindings(v4, p2, p3, floor0) -- equivalent call inferred; original call site unknown
end

fn = function(p, data, callback, callback2)
	if v2:FindFirstChild("PurchaseDialog") then
		v2.PurchaseDialog:Destroy()
	end

	local purchaseDialog, v4, v5, v6, v7 = createPurchaseDialog(p, data, v2)
	v4.Activated:Connect(function()
		local v8 = floor0ShopFunction:InvokeServer("Purchase", p, "Ichor")

		if v8.success then
			v[p] = {
				currency = "Ichor",
				cost = data.ichorCost
			}
			callback("Purchased " .. data.name .. " for " .. data.ichorCost .. " Ichor!")
			Floor0ShopClient.updateShopItemVisual(p)
			Floor0ShopClient.updateIchorDisplay()
		else
			callback2(v8.message)
		end

		purchaseDialog:Destroy()
	end)

	local function returnSelection(p2)
		local selectionFrame = v2.SelectionFrame
		local margin = selectionFrame and selectionFrame:FindFirstChild("Margin")
		local shopFrame = margin and margin:FindFirstChild("ShopFrame")
		local child = shopFrame and shopFrame:FindFirstChild(p2 .. "Item")
		local purchase = child and child:FindFirstChild("Purchase")

		if purchase then
			GuiService.SelectedObject = isGamepadPreferred() and purchase or nil
		end
	end

	v5.Activated:Connect(function()
		local v8 = floor0ShopFunction:InvokeServer("Purchase", p, "Tokens")

		if v8.success then
			v[p] = {
				currency = "Tokens",
				cost = data.tokenCost
			}
			callback("Purchased " .. data.name .. " for " .. data.tokenCost .. " Tokens!")
			Floor0ShopClient.updateShopItemVisual(p)
		else
			callback2(v8.message)
		end

		purchaseDialog:Destroy()
		returnSelection(p)
	end)
	v6.Activated:Connect(function()
		purchaseDialog:Destroy()
		returnSelection(p)
	end)
	v7.Activated:Connect(function()
		purchaseDialog:Destroy()
		returnSelection(p)
	end)
end

function Floor0ShopClient.updateShopItemVisual(p)
	local margin = v2.SelectionFrame:FindFirstChild("Margin")
	local shopFrame = margin and margin:FindFirstChild("ShopFrame")

	if shopFrame then
		local v4 = ({
			Bandage = "BandageItem",
			HealthKit = "HealthKitItem",
			Valve = "ValveItem"
		})[p]
		local child = v4 and shopFrame:FindFirstChild(v4)

		if child then
			local purchased = child:FindFirstChild("Purchased")
			purchased.ImageTransparency = 1
			purchased.Visible = true
			tweens:playTween(purchased, TweenInfo.new(0.15, Enum.EasingStyle.Cubic), {
				ImageTransparency = 0.2
			})
			tweens:playTween(child.UIScale, TweenInfo.new(0.5, Enum.EasingStyle.Bounce), {
				Scale = 0.9
			})
			tweens:playTween(child.DisplayFrame.Glow, TweenInfo.new(0.15), {
				ImageTransparency = 1
			})
			tweens:playTween(child.DisplayFrame.Glow2, TweenInfo.new(0.15), {
				ImageTransparency = 1
			})
			tweens:playTween(child.DisplayFrame.ItemImage, TweenInfo.new(0.15), {
				ImageColor3 = Color3.fromRGB(0, 0, 0)
			})
			purchased.Sold.Popout.TextTransparency = 0.5
			tweens:playTween(purchased.Sold.Popout.UIScale, TweenInfo.new(1), {
				Scale = 3
			})
			tweens:playTween(purchased.Sold.Popout, TweenInfo.new(1), {
				TextTransparency = 1
			})
			tweens:playTween(purchased.Sold.Popout.UIStroke, TweenInfo.new(1), {
				Transparency = 1
			})
			Audio:PlayOne("Sounds.UI.Money.MoneySpent")
		end
	else
		local floor0 = v2.SelectionFrame:FindFirstChild("Floor0")
		local child = floor0 and floor0:FindFirstChild(p .. "Frame")

		if child then
			child.BuyButton.Text = "PURCHASED"
			child.BuyButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
			child.BuyButton.Active = false
		end
	end
end

function Floor0ShopClient.setupShop(p, p2, p3, p4)
	v2 = p
	InputService:SetContextEnabled("Floor0Shop", true)

	if not floor0ShopFunction then
		floor0ShopFunction = ReplicatedStorage:FindFirstChild("Floor0ShopFunction")

		if not floor0ShopFunction then
			warn("[Floor0ShopClient] Floor0ShopFunction not found!")
			return
		end
	end

	if not readyUpEvent then
		readyUpEvent = ReplicatedStorage.Events:FindFirstChild("ReadyUpEvent")

		if not readyUpEvent then
			warn("[Floor0ShopClient] ReadyUpEvent not found!")
			return
		end
	end

	local margin = p.SelectionFrame:FindFirstChild("Margin")
	local floor0 = p.SelectionFrame:FindFirstChild("Floor0")

	if margin and margin:FindFirstChild("ShopFrame") then
		setupShopInNewUI(p, p2, p3, p4)
	elseif floor0 then
		setupShopInFloor0Frame(floor0, p, p2, p3, p4)
	else
		warn("[Floor0ShopClient] No suitable shop frame found! Looking for Margin/ShopFrame or Floor0 frame.")
		return
	end

	local quickLinks = p.SelectionFrame:FindFirstChild("QuickLinks")

	if quickLinks then
		Floor0Shop.SetupToggleButtons(quickLinks)
		quickLinks:FindFirstChild("Shop")
	end

	Floor0ShopClient.updateIchorDisplay()
end

function Floor0ShopClient.hideShop(instance)
	v2 = instance

	for _, connection in pairs(v3) do
		if connection then
			connection:Disconnect()
		end
	end

	v3 = {}
	InputService:SetContextEnabled("Floor0Shop", false)
	local margin = instance.SelectionFrame:FindFirstChild("Margin")

	if margin then
		local shopFrame = margin:FindFirstChild("ShopFrame")

		if shopFrame then
			for _, frame in pairs(shopFrame:GetChildren()) do
				if not (frame:IsA("Frame") and frame.Name == "Item") then
					continue
				end

				local purchase = frame:FindFirstChild("Purchase")

				if purchase then
					local purchasedLabel = purchase:FindFirstChild("PurchasedLabel")

					if purchasedLabel then
						purchasedLabel:Destroy()
					end

					purchase.Active = true
				end

				local background = frame:FindFirstChild("Background")

				if background then
					background.ImageColor3 = Color3.fromRGB(255, 255, 255)
				end
			end
		end
	end

	local floor0 = instance.SelectionFrame:FindFirstChild("Floor0")

	if floor0 then
		for _, guiObject in pairs(floor0:GetChildren()) do
			if guiObject:IsA("GuiObject") then
				guiObject:Destroy()
			end
		end
	end

	if instance.SelectionFrame:FindFirstChild("ReadyUpButton") then
		instance.SelectionFrame.ReadyUpButton:Destroy()
	end

	if instance:FindFirstChild("PurchaseDialog") then
		instance.PurchaseDialog:Destroy()
	end

	flag = false
end

function Floor0ShopClient.updateIchorDisplay()
	if not v2 then
		return
	end

	local quickLinks = v2.SelectionFrame:FindFirstChild("QuickLinks")

	if quickLinks then
		local uI_Elements = quickLinks:FindFirstChild("UI_Elements")

		if uI_Elements then
			local playerIchorCount = uI_Elements:FindFirstChild("PlayerIchorCount")

			if playerIchorCount and playerIchorCount.Value then
				local child = game.ReplicatedStorage.PlayerData:FindFirstChild((tostring(game.Players.LocalPlayer.UserId)))

				if child then
					local coin = child:FindFirstChild("Coin")

					if coin then
						local text = tostring(coin.Value)
						playerIchorCount.Value.Text = text
						local priceTop = playerIchorCount.Value:GetAttribute("HasDropText") and playerIchorCount.Value:FindFirstChild("PriceTop")

						if priceTop then
							priceTop.Text = text
						end

						return
					else
						warn("[Floor0ShopClient] Coin not found in ReplicatedData")
					end
				else
					warn("[Floor0ShopClient] ReplicatedData not found for player")
				end
			else
				warn("[Floor0ShopClient] PlayerIchorCount QuickLink not found or has no value")
			end
		else
			warn("[Floor0ShopClient] UI_Elements folder not found in QuickLinks")
		end
	else
		warn("[Floor0ShopClient] QuickLinks not found")
	end

	local margin = v2.SelectionFrame:FindFirstChild("Margin")

	if margin then
		local bottomFrame = margin:FindFirstChild("BottomFrame")
		local currency = bottomFrame and bottomFrame:FindFirstChild("Currency")

		if currency then
			local ichor = currency:FindFirstChild("Ichor")
			local numberWithDrop = ichor and ichor:FindFirstChild("NumberWithDrop")

			if numberWithDrop then
				local child = game.ReplicatedStorage.PlayerData:FindFirstChild((tostring(game.Players.LocalPlayer.UserId)))
				local coin = child and child:FindFirstChild("Coin")

				if coin then
					local text = tostring(coin.Value)
					numberWithDrop.Text = text
					local priceTop = numberWithDrop:GetAttribute("HasDropText") and numberWithDrop:FindFirstChild("PriceTop")

					if priceTop then
						priceTop.Text = text
					end
				end
			end
		end
	end
end

game.ReplicatedStorage.PlayerData.ChildAdded:Connect(function(child)
	local coin = child.Name == tostring(game.Players.LocalPlayer.UserId) and child:WaitForChild("Coin", 5)

	if coin then
		coin.Changed:Connect(function()
			Floor0ShopClient.updateIchorDisplay()
		end)
		Floor0ShopClient.updateIchorDisplay()
	end
end)
local child = game.ReplicatedStorage.PlayerData:FindFirstChild((tostring(game.Players.LocalPlayer.UserId)))
local coin = child and child:FindFirstChild("Coin")

if coin then
	coin.Changed:Connect(function()
		Floor0ShopClient.updateIchorDisplay()
	end)
	Floor0ShopClient.updateIchorDisplay()
end

return Floor0ShopClient