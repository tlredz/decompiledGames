game:GetService("LocalizationService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
game:GetService("LocalizationService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local script2 = script
local TopbarPlusReference = require(script2.TopbarPlusReference)
local object = TopbarPlusReference.getObject()
local value = object and object.Value

if value and value ~= script2 then
	return require(value)
end

if not object then
	TopbarPlusReference.addToReplicatedStorage()
end

local NewIcon = {}
NewIcon.__index = NewIcon
local IconController = require(script2.IconController)
local Signal = require(script2.Signal)
local Maid = require(script2.Maid)
local TopbarPlusGui = require(script2.TopbarPlusGui)
local Themes = require(script2.Themes)
local activeItems = TopbarPlusGui.ActiveItems
local topbarContainer = TopbarPlusGui.TopbarContainer
local iconContainer = topbarContainer.IconContainer
local default = Themes.Default
local v2 = {}

function NewIcon.new()
	local class = {}
	setmetatable(class, NewIcon)
	local maid = Maid.new()
	class._maid = maid
	class._hoveringMaid = maid:give(Maid.new())
	class._dropdownClippingMaid = maid:give(Maid.new())
	class._menuClippingMaid = maid:give(Maid.new())
	local instances = {}
	class.instances = instances
	local iconContainer2 = maid:give(iconContainer:Clone())
	iconContainer2.Visible = true
	iconContainer2.Parent = topbarContainer
	instances.iconContainer = iconContainer2
	instances.iconButton = iconContainer2.IconButton
	instances.iconImage = instances.iconButton.IconImage
	instances.iconLabel = instances.iconButton.IconLabel
	instances.fakeIconLabel = instances.iconButton.FakeIconLabel
	instances.iconGradient = instances.iconButton.IconGradient
	instances.iconCorner = instances.iconButton.IconCorner
	instances.iconOverlay = iconContainer2.IconOverlay
	instances.iconOverlayCorner = instances.iconOverlay.IconOverlayCorner
	instances.noticeFrame = instances.iconButton.NoticeFrame
	instances.noticeLabel = instances.noticeFrame.NoticeLabel
	instances.captionContainer = iconContainer2.CaptionContainer
	instances.captionFrame = instances.captionContainer.CaptionFrame
	instances.captionLabel = instances.captionContainer.CaptionLabel
	instances.captionCorner = instances.captionFrame.CaptionCorner
	instances.captionOverlineContainer = instances.captionContainer.CaptionOverlineContainer
	instances.captionOverline = instances.captionOverlineContainer.CaptionOverline
	instances.captionOverlineCorner = instances.captionOverline.CaptionOverlineCorner
	instances.captionVisibilityBlocker = instances.captionFrame.CaptionVisibilityBlocker
	instances.captionVisibilityCorner = instances.captionVisibilityBlocker.CaptionVisibilityCorner
	instances.tipFrame = iconContainer2.TipFrame
	instances.tipLabel = instances.tipFrame.TipLabel
	instances.tipCorner = instances.tipFrame.TipCorner
	instances.dropdownContainer = iconContainer2.DropdownContainer
	instances.dropdownFrame = instances.dropdownContainer.DropdownFrame
	instances.dropdownList = instances.dropdownFrame.DropdownList
	instances.menuContainer = iconContainer2.MenuContainer
	instances.menuFrame = instances.menuContainer.MenuFrame
	instances.menuList = instances.menuFrame.MenuList
	instances.clickSound = iconContainer2.ClickSound
	class._settings = v2.settings
	class._groupSettings = v2.groupSettings
	class._settingsDictionary = {}
	class._uniqueSettings = v2.uniqueSettings
	class._uniqueSettingsDictionary = {}
	class.uniqueValues = {}
	local v6 = {
		dropdown = function(_, p, p2, uDim)
			local dropdownSlideInfo = class:get("dropdownSlideInfo")
			local dropdownBindToggleToIcon = class:get("dropdownBindToggleToIcon")
			local v7

			if class:get("dropdownHidePlayerlistOnOverlap") == true then
				v7 = class:get("alignment") == "right"
			else
				v7 = false
			end

			local _ = class.instances.dropdownContainer
			local dropdownFrame = class.instances.dropdownFrame
			local v8 = true
			local v9 = not class.isSelected

			if dropdownBindToggleToIcon == false then
				v9 = not class.dropdownOpen
			end

			local _longPressing = class._longPressing or class._rightClicking

			if class._tappingAway or v9 and not _longPressing or _longPressing and class.dropdownOpen then
				local dropdownSize = class:get("dropdownSize")
				local v10 = dropdownSize and dropdownSize.X.Offset / 1 or 0
				uDim = UDim2.new(0, v10, 0, 0)
				v8 = false
			end

			if #class.dropdownIcons > 0 and v8 and v7 then
				if StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList) then
					IconController._bringBackPlayerlist = IconController._bringBackPlayerlist and IconController._bringBackPlayerlist + 1 or 1
					class._bringBackPlayerlist = true
					StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
				end
			elseif class._bringBackPlayerlist and not v8 and IconController._bringBackPlayerlist then
				IconController._bringBackPlayerlist -= 1

				if IconController._bringBackPlayerlist <= 0 then
					IconController._bringBackPlayerlist = nil
					StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
				end

				class._bringBackPlayerlist = nil
			end

			local tween = TweenService:Create(p, dropdownSlideInfo, {
				[p2] = uDim
			})
			local completedConnection = nil
			completedConnection = tween.Completed:Connect(function()
				completedConnection:Disconnect()
			end)
			tween:Play()

			if not v8 then
				class._dropdownCanvasPos = dropdownFrame.CanvasPosition
			end

			dropdownFrame.ScrollingEnabled = v8
			class.dropdownOpen = v8
			class:_decideToCallSignal("dropdown")
		end,
		menu = function(_, p, p2, uDim)
			local menuSlideInfo = class:get("menuSlideInfo")
			local menuBindToggleToIcon = class:get("menuBindToggleToIcon")
			local _ = class.instances.menuContainer
			local menuFrame = class.instances.menuFrame
			local flag = true
			local v7 = not class.isSelected

			if menuBindToggleToIcon == false then
				v7 = not class.menuOpen
			end

			local _longPressing = class._longPressing or class._rightClicking

			if class._tappingAway or v7 and not _longPressing or _longPressing and class.menuOpen then
				local menuSize = class:get("menuSize")
				local v8 = menuSize and menuSize.Y.Offset / 1 or 0
				uDim = UDim2.new(0, 0, 0, v8)
				flag = false
			end

			if flag ~= class.menuOpen then
				class.updated:Fire()
			end

			if flag and menuSlideInfo.EasingDirection == Enum.EasingDirection.Out then
				menuSlideInfo = TweenInfo.new(menuSlideInfo.Time, menuSlideInfo.EasingStyle, Enum.EasingDirection.In)
			end

			local tween = TweenService:Create(p, menuSlideInfo, {
				[p2] = uDim
			})
			local completedConnection = nil
			completedConnection = tween.Completed:Connect(function()
				completedConnection:Disconnect()
			end)
			tween:Play()

			if flag then
				if class._menuCanvasPos then
					menuFrame.CanvasPosition = class._menuCanvasPos
				end
			else
				class._menuCanvasPos = menuFrame.CanvasPosition
			end

			menuFrame.ScrollingEnabled = flag
			class.menuOpen = flag
			class:_decideToCallSignal("menu")
		end
	}

	for k, v7 in pairs(v2.flat) do
		local object2 = setmetatable({
			additionalValues = {}
		}, v2.metas[k])

		if v7.type == "toggleable" then
			object2.values = {
				deselected = nil,
				selected = nil
			}
		end

		class._settingsDictionary[k] = object2
		local unique = v7.unique

		if unique then
			class._uniqueSettingsDictionary[k] = v6[unique]
		end
	end

	class.updated = maid:give(Signal.new())
	class.selected = maid:give(Signal.new())
	class.deselected = maid:give(Signal.new())
	class.toggled = maid:give(Signal.new())
	class.userSelected = maid:give(Signal.new())
	class.userDeselected = maid:give(Signal.new())
	class.userToggled = maid:give(Signal.new())
	class.hoverStarted = maid:give(Signal.new())
	class.hoverEnded = maid:give(Signal.new())
	class.dropdownOpened = maid:give(Signal.new())
	class.dropdownClosed = maid:give(Signal.new())
	class.menuOpened = maid:give(Signal.new())
	class.menuClosed = maid:give(Signal.new())
	class.notified = maid:give(Signal.new())
	class._endNotices = maid:give(Signal.new())
	class._ignoreClippingChanged = maid:give(Signal.new())

	local function setFeatureChange(p, p2)
		local _parentIcon = class._parentIcon
		class:set(p .. "IgnoreClipping", p2)

		if p2 == true and _parentIcon then
			local connection = _parentIcon._ignoreClippingChanged:Connect(function(_, p3)
				class:set(p .. "IgnoreClipping", p3)
			end)
			local connection2 = nil
			connection2 = class[p .. "Closed"]:Connect(function()
				connection2:Disconnect()
				connection:Disconnect()
			end)
		end
	end

	class.dropdownOpened:Connect(function()
		setFeatureChange("dropdown", true)
	end)
	class.dropdownClosed:Connect(function()
		local _ = class._parentIcon
		class:set("dropdownIgnoreClipping", false)
	end)
	class.menuOpened:Connect(function()
		setFeatureChange("menu", true)
	end)
	class.menuClosed:Connect(function()
		local _ = class._parentIcon
		class:set("menuIgnoreClipping", false)
	end)
	class.deselectWhenOtherIconSelected = true
	class.name = ""
	class.isSelected = false
	class.presentOnTopbar = true
	class.accountForWhenDisabled = false
	class.enabled = true
	class.hovering = false
	class.tipText = nil
	class.captionText = nil
	class.totalNotices = 0
	class.notices = {}
	class.dropdownIcons = {}
	class.menuIcons = {}
	class.dropdownOpen = false
	class.menuOpen = false
	class.locked = false
	class.topPadding = UDim.new(0, 4)
	class.targetPosition = nil
	class.toggleItems = {}
	class.lockedSettings = {}
	class.UID = HttpService:GenerateGUID(true)
	class.blockBackBehaviourChecks = {}
	class._draggingFinger = false
	class._updatingIconSize = true
	class._previousDropdownOpen = false
	class._previousMenuOpen = false
	class._bindedToggleKeys = {}
	class._bindedEvents = {}
	class:setName("UnnamedIcon")
	class:setTheme(default, true)

	local function fn(...)
		if class.locked then
			return
		end

		if class.isSelected then
			class:deselect()
			class.userDeselected:Fire()
			class.userToggled:Fire(false)
			return true
		else
			class:select(...)
			class.userSelected:Fire()
			class.userToggled:Fire(true)
		end
	end

	local now = -1
	instances.iconButton.MouseButton1Click:Connect(function()
		now = tick()
		fn()
	end)
	instances.iconButton.MouseButton2Click:Connect(function()
		now = tick()
		fn(nil, true)
	end)
	local position = nil
	maid:give(UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
			position = input.Position
		end
	end))
	maid:give(UserInputService.InputEnded:Connect(function(input)
		if not (class._parentIcon and class._parentIcon.dropdownOpen and class._parentIcon._clickFallbackEnabled) then
			return
		end

		local v7 = input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
		local v8 = input.UserInputType == Enum.UserInputType.MouseButton2

		if not (v7 or v8) then
			return
		end

		local iconButton = instances.iconButton

		if not iconButton or not iconButton.Visible or not iconButton.Active or class.locked then
			return
		end

		local position2 = input.Position
		local absolutePosition = iconButton.AbsolutePosition
		local absoluteSize = iconButton.AbsoluteSize

		if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
			return
		end

		if position2.X < absolutePosition.X or position2.X > absolutePosition.X + absoluteSize.X or position2.Y < absolutePosition.Y or position2.Y > absolutePosition.Y + absoluteSize.Y then
			return
		end

		if not position then
			return
		end

		if position.X < absolutePosition.X or position.X > absolutePosition.X + absoluteSize.X or position.Y < absolutePosition.Y or position.Y > absolutePosition.Y + absoluteSize.Y then
			return
		end

		if math.abs(position.X - position2.X) > 10 or math.abs(position.Y - position2.Y) > 10 then
			return
		end

		local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

		if playerGui then
			local success, guiObjectsAtPosition = pcall(
				playerGui.GetGuiObjectsAtPosition,
				playerGui,
				position2.X,
				position2.Y
			)

			if success and guiObjectsAtPosition then
				for _, button in ipairs(guiObjectsAtPosition) do
					if not (button:IsA("GuiButton") and button.Active and button.Visible) then
						continue
					end

					if button ~= iconButton then
						return
					end

					break
				end
			end
		end

		local now2 = tick()
		task.delay(0.05, function()
			local v9 = now

			if now2 - 0.15 <= v9 then
				return
			end

			if v8 then
				fn(nil, true)
			else
				fn()
			end
		end)
	end))
	instances.iconButton.MouseButton1Down:Connect(function()
		if class.locked then
			return
		end

		class:_updateStateOverlay(0.7, Color3.new(0, 0, 0))
	end)
	instances.iconButton.MouseButton1Up:Connect(function()
		if class.overlayLocked then
			return
		end

		class:_updateStateOverlay(0.9, Color3.new(1, 1, 1))
	end)
	local v7 = {
		[Enum.UserInputType.MouseButton1] = true,
		[Enum.UserInputType.MouseButton2] = true,
		[Enum.UserInputType.MouseButton3] = true,
		[Enum.UserInputType.Touch] = true
	}
	maid:give(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and v7[input.UserInputType] then
			class._tappingAway = true

			if class.dropdownOpen and class:get("dropdownCloseOnTapAway") == true then
				class:_update("dropdownSize")
			end

			if class.menuOpen and class:get("menuCloseOnTapAway") == true then
				class:_update("menuSize")
			end

			class._tappingAway = false
		end

		if class._bindedToggleKeys[input.KeyCode] and not (gameProcessed or class.locked) then
			if class.isSelected then
				class:deselect()
				class.userDeselected:Fire()
				class.userToggled:Fire(false)
			else
				class:select()
				class.userSelected:Fire()
				class.userToggled:Fire(true)
			end
		end
	end))
	class.hoverStarted:Connect(function(_, _)
		class.hovering = true

		if not class.locked then
			class:_updateStateOverlay(0.9, Color3.fromRGB(255, 255, 255))
		end

		class:_updateHovering()
	end)
	class.hoverEnded:Connect(function()
		class.hovering = false
		class:_updateStateOverlay(1)
		class._hoveringMaid:clean()
		class:_updateHovering()
	end)
	instances.iconButton.MouseEnter:Connect(function(p, p2)
		class.hoverStarted:Fire(p, p2)
	end)
	instances.iconButton.MouseLeave:Connect(function()
		class.hoverEnded:Fire()
	end)
	instances.iconButton.SelectionGained:Connect(function()
		class.hoverStarted:Fire()
	end)
	instances.iconButton.SelectionLost:Connect(function()
		class.hoverEnded:Fire()
	end)
	instances.iconButton.MouseButton1Down:Connect(function()
		if class._draggingFinger then
			class.hoverStarted:Fire()
		end

		local heartbeatConnection = nil
		local mouseButton1UpConnection = nil
		local v8 = tick() + 0.7
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if v8 <= tick() then
				mouseButton1UpConnection:Disconnect()
				heartbeatConnection:Disconnect()
				class._longPressing = true

				if class:get("dropdownToggleOnLongPress") == true then
					class:_update("dropdownSize")
				end

				if class:get("menuToggleOnLongPress") == true then
					class:_update("menuSize")
				end

				class._longPressing = false
			end
		end)
		mouseButton1UpConnection = instances.iconButton.MouseButton1Up:Connect(function()
			mouseButton1UpConnection:Disconnect()
			heartbeatConnection:Disconnect()
		end)
	end)

	if UserInputService.TouchEnabled then
		instances.iconButton.MouseButton1Up:Connect(function()
			if class.hovering then
				class.hoverEnded:Fire()
			end
		end)
		maid:give(UserInputService.TouchMoved:Connect(function(_, p)
			if p then
				return
			end

			class._draggingFinger = true
		end))
		maid:give(UserInputService.TouchEnded:Connect(function()
			class._draggingFinger = false
		end))
	end

	class._updatingIconSize = false
	class:_updateIconSize()
	IconController.iconAdded:Fire(class)
	return class
