local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local FurnitureController = require(ReplicatedStorage.client.legacyControllers.FurnitureController)
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local fx = require(ReplicatedStorage.shared.modules.fx)
local personalAquariumFurniture = require(ReplicatedStorage.shared.modules.library.personalAquariumFurniture)
local SharedPlacement = require(ReplicatedStorage.shared.modules.SharedPersonalAquarium.SharedPlacement)
local CustomColorPicker = require(ReplicatedStorage.shared.modules.CustomColorPicker)
local Trove = require(ReplicatedStorage.packages.Trove)
local localPlayer = Players.LocalPlayer
local safeZone = HudController:GetSafeZone()
local personalAquariumCustomization = safeZone:WaitForChild("personalAquariumCustomization")
local actionPanel = personalAquariumCustomization:WaitForChild("actionPanel")
local placeRemove = actionPanel:WaitForChild("Action"):WaitForChild("Place/Remove")
local label = placeRemove:WaitForChild("Label")
local actions = actionPanel:WaitForChild("Actions")
local virtualCursor = personalAquariumCustomization:WaitForChild("virtualCursor")
local condition = virtualCursor:WaitForChild("Condition")

local function resolveButton(instance, childName: string)
	local button = instance:WaitForChild(childName)

	if button:IsA("GuiButton") then
		return button
	end

	local guiButton = button:FindFirstChildWhichIsA("GuiButton")

	if guiButton then
		return guiButton
	end

	error((`[PersonalAquariumCustomization] No GuiButton found for "{childName}".`))
end

local select = actions:WaitForChild("Select")

if not select:IsA("GuiButton") then
	select = select:FindFirstChildWhichIsA("GuiButton")

	if not select then
		error("[PersonalAquariumCustomization] No GuiButton found for \"Select\".")
		select = nil
	end
end

local move = actions:WaitForChild("Move")

if not move:IsA("GuiButton") then
	move = move:FindFirstChildWhichIsA("GuiButton")

	if not move then
		error("[PersonalAquariumCustomization] No GuiButton found for \"Move\".")
		move = nil
	end
end

local rotate = actions:WaitForChild("Rotate")

if not rotate:IsA("GuiButton") then
	rotate = rotate:FindFirstChildWhichIsA("GuiButton")

	if not rotate then
		error("[PersonalAquariumCustomization] No GuiButton found for \"Rotate\".")
		rotate = nil
	end
end

