local MarketplaceService = game:GetService("MarketplaceService")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TweenService")
game:GetService("UserInputService")
local shop = script:FindFirstAncestor("Shop")
local _ = shop.Parent.Parent
local inspectItemPage = shop.InspectItemPage
local inspectItem = inspectItemPage.InspectItem
local parent = script.Parent
local example = script.Example
local exampleCurrency = script.ExampleCurrency
local itemSkinsPage = shop.ItemSkinsPage
local _ = itemSkinsPage.Frame
local purchase = itemSkinsPage.Frame.Purchase
local gift = itemSkinsPage.Frame.Gift
local cancel = itemSkinsPage.Frame.Cancel
local UI = require(ReplicatedStorage.Modules.UI)
require(game.ReplicatedStorage.Assets.Data.UIData.RandomUITypes)
local Data = require(game.ReplicatedStorage.Modules.Data)
require(ReplicatedStorage.Modules.Server)
local GiftUtil = require(ReplicatedStorage.Modules.GiftUtil)
local Gamepasses = require(ReplicatedStorage.Assets.Data.Store.Gamepasses)
local Currency = require(ReplicatedStorage.Assets.Data.Store.Currency)
local Bundles = require(ReplicatedStorage.Assets.Data.Store.Bundles)
local ToolProducts = require(ReplicatedStorage.Assets.Data.Store.ToolProducts)
local toolProducts = ToolProducts.ToolProducts
local tiers = ToolProducts.Tiers
local getOwnershipAttribute = ToolProducts.GetOwnershipAttribute
local Network = require(ReplicatedStorage.Modules.Network)
local localPlayer = Players.LocalPlayer
Data.Inventory:WaitFor("Get")
Instance.new("BindableEvent")

local function GetGamepasses()
	return Gamepasses
end

local function GetGamepassId(p)
	for _, gamepass in Gamepasses do
		if p == gamepass then
			return gamepass.Id
		end
	end

	return nil
end

local function GetCurrencyInternalName(p)
	for k, v in Currency do
		if p == v then
			return k
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getGamepassGiftId(display: string)
	for _, gamepass in Gamepasses do
		if gamepass.Display == display then
			return gamepass.GiftId
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DoesOwnGamepass(p)
	local gamepassGiftId = getGamepassGiftId(p.Display) -- equivalent call inferred; original call site unknown
	return localPlayer:GetAttribute((`P{gamepassGiftId}`))
end

local function CommaValue(p)
	local v = tonumber(p)

	if v then
		return string.format("%0.0f", v):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
	end

	return "???"
end

local function CreateItemCategory(text: string)
	local category = UI:CreateCategory(parent)
	category.Collapsible.InfoContainer.Title.Text = text

	local function GetItemCount()
		local count = 0

		for _, button in category.List:GetChildren() do
			if button:IsA("ImageButton") and button.Visible then
				count += 1
			end
		end

		return count
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateVisibility()
		category.Visible = GetItemCount() > 0
	end

	category.List.ChildAdded:Connect(function(button)
		UpdateVisibility() -- equivalent call inferred; original call site unknown

		if button:IsA("ImageButton") then
			button:GetPropertyChangedSignal("Visible"):Connect(function()
				UpdateVisibility() -- equivalent call inferred; original call site unknown
			end)
		end
	end)
	category.List.ChildRemoved:Connect(function()
		UpdateVisibility() -- equivalent call inferred; original call site unknown
	end)
	UpdateVisibility() -- equivalent call inferred; original call site unknown
	return category
end

local function CreateCurrencyItemCategory(text: string)
	local robuxCategory = UI:CreateRobuxCategory(parent)
	robuxCategory.Collapse.InfoContainer.Title.Text = text

	local function GetItemCount()
		local count = 0

		for _, button in robuxCategory.ItemList1:GetChildren() do
			if button:IsA("ImageButton") and button.Visible then
				count += 1
			end
		end

		return count
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function UpdateVisibility()
		robuxCategory.Visible = GetItemCount() > 0
	end

	robuxCategory.ItemList1.ChildAdded:Connect(function(button)
		UpdateVisibility() -- equivalent call inferred; original call site unknown

		if button:IsA("ImageButton") then
			button:GetPropertyChangedSignal("Visible"):Connect(function()
				UpdateVisibility() -- equivalent call inferred; original call site unknown
			end)
		end
	end)
	robuxCategory.ItemList1.ChildRemoved:Connect(function()
		UpdateVisibility() -- equivalent call inferred; original call site unknown
	end)
	UpdateVisibility() -- equivalent call inferred; original call site unknown
	return robuxCategory