end

function NewIcon.mimic(p)
	local v3 = p .. "Mimic"
	local icon = IconController.getIcon(v3)

	if icon then
		return icon
	end

	local v4 = NewIcon.new()
	v4:setName(v3)

	if p ~= "Chat" then
		return v4
	end

	v4:setOrder(-1)
	v4:setImage("rbxasset://textures/ui/TopBar/chatOff.png", "deselected")
	v4:setImage("rbxasset://textures/ui/TopBar/chatOn.png", "selected")
	v4:setImageYScale(0.625)
	return v4
end

function NewIcon:set(p, hoveringValue, value2, value3)
	local v3 = self._settingsDictionary[p]
	assert(v3 ~= nil, ("setting '%s' does not exist"):format(p))

	if type(value2) == "string" then
		value2 = value2:lower()
	end

	local previous = self:get(p, value2)

	if value2 == "hovering" then
		v3.hoveringValue = hoveringValue

		if value3 ~= "_ignorePrevious" then
			v3.additionalValues["previous_" .. "hovering"] = previous
		end

		if type(value3) == "string" then
			v3.additionalValues[value3 .. "_" .. "hovering"] = previous
		end

		self:_update(p)
	else
		local v5

		if v3.type == "toggleable" then
			local v6 = {}

			if value2 == "deselected" or value2 == "selected" then
				table.insert(v6, value2)
				v5 = value2
			else
				table.insert(v6, "deselected")
				table.insert(v6, "selected")
			end

			for _, v7 in pairs(v6) do
				v3.values[v7] = hoveringValue

				if value3 ~= "_ignorePrevious" then
					v3.additionalValues["previous_" .. v7] = previous
				end

				if type(value3) == "string" then
					v3.additionalValues[value3 .. "_" .. v7] = previous
				end
			end
		else
			v3.value = hoveringValue

			if type(value3) == "string" then
				if value3 ~= "_ignorePrevious" then
					v3.additionalValues.previous = previous
				end

				v3.additionalValues[value3] = previous
			end

			v5 = value2
		end

		if previous == hoveringValue then
			return self, "Value was already set"
		end

		local toggleState = self:getToggleState()

		if not self._updateAfterSettingAll and v3.instanceNames and (toggleState == v5 or v5 == nil) then
			local v6

			if p == "iconSize" then
				v6 = previous and previous.X.Scale == 1
			else
				v6 = false
			end

			self:_update(p, toggleState, v3.tweenAction and not v6 and self:get(v3.tweenAction) or TweenInfo.new(0))
		end
	end

	if v3.callMethods then
		for _, callMethod in pairs(v3.callMethods) do
			callMethod(self, hoveringValue, value2)
		end
	end

	if v3.callSignals then
		for _, callSignal in pairs(v3.callSignals) do
			callSignal:Fire()
		end
	end

	return self
