game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local packages = ReplicatedStorage.packages
local legacyControllers = ReplicatedStorage.client.legacyControllers
local utils = ReplicatedStorage.shared.utils
local modules = ReplicatedStorage.shared.modules
local _ = modules.library
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local HudController = require(legacyControllers.HudController)
local QuestController = require(legacyControllers.QuestController)
local DataController = require(legacyControllers.DataController)
require(utils.GeneralUtils)
local NumberUtils = require(utils.NumberUtils)
local FischUtils = require(utils.FischUtils)
local LocalCurrencies = require(modules.LocalCurrencies)
local titles = require(modules.character.titles)
local Dealers = require(modules.Dealers)
local remoteFunction = Net:RemoteFunction("Dealer/GetState")
local remoteFunction2 = Net:RemoteFunction("Dealer/Purchase")
local remoteEvent = Net:RemoteEvent("Dealer/Load")
local container = HudController:GetSafeZone().Dealer.Container
local scrollingFrame = container.Catalog.ScrollingFrame
local top = container.Top
local nothing = top.Nothing
local selectedItem = top.SelectedItem
local header = top.Header
local purchaseLabel = selectedItem.PurchaseLabel
local itemContainer = selectedItem.ItemContainer
local item = itemContainer.Item
local purchase = selectedItem.Purchase
local amount = purchase.Amount
local less = amount.Less
local more = amount.More
local max = amount.Max
local textBox = amount.TextBox
local button = purchase.Button
local sample = script.Sample
local v = nil
local v2 = nil
local v3 = nil
local extraIngredientsByClone = {}
local v4 = 1
local maid = Trove.new()
local maid2 = Trove.new()
local maid3 = Trove.new()
local DealerController = {}

local function formatCountdown(p: number)
	local v5 = math.max(0, (math.floor(p)))
	local v6 = math.floor(v5 / 3600)
	local v7 = math.floor(v5 % 3600 / 60)
	local v8 = v5 % 60
	return string.format("%02d:%02d:%02d", v6, v7, v8)
end

local v5 = {
	AsOne = true
}

local function getItemDetails(p: string)
	local v6 = v and Dealers[v]

	if not v6 then
		return nil, "", p
	end

	local availableItem = v6.AvailableItems[p]

	if not availableItem then
		return nil, "", p
	end

	local clone = table.clone(availableItem.Reward)

	for k, v7 in clone do
		if v7 == "purchase-amount" then
			clone[k] = 1
		end
	end

	local rewardDescription, v7 = QuestController:GetRewardDescription(clone, v5)
	return availableItem, v7 or "", rewardDescription
end

local function applyTitleStyle(titleLabel, title)
	local font = Font.new(
		not title.CustomFont and "rbxasset://fonts/families/SourceSansPro.json" or title.CustomFont.Family or "rbxasset://fonts/families/SourceSansPro.json",
		title.CustomFont and title.CustomFont.Weight or Enum.FontWeight.Regular,
		title.CustomFont and title.CustomFont.Style or Enum.FontStyle.Normal
	)

	if title.Bold and not font.Bold then
		font.Bold = true
	end

	if title.Italic then
		font.Style = Enum.FontStyle.Italic
	end

	titleLabel.FontFace = font
	titleLabel.Text = title.Text or ""

	if title.StrokeColor == Color3.new(1, 1, 1) then
		titleLabel.TextStrokeTransparency = 1
	else
		titleLabel.TextStrokeColor3 = title.StrokeColor
		titleLabel.TextStrokeTransparency = 0
	end

	local uIGradient = titleLabel:FindFirstChildOfClass("UIGradient")

	if typeof(title.TextColor) == "ColorSequence" then
		if uIGradient then
			uIGradient:Destroy()
		end

		local uIGradient2 = Instance.new("UIGradient")
		uIGradient2.Color = title.TextColor
		uIGradient2.Rotation = title.GradientRotation or 45

		if title.Animated then
			uIGradient2:AddTag("AnimatedGradient")
			uIGradient2:SetAttribute("AnimationSpeed", title.AnimationSpeed or 1)
		end

		uIGradient2.Parent = titleLabel
	else
		if uIGradient then
			uIGradient:Destroy()
		end

		titleLabel.TextColor3 = title.TextColor
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCurrentItem()
	if v2 and v3 then
		return v2.Items[v3]
	end

	return nil
end