end

local function CreateGamepass(data, value)
	local clone = example:Clone()
	local footer = clone.Footer

	while not data.Ready do
		task.wait()
	end

	clone.GamepassName.Text = data.Display
	clone.Header.GamepassName.Text = data.Display
	footer.Buy.Title.Text = ` {CommaValue(data.Price or value or -1)}`
	clone.Icon.Icon.Image = data.Icon
	return clone
end

local function CreateCurrency(data, value)
	local clone = exampleCurrency:Clone()
	local footer = clone.Footer

	while not data.Ready do
		task.wait()
	end

	clone.Header.GamepassName.Text = data.Display
	footer.Buy.Title.Text = ` {CommaValue(data.Price or value or -1)}`
	clone.Icon.Image = data.Icon
	return clone
end

local function CreateCandyCane(data, p)
	local clone = script.ExampleCandyCane:Clone()
	local footer = clone.Footer
	clone.Header.GamepassName.Text = data.Display
	footer.Buy.Title.Text = ` {CommaValue(data.Price or p)}`
	clone.Icon.Image = data.Icon
	return clone
end

local function UpdateGamepassPreview(data)
	inspectItemPage.Visible = true
	inspectItem.Buttons.Gift.Visible = true
	inspectItem.Description.Text = data.Description
	inspectItem.Item.ItemImage.Image = data.Icon
	inspectItem.Item.ItemImage.Visible = true
	inspectItem.Item.Title.Visible = false
	inspectItem.ItemName.Text = `{data.Display}`
	inspectItem.Robux.Visible = true
	inspectItem.Robux.Text = "" .. CommaValue(data.Price or -1)

	if DoesOwnGamepass(data) then
		inspectItem.Buttons.Owned.Visible = true
	else
		inspectItem.Buttons.Purchase.Visible = true
	end

	localPlayer:GetAttributeChangedSignal((`P{data.Id}`)):Connect(function()
		if DoesOwnGamepass(data) then
			inspectItem.Buttons.Owned.Visible = true
		else
			inspectItem.Buttons.Purchase.Visible = true
		end
	end)
	local connections = {}
	table.insert(connections, inspectItem.Buttons.Purchase.MouseButton1Click:Connect(function()
		if DoesOwnGamepass(data) then
			return
		end

		MarketplaceService:PromptGamePassPurchase(localPlayer, data.Id)
	end))
	table.insert(connections, MarketplaceService.PromptGamePassPurchaseFinished:Once(function(_, _, p)
		inspectItemPage.Visible = not p
	end))
	table.insert(connections, inspectItem.Buttons.Gift.MouseButton1Click:Connect(function()
		GiftUtil:PromptGift(data.GiftId)
	end))
	inspectItemPage:GetPropertyChangedSignal("Visible"):Once(function()
		for _, connection in connections do
			connection:Disconnect()
		end
	end)
end