end

function NewIcon:setAdditionalValue(p2, p3, p4, p5)
	local v3 = self._settingsDictionary[p2]
	assert(v3 ~= nil, ("setting '%s' does not exist"):format(p2))
	local v4 = p3 .. "_"

	if p5 then
		v4 ..= p5
	end

	for k, _ in pairs(v3.additionalValues) do
		if string.match(k, v4) then
			v3.additionalValues[k] = p4
		end
	end
end

function NewIcon:get(p, value2, value3)
	local v3 = self._settingsDictionary[p]
	assert(v3 ~= nil, ("setting '%s' does not exist"):format(p))
	local hoveringValue = nil
	local v4 = nil

	if typeof(value2) == "string" then
		value2 = value2:lower()
	end

	if value2 == "hovering" and value3 == nil then
		hoveringValue = v3.hoveringValue

		if type(nil) == "string" then
			v4 = v3.additionalValues[nil .. "_" .. "hovering"]
		else
			v4 = false
		end
	end

	if v3.type == "toggleable" then
		local v5 = (value2 == "deselected" or value2 == "selected") and value2 or self:getToggleState()

		if v4 == nil then
			if type(value3) == "string" then
				v4 = v3.additionalValues[value3 .. "_" .. v5]
			else
				v4 = false
			end
		end

		if hoveringValue == nil then
			return v3.values[v5], v4
		end

		return hoveringValue, v4
	else
		if v4 == nil then
			if type(value3) == "string" then
				v4 = v3.additionalValues[value3]
			else
				v4 = false
			end
		end

		if hoveringValue == nil then
			hoveringValue = v3.value
		end

		return hoveringValue, v4
	end
end

function NewIcon:getHovering(p2)
	local v3 = self._settingsDictionary[p2]
	assert(v3 ~= nil, ("setting '%s' does not exist"):format(p2))
	return v3.hoveringValue
end

function NewIcon:getToggleState(p2)
	if p2 or self.isSelected then
		return "selected"
	end

	return "deselected"
end

function NewIcon:getIconState()
	if self.hovering then
		return "hovering"
	end

	return self:getToggleState()
end

function NewIcon:_update(p, p2, p3)
	local v3 = self._settingsDictionary[p]
	assert(v3 ~= nil, ("setting '%s' does not exist"):format(p))
	local v4 = p2 or self:getToggleState()
	local value2 = v3.value or v3.values and v3.values[v4]

	if self.hovering and v3.hoveringValue then
		value2 = v3.hoveringValue
	end

	if value2 == nil then
		return
	end

	local v5 = p3 or v3.tweenAction and v3.tweenAction ~= "" and self:get(v3.tweenAction) or self:get("toggleTransitionInfo") or TweenInfo.new(0.15)
	local propertyName = v3.propertyName
	local v6 = {
		string = true,
		NumberSequence = true,
		Text = true,
		EnumItem = true,
		ColorSequence = true
	}
	local v7 = self._uniqueSettingsDictionary[p]
	local forcedGroupValue

	if v3.useForcedGroupValue then
		forcedGroupValue = v3.forcedGroupValue
	else
		forcedGroupValue = value2
	end

	if v3.instanceNames then
		for _, instanceName in pairs(v3.instanceNames) do
			local instance = self.instances[instanceName]
			local v8 = v6[typeof(instance[propertyName])] or typeof(instance) == "table"

			if v7 then
				v7(p, instance, propertyName, forcedGroupValue)
			elseif v8 then
				instance[propertyName] = value2
			else
				TweenService:Create(instance, v5, {
					[propertyName] = forcedGroupValue
				}):Play()
			end

			if p == "iconSize" and instance[propertyName] ~= forcedGroupValue then
				self.updated:Fire()
			end
		end
	end
end

function NewIcon:_updateAll(p, p2)
	for k, v3 in pairs(self._settingsDictionary) do
		if v3.instanceNames then
			self:_update(k, p, p2)
		end
	end

	self:_updateIconSize()
	self:_updateCaptionSize()
	self:_updateTipSize()
end

function NewIcon:_updateHovering(p)
	for k, v3 in pairs(self._settingsDictionary) do
		if v3.instanceNames and v3.hoveringValue ~= nil then
			self:_update(k, nil, p)
		end
	end
end

function NewIcon:_updateStateOverlay(value2, p2)
	local iconOverlay = self.instances.iconOverlay
	iconOverlay.BackgroundTransparency = value2 or 1
	iconOverlay.BackgroundColor3 = p2 or Color3.new(1, 1, 1)
end

function NewIcon:setTheme(items, updateAfterSettingAll)
	self._updateAfterSettingAll = updateAfterSettingAll

	for k, item in pairs(items) do
		if k == "toggleable" then
			for k2, v3 in pairs(item.deselected) do
				if not self.lockedSettings[k2] then
					self:set(k2, v3, "both")
				end
			end

			for k2, v3 in pairs(item.selected) do
				if not self.lockedSettings[k2] then
					self:set(k2, v3, "selected")
				end
			end
		else
			for k2, v3 in pairs(item) do
				if self.lockedSettings[k2] then
					continue
				end

				local v4 = self._settingsDictionary[k2]

				if k == "action" and v4 == nil then
					self._settingsDictionary[k2] = {}
				end

				self:set(k2, v3)
			end
		end
	end

	self._updateAfterSettingAll = nil

	if updateAfterSettingAll then
		self:_updateAll()
	end

	return self
end

function NewIcon:getInstance(p2)
	return self.instances[p2]
end

function NewIcon:setInstance(p2, p3)
	local instance = self.instances[p2]
	self.instances[p2] = p3

	if instance then
		instance:Destroy()
	end

	return self
end

function NewIcon:getSettingDetail(p2)
	return self._settingsDictionary[p2] or false
end

function NewIcon:modifySetting(p, items)
	local settingDetail = self:getSettingDetail(p)

	for k, item in pairs(items) do
		settingDetail[k] = item
	end

	return self
end

function NewIcon:convertLabelToNumberSpinner(p)
	self:set("iconLabelSize", UDim2.new(1, 0, 1, 0))
	p.Parent = self:getInstance("iconButton")
	local v3 = {}
	setmetatable(v3, {
		__newindex = function(_, p2, p3)
			for _, label in pairs(p.Frame:GetDescendants()) do
				if label:IsA("TextLabel") then
					label[p2] = p3
				end
			end
		end
	})
	local instance = self:getInstance("iconButton")
	instance.ZIndex = 0
	self:setInstance("iconLabel", v3)
	self:modifySetting("iconText", {
		instanceNames = {}
	})
	self:setInstance("iconLabelSpinner", p.Frame)

	for _, v4 in pairs({
		"iconLabelVisible",
		"iconLabelAnchorPoint",
		"iconLabelPosition",
		"iconLabelSize"
	}) do
		self:modifySetting(v4, {
			instanceNames = { "iconLabelSpinner" }
		})
	end

	self:_updateAll()
	return self
end

function NewIcon:setEnabled(p)
	self.enabled = p
	self.instances.iconContainer.Visible = p
	self.updated:Fire()
	return self
end

function NewIcon:setName(name)
	self.name = name
	self.instances.iconContainer.Name = name
	return self
end

function NewIcon:setProperty(p2, p3)
	self[p2] = p3
	return self
end

function NewIcon:_playClickSound()
	local clickSound = self.instances.clickSound

	if clickSound.SoundId ~= nil and #clickSound.SoundId > 0 and clickSound.Volume > 0 then
		local clone = clickSound:Clone()
		clone.Parent = clickSound.Parent
		clone:Play()
		Debris:AddItem(clone, clickSound.TimeLength)
	end
end