local function updatePurchaseLabel()
	local currentItem = getCurrentItem() -- equivalent call inferred; original call site unknown

	if not currentItem then
		purchaseLabel.Text = ""
		return
	end

	item.Stock.Text = `x{math.clamp(currentItem.Remaining, 0, 1e999)}`

	if currentItem.Remaining <= 0 then
		purchaseLabel.Text = v2 and v2.ExpiresAt == 1e999 and "Sold out" or "Sold out for this rotation"

		for k, v6 in extraIngredientsByClone do
			k.Stock.Text = `x{DataController.CountItem(v6.Name, v6.SubValues, nil, true)}/{v6.AmountPerCraft}`
		end
	else
		local v6 = currentItem.Price * v4
		purchaseLabel.Text = string.format(
			"I'll give you <font color=\"%s\">%dx</font> for <font color=\"%s\">%s %s</font>",
			"#82c5ff",
			v4,
			`#{LocalCurrencies["Shady Scrip"].Color:ToHex()}`,
			NumberUtils:Comma(v6),
			LocalCurrencies["Shady Scrip"].DisplayName
		)

		if next(extraIngredientsByClone) then
			item.Stock.Text = `x{v4}`
			purchaseLabel.Text = string.format(
				"Fuse items for <font color=\"%s\">%s %s</font> <font color=\"#fff7a1\">(x%d left)</font>",
				`#{LocalCurrencies["Shady Scrip"].Color:ToHex()}`,
				NumberUtils:Comma(v6),
				LocalCurrencies["Shady Scrip"].DisplayName,
				currentItem.Remaining
			)

			for k, v7 in extraIngredientsByClone do
				k.Stock.Text = `x{DataController.CountItem(v7.Name, v7.SubValues, nil, true)}/{v7.AmountPerCraft * v4}`
			end
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setSelectedAmount(p: number)
	local currentItem = getCurrentItem() -- equivalent call inferred; original call site unknown
	local v6 = currentItem and math.max(1, currentItem.Remaining) or 1
	v4 = math.clamp(math.floor(p), 1, v6)
	textBox.Text = `{v4}x`
	updatePurchaseLabel()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showNothing()
	v3 = nil
	maid2:Clean()
	selectedItem.Visible = false
	nothing.Visible = true
end

