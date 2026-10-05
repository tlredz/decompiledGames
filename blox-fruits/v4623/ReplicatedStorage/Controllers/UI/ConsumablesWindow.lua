local ConsumablesWindow = {}
local localPlayer = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local Potions = require(game.ReplicatedStorage.Modules.Consumables.Potions)
local Food = require(game.ReplicatedStorage.Modules.Consumables.Food)
local ImageUtil = require(game.ReplicatedStorage.Modules.Asset.ImageUtil)
local RarityUtil = require(game.ReplicatedStorage:WaitForChild("Modules").Asset.RarityUtil)
local Debounce = require(game.ReplicatedStorage.Modules.Util.Debounce)
local private = Debounce.private()
local HUD = require(game.ReplicatedStorage.Controllers.UI.HUD)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local Net = require(game.ReplicatedStorage.Modules.Net)
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
require(game.ReplicatedStorage.Modules.Util.ColorUtil)
local ClientSignals = require(game.ReplicatedStorage.ClientSignals)
local inventoryItemUpdated = ClientSignals.InventoryItemUpdated()
local remoteFunction = Net:RemoteFunction("ConsumablesNetworkRF")
local AssetComponent = require(game.ReplicatedStorage.Modules.Create.AssetComponent)

local function fn(...) end

local v = nil
local maid = nil
local v2 = nil
local v3 = nil
local consumablesUI = nil
local consumables = nil
local left = nil
local right = nil
local scrollingFrame = nil
local uIGridLayout = nil
local v4 = nil
local v5 = {}
local v6 = {}
local v7 = {}
local v8 = false
local flag = false
local v9 = nil
local v10 = nil
local v11 = {
	AnchorPoint = Vector2.new(0.65, 0.5),
	Position = UDim2.fromScale(0.5, 0.475)
}
local v12 = {
	AnchorPoint = Vector2.new(0.65, 0.5),
	Position = UDim2.fromScale(0.5, 1.6)
}
local v13 = {
	Potion = true,
	Food = true
}

local function isConsumable(p: string)
	return v13[p]
end

local function getmaxitems()
	if v8 then
		return 9
	end

	return 16
end

function tweenFrame(object)
	if v3 then
		v3:Cancel()
		v3 = nil
	end

	object:Play()
	object.Completed:Connect(function(p)
		if p == Enum.PlaybackState.Completed then
			v3 = nil

			if LastInput:Get() == "Gamepad" then
				local GuiService = game:GetService("GuiService")
				GuiService.SelectedObject = scrollingFrame
			end
		end
	end)
	v3 = object
	return object
end

local function updateTooltip()
	if v2 then
		v2:Destroy()
	end

	local v14 = v10

	if not v14 then
		left.Visible = false
		return
	end

	if not maid then
		return
	end

	ImageUtil.applySpriteFromItemId(v14.details.Name, {
		"Material",
		"Fish",
		"Bait",
		"Scroll",
		"Tool",
		"Consumable"
	}, left.Frame)
	local v15 = assert(RarityUtil.tryGetRarity(v14.details.Rarity), (`bad rarity for "{v14.details.Rarity}"`))
	local color = v15.Color
	local v16

	if v14.details.Type == "Potion" then
		v16 = Potions.Potions[v14.details.Name] or nil
	end

	local v17

	if v14.details.Type == "Food" then
		v17 = Food.Food[v14.details.Name] or nil
	end

	assert(v16 or v17, (`Unknown consumable: {v14.details.Name}`))
	local name = v15.Name
	local v18 = nil

	if v16 and v16.Description then
		v18 = v16.Description({
			Level = localPlayer.Data.Level.Value
		})
	elseif v17 and v17.Description then
		v18 = v17.Description({
			Level = localPlayer.Data.Level.Value
		})
	end

	left.ItemDescription.Text = v18 or ""
	left.ItemName.Text = v14.DisplayName
	left.ItemRarity.Text = name
	left.ItemRarity.TextColor3 = color

	if v15.Outline then
		left.ItemRarity.TextStrokeColor3 = v15.Color:Lerp(Color3.new(0, 0, 0), 0.2)
	else
		left.ItemRarity.TextStrokeColor3 = Color3.new(0, 0, 0)
	end

	local TextButtonComponent = require(game.ReplicatedStorage.Modules.Create.TextButtonComponent)
	local textButtonComponent = TextButtonComponent(left.Selector.Equip)
	v2 = maid:Extend()
	assert(v2, "bad toolTipMaid"):Add(function()
		v2 = nil
		textButtonComponent:Destroy()
	end)
	textButtonComponent:UpdateProperties({
		Visible = true,
		Appearance = private.is("Any") and "Inactive" or "Active",
		TextLabel = {
			Text = "Unstore"
		}
	})
	left.Visible = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function selectEntry(p)
	for _, v14 in pairs(v4) do
		v14.Selected = false
	end

	v10 = p

	if v10 then
		v10.Selected = true
	end

	updateTooltip()
	updateRender()