function NewIcon:select(p, ...)
	self.isSelected = true
	self:_setToggleItemsVisible(true, p)
	self:_updateNotice()
	self:_updateAll()
	self:_playClickSound()

	if #self.dropdownIcons > 0 or #self.menuIcons > 0 then
		IconController:_updateSelectionGroup()
	end

	if UserInputService.GamepadEnabled then
		for _, list in pairs(self.toggleItems) do
			if not (#list > 0) then
				continue
			end

			local v3 = Maid.new()
			GuiService:AddSelectionTuple(self.UID, unpack(list))
			GuiService.SelectedObject = list[1]
			IconController.activeButtonBCallbacks += 1
			v3:give(UserInputService.InputEnded:Connect(function(input, _)
				local v5 = false

				for _, blockBackBehaviourCheck in pairs(self.blockBackBehaviourChecks) do
					if blockBackBehaviourCheck() ~= true then
						continue
					end

					v5 = true
					break
				end

				if input.KeyCode == Enum.KeyCode.ButtonB and not v5 then
					GuiService.SelectedObject = self.instances.iconButton
					self:deselect()
				end
			end))
			v3:give(self.deselected:Connect(function()
				v3:clean()
			end))
			v3:give(function()
				IconController.activeButtonBCallbacks -= 1

				if IconController.activeButtonBCallbacks < 0 then
					IconController.activeButtonBCallbacks = 0
				end
			end)
		end
	end

	self.selected:Fire(...)
	self.toggled:Fire(self.isSelected)
	return self
end

function NewIcon:deselect(p)
	self.isSelected = false
	self:_setToggleItemsVisible(false, p)
	self:_updateNotice()
	self:_updateAll()
	self:_playClickSound()

	if #self.dropdownIcons > 0 or #self.menuIcons > 0 then
		IconController:_updateSelectionGroup()
	end

	self.deselected:Fire()
	self.toggled:Fire(self.isSelected)

	if UserInputService.GamepadEnabled then
		GuiService:RemoveSelectionGroup(self.UID)
	end

	return self
end

function NewIcon:notify(deselected, p)
	coroutine.wrap(function()
		if not deselected then
			deselected = self.deselected
		end

		if self._parentIcon then
			self._parentIcon:notify(deselected)
		end

		local connection = Signal.new()
		local connection2 = self._endNotices:Connect(function()
			connection:Fire()
		end)
		local connection3 = deselected:Connect(function()
			connection:Fire()
		end)
		p = p or HttpService:GenerateGUID(true)
		self.notices[p] = {
			completeSignal = connection,
			clearNoticeEvent = deselected
		}
		self.totalNotices += 1
		self:_updateNotice()
		self.notified:Fire(p)
		connection:Wait()
		connection2:Disconnect()
		connection3:Disconnect()
		connection:Disconnect()
		self.totalNotices -= 1
		self.notices[p] = nil
		self:_updateNotice()
	end)()
	return self
end

function NewIcon:_updateNotice()
	local v3 = not (self.totalNotices < 1)

	if not self.isSelected and (#self.dropdownIcons > 0 or #self.menuIcons > 0) then
		v3 = self.totalNotices > 0 or v3
	end

	if self.isSelected and (#self.dropdownIcons > 0 or #self.menuIcons > 0) then
		v3 = false
	end

	local v4 = v3 and 0 or 1
	self:set("noticeImageTransparency", v4)
	self:set("noticeTextTransparency", v4)
	self.instances.noticeLabel.Text = self.totalNotices < 100 and self.totalNotices or "99+"
end

function NewIcon:clearNotices()
	self._endNotices:Fire()
	return self
end

function NewIcon.disableStateOverlay(p, p2)
	local v3 = p2 == nil or p2
	p.instances.iconOverlay.Visible = not v3
	return p
end

function NewIcon:setLabel(value2, p)
	self:set("iconText", value2 or "", p)
	return self
end

function NewIcon:setCornerRadius(p, p2, p3)
	local cornerRadius = self.instances.iconCorner.CornerRadius
	self:set("iconCornerRadius", UDim.new(p or cornerRadius.Scale, p2 or cornerRadius.Offset), p3)
	return self
end

function NewIcon:setImage(value2, p)
	return self:set("iconImage", tonumber(value2) and "http://www.roblox.com/asset/?id=" .. value2 or value2 or "", p)
end

function NewIcon:setOrder(p, p2)
	return self:set("order", tonumber(p) or 1, p2)
end

function NewIcon:setLeft(p)
	return self:set("alignment", "left", p)
end

function NewIcon:setMid(p)
	return self:set("alignment", "mid", p)
end

function NewIcon:setRight(p)
	if not self.internalIcon then
		IconController.setupHealthbar()
	end

	return self:set("alignment", "right", p)
end

function NewIcon:setImageYScale(p, p2)
	return self:set("iconImageYScale", tonumber(p) or 0.63, p2)
end

function NewIcon:setImageRatio(p, p2)
	return self:set("iconImageRatio", tonumber(p) or 1, p2)
end

function NewIcon:setLabelYScale(p, p2)
	return self:set("iconLabelYScale", tonumber(p) or 0.45, p2)
end

function NewIcon:setBaseZIndex(p, p2)
	return self:set("baseZIndex", tonumber(p) or 1, p2)
end

function NewIcon._updateBaseZIndex(p, p2)
	local iconContainer2 = p.instances.iconContainer
	local v3 = (tonumber(p2) or iconContainer2.ZIndex) - iconContainer2.ZIndex

	if v3 == 0 then
		return "The baseValue is the same"
	end

	for _, guiObject in pairs(p.instances) do
		if guiObject:IsA("GuiObject") then
			guiObject.ZIndex += v3
		end
	end

	return true
end

function NewIcon:setSize(p, p2, p3)
	if tonumber(p) then
		self.forcefullyAppliedXSize = true
		self:set("forcedIconSizeX", tonumber(p), p3)
	else
		self.forcefullyAppliedXSize = false
		self:set("forcedIconSizeX", 32, p3)
	end

	if tonumber(p2) then
		self.forcefullyAppliedYSize = true
		self:set("forcedIconSizeY", tonumber(p2), p3)
	else
		self.forcefullyAppliedYSize = false
		self:set("forcedIconSizeY", 32, p3)
	end

	local v3 = tonumber(p) or 32
	local v4 = tonumber(p2) or (p2 == "_NIL" or not v3) and 32 or v3
	self:set("iconSize", UDim2.new(0, v3, 0, v4), p3)
	return self
end

function NewIcon:setXSize(p, p2)
	self:setSize(p, "_NIL", p2)
	return self
end

function NewIcon:setYSize(p, p2)
	self:setSize("_NIL", p, p2)
	return self
end

function NewIcon:_getContentText(text)
	self.instances.fakeIconLabel.Text = text
	local contentText = self.instances.fakeIconLabel.ContentText
	local v3

	if typeof(self.instances.iconLabel) == "Instance" then
		v3 = IconController.translator:Translate(self.instances.iconLabel, contentText)
	else
		v3 = false
	end

	if typeof(v3) ~= "string" or v3 == "" then
		v3 = contentText
	end

	self.instances.fakeIconLabel.Text = ""
	return v3
end

function NewIcon:_updateIconSize(_, p)
	if self._destroyed then
		return
	end

	local v3 = {
		iconImage = self:get("iconImage", p) or "_NIL",
		iconText = self:get("iconText", p) or "_NIL",
		iconFont = self:get("iconFont", p) or "_NIL",
		iconSize = self:get("iconSize", p) or "_NIL",
		forcedIconSizeX = self:get("forcedIconSizeX", p) or "_NIL",
		iconImageYScale = self:get("iconImageYScale", p) or "_NIL",
		iconImageRatio = self:get("iconImageRatio", p) or "_NIL",
		iconLabelYScale = self:get("iconLabelYScale", p) or "_NIL"
	}

	for _, v4 in pairs(v3) do
		if v4 == "_NIL" then
			return
		end
	end

	local iconContainer2 = self.instances.iconContainer

	if not iconContainer2.Parent then
		return
	end

	local offset = v3.iconSize.X.Offset
	local scale = v3.iconSize.X.Scale
	local v4 = offset + scale * iconContainer2.Parent.AbsoluteSize.X
	local forcedIconSizeX = v3.forcedIconSizeX
	local v5 = scale > 0 and v4 or self.forcefullyAppliedXSize and forcedIconSizeX or 9999
	local v6 = v3.iconSize.Y.Offset + v3.iconSize.Y.Scale * iconContainer2.Parent.AbsoluteSize.Y
	local v7 = v6 * v3.iconLabelYScale
	local X = TextService:GetTextSize(self:_getContentText(v3.iconText), v7, v3.iconFont, Vector2.new(10000, v7)).X
	local v8 = v6 * v3.iconImageYScale * v3.iconImageRatio
	local v9 = v3.iconImage ~= ""
	local v10 = v3.iconText ~= ""
	local v11 = 0.5
	local v12 = nil
	local v13 = v7 / 2

	if v9 and not v10 then
		self:set("iconImageVisible", true, p)
		self:set("iconImageAnchorPoint", Vector2.new(0.5, 0.5), p)
		self:set("iconImagePosition", UDim2.new(0.5, 0, 0.5, 0), p)
		self:set("iconImageSize", UDim2.new(v3.iconImageYScale * v3.iconImageRatio, 0, v3.iconImageYScale, 0), p)
		self:set("iconLabelVisible", false, p)
		v12 = 0
		v11 = 0.45
	elseif v9 or not v10 then
		if v9 and v10 then
			local v14 = 12 + v8 + 8
			v12 = v14 + X + 12
			self:set("iconImageVisible", true, p)
			self:set("iconImageAnchorPoint", Vector2.new(0, 0.5), p)
			self:set("iconImagePosition", UDim2.new(0, 12, 0.5, 0), p)
			self:set("iconImageSize", UDim2.new(0, v8, v3.iconImageYScale, 0), p)
			self:set("iconLabelVisible", true, p)
			self:set("iconLabelAnchorPoint", Vector2.new(0, 0.5), p)
			self:set("iconLabelPosition", UDim2.new(0, v14, 0.5, 0), p)
			self:set("iconLabelSize", UDim2.new(1, -v14 - 12, v3.iconLabelYScale, v13), p)
			self:set("iconLabelTextXAlignment", Enum.TextXAlignment.Left, p)
		end
	else
		v12 = X + 24
		self:set("iconLabelVisible", true, p)
		self:set("iconLabelAnchorPoint", Vector2.new(0, 0.5), p)
		self:set("iconLabelPosition", UDim2.new(0, 12, 0.5, 0), p)
		self:set("iconLabelSize", UDim2.new(1, -24, v3.iconLabelYScale, v13), p)
		self:set("iconLabelTextXAlignment", Enum.TextXAlignment.Center, p)
		self:set("iconImageVisible", false, p)
	end

	if v12 and not self._updatingIconSize then
		self._updatingIconSize = true
		local v14 = scale > 0 and scale or 0
		local v15 = scale > 0 and 0 or math.clamp(v12, forcedIconSizeX, v5)
		self:set("iconSize", UDim2.new(v14, v15, v3.iconSize.Y.Scale, v3.iconSize.Y.Offset), p, "_ignorePrevious")
		local _parentIcon = self._parentIcon

		if _parentIcon then
			local uDim = UDim2.new(0, v12, 0, v3.iconSize.Y.Offset)

			if #_parentIcon.dropdownIcons > 0 then
				self:setAdditionalValue("iconSize", "beforeDropdown", uDim, p)
				_parentIcon:_updateDropdown()
			end

			if #_parentIcon.menuIcons > 0 then
				self:setAdditionalValue("iconSize", "beforeMenu", uDim, p)
				_parentIcon:_updateMenu()
			end
		end

		self._updatingIconSize = false
	end

	self:set("iconLabelTextSize", v7, p)
	self:set("noticeFramePosition", UDim2.new(v11, 0, 0, -2), p)
	self._updatingIconSize = false
end

function NewIcon:bindEvent(p2, callback)
	local v3 = self[p2]
	local connect

	if v3 then
		if typeof(v3) == "table" then
			connect = v3.Connect
		else
			connect = false
		end
	else
		connect = v3
	end

	assert(connect, "argument[1] must be a valid topbarplus icon event name!")
	assert(typeof(callback) == "function", "argument[2] must be a function!")
	self._bindedEvents[p2] = v3:Connect(function(...)
		callback(self, ...)
	end)
	return self
end

function NewIcon:unbindEvent(p2)
	local _bindedEvent = self._bindedEvents[p2]

	if _bindedEvent then
		_bindedEvent:Disconnect()
		self._bindedEvents[p2] = nil
	end

	return self
end

function NewIcon:bindToggleKey(p2)
	assert(typeof(p2) == "EnumItem", "argument[1] must be a KeyCode EnumItem!")
	self._bindedToggleKeys[p2] = true
	return self
end

function NewIcon:unbindToggleKey(p2)
	assert(typeof(p2) == "EnumItem", "argument[1] must be a KeyCode EnumItem!")
	self._bindedToggleKeys[p2] = nil
	return self
end

function NewIcon:lock()
	self.instances.iconButton.Active = false
	self.locked = true
	task.defer(function()
		if self.locked then
			self.overlayLocked = true
		end
	end)
	return self
end

function NewIcon:unlock()
	self.instances.iconButton.Active = true
	self.locked = false
	self.overlayLocked = false
	return self
end

function NewIcon:debounce(duration)
	self:lock()
	task.wait(duration)
	self:unlock()
	return self
end

function NewIcon:autoDeselect(p2)
	self.deselectWhenOtherIconSelected = p2 == nil or p2
	return self
end

function NewIcon:setTopPadding(value2, value3)
	self.topPadding = UDim.new(value3 or 0, value2 or 4)
	self.updated:Fire()
	return self
end

function NewIcon:bindToggleItem(instance)
	if not (instance:IsA("GuiObject") or instance:IsA("LayerCollector")) then
		error("Toggle item must be a GuiObject or LayerCollector!")
	end

	self.toggleItems[instance] = true
	self:updateSelectionInstances()
	return self
end

function NewIcon:updateSelectionInstances()
	for folder, _ in pairs(self.toggleItems) do
		local buttons = {}

		for _, button in pairs(folder:GetDescendants()) do
			if not ((button:IsA("TextButton") or button:IsA("ImageButton")) and button.Active) then
				continue
			end

			table.insert(buttons, button)
		end

		self.toggleItems[folder] = buttons
	end
end

function NewIcon.addBackBlocker(p, p2)
	table.insert(p.blockBackBehaviourChecks, p2)
	return p
end

function NewIcon.unbindToggleItem(p, p2)
	p.toggleItems[p2] = nil
	return p
end

function NewIcon:_setToggleItemsVisible(p2, p3)
	for layerCollector, _ in pairs(self.toggleItems) do
		if not p3 or p3.toggleItems[layerCollector] == nil then
			layerCollector[layerCollector:IsA("LayerCollector") and "Enabled" or "Visible"] = p2
		end
	end
end

function NewIcon.call(p, callback)
	task.spawn(callback, p)
	return p
end

function NewIcon:give(callback)
	local v3

	if typeof(callback) == "function" then
		v3 = callback(self)

		if typeof(callback) == "function" then
			v3 = nil
		end
	else
		v3 = callback
	end

	if v3 ~= nil then
		self._maid:give(v3)
	end

	return self
end

function NewIcon:setTip(tipText)
	assert(typeof(tipText) == "string" or tipText == nil, "Expected string, got " .. typeof(tipText))
	local text = tipText or ""
	local v4 = text ~= ""
	self.tipText = tipText
	self.instances.tipLabel.Text = text
	self.instances.tipFrame.Parent = v4 and activeItems or self.instances.iconContainer
	self._maid.tipFrame = self.instances.tipFrame
	self:_updateTipSize()
	local tipMaid = Maid.new()
	self._maid.tipMaid = tipMaid

	if v4 then
		tipMaid:give(self.hoverStarted:Connect(function()
			if not self.isSelected then
				self:displayTip(true)
			end
		end))
		tipMaid:give(self.hoverEnded:Connect(function()
			self:displayTip(false)
		end))
		tipMaid:give(self.selected:Connect(function()
			if self.hovering then
				self:displayTip(false)
			end
		end))
	end

	self:displayTip(self.hovering and v4)
	return self
end

function NewIcon:_updateTipSize()
	local tipText = self.tipText or ""
	local v3 = tipText ~= ""
	local textSize = TextService:GetTextSize(
		self:_getContentText(tipText),
		12,
		Enum.Font.GothamSemibold,
		Vector2.new(1000, 14)
	)
	self.instances.tipFrame.Size = v3 and UDim2.new(0, textSize.X + 6, 0, 20) or UDim2.new(0, 0, 0, 0)
end

function NewIcon:displayTip(p)
	if UserInputService.TouchEnabled and not self._draggingFinger then
		return
	end

	local tipVisible = self.tipVisible or false

	if typeof(p) == "boolean" then
		tipVisible = p
	end

	self.tipVisible = tipVisible
	local tipFrame = self.instances.tipFrame

	if tipVisible then
		local function updateTipPositon(X, Y)
			local currentCamera = workspace.CurrentCamera
			local viewportSize = currentCamera and currentCamera.ViewportSize
			local v3, v4

			if UserInputService.TouchEnabled then
				local v5 = X - tipFrame.Size.X.Offset / 2
				local v6 = viewportSize.X - tipFrame.Size.X.Offset
				local v7 = Y + 55 + 60
				local v8 = tipFrame.AbsoluteSize.Y + 55 + 64 + 3
				local v9 = viewportSize.Y - tipFrame.Size.Y.Offset
				v3 = math.clamp(v5, 0, v6)
				v4 = math.clamp(v7, v8, v9)
			elseif IconController.controllerModeEnabled then
				local indicator = TopbarPlusGui.Indicator
				local absolutePosition = indicator.AbsolutePosition
				v3 = absolutePosition.X - tipFrame.Size.X.Offset / 2 + indicator.AbsoluteSize.X / 2
				v4 = absolutePosition.Y + 90
			else
				local v5 = viewportSize.X - tipFrame.Size.X.Offset - 48
				local v6 = tipFrame.Size.Y.Offset + 3
				local Y2 = viewportSize.Y
				v3 = math.clamp(X, 0, v5)
				v4 = math.clamp(Y, v6, Y2)
			end

			tipFrame.Position = UDim2.new(0, v3, 0, v4 - 20)
		end

		local mouseLocation = UserInputService:GetMouseLocation()

		if mouseLocation then
			updateTipPositon(mouseLocation.X, mouseLocation.Y)
		end

		self._hoveringMaid:give(self.instances.iconButton.MouseMoved:Connect(updateTipPositon))
	end

	for _, v3 in pairs(self._groupSettings.tip) do
		self._settingsDictionary[v3].useForcedGroupValue = not tipVisible
		self:_update(v3)
	end
end

local v = {
	tip = 1,
	caption = 1
}

function NewIcon:setCaption(captionText)
	assert(typeof(captionText) == "string" or captionText == nil, "Expected string, got " .. typeof(captionText))
	local text = captionText or ""
	local v4 = text ~= ""
	self.captionText = captionText
	self.instances.captionLabel.Text = text
	self.instances.captionContainer.Parent = v4 and activeItems or self.instances.iconContainer
	self._maid.captionContainer = self.instances.captionContainer
	self:_updateIconSize(nil, self:getIconState())
	local captionMaid = Maid.new()
	self._maid.captionMaid = captionMaid

	if v4 then
		captionMaid:give(self.hoverStarted:Connect(function()
			if not self.isSelected then
				self:displayCaption(true)
			end
		end))
		captionMaid:give(self.hoverEnded:Connect(function()
			self:displayCaption(false)
		end))
		captionMaid:give(self.selected:Connect(function()
			if self.hovering then
				self:displayCaption(false)
			end
		end))
		local iconContainer2 = self.instances.iconContainer
		captionMaid:give(iconContainer2:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			if self.hovering then
				self:displayCaption()
			end
		end))
		captionMaid:give(iconContainer2:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
			if self.hovering then
				self:displayCaption()
			end
		end))
	end

	self:_updateCaptionSize()
	self:displayCaption(self.hovering and v4)
	return self
end

function NewIcon:_updateCaptionSize()
	local iconSize = self:get("iconSize")
	local captionFont = self:get("captionFont")

	if iconSize and captionFont then
		local offset = iconSize.Y.Offset
		local scale = iconSize.Y.Scale
		local iconContainer2 = self.instances.iconContainer
		local captionContainer = self.instances.captionContainer

		if (self.captionText or "") ~= "" then
			local v3 = offset + scale * iconContainer2.Parent.AbsoluteSize.Y
			local captionLabel = self.instances.captionLabel
			local textSize = v3 * 0.8 * 0.58
			local X = TextService:GetTextSize(
				self:_getContentText(self.captionText),
				textSize,
				captionFont,
				Vector2.new(10000, textSize)
			).X
			captionLabel.TextSize = textSize
			captionLabel.Size = UDim2.new(0, X, 0.58, 0)
			captionContainer.Size = UDim2.new(0, X + 12, 0, v3 * 0.8)
		else
			captionContainer.Size = UDim2.new(0, 0, 0, 0)
		end
	end
end

function NewIcon:displayCaption(p)
	if UserInputService.TouchEnabled and not self._draggingFinger then
		return
	end

	local total = 8

	if self._draggingFinger then
		total += 55
	end

	local iconContainer2 = self.instances.iconContainer
	local captionContainer = self.instances.captionContainer
	captionContainer.Position = UDim2.new(
		0,
		iconContainer2.AbsolutePosition.X + iconContainer2.AbsoluteSize.X / 2 - captionContainer.AbsoluteSize.X / 2,
		0,
		iconContainer2.AbsolutePosition.Y + iconContainer2.AbsoluteSize.Y * 2 + total
	)
	local captionVisible = self.captionVisible or false

	if typeof(p) == "boolean" then
		captionVisible = p
	end

	self.captionVisible = captionVisible
	self:get("captionFadeInfo")

	for _, v3 in pairs(self._groupSettings.caption) do
		self._settingsDictionary[v3].useForcedGroupValue = not captionVisible
		self:_update(v3)
	end
end

function NewIcon:join(parentIcon, joinedFeatureName, p)
	if self._parentIcon then
		self:leave()
	end

	local v3 = not joinedFeatureName and "dropdown" or joinedFeatureName:lower() or "dropdown"
	local v4 = "before" .. joinedFeatureName:sub(1, 1):upper() .. joinedFeatureName:sub(2)
	local instance = parentIcon.instances[joinedFeatureName .. "Frame"]
	self.presentOnTopbar = false
	self.joinedFeatureName = joinedFeatureName
	self._parentIcon = parentIcon
	self.instances.iconContainer.Parent = instance

	for k, notice in pairs(self.notices) do
		parentIcon:notify(notice.clearNoticeEvent, k)
	end

	if joinedFeatureName == "dropdown" then
		local dropdownSquareCorners = parentIcon:get("dropdownSquareCorners")
		self:set("iconSize", UDim2.new(1, 0, 0, self:get("iconSize", "deselected").Y.Offset), "deselected", v4)
		self:set("iconSize", UDim2.new(1, 0, 0, self:get("iconSize", "selected").Y.Offset), "selected", v4)

		if dropdownSquareCorners then
			self:set("iconCornerRadius", UDim.new(0, 0), "deselected", v4)
			self:set("iconCornerRadius", UDim.new(0, 0), "selected", v4)
		end

		self:set("captionBlockerTransparency", 0.4, nil, v4)
	end

	table.insert(parentIcon[v3 .. "Icons"], self)

	if not p then
		if joinedFeatureName == "dropdown" then
			parentIcon:_updateDropdown()
		elseif joinedFeatureName == "menu" then
			parentIcon:_updateMenu()
		end
	end

	parentIcon.deselectWhenOtherIconSelected = false
	IconController:_updateSelectionGroup()
	self:_decideToCallSignal("dropdown")
	self:_decideToCallSignal("menu")
	return self
end

function NewIcon:leave()
	if self._destroyed or self.instances.iconContainer.Parent == nil then
		return
	end

	local v3 = { "iconSize", "captionBlockerTransparency", "iconCornerRadius" }
	local _parentIcon = self._parentIcon
	self.instances.iconContainer.Parent = topbarContainer
	self.presentOnTopbar = true
	self.joinedFeatureName = nil

	local function scanFeature(list, p, callback)
		for k, v4 in pairs(list) do
			if v4 ~= self then
				continue
			end

			for _, v5 in pairs(v3) do
				for _, v6 in pairs({ "deselected", "selected" }) do
					local _, v7 = self:get(v5, v6, p)

					if v7 then
						self:set(v5, v7, v6)
					end
				end
			end

			table.remove(list, k)
			callback(_parentIcon)

			if #list ~= 0 then
				break
			end

			self._parentIcon.deselectWhenOtherIconSelected = true
			break
		end
	end

	scanFeature(_parentIcon.dropdownIcons, "beforeDropdown", _parentIcon._updateDropdown)
	scanFeature(_parentIcon.menuIcons, "beforeMenu", _parentIcon._updateMenu)

	for k, _ in pairs(self.notices) do
		local notice = _parentIcon.notices[k]

		if notice then
			notice.completeSignal:Fire()
		end
	end

	self._parentIcon = nil
	IconController:_updateSelectionGroup()
	self:_decideToCallSignal("dropdown")
	self:_decideToCallSignal("menu")
	return self
end

function NewIcon:_decideToCallSignal(value2)
	local v3 = self[value2 .. "Open"]
	local v4 = "_previous" .. string.sub(value2, 1, 1):upper() .. value2:sub(2) .. "Open"
	local v5 = self[v4]
	local count = #self[value2 .. "Icons"]

	if v3 and count > 0 and v5 == false then
		self[v4] = true
		self[value2 .. "Opened"]:Fire()
	elseif (not v3 or count == 0) and v5 == true then
		self[v4] = false
		self[value2 .. "Closed"]:Fire()
	end
end

function NewIcon:_ignoreClipping(p)
	local v3 = self:get(p .. "IgnoreClipping")

	if self._parentIcon then
		local v4 = self["_" .. p .. "ClippingMaid"]
		local instance = self.instances[p .. "Container"]
		v4:clean()

		if v3 then
			local frame = Instance.new("Frame")
			frame.Name = instance.Name .. "FakeFrame"
			frame.ClipsDescendants = true
			frame.BackgroundTransparency = 1
			frame.Size = instance.Size
			frame.Position = instance.Position
			frame.Parent = activeItems

			for _, child in pairs(instance:GetChildren()) do
				child.Parent = frame
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateSize()
				local absoluteSize = instance.AbsoluteSize
				frame.Size = UDim2.new(0, absoluteSize.X, 0, absoluteSize.Y)
			end

			v4:give(instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				updateSize() -- equivalent call inferred; original call site unknown
			end))
			updateSize() -- equivalent call inferred; original call site unknown

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updatePos()
				local absolutePosition = instance.absolutePosition
				frame.Position = UDim2.new(0, absolutePosition.X, 0, absolutePosition.Y + 36)
			end

			v4:give(instance:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
				updatePos() -- equivalent call inferred; original call site unknown
			end))
			updatePos() -- equivalent call inferred; original call site unknown
			v4:give(function()
				for _, child in pairs(frame:GetChildren()) do
					child.Parent = instance
				end

				frame.Name = "Destroying..."
				frame:Destroy()
			end)
		end
	end

	self._ignoreClippingChanged:Fire(p, v3)