local color = personalAquariumCustomization:WaitForChild("color")
local furniturePanel = personalAquariumCustomization:WaitForChild("furniturePanel")
local scrollingFrame = furniturePanel:WaitForChild("ScrollingFrame")
local furniture = scrollingFrame:WaitForChild("Furniture")
local textBox = furniturePanel:WaitForChild("Search"):WaitForChild("TextBox")
local ui = ReplicatedStorage.resources.sounds.sfx.ui
local anno_localthought = ReplicatedStorage.events.anno_localthought
local color2 = Color3.fromRGB(162, 234, 166)
local color3 = Color3.fromRGB(255, 255, 255)
local color4 = Color3.fromRGB(162, 234, 166)
local color5 = Color3.fromRGB(255, 255, 255)
local v = {
	"StatChangeList",
	"coins",
	"keeperLevel",
	"lvl",
	"statuses"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function setBackpackEnabled(enabled: boolean)
	local backpack = localPlayer:WaitForChild("PlayerGui"):FindFirstChild("backpack")

	if backpack and backpack:IsA("ScreenGui") then
		backpack.Enabled = enabled
	end
end

local visibilityByGuiObject = {}

local function setHudElementsHidden(visible: boolean)
	if visible then
		table.clear(visibilityByGuiObject)

		for _, childName in ipairs(v) do
			local guiObject = safeZone:FindFirstChild(childName)

			if not (guiObject and guiObject:IsA("GuiObject")) then
				continue
			end

			visibilityByGuiObject[guiObject] = guiObject.Visible
			guiObject.Visible = false
		end
	else
		for k, visible2 in pairs(visibilityByGuiObject) do
			if k and k.Parent then
				k.Visible = visible2
			end
		end

		table.clear(visibilityByGuiObject)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updatePlaceRemoveLabel()
	local v2

	if FurnitureController.CurrentMode == "Idle" then
		v2 = FurnitureController.SelectedUid ~= nil
	else
		v2 = false
	end

	placeRemove.Visible = FurnitureController.CurrentMode == "Placing" or v2

	if v2 then
		label.Text = "Remove"
	else
		label.Text = "Place"
	end
end

local function applyToolTint(instance, flag: boolean)
	local v2

	if flag then
		v2 = color2
	else
		v2 = color3
	end

	local itemIcon = instance:FindFirstChild("itemIcon")

	if itemIcon and itemIcon:IsA("ImageLabel") then
		itemIcon.ImageColor3 = v2
	end

	local itemName = instance:FindFirstChild("itemName")

	if itemName and itemName:IsA("TextLabel") then
		itemName.TextColor3 = v2
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateToolHighlight()
	applyToolTint(select, FurnitureController.CurrentTool == "Select")
	applyToolTint(move, FurnitureController.CurrentTool == "Move")
	applyToolTint(rotate, FurnitureController.CurrentTool == "Rotate")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function connectButtonSounds(p)
	p.MouseEnter:Connect(function()
		fx:PlaySound(ui.select, p, false)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isOnGamepad()
	return UserInputService.GamepadEnabled and UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateCursorIndicator()
	virtualCursor.Visible = isOnGamepad() and FurnitureController.IsEditing

	if FurnitureController.IsCursorOn then
		condition.Text = "Virtual Cursor: Enabled"
		condition.TextColor3 = color4
	else
		condition.Text = "Virtual Cursor: Disabled"
		condition.TextColor3 = color5
	end
end

local clonesByName = {}
local maid = Trove.new()

local function getTotalPlacedCount()
	local v2 = DataController.PlayerDataReplicator:TryIndex({ "PersonalAquarium", "PlacedFurniture" }) or {}
	local count = 0

	for _, v3 in pairs(v2) do
		if typeof(v3) == "table" then
			count += 1
		end
	end

	return count
end

local function getAvailableCount(p: string)
	local playerDataReplicator = DataController.PlayerDataReplicator
	local v2 = playerDataReplicator:TryIndex({ "PersonalAquarium", "OwnedFurniture", p }) or 0
	local v3 = playerDataReplicator:TryIndex({ "PersonalAquarium", "PlacedFurniture" }) or {}
	local count = 0

	for _, v4 in pairs(v3) do
		if typeof(v4) == "table" and v4.f == p then
			count += 1
		end
	end

	return (math.max(0, v2 - count))
end

local function matchesSearch(value: string)
	local v2 = textBox.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")

	if v2 == "" then
		return true
	end

	local v3 = personalAquariumFurniture[value]
	local v4

	if v3 then
		v4 = v3.DisplayName or value
	else
		v4 = value
	end

	return v4:lower():find(v2, 1, true) ~= nil or value:lower():find(v2, 1, true) ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateTileAmount(p: string)
	local v2 = clonesByName[p]

	if not v2 then
		return
	end

	local availableCount = getAvailableCount(p)
	v2.itemAmount.Text = `x{availableCount}`
	v2.Visible = availableCount > 0 and matchesSearch(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateFurnitureSearch()
	for k in pairs(clonesByName) do
		updateTileAmount(k) -- equivalent call inferred; original call site unknown
	end
end

local function createFurnitureTile(name: string)
	if clonesByName[name] then
		updateTileAmount(name) -- equivalent call inferred; original call site unknown
	else
		local v2 = personalAquariumFurniture[name]

		if not v2 then
			return
		end

		local clone = furniture:Clone()
		clone.Name = name
		clone.Visible = true
		clone.itemName.Text = v2.DisplayName
		clone.itemIcon.Image = v2.Icon
		maid:Add(clone.MouseEnter:Connect(function()
			fx:PlaySound(ui.select, clone, false)
		end))
		maid:Add(clone.Activated:Connect(function()
			if getAvailableCount(name) <= 0 then
				return
			end

			if getTotalPlacedCount() >= SharedPlacement.MAX_PLACED_FURNITURE then
				anno_localthought:Fire("You've reached the furniture limit.")
				return
			end

			fx:PlaySound(ui.click2, clone, false)
			FurnitureController.StartPlacing(name)
		end))
		clone.Parent = scrollingFrame
		clonesByName[name] = clone
		updateTileAmount(name) -- equivalent call inferred; original call site unknown
	end
end

local function refreshAllTileAmounts()
	updateFurnitureSearch() -- equivalent call inferred; original call site unknown
end

local function loadFurniturePanel()
	furniture:IsA("GuiButton")
	local playerDataReplicator = DataController.PlayerDataReplicator
	playerDataReplicator:WaitForLoaded()
	local v2 = playerDataReplicator:TryIndex({ "PersonalAquarium", "OwnedFurniture" }) or {}
	local v3 = {}

	for k in pairs(v2) do
		table.insert(v3, k)
	end

	table.sort(v3)

	for i, v4 in ipairs(v3) do
		createFurnitureTile(v4)
		local v5 = clonesByName[v4]

		if v5 then
			v5.LayoutOrder = i
		end
	end

	maid:Add(playerDataReplicator:ObserveKeys({ "PersonalAquarium", "OwnedFurniture" }, function(name, p2)
		if p2 then
			createFurnitureTile(name)
		end

		updateFurnitureSearch() -- equivalent call inferred; original call site unknown
	end))
	maid:Add(playerDataReplicator:Observe({ "PersonalAquarium", "PlacedFurniture" }, function()
		updateFurnitureSearch() -- equivalent call inferred; original call site unknown
		local placeFurnitureId = FurnitureController.PlaceFurnitureId

		if FurnitureController.CurrentMode == "Placing" and placeFurnitureId and (getAvailableCount(placeFurnitureId) <= 0 or getTotalPlacedCount() >= SharedPlacement.MAX_PLACED_FURNITURE) then
			FurnitureController.CancelPlacing()
		end
	end))
	maid:Add(textBox:GetPropertyChangedSignal("Text"):Connect(function()
		updateFurnitureSearch() -- equivalent call inferred; original call site unknown
	end))
	updateFurnitureSearch() -- equivalent call inferred; original call site unknown
end

local function unloadFurniturePanel()
	maid:Clean()

	for _, v2 in pairs(clonesByName) do
		v2:Destroy()
	end

	clonesByName = {}
end

local v2 = nil
local flag = false
local v3 = nil
local selectedUid = nil
local now = 0
local color6 = Color3.fromRGB(255, 255, 255)

local function getSelectedEntry()
	local selectedUid2 = FurnitureController.SelectedUid

	if not selectedUid2 then
		return nil
	end

	local v4 = DataController.PlayerDataReplicator:TryIndex({ "PersonalAquarium", "PlacedFurniture" }) or {}

	for _, v5 in pairs(v4) do
		if typeof(v5) == "table" and v5.u == selectedUid2 then
			return v5
		end
	end

	return nil
end

local function isSelectionRecolorable()
	local selectedEntry = getSelectedEntry()

	if not selectedEntry then
		return false
	end

	local v4 = personalAquariumFurniture[selectedEntry.f]
	return v4 ~= nil and v4.Recolorable
end

-- equivalent calls inferred from this helper; original call sites unknown
local function commitColor(color7: Color3, p: string)
	now = os.clock()
	FurnitureController.RecolorUid(
		p,
		math.round(color7.R * 255),
		math.round(color7.G * 255),
		(math.round(color7.B * 255))
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function flushPendingColor()
	local v4 = v3
	local v5 = selectedUid
	v3 = nil

	if v4 and v5 then
		commitColor(v4, v5) -- equivalent call inferred; original call site unknown
	end
end

local function onPickerChanged(color7: Color3)
	local selectedEntry = getSelectedEntry()
	local recolorable

	if selectedEntry then
		local v4 = personalAquariumFurniture[selectedEntry.f]

		if v4 == nil then
			recolorable = false
		else
			recolorable = v4.Recolorable
		end
	else
		recolorable = false
	end

	if not recolorable then
		return
	end

	v3 = color7
	selectedUid = FurnitureController.SelectedUid

	if os.clock() - now >= 0.25 then
		flushPendingColor() -- equivalent call inferred; original call site unknown
	else
		if flag then
			return
		end

		flag = true
		task.delay(0.25, function()
			flag = false
			flushPendingColor() -- equivalent call inferred; original call site unknown
		end)
	end
end

local function updateColorFrame()
	if v3 and selectedUid ~= FurnitureController.SelectedUid then
		flushPendingColor() -- equivalent call inferred; original call site unknown
	end

	local selectedEntry = getSelectedEntry()
	local recolorable

	if selectedEntry then
		local v4 = personalAquariumFurniture[selectedEntry.f]

		if v4 == nil then
			recolorable = false
		else
			recolorable = v4.Recolorable
		end
	else
		recolorable = false
	end

	color.Visible = recolorable

	if not recolorable then
		return
	end

	local selectedEntry2 = getSelectedEntry()
	local c = selectedEntry2 and selectedEntry2.c

	if typeof(c) == "table" and #c == 3 then
		v2:LoadColor(Color3.fromRGB(c[1], c[2], c[3]))
	else
		v2:LoadColor(color6)
	end
end

return {
	init = function()
		personalAquariumCustomization.Visible = false
		furniture.Visible = false
		FurnitureController.EditModeChanged:Connect(function(visible: boolean)
			personalAquariumCustomization.Visible = visible
			setBackpackEnabled(not visible) -- equivalent call inferred; original call site unknown
			setHudElementsHidden(visible)
			updateCursorIndicator() -- equivalent call inferred; original call site unknown

			if visible then
				task.spawn(loadFurniturePanel)
			else
				unloadFurniturePanel()
			end
		end)
		FurnitureController.CursorModeChanged:Connect(function()
			updateCursorIndicator() -- equivalent call inferred; original call site unknown
		end)
		UserInputService.LastInputTypeChanged:Connect(updateCursorIndicator)
		updateCursorIndicator() -- equivalent call inferred; original call site unknown
		FurnitureController.ModeChanged:Connect(updatePlaceRemoveLabel)
		FurnitureController.SelectionChanged:Connect(updatePlaceRemoveLabel)
		updatePlaceRemoveLabel() -- equivalent call inferred; original call site unknown
		FurnitureController.ToolChanged:Connect(updateToolHighlight)
		updateToolHighlight() -- equivalent call inferred; original call site unknown
		v2 = CustomColorPicker.new(color, onPickerChanged)
		color.Visible = false
		FurnitureController.SelectionChanged:Connect(updateColorFrame)
		FurnitureController.ModeChanged:Connect(updateColorFrame)
		local reset = color:WaitForChild("Reset")

		if not reset:IsA("GuiButton") then
			reset = reset:FindFirstChildWhichIsA("GuiButton")

			if not reset then
				error("[PersonalAquariumCustomization] No GuiButton found for \"Reset\".")
				reset = nil
			end
		end

		connectButtonSounds(reset) -- equivalent call inferred; original call site unknown
		reset.Activated:Connect(function()
			local selectedEntry = getSelectedEntry()
			local recolorable

			if selectedEntry then
				local v4 = personalAquariumFurniture[selectedEntry.f]

				if v4 == nil then
					recolorable = false
				else
					recolorable = v4.Recolorable
				end
			else
				recolorable = false
			end

			if not recolorable then
				return
			end

			fx:PlaySound(ui.click2, reset, false)
			v3 = nil
			selectedUid = nil
			FurnitureController.ResetColor()
			v2:LoadColor(color6)
		end)
		connectButtonSounds(placeRemove) -- equivalent call inferred; original call site unknown
		connectButtonSounds(select) -- equivalent call inferred; original call site unknown
		connectButtonSounds(move) -- equivalent call inferred; original call site unknown
		connectButtonSounds(rotate) -- equivalent call inferred; original call site unknown
		placeRemove.Activated:Connect(function()
			fx:PlaySound(ui.click2, placeRemove, false)

			if FurnitureController.CurrentMode == "Idle" and FurnitureController.SelectedUid then
				FurnitureController.RemoveSelected()
			else
				FurnitureController.ConfirmGhost()
			end
		end)
		select.Activated:Connect(function()
			fx:PlaySound(ui.click2, select, false)
			FurnitureController.CancelPlacing()
			FurnitureController.SetTool("Select")
		end)
		move.Activated:Connect(function()
			fx:PlaySound(ui.click2, move, false)
			FurnitureController.SetTool("Move")
		end)
		rotate.Activated:Connect(function()
			fx:PlaySound(ui.click2, rotate, false)
			FurnitureController.SetTool("Rotate")
		end)
	end
}