end

local thread = nil

function updateSort(flag2: boolean?)
	if thread then
		task.cancel(thread)
		thread = nil
	end

	local function update()
		local count = 0

		for _, v14 in pairs(v4) do
			if v13[v14.details.Type] and v14.InSearch and v14.Visible then
				count += 1
			end
		end

		table.sort(v4, function(a, b)
			if a.InSearch and not b.InSearch then
				return true
			end

			if not a.InSearch then
				return false
			end

			if a.Visible and not b.Visible then
				return true
			end

			if not a.Visible then
				return false
			end

			local rarity = a.details.Rarity
			local rarity2 = b.details.Rarity

			if rarity == rarity2 then
				return #a.DisplayName < #b.DisplayName
			end

			return rarity < rarity2
		end)
		local Y = uIGridLayout.AbsoluteCellSize.Y
		local offset = uIGridLayout.Parent.UIPadding.PaddingTop.Offset
		local offset2 = uIGridLayout.CellPadding.Y.Offset
		local v14 = math.max(math.ceil(count / (v8 and 3 or 4)), 2)
		right.Content.ScrollingFrame.CanvasSize = UDim2.fromOffset(0, v14 * (Y + offset2) + offset / 2)
		updateRender()
	end

	if flag2 then
		update()
	else
		thread = task.delay(0.05, function()
			thread = nil

			if not maid then
				return
			end

			update()
		end)
	end
end

function updateRender(flag2: boolean?)
	local v14 = v8 and 9 or 16
	local Y = uIGridLayout.AbsoluteCellSize.Y
	local offset = uIGridLayout.CellPadding.Y.Offset
	local v15 = math.ceil((scrollingFrame.CanvasPosition.Y + offset) / (Y + offset))

	for i = 1, v14 do
		local v16 = v7[i]

		if not v16 then
			continue
		end

		local component = v16.Component
		local instance = component._Rbx.instance
		local filled = instance.Filled
		local blank = instance.Blank
		local v17 = math.sqrt(v14) * (v15 - 1) + i
		filled.TextButton.NextSelectionLeft = nil
		instance:SetAttribute("CurrentItem", v17)
		local v18 = v4[v17]

		if v18 and v18.InSearch and v18.Visible then
			if i % math.sqrt(v14) == 1 then
				filled.TextButton.NextSelectionLeft = left.Selector.Equip
			end

			if not flag2 or not component._AssetInfo or component._AssetInfo.StorageName ~= v18.details.Name then
				v16.StorageName = v18.details.Name
				v16.Type = v18.details.Type
				component:UpdateAsset({
					StorageName = v18.details.Name,
					DisplayName = v18.DisplayName,
					Type = "Potion",
					Rarity = v18.details.Rarity,
					Count = v18.details.Count,
					IsNew = v6[v18.details.Name] ~= nil and 1 or false,
					Selected = v18.Selected == true
				})
				filled.Visible = true
				blank.Visible = false
			end
		else
			v16.StorageName = nil
			v16.Type = nil
			filled.Visible = false
			blank.Visible = true
			component:UpdateAsset(nil)
		end
	end

	scrollingFrame.Frame.Position = UDim2.fromOffset(0, (v15 - 1) * (Y + offset))
	local v16 = scrollingFrame.CanvasSize.Y.Offset - scrollingFrame.CanvasPosition.Y - scrollingFrame.AbsoluteSize.Y
	local Y2 = scrollingFrame.CanvasPosition.Y
	local background = right.Content.Background
	local Y3 = background.FadeTop.AbsoluteSize.Y
	background.FadeTop.Position = UDim2.fromOffset(0, (math.min(-Y3 + Y2, 0)))
	background.FadeBottom.Position = UDim2.new(0, 0, 1, math.min(-Y3 + v16, 0) * -1)