end

function NewIcon:setDropdown(items)
	for _, dropdownIcon in pairs(self.dropdownIcons) do
		dropdownIcon:leave()
	end

	if type(items) == "table" then
		for _, item in pairs(items) do
			item:join(self, "dropdown", true)
		end
	end

	self:_updateDropdown()
	return self
end

function NewIcon:_updateDropdown()
	local v3 = {
		maxIconsBeforeScroll = self:get("dropdownMaxIconsBeforeScroll") or "_NIL",
		minWidth = self:get("dropdownMinWidth") or "_NIL",
		padding = self:get("dropdownListPadding") or "_NIL",
		dropdownAlignment = self:get("dropdownAlignment") or "_NIL",
		iconAlignment = self:get("alignment") or "_NIL",
		scrollBarThickness = self:get("dropdownScrollBarThickness") or "_NIL"
	}

	for _, v4 in pairs(v3) do
		if v4 == "_NIL" then
			return
		end
	end

	local offset = v3.padding.Offset
	local dropdownContainer = self.instances.dropdownContainer
	local dropdownFrame = self.instances.dropdownFrame
	local _ = self.instances.dropdownList
	local count = #self.dropdownIcons
	local maxIconsBeforeScroll

	if v3.maxIconsBeforeScroll < count then
		maxIconsBeforeScroll = v3.maxIconsBeforeScroll or count
	else
		maxIconsBeforeScroll = count
	end

	local v4 = -offset
	local minWidth = v3.minWidth
	table.sort(self.dropdownIcons, function(a, b)
		return a:get("order") < b:get("order")
	end)
	local total = 0

	for i = 1, count do
		local dropdownIcon = self.dropdownIcons[i]
		local _, v5 = dropdownIcon:get("iconSize", nil, "beforeDropdown")
		local v6 = v5.Y.Offset + offset

		if i <= maxIconsBeforeScroll then
			total += v6
		end

		if i == count then
			total += v6 / 4
		end

		v4 += v6
		local offset2 = v5.X.Offset

		if minWidth < offset2 then
			minWidth = offset2
		end

		local v7 = i == 1 and self or self.dropdownIcons[i - 1]
		local dropdownIcon2 = self.dropdownIcons[i + 1]
		dropdownIcon.instances.iconButton.NextSelectionUp = v7 and v7.instances.iconButton
		dropdownIcon.instances.iconButton.NextSelectionDown = dropdownIcon2 and dropdownIcon2.instances.iconButton
	end

	local v5 = maxIconsBeforeScroll == count and 0 or v4
	self:set("dropdownCanvasSize", UDim2.new(0, 0, 0, v5))
	self:set("dropdownSize", UDim2.new(0, (minWidth + 4) * 2, 0, total))
	local dropdownAlignment = v3.dropdownAlignment:lower()
	local v6 = {
		left = {
			AnchorPoint = Vector2.new(0, 0),
			PositionXScale = 0,
			ThicknessMultiplier = 0
		},
		mid = {
			AnchorPoint = Vector2.new(0.5, 0),
			PositionXScale = 0.5,
			ThicknessMultiplier = 0.5
		},
		right = {
			AnchorPoint = Vector2.new(0.5, 0),
			PositionXScale = 1,
			FrameAnchorPoint = Vector2.new(0, 0),
			FramePositionXScale = 0,
			ThicknessMultiplier = 1
		}
	}
	local v7 = v6[dropdownAlignment] or v6[v3.iconAlignment:lower()]
	dropdownContainer.AnchorPoint = v7.AnchorPoint
	dropdownContainer.Position = UDim2.new(v7.PositionXScale, 0, 1, offset + 0)
	local v8 = v3.scrollBarThickness * v7.ThicknessMultiplier
	local v9 = dropdownFrame.VerticalScrollBarPosition == Enum.VerticalScrollBarPosition.Right and v8 or -v8
	dropdownFrame.AnchorPoint = v7.FrameAnchorPoint or v7.AnchorPoint
	dropdownFrame.Position = UDim2.new(v7.FramePositionXScale or v7.PositionXScale, v9, 0, 0)
	self._dropdownCanvasPos = Vector2.new(0, 0)