local function UpdateToolPreview(p: string, data)
	inspectItemPage.Visible = true
	inspectItem.Buttons.Gift.Visible = true
	inspectItem.Description.Text = data.Description or ""
	inspectItem.Item.ItemImage.Image = data.Icon or ""
	inspectItem.Item.ItemImage.Visible = true
	inspectItem.Item.Title.Visible = false
	inspectItem.ItemName.Text = data.Display
	inspectItem.Robux.Visible = true
	inspectItem.Robux.Text = "" .. CommaValue(data.Price or -1)
	local ownershipAttribute = getOwnershipAttribute(p)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function RefreshOwnership()
		local visible = localPlayer:GetAttribute(ownershipAttribute) == true
		inspectItem.Buttons.Owned.Visible = visible
		inspectItem.Buttons.Purchase.Visible = not visible
	end

	RefreshOwnership() -- equivalent call inferred; original call site unknown
	local connections = {}
	table.insert(connections, localPlayer:GetAttributeChangedSignal(ownershipAttribute):Connect(RefreshOwnership))
	table.insert(connections, inspectItem.Buttons.Purchase.MouseButton1Click:Connect(function()
		if localPlayer:GetAttribute(ownershipAttribute) then
			return
		end

		Network:fire("PromptToolProduct", p)
	end))
	table.insert(connections, MarketplaceService.PromptProductPurchaseFinished:Connect(function(p2, _, p3)
		if p2 == localPlayer.UserId and p3 then
			inspectItemPage.Visible = false
		end
	end))
	table.insert(connections, inspectItem.Buttons.Gift.MouseButton1Click:Connect(function()
		local tier = tiers[data.Tier]

		if not tier then
			return
		end

		Network:fire("SetPendingToolGift", p)
		GiftUtil:PromptGift(tier.Id)
	end))
	inspectItemPage:GetPropertyChangedSignal("Visible"):Once(function()
		for _, connection in connections do
			connection:Disconnect()
		end
	end)
end

local function GetCurrencyName(p)
	return (`{CommaValue(math.round(p.Amount * (workspace:GetAttribute("RobuxCreditsMultiplier") or 1)))} Credits`)
end

local function GetCandyCaneName(p)
	return (`{CommaValue(math.round(p.Amount))} Candy Canes`)
end

local function UpdateCurrencyPreview(data)
	inspectItemPage.Visible = true
	inspectItem.Buttons.Gift.Visible = true
	inspectItem.Description.Text = `Grants {`{CommaValue(math.round(data.Amount * (workspace:GetAttribute("RobuxCreditsMultiplier") or 1)))} Credits`}.`
	inspectItem.Item.ItemImage.Image = data.Icon
	inspectItem.Item.ItemImage.Visible = true
	inspectItem.Item.Title.Visible = false

	for _, v in Currency do
		if data == v then
			break
		end
	end

	inspectItem.ItemName.Text = `{CommaValue(math.round(data.Amount * (workspace:GetAttribute("RobuxCreditsMultiplier") or 1)))} Credits`
	inspectItem.Robux.Visible = true
	inspectItem.Price.Visible = false
	inspectItem.Robux.Text = "" .. CommaValue(data.Price or -1)
	inspectItem.Buttons.Purchase.Visible = true
	local connections = {}
	table.insert(connections, inspectItem.Buttons.Purchase.MouseButton1Click:Connect(function()
		MarketplaceService:PromptProductPurchase(localPlayer, data.Id)
		table.insert(connections, MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, _, p2)
			if p == Players.LocalPlayer.UserId and p2 then
				inspectItemPage.Visible = false
			end
		end))
	end))
	table.insert(connections, inspectItem.Buttons.Gift.MouseButton1Click:Connect(function()
		GiftUtil:PromptGift(data.Id)
	end))
	inspectItemPage:GetPropertyChangedSignal("Visible"):Once(function()
		for _, connection in connections do
			connection:Disconnect()
		end
	end)
end

local function CreateGamepassList()
	local itemCategory = CreateItemCategory("Gamepasses")
	itemCategory.Name = "Gamepasses"
	itemCategory.List.UIGridLayout.CellSize = UDim2.new(0, 68, 0, 80)
	itemCategory.List.UIGridLayout.UIAspectRatioConstraint:Destroy()

	for _, v3 in Gamepasses do
		local gamepass = CreateGamepass(v3)
		gamepass.Parent = itemCategory.List
		gamepass.LayoutOrder = tonumber(v3.Price) or 0
		gamepass.Name = v3.Display:lower():gsub(" ", "_")
		local v5 = v3
		shop.Hotbar.SearchBar.Search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			local text = shop.Hotbar.SearchBar.Search.TextBox.Text

			if v5.Display:lower():find(text:lower()) then
				gamepass.Visible = true
			else
				gamepass.Visible = false
			end
		end)
		local gamepassGiftId = getGamepassGiftId(v3.Display) -- equivalent call inferred; original call site unknown
		local gamepass2 = gamepass
		local v10 = v3
		localPlayer:GetAttributeChangedSignal((`P{gamepassGiftId}`)):Connect(function()
			local hidden = gamepass2.Hidden
			hidden.Visible = DoesOwnGamepass(v10) and true or false
		end)
		local hidden = gamepass.Hidden
		hidden.Visible = DoesOwnGamepass(v3) and true or false
		gamepass.Visible = true
		local v11 = v3
		local v12 = gamepass
		gamepass.MouseButton1Click:Connect(function()
			if inspectItemPage.Visible then
				return
			end

			purchase:SetAttribute("ProductId", getGamepassGiftId(v11.Display))

			-- equivalent calls inferred from this helper; original call sites unknown
			local function UpdateHidden()
				local hidden2 = v12.Hidden
				hidden2.Visible = DoesOwnGamepass(v11)
			end

			local gamepassGiftId2 = getGamepassGiftId(v11.Display) -- equivalent call inferred; original call site unknown
			localPlayer:GetAttributeChangedSignal((`P{gamepassGiftId2}`)):Connect(function()
				return UpdateHidden()
			end)
			UpdateHidden() -- equivalent call inferred; original call site unknown
			UpdateGamepassPreview(v11)
		end)
		UI:Bind(gamepass)
		UI:AddShadowOnHover(gamepass)
	end

	itemCategory.Parent = parent