end

function findItem(p: string, p2: string)
	assert(p, "bad name")
	assert(p2, "bad itemType")

	for _, v14 in pairs(v4) do
		if v14.details.Type == p2 and p == v14.details.Name then
			return v14
		end
	end

	return nil
end

local function _itemData(p, p2)
	assert(
		p.details.Type == "Food" or p.details.Type == "Potion",
		(`incompatible fromItem.details.Type: "{p.details.Type}"`)
	)
	local v14 = {
		details = {
			Name = assert(p.details.Name, "bad fromItem.details.Name"),
			Type = p.details.Type,
			Rarity = p.details.Rarity,
			Count = p.details.Count or 0
		},
		DisplayName = p.DisplayName or p.details.Name,
		Selected = 0,
		InSearch = 0,
		Visible = true
	}
	local selected

	if p2 then
		selected = p2.Selected
	else
		selected = false
	end

	v14.Selected = selected
	local inSearch

	if p2 then
		inSearch = p2.InSearch
	else
		inSearch = false
	end

	v14.InSearch = inSearch
	return v14
end

local function updateItem(p, flag2: boolean?)
	local v14

	if v13[p.details.Type] and v9 == "Food" and p.details.Type == "Food" then
		v14 = true
	elseif v9 == "Potion" then
		v14 = p.details.Type == "Potion"
	else
		v14 = false
	end

	if not v14 then
		return
	end

	local v15 = nil

	for i = #v4, 1, -1 do
		if v4[i].details.Name ~= p.details.Name then
			continue
		end

		v15 = v4[i]
		table.remove(v4, i)
		break
	end

	if p.details.Count > 0 then
		if v15 then
			fn((`Update: {p.details.Name}`))
		else
			fn((`First: {p.details.Name}`))
		end

		fn("item.details.Count", p.details.Count)
		v15 = _itemData(p, v15)
		assert(v15, "item not found")
		table.insert(v4, v15)
	elseif v15 then
		v6[p.details.Name] = nil

		if v10 and p.details.Name == v10.details.Name then
			selectEntry(nil) -- equivalent call inferred; original call site unknown
		end

		fn((`Removed: {p.details.Name}`))
	else
		fn((`idk : {p.details.Name}`))
	end

	if not flag2 then
		updateSort()
	end

	return v15
end

local function getInventory()
	v4 = {}
	updateSort()
	return v4
end