end

function NewIcon:_dropdownIgnoreClipping()
	self:_ignoreClipping("dropdown")
end

function NewIcon:setMenu(items)
	for _, menuIcon in pairs(self.menuIcons) do
		menuIcon:leave()
	end

	if type(items) == "table" then
		for _, item in pairs(items) do
			item:join(self, "menu", true)
		end
	end

	self:_updateMenu()
	return self
end

function NewIcon:_getMenuDirection()
	local menuDirection = (self:get("menuDirection") or "_NIL"):lower()
	local alignment = (self:get("alignment") or "_NIL"):lower()

	if menuDirection ~= "left" and menuDirection ~= "right" then
		menuDirection = alignment == "left" and "right" or "left"
	end

	return menuDirection
end

function NewIcon:_updateMenu()
	local v3 = {
		maxIconsBeforeScroll = self:get("menuMaxIconsBeforeScroll") or "_NIL",
		direction = self:get("menuDirection") or "_NIL",
		iconAlignment = self:get("alignment") or "_NIL",
		scrollBarThickness = self:get("menuScrollBarThickness") or "_NIL"
	}

	for _, v4 in pairs(v3) do
		if v4 == "_NIL" then
			return
		end
	end

	local v4 = IconController[v3.iconAlignment .. "Gap"]
	local menuContainer = self.instances.menuContainer
	local menuFrame = self.instances.menuFrame
	local menuList = self.instances.menuList
	local count = #self.menuIcons
	local _getMenuDirection = self:_getMenuDirection()
	local maxIconsBeforeScroll

	if v3.maxIconsBeforeScroll < count then
		maxIconsBeforeScroll = v3.maxIconsBeforeScroll or count
	else
		maxIconsBeforeScroll = count
	end

	local v5 = -v4
	local fn = _getMenuDirection == "right" and (function(object3, object4)
		return object3:get("order") < object4:get("order")
	end or function(object3, object4)
		return object3:get("order") > object4:get("order")
	end) or function(object3, object4)
		return object3:get("order") > object4:get("order")
	end
	table.sort(self.menuIcons, fn)
	local v6 = 0
	local v7 = 0

	for i = 1, count do
		local menuIcon = self.menuIcons[i]
		local iconSize = menuIcon:get("iconSize")
		local v8 = iconSize.X.Offset + v4

		if i <= maxIconsBeforeScroll then
			v6 += v8
		end

		if i == maxIconsBeforeScroll and i ~= count then
			v6 -= 2
		end

		v5 += v8
		local offset = iconSize.Y.Offset

		if v7 < offset then
			v7 = offset
		end

		local menuIcon2 = self.menuIcons[i - 1]
		local menuIcon3 = self.menuIcons[i + 1]
		menuIcon.instances.iconButton.NextSelectionRight = menuIcon2 and menuIcon2.instances.iconButton
		menuIcon.instances.iconButton.NextSelectionLeft = menuIcon3 and menuIcon3.instances.iconButton
	end

	local v8 = maxIconsBeforeScroll == count and 0 or v5 + v4
	self:set("menuCanvasSize", UDim2.new(0, v8, 0, 0))
	self:set("menuSize", UDim2.new(0, v6, 0, v7 + v3.scrollBarThickness + 3))
	local v9 = ({
		left = {
			containerAnchorPoint = Vector2.new(1, 0),
			containerPosition = UDim2.new(0, -4, 0, 0),
			canvasPosition = Vector2.new(v8, 0)
		},
		right = {
			containerAnchorPoint = Vector2.new(0, 0),
			containerPosition = UDim2.new(1, v4 - 2, 0, 0),
			canvasPosition = Vector2.new(0, 0)
		}
	})[_getMenuDirection]
	menuContainer.AnchorPoint = v9.containerAnchorPoint
	menuContainer.Position = v9.containerPosition
	menuFrame.CanvasPosition = v9.canvasPosition
	self._menuCanvasPos = v9.canvasPosition
	menuList.Padding = UDim.new(0, v4)