end

local function CreateCurrencyList()
	local currencyItemCategory = CreateCurrencyItemCategory("Currency")
	currencyItemCategory.Name = "Currency"

	for _, v2 in Currency do
		local currency = CreateCurrency(v2)
		currency.Header.GamepassName.Text = `{CommaValue(math.round(v2.Amount * (workspace:GetAttribute("RobuxCreditsMultiplier") or 1)))} Credits`
		currency.Parent = currencyItemCategory.ItemList1
		currency.Size = UDim2.new(0, example.Size.X.Offset, 0, example.Size.Y.Offset * currency.UIScale.Scale)
		currency.UIStroke.Thickness = 1 / currency.UIScale.Scale
		UI:BindReactive(currency.Icon, 0.04)

		if v2.Amount >= 1750 then
			currency.UIScale:Destroy()
			currency.UIStroke.Thickness = 1

			if v2.Amount == 1750 then
				currency.Size = UDim2.new(0, 117, 0, 80)
			else
				currency.Size = UDim2.new(0, 177, 0, 80)
			end
		end

		currency.LayoutOrder = v2.Price
		currency.Name = v2.Display:lower():gsub(" ", "_")
		local v4 = v2
		shop.Hotbar.SearchBar.Search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			local text = shop.Hotbar.SearchBar.Search.TextBox.Text

			if v4.Display:lower():find(text:lower()) then
				currency.Visible = true
			else
				currency.Visible = false
			end
		end)
		currency.Visible = true
		local v6 = v2
		currency.MouseButton1Click:Connect(function()
			if inspectItemPage.Visible then
				return
			end

			UpdateCurrencyPreview(v6)
		end)
		local currency2 = currency
		local v8 = v2
		workspace:GetAttributeChangedSignal("RobuxCreditsMultiplier"):Connect(function()
			currency2.Header.GamepassName.Text = `{CommaValue(math.round(v8.Amount * (workspace:GetAttribute("RobuxCreditsMultiplier") or 1)))} Credits`
		end)
		UI:Bind(currency)
		UI:AddShadowOnHover(currency)
	end

	currencyItemCategory.Parent = parent
end

local function IsWithinTimePeriod(p, p2: number)
	return p.Start < p2 and p2 < p.End
end