local function sanitizeAmountText(value: string)
	local v6 = string.match(value, "^(%d+)")

	if not v6 then
		return ""
	end

	if string.sub(value, #v6 + 1, #v6 + 1) == "x" then
		return v6 .. "x"
	end

	return v6
end

local function selectItem(p: string)
	if not (v2 and v2.Items[p]) then
		return
	end

	maid2:Clean()
	v3 = p
	maid2:Add(function()
		table.clear(extraIngredientsByClone)
	end)
	nothing.Visible = false
	selectedItem.Visible = true
	local itemDetails, image, text2 = getItemDetails(p)
	local title = titles[p]
	local titleLabel = item:FindFirstChild("titleLabel")

	if title and titleLabel then
		item.ItemName.Text = "Title"
		item.ImageLabel.Visible = false
		titleLabel.Visible = true
		applyTitleStyle(titleLabel, title)
	else
		item.ItemName.Text = text2
		item.ImageLabel.Visible = true
		item.ImageLabel.Image = image

		if titleLabel then
			titleLabel.Visible = false
		end
	end

	local extraIngredients = itemDetails and itemDetails.ExtraIngredients
	local visible

	if extraIngredients == nil then
		visible = false
	else
		visible = #extraIngredients > 0
	end

	itemContainer.convertIcon.Visible = visible
	local stock = item.Stock
	local textColor

	if visible then
		textColor = Color3.fromRGB(149, 213, 255)
	else
		textColor = Color3.fromRGB(255, 247, 161)
	end

	stock.TextColor3 = textColor

	if extraIngredients then
		for k, extraIngredient in extraIngredients do
			local image2 = FischUtils.GetItemIcon(extraIngredient.Name, extraIngredient.SubValues) or ""
			local itemDisplay = FischUtils.ItemDisplay({
				name = extraIngredient.Name,
				sub = extraIngredient.SubValues
			}, {
				rich = true,
				add_weight = false,
				disable_newlines = false,
				bold_main = true
			})
			local _, v11 = itemDisplay:gsub("\n", "")
			local clone = script.IngredientSample:Clone()
			clone.LayoutOrder = -k
			clone.ImageLabel.Image = image2
			clone.ItemName.Text = itemDisplay
			clone.ItemName.Size = UDim2.fromScale(0.9, 0.15 * (v11 + 1))
			clone.Name = extraIngredient.Name
			clone.Parent = itemContainer
			extraIngredientsByClone[clone] = extraIngredient
			maid2:Add(clone)
		end

		maid2:Add(DataController.InventoryReplicator:Listen({ "Inventory" }, updatePurchaseLabel))
	end

	local currentItem = getCurrentItem() -- equivalent call inferred; original call site unknown
	v4 = math.clamp(1, 1, currentItem and math.max(1, currentItem.Remaining) or 1)
	textBox.Text = `{v4}x`
	updatePurchaseLabel()
	maid2:Add(less.Activated:Connect(function()
		setSelectedAmount(v4 - 1) -- equivalent call inferred; original call site unknown
	end))
	maid2:Add(more.Activated:Connect(function()
		setSelectedAmount(v4 + 1) -- equivalent call inferred; original call site unknown
	end))
	maid2:Add(max.Activated:Connect(function()
		local currentItem2 = getCurrentItem() -- equivalent call inferred; original call site unknown

		if currentItem2 then
			setSelectedAmount(currentItem2.Remaining) -- equivalent call inferred; original call site unknown
		end
	end))
	maid2:Add(textBox.FocusLost:Connect(function()
		setSelectedAmount(tonumber((string.match(textBox.Text, "%d+"))) or 1) -- equivalent call inferred; original call site unknown
	end))
	maid2:Add(textBox:GetPropertyChangedSignal("Text"):Connect(function()
		local text = textBox.Text
		local text3 = string.match(text, "^(%d+)")

		if text3 then
			if string.sub(text, #text3 + 1, #text3 + 1) == "x" then
				text3 ..= "x"
			end
		else
			text3 = ""
		end

		if text3 ~= textBox.Text then
			textBox.Text = text3
		end
	end))
	maid2:Add(button.Activated:Connect(function()
		DealerController:Purchase()
	end))
end

local function rebuildCatalog()
	maid3:Clean()

	for _, guiObject in scrollingFrame:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	if not v2 then
		return
	end

	local v6 = {}

	for k in v2.Items do
		table.insert(v6, k)
	end

	table.sort(v6)

	for _, name in v6 do
		local item2 = v2.Items[name]
		local clone = sample:Clone()
		clone.Name = name
		local itemDetails, image = getItemDetails(name)
		local title = titles[name]
		local titleLabel = clone:FindFirstChild("titleLabel")

		if title and titleLabel then
			local itemName_2 = clone:FindFirstChild("ItemName")
			itemName_2.Text = "Title"
			local imageLabel = clone:FindFirstChild("ImageLabel")
			imageLabel.Visible = false
			titleLabel.Visible = true
			applyTitleStyle(titleLabel, title)
		else
			local itemName = clone:FindFirstChild("ItemName")
			local text

			if itemDetails then
				text = itemDetails.DisplayName or name
			else
				text = name
			end

			itemName.Text = text

			if itemDetails and itemDetails.DisplaySubName then
				clone.SubName.Text = itemDetails.DisplaySubName
				clone.SubName.Visible = true
			end

			local imageLabel_2 = clone:FindFirstChild("ImageLabel")
			imageLabel_2.Visible = true
			local imageLabel_3 = clone:FindFirstChild("ImageLabel")
			imageLabel_3.Image = image

			if titleLabel then
				titleLabel.Visible = false
			end
		end

		local price = clone:FindFirstChild("Price")
		price.TextColor3 = LocalCurrencies["Shady Scrip"].Color
		local price_2 = clone:FindFirstChild("Price")
		price_2.Text = `{NumberUtils:Comma(item2.Price)} {LocalCurrencies["Shady Scrip"].DisplayName}`
		local stock = clone:FindFirstChild("Stock")
		stock.Text = `x{math.clamp(item2.Remaining, 0, 1e999)}`
		clone.Visible = true
		clone.Parent = scrollingFrame
		local v9 = name
		maid3:Add(clone.Activated:Connect(function()
			selectItem(v9)
		end))
	end

	local uIListLayout = scrollingFrame:FindFirstChildOfClass("UIListLayout")
	local uIPadding = scrollingFrame:FindFirstChildOfClass("UIPadding")
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.None

	if uIListLayout then
		if #v6 >= 5 then
			uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
			local Y = scrollingFrame.AbsoluteSize.Y

			if scrollingFrame.HorizontalScrollBarInset == Enum.ScrollBarInset.ScrollBar then
				Y -= scrollingFrame.ScrollBarThickness
			end

			if uIPadding then
				Y -= uIPadding.PaddingTop.Offset + uIPadding.PaddingBottom.Offset
			end

			local scale = uIListLayout.Padding.Scale
			local v7 = uIListLayout.Padding.Offset + scale * scrollingFrame.AbsoluteSize.X
			local v8 = Y * #v6 + v7 * #v6 + v7 * 1.3

			if uIPadding then
				v8 += uIPadding.PaddingLeft.Offset + uIPadding.PaddingRight.Offset
			end

			scrollingFrame.CanvasSize = UDim2.fromOffset(v8, 0)
		else
			uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			scrollingFrame.CanvasSize = UDim2.new()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyState(result)
	v2 = result
	rebuildCatalog()

	if v3 and result and result.Items[v3] then
		local item2 = result.Items[v3]
		setSelectedAmount(math.min(v4, (math.max(1, item2.Remaining)))) -- equivalent call inferred; original call site unknown
	else
		showNothing() -- equivalent call inferred; original call site unknown
	end
end

local function refreshHeader()
	local text = v or "??? Dealer"
	local v7 = not v2 and 0 or v2.ExpiresAt - workspace:GetServerTimeNow()
	header.Label.Text = text

	if v2 and v2.ExpiresAt == 1e999 then
		header.RefreshTime.Text = ""
		return
	end

	local refreshTime = header.RefreshTime
	local v8 = math.max(0, (math.floor(v7)))
	local v9 = math.floor(v8 / 3600)
	local v10 = math.floor(v8 % 3600 / 60)
	local v11 = v8 % 60
	refreshTime.Text = `Refresh: {string.format("%02d:%02d:%02d", v9, v10, v11)}`
end

-- equivalent calls inferred from this helper; original call sites unknown
local function fetchState()
	if not v then
		return
	end

	local success, result = pcall(function()
		return remoteFunction:InvokeServer(v)
	end)

	if success and typeof(result) == "table" then
		applyState(result) -- equivalent call inferred; original call site unknown
	end
end

function DealerController:LoadDealer(p: string)
	maid:Clean()
	v = p
	v2 = nil
	v3 = nil
	fetchState() -- equivalent call inferred; original call site unknown
	local text = v or "??? Dealer"
	local v7 = not v2 and 0 or v2.ExpiresAt - workspace:GetServerTimeNow()
	header.Label.Text = text

	if v2 and v2.ExpiresAt == 1e999 then
		header.RefreshTime.Text = ""
	else
		local refreshTime = header.RefreshTime
		local v8 = math.max(0, (math.floor(v7)))
		local v9 = math.floor(v8 / 3600)
		local v10 = math.floor(v8 % 3600 / 60)
		local v11 = v8 % 60
		refreshTime.Text = `Refresh: {string.format("%02d:%02d:%02d", v9, v10, v11)}`
	end

	local flag = true
	maid:Add(function()
		flag = false
	end)
	task.spawn(function()
		while flag do
			local text2 = v or "??? Dealer"
			local v9 = not v2 and 0 or v2.ExpiresAt - workspace:GetServerTimeNow()
			header.Label.Text = text2

			if v2 and v2.ExpiresAt == 1e999 then
				header.RefreshTime.Text = ""
			else
				local refreshTime = header.RefreshTime
				local v10 = math.max(0, (math.floor(v9)))
				local v11 = math.floor(v10 / 3600)
				local v12 = math.floor(v10 % 3600 / 60)
				local v13 = v10 % 60
				refreshTime.Text = `Refresh: {string.format("%02d:%02d:%02d", v11, v12, v13)}`
			end

			if flag and v2 and v2.ExpiresAt ~= 1e999 and workspace:GetServerTimeNow() >= v2.ExpiresAt then
				v2 = nil
				fetchState() -- equivalent call inferred; original call site unknown
			end

			task.wait(1)
		end
	end)
	container.Parent.Visible = true
end

function DealerController.CloseDealer(_)
	maid:Clean()
	maid2:Clean()
	maid3:Clean()
	v = nil
	v2 = nil
	v3 = nil
	container.Parent.Visible = false
end

function DealerController:Purchase()
	if not (v and v3) then
		return
	end

	local v6 = v
	local v7 = v3
	local v8 = v4
	task.spawn(function()
		local success, result = pcall(function()
			return remoteFunction2:InvokeServer(v6, v7, v8)
		end)

		if not success or typeof(result) ~= "table" or v ~= v6 then
			return
		end

		applyState(result) -- equivalent call inferred; original call site unknown
	end)
end

function DealerController.Start(_)
	selectedItem.Visible = false
	nothing.Visible = true
	remoteEvent.OnClientEvent:Connect(function(p: string)
		DealerController:LoadDealer(p)
	end)
end

return DealerController