end

function NewIcon:_menuIgnoreClipping()
	self:_ignoreClipping("menu")
end

function NewIcon:destroy()
	if self._destroyed then
		return
	end

	IconController.iconRemoved:Fire(self)
	self:clearNotices()

	if self._parentIcon then
		self:leave()
	end

	self:setDropdown()
	self:setMenu()
	self._destroyed = true
	self._maid:clean()
end

NewIcon.Destroy = NewIcon.destroy
v2.settings = {
	action = {
		toggleTransitionInfo = {},
		resizeInfo = {},
		repositionInfo = {},
		captionFadeInfo = {},
		tipFadeInfo = {},
		dropdownSlideInfo = {},
		menuSlideInfo = {}
	},
	toggleable = {
		iconBackgroundColor = {
			instanceNames = { "iconButton" },
			propertyName = "BackgroundColor3"
		},
		iconBackgroundTransparency = {
			instanceNames = { "iconButton" },
			propertyName = "BackgroundTransparency"
		},
		iconCornerRadius = {
			instanceNames = { "iconCorner", "iconOverlayCorner" },
			propertyName = "CornerRadius"
		},
		iconGradientColor = {
			instanceNames = { "iconGradient" },
			propertyName = "Color"
		},
		iconGradientRotation = {
			instanceNames = { "iconGradient" },
			propertyName = "Rotation"
		},
		iconImage = {
			callMethods = { NewIcon._updateIconSize },
			instanceNames = { "iconImage" },
			propertyName = "Image"
		},
		iconImageColor = {
			instanceNames = { "iconImage" },
			propertyName = "ImageColor3"
		},
		iconImageTransparency = {
			instanceNames = { "iconImage" },
			propertyName = "ImageTransparency"
		},
		iconScale = {
			instanceNames = { "iconButton" },
			propertyName = "Size"
		},
		forcedIconSizeX = {},
		forcedIconSizeY = {},
		iconSize = {
			callSignals = {},
			callMethods = { NewIcon._updateIconSize },
			instanceNames = { "iconContainer" },
			propertyName = "Size",
			tweenAction = "resizeInfo"
		},
		iconOffset = {
			instanceNames = { "iconButton" },
			propertyName = "Position"
		},
		iconText = {
			callMethods = { NewIcon._updateIconSize },
			instanceNames = { "iconLabel" },
			propertyName = "Text"
		},
		iconTextColor = {
			instanceNames = { "iconLabel" },
			propertyName = "TextColor3"
		},
		iconFont = {
			callMethods = { NewIcon._updateIconSize },
			instanceNames = { "iconLabel" },
			propertyName = "Font"
		},
		iconImageYScale = {
			callMethods = { NewIcon._updateIconSize }
		},
		iconImageRatio = {
			callMethods = { NewIcon._updateIconSize }
		},
		iconLabelYScale = {
			callMethods = { NewIcon._updateIconSize }
		},
		noticeCircleColor = {
			instanceNames = { "noticeFrame" },
			propertyName = "ImageColor3"
		},
		noticeCircleImage = {
			instanceNames = { "noticeFrame" },
			propertyName = "Image"
		},
		noticeTextColor = {
			instanceNames = { "noticeLabel" },
			propertyName = "TextColor3"
		},
		noticeImageTransparency = {
			instanceNames = { "noticeFrame" },
			propertyName = "ImageTransparency"
		},
		noticeTextTransparency = {
			instanceNames = { "noticeLabel" },
			propertyName = "TextTransparency"
		},
		baseZIndex = {
			callMethods = { NewIcon._updateBaseZIndex }
		},
		order = {
			callSignals = {},
			instanceNames = { "iconContainer" },
			propertyName = "LayoutOrder"
		},
		alignment = {
			callSignals = {},
			callMethods = { NewIcon._updateDropdown }
		},
		iconImageVisible = {
			instanceNames = { "iconImage" },
			propertyName = "Visible"
		},
		iconImageAnchorPoint = {
			instanceNames = { "iconImage" },
			propertyName = "AnchorPoint"
		},
		iconImagePosition = {
			instanceNames = { "iconImage" },
			propertyName = "Position",
			tweenAction = "resizeInfo"
		},
		iconImageSize = {
			instanceNames = { "iconImage" },
			propertyName = "Size",
			tweenAction = "resizeInfo"
		},
		iconImageTextXAlignment = {
			instanceNames = { "iconImage" },
			propertyName = "TextXAlignment"
		},
		iconLabelVisible = {
			instanceNames = { "iconLabel" },
			propertyName = "Visible"
		},
		iconLabelAnchorPoint = {
			instanceNames = { "iconLabel" },
			propertyName = "AnchorPoint"
		},
		iconLabelPosition = {
			instanceNames = { "iconLabel" },
			propertyName = "Position",
			tweenAction = "resizeInfo"
		},
		iconLabelSize = {
			instanceNames = { "iconLabel" },
			propertyName = "Size",
			tweenAction = "resizeInfo"
		},
		iconLabelTextXAlignment = {
			instanceNames = { "iconLabel" },
			propertyName = "TextXAlignment"
		},
		iconLabelTextSize = {
			instanceNames = { "iconLabel" },
			propertyName = "TextSize"
		},
		noticeFramePosition = {
			instanceNames = { "noticeFrame" },
			propertyName = "Position"
		},
		clickSoundId = {
			instanceNames = { "clickSound" },
			propertyName = "SoundId"
		},
		clickVolume = {
			instanceNames = { "clickSound" },
			propertyName = "Volume"
		},
		clickPlaybackSpeed = {
			instanceNames = { "clickSound" },
			propertyName = "PlaybackSpeed"
		},
		clickTimePosition = {
			instanceNames = { "clickSound" },
			propertyName = "TimePosition"
		}
	},
	other = {
		captionBackgroundColor = {
			instanceNames = { "captionFrame" },
			propertyName = "BackgroundColor3"
		},
		captionBackgroundTransparency = {
			instanceNames = { "captionFrame" },
			propertyName = "BackgroundTransparency",
			group = "caption"
		},
		captionBlockerTransparency = {
			instanceNames = { "captionVisibilityBlocker" },
			propertyName = "BackgroundTransparency",
			group = "caption"
		},
		captionOverlineColor = {
			instanceNames = { "captionOverline" },
			propertyName = "BackgroundColor3"
		},
		captionOverlineTransparency = {
			instanceNames = { "captionOverline" },
			propertyName = "BackgroundTransparency",
			group = "caption"
		},
		captionTextColor = {
			instanceNames = { "captionLabel" },
			propertyName = "TextColor3"
		},
		captionTextTransparency = {
			instanceNames = { "captionLabel" },
			propertyName = "TextTransparency",
			group = "caption"
		},
		captionFont = {
			instanceNames = { "captionLabel" },
			propertyName = "Font"
		},
		captionCornerRadius = {
			instanceNames = { "captionCorner", "captionOverlineCorner", "captionVisibilityCorner" },
			propertyName = "CornerRadius"
		},
		tipBackgroundColor = {
			instanceNames = { "tipFrame" },
			propertyName = "BackgroundColor3"
		},
		tipBackgroundTransparency = {
			instanceNames = { "tipFrame" },
			propertyName = "BackgroundTransparency",
			group = "tip"
		},
		tipTextColor = {
			instanceNames = { "tipLabel" },
			propertyName = "TextColor3"
		},
		tipTextTransparency = {
			instanceNames = { "tipLabel" },
			propertyName = "TextTransparency",
			group = "tip"
		},
		tipFont = {
			instanceNames = { "tipLabel" },
			propertyName = "Font"
		},
		tipCornerRadius = {
			instanceNames = { "tipCorner" },
			propertyName = "CornerRadius"
		},
		dropdownSize = {
			instanceNames = { "dropdownContainer" },
			propertyName = "Size",
			unique = "dropdown"
		},
		dropdownCanvasSize = {
			instanceNames = { "dropdownFrame" },
			propertyName = "CanvasSize"
		},
		dropdownMaxIconsBeforeScroll = {
			callMethods = { NewIcon._updateDropdown }
		},
		dropdownMinWidth = {
			callMethods = { NewIcon._updateDropdown }
		},
		dropdownSquareCorners = {
			callMethods = { NewIcon._updateDropdown }
		},
		dropdownBindToggleToIcon = {},
		dropdownToggleOnLongPress = {},
		dropdownToggleOnRightClick = {},
		dropdownCloseOnTapAway = {},
		dropdownHidePlayerlistOnOverlap = {},
		dropdownListPadding = {
			callMethods = { NewIcon._updateDropdown },
			instanceNames = { "dropdownList" },
			propertyName = "Padding"
		},
		dropdownAlignment = {
			callMethods = { NewIcon._updateDropdown }
		},
		dropdownScrollBarColor = {
			instanceNames = { "dropdownFrame" },
			propertyName = "ScrollBarImageColor3"
		},
		dropdownScrollBarTransparency = {
			instanceNames = { "dropdownFrame" },
			propertyName = "ScrollBarImageTransparency"
		},
		dropdownScrollBarThickness = {
			instanceNames = { "dropdownFrame" },
			propertyName = "ScrollBarThickness"
		},
		dropdownIgnoreClipping = {
			callMethods = { NewIcon._dropdownIgnoreClipping }
		},
		menuSize = {
			instanceNames = { "menuContainer" },
			propertyName = "Size",
			unique = "menu"
		},
		menuCanvasSize = {
			instanceNames = { "menuFrame" },
			propertyName = "CanvasSize"
		},
		menuMaxIconsBeforeScroll = {
			callMethods = { NewIcon._updateMenu }
		},
		menuBindToggleToIcon = {},
		menuToggleOnLongPress = {},
		menuToggleOnRightClick = {},
		menuCloseOnTapAway = {},
		menuListPadding = {
			callMethods = { NewIcon._updateMenu },
			instanceNames = { "menuList" },
			propertyName = "Padding"
		},
		menuDirection = {
			callMethods = { NewIcon._updateMenu }
		},
		menuScrollBarColor = {
			instanceNames = { "menuFrame" },
			propertyName = "ScrollBarImageColor3"
		},
		menuScrollBarTransparency = {
			instanceNames = { "menuFrame" },
			propertyName = "ScrollBarImageTransparency"
		},
		menuScrollBarThickness = {
			instanceNames = { "menuFrame" },
			propertyName = "ScrollBarThickness"
		},
		menuIgnoreClipping = {
			callMethods = { NewIcon._menuIgnoreClipping }
		}
	}
}
v2.groupSettings = {}
v2.uniqueSettings = {}
v2.flat = {}
v2.metas = {}

for k, setting in pairs(v2.settings) do
	for k2, v3 in pairs(setting) do
		v3.type = k
		local group = v3.group

		if group then
			local groupSetting = v2.groupSettings[group]

			if not groupSetting then
				groupSetting = {}
				v2.groupSettings[group] = groupSetting
			end

			table.insert(groupSetting, k2)
			v3.forcedGroupValue = v[group]
			v3.useForcedGroupValue = true
		end

		local unique = v3.unique

		if unique then
			local v4 = v2.uniqueSettings[unique] or {}
			table.insert(v4, k2)
			v2.uniqueSettings[unique] = v4
		end

		v2.flat[k2] = v3
		v2.metas[k2] = {
			__index = v3
		}
	end
end

return NewIcon