function ConsumablesWindow:Open(message)
	v8 = LastInput:Get() == "Touch"
	assert(message.SelectedCategory, "bad openInfo.SelectedCategory")
	assert(
		message.SelectedCategory == "Food" or assert(message.SelectedCategory == "Potion"),
		(`incompatible openInfo.SelectedCategory "{message.SelectedCategory}"`)
	)
	local selectedCategory = message.SelectedCategory

	if v9 == selectedCategory and flag then
		return
	end

	local Global = require(game.ReplicatedStorage.Global)
	Global.closeOthers("Consumables")

	if flag then
		ConsumablesWindow:Close(true)
	end

	v9 = selectedCategory
	flag = true
	v4 = {}
	updateSort()
	maid = Trove.new()
	assert(maid, "bad screenMaid"):Add(function()
		flag = false
		private.clear()
		v9 = nil
		v10 = nil
		selectEntry(nil) -- equivalent call inferred; original call site unknown
		table.clear(v6)
		table.clear(v7)
	end)
	maid:Add(right.Exit.Activated:Connect(function()
		ConsumablesWindow:Close()
	end))

	if message.SelectedCategory == "Food" then
		right.Title.TextLabel.Text = "Food"
	elseif message.SelectedCategory == "Potion" then
		right.Title.TextLabel.Text = "Potions"
	else
		error(message)
	end

	for i = 1, v8 and 9 or 16 do
		local v14 = v5[i]

		if not v14 then
			local Create = require(game.ReplicatedStorage.Modules.Create)
			v14 = Create.Template("AssetComponentTemplate")
		end

		v14:FindFirstChild("Filled")
		local v15 = v5[i] ~= nil
		v5[i] = v14
		v14.Visible = true
		v14.LayoutOrder = i
		v14.Parent = scrollingFrame.Frame
		local component = maid:Add(AssetComponent(v14))
		component:EnableHoverHighlight(true)
		component:EnableAutoShine(true)

		if not v15 then
			local v17 = v14
			assert(v14:FindFirstChild("TextButton", true), "bad textButton").Activated:Connect(function()
				if private.is("Any") then
					return
				end

				local v18 = nil

				for k, v20 in pairs(v7) do
					if v20.Component._Rbx.instance ~= v17 then
						continue
					end

					v18 = v20
					break
				end

				assert(v18, "bad tile")
				assert(v18.StorageName, "bad tile.StorageName")
				assert(v18.Type, "bad tile.Type")
				local item = findItem(v18.StorageName, v18.Type)

				if not item then
					warn("No entry", v18)
					return
				end

				v6[item.details.Name] = nil

				if item.Selected then
					for k, v20 in pairs(v4) do
						v20.Selected = false
					end

					v10 = nil
				else
					for k, v20 in pairs(v4) do
						v20.Selected = false
					end

					v10 = item
				end

				if v10 then
					v10.Selected = true
				end

				updateTooltip()
				updateRender()
			end)
		end

		table.insert(v7, {
			Component = component,
			Rbx = component._Rbx.instance,
			StorageName = nil,
			Type = nil
		})
	end

	uIGridLayout.CellPadding = UDim2.new(0, v8 and 8 or 4, 0, 8)
	uIGridLayout.CellSize = UDim2.new(1 / (v8 and 3 or 4), -uIGridLayout.CellPadding.X.Offset, 1 / (v8 and 3 or 4), 0)

	if message.NoTween then
		consumables.Position = v11.Position
		consumables.AnchorPoint = v11.AnchorPoint
	else
		tweenFrame(TweenService:Create(consumables, TweenInfo.new(0.3), v11))
	end

	local textBox = consumables.Right.Content.Search.TextBox
	maid:Add(textBox:GetPropertyChangedSignal("Text"):Connect(function()
		local text = textBox.Text:lower()

		for _, v14 in pairs(v4) do
			local displayName = v14.DisplayName:lower()

			if displayName and displayName:match(text) then
				v14.InSearch = true
			else
				v14.InSearch = false
			end
		end

		right.Content.ScrollingFrame.CanvasPosition = Vector2.new(0, 0)
		updateSort()
	end))
	maid:Add(left.Selector.Equip.Activated:Connect(function()
		if not v10 then
			return
		end

		private.try("Any", function()
			updateTooltip()
			return remoteFunction:InvokeServer({
				Context = "UnstoreConsumable",
				StorageName = v10.details.Name
			})
		end, function(value)
			if value == true then
				updateTooltip()
			elseif typeof(value) == "string" then
				v.new("<Color=Red>Please wait.<Color=/>"):Display()
			end
		end)
	end))
	maid:Add(right.Content.Return.Activated:Connect(function()
		local Global2 = require(game.ReplicatedStorage.Global)
		Global2.openMenu("Items")
	end))
	maid:Add(scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		updateSort()
	end))
	local _ = scrollingFrame.CanvasPosition.Y
	local v14 = 1e999
	maid:Add(scrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		local Y = scrollingFrame.CanvasPosition.Y

		if math.abs(v14 - Y) <= uIGridLayout.AbsoluteCellSize.Y * 0.15 then
			return
		end

		v14 = Y
		updateRender(true)
	end))
	local maid2 = maid
	local GuiService = game:GetService("GuiService")
	maid2:Add(GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
		local GuiService2 = game:GetService("GuiService")
		local selectedObject = GuiService2.SelectedObject

		if not (selectedObject and selectedObject:IsDescendantOf(scrollingFrame.Frame)) then
			return
		end

		local parent = selectedObject:FindFirstAncestor("Filled").Parent
		local v15 = v8 and 9 or 16
		local Y = uIGridLayout.AbsoluteCellSize.Y
		local offset = uIGridLayout.CellPadding.Y.Offset
		local currentItem = parent:GetAttribute("CurrentItem")
		local v16 = math.floor((currentItem - 1) / math.sqrt(v15))
		scrollingFrame.CanvasPosition = Vector2.new(0, v16 * (Y + offset) - (Y + offset) * 0.5 + 3)

		for _, v17 in pairs(v7) do
			if v17.Component._Rbx.instance:GetAttribute("CurrentItem") ~= currentItem then
				continue
			end

			local GuiService3 = game:GetService("GuiService")
			GuiService3.SelectedObject = v17.Component._Rbx.instance.Filled.TextButton
			break
		end
	end))

	local function controllerAction(_: string, p, p2)
		if p ~= Enum.UserInputState.End or p2.UserInputType ~= Enum.UserInputType.Gamepad1 then
			return Enum.ContextActionResult.Pass
		end

		local GuiService2 = game:GetService("GuiService")
		GuiService2.SelectedObject = scrollingFrame
		return Enum.ContextActionResult.Sink
	end

	game.ContextActionService:BindActionAtPriority(
		"ConsumablesWindowEscape",
		controllerAction,
		false,
		3,
		Enum.KeyCode.ButtonB
	)
	maid:Add(function()
		game.ContextActionService:UnbindAction("ConsumablesWindowEscape")
	end)
	updateSort(true)