local function CreateBundleList()
	local gamepasses = parent:FindFirstChild("Gamepasses")

	for _, bundle in Bundles do
		if not bundle.LimitedTime then
			continue
		end

		local limitedTime = bundle.LimitedTime
		local now = os.time()
		local v

		if limitedTime.Start < now then
			v = now < limitedTime.End
		else
			v = false
		end

		if not v then
			continue
		end

		local gamepass = CreateGamepass(bundle)
		gamepass.Parent = gamepasses.List
		gamepass.GamepassName.TextSize = 8
		gamepass.LayoutOrder = -1
		gamepass.Name = bundle.Display:lower():gsub(" ", "_")
		local v3 = bundle
		shop.Hotbar.SearchBar.Search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			local text = shop.Hotbar.SearchBar.Search.TextBox.Text

			if v3.Display:lower():find(text:lower()) then
				gamepass.Visible = true
			else
				gamepass.Visible = false
			end
		end)
		local v5 = bundle
		gamepass.Footer.Buy.MouseButton1Click:Connect(function()
			MarketplaceService:PromptProductPurchase(localPlayer, v5.ProductId)
		end)
		gamepass.Visible = true
		local v6 = bundle
		gamepass.MouseButton1Click:Connect(function()
			purchase:SetAttribute("ProductId", v6.ProductId)
			inspectItemPage.InspectItem.ItemName.Text = v6.Name
			itemSkinsPage.Preview:Fire(v6.Name)
			itemSkinsPage.Sidebar.Visible = false
			itemSkinsPage.Frame.NeedOwnHint.Visible = #(v6.Skins or {}) > 0
			itemSkinsPage.Frame.BundlePrice.Visible = true
			itemSkinsPage.Frame.BundlePrice.Text = `Price:  {CommaValue(tonumber(v6.Price) or -1)}`
			purchase.Visible = true
			gift.Visible = true
			cancel.Visible = false
		end)
		-- equivalent calls inferred from this helper; original call sites unknown
		local gamepass2 = gamepass
		local v8 = bundle

		local function UpdateHidden()
			gamepass2.Hidden.Visible = localPlayer:GetAttribute((`P{v8.ProductId}`))
		end

		local UpdateHidden2 = UpdateHidden
		localPlayer:GetAttributeChangedSignal((`P{bundle.ProductId}`)):Connect(function()
			return UpdateHidden2()
		end)
		UpdateHidden() -- equivalent call inferred; original call site unknown
		UI:Bind(gamepass)
		UI:AddShadowOnHover(gamepass)
	end
end

local function CreateToolList()
	local itemCategory = CreateItemCategory("Tools")
	itemCategory.Name = "Tools"
	itemCategory.List.UIGridLayout.CellSize = UDim2.new(0, 68, 0, 80)
	local uIAspectRatioConstraint = itemCategory.List.UIGridLayout:FindFirstChild("UIAspectRatioConstraint")

	if uIAspectRatioConstraint then
		uIAspectRatioConstraint:Destroy()
	end

	for k, toolProduct in toolProducts do
		local gamepass = CreateGamepass(toolProduct)
		gamepass.Parent = itemCategory.List
		gamepass.GamepassName.TextSize = 8
		gamepass.LayoutOrder = tonumber(toolProduct.Price) or 0
		gamepass.Name = toolProduct.Display:lower():gsub(" ", "_")
		local v4 = toolProduct
		shop.Hotbar.SearchBar.Search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			local text = shop.Hotbar.SearchBar.Search.TextBox.Text
			gamepass.Visible = v4.Display:lower():find(text:lower()) ~= nil
		end)
		local ownershipAttribute = getOwnershipAttribute(k)
		-- equivalent calls inferred from this helper; original call sites unknown
		local gamepass2 = gamepass

		local function UpdateHidden()
			gamepass2.Hidden.Visible = localPlayer:GetAttribute(ownershipAttribute) and true or false
		end

		localPlayer:GetAttributeChangedSignal(ownershipAttribute):Connect(UpdateHidden)
		UpdateHidden() -- equivalent call inferred; original call site unknown
		gamepass.Visible = true
		local v7 = ownershipAttribute
		local v8 = k
		gamepass.Footer.Buy.MouseButton1Click:Connect(function()
			if localPlayer:GetAttribute(v7) then
				return
			end

			Network:fire("PromptToolProduct", v8)
		end)
		local v9 = k
		local v10 = toolProduct
		gamepass.MouseButton1Click:Connect(function()
			if inspectItemPage.Visible then
				return
			end

			UpdateToolPreview(v9, v10)
		end)
		UI:Bind(gamepass)
		UI:AddShadowOnHover(gamepass)
	end

	itemCategory.Parent = parent
end

script.Parent:GetPropertyChangedSignal("Visible"):Connect(function()
	if script.Parent.Visible then
		script.Sound:Play()
	end
end)
CreateCurrencyList()
CreateGamepassList()
CreateBundleList()
parent:SetAttribute("Ready", true)