end

function ConsumablesWindow:Close(flag2: boolean?)
	if not flag then
		return
	end

	if maid then
		maid:Destroy()
		maid = nil
	end

	if not flag2 then
		tweenFrame(TweenService:Create(consumables, TweenInfo.new(0.3), v12))
	end
end

function ConsumablesWindow:IsOpen()
	return flag == true
end

function ConsumablesWindow:OnStart()
	consumablesUI = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Popups"):WaitForChild("ConsumablesUI")
	consumables = consumablesUI.Consumables
	left = consumables.Left
	right = consumables.Right
	scrollingFrame = right.Content.ScrollingFrame
	uIGridLayout = scrollingFrame.Frame.UIGridLayout
	consumables.Position = v12.Position
	consumables.AnchorPoint = v12.AnchorPoint
	consumables.Visible = true
	local v14 = {
		ItemAdded = true,
		ItemRemoved = true
	}
	inventoryItemUpdated:Connect(function(p, p2)
		if not v14[p] then
			return
		end

		if v13[p2.details.Type] then
			if p == "ItemAdded" then
				v6[p2.details.Name] = true
			end

			if ConsumablesWindow:IsOpen() then
				updateItem(p2)
			end
		end
	end)
	local Notification = require(game.ReplicatedStorage.Notification)
	v = Notification
	task.spawn(function()
		while not HUD.IsInitialized do
			task.wait()
		end

		assert(HUD.IsInitialized, "bad HUD")
		HUD:RegisterPage("Consumables", function(...)
			return self:Open(...)
		end, function(...)
			return self:Close(...)
		end, function()
			return flag
		end)
	end)
end

return ConsumablesWindow