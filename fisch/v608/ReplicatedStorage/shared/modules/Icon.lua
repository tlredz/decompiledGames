game:GetService("LocalizationService")
local UserInputService = game:GetService("UserInputService")
game:GetService("RunService")
game:GetService("TextService")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local script2 = script
local Reference = require(script2.Reference)
local object = Reference.getObject()
local value = object and object.Value

if value and value ~= script2 then
	return require(value)
end

if not object then
	Reference.addToReplicatedStorage()
end

local GoodSignal = require(script2.Packages.GoodSignal)
local Janitor = require(script2.Packages.Janitor)
local Utility = require(script2.Utility)
require(script2.Attribute)
local Themes = require(script2.Features.Themes)
local Gamepad = require(script2.Features.Gamepad)
local Overflow = require(script2.Features.Overflow)
local Icon = {}
Icon.__index = Icon
local localPlayer = Players.LocalPlayer
local themes = script2.Features.Themes
local playerGui = localPlayer:WaitForChild("PlayerGui")
local iconsDictionary = {}
local v2 = GoodSignal.new()
local elements = script2.Elements
local count = 0

if GuiService.TopbarInset.Height == 0 then
	GuiService:GetPropertyChangedSignal("TopbarInset"):Wait()
end

Icon.baseDisplayOrderChanged = GoodSignal.new()
Icon.baseDisplayOrder = 10
Icon.baseTheme = require(themes.Default)
Icon.isOldTopbar = GuiService.TopbarInset.Height == 36
Icon.iconsDictionary = iconsDictionary
local Container = require(elements.Container)
Icon.container = Container(Icon)
Icon.topbarEnabled = true
Icon.iconAdded = GoodSignal.new()
Icon.iconRemoved = GoodSignal.new()
Icon.iconChanged = GoodSignal.new()

function Icon.getIcons()
	return Icon.iconsDictionary
end

function Icon.getIconByUID(p)
	local v3 = Icon.iconsDictionary[p]

	if v3 then
		return v3
	end
end

function Icon.getIcon(p)
	local iconByUID = Icon.getIconByUID(p)

	if iconByUID then
		return iconByUID
	end

	for _, v3 in pairs(iconsDictionary) do
		if v3.name == p then
			return v3
		end
	end
end

function Icon.setTopbarEnabled(topbarEnabled, p)
	if typeof(topbarEnabled) ~= "boolean" then
		topbarEnabled = Icon.topbarEnabled
	end

	if not p then
		Icon.topbarEnabled = topbarEnabled
	end

	for _, v3 in pairs(Icon.container) do
		v3.Enabled = topbarEnabled
	end
end

function Icon.modifyBaseTheme(p)
	local modifications = Themes.getModifications(p)

	for _, modification in pairs(modifications) do
		for _, v3 in pairs(Icon.baseTheme) do
			Themes.merge(v3, modification)
		end
	end

	for _, v3 in pairs(iconsDictionary) do
		v3:setTheme(Icon.baseTheme)
	end
end

function Icon.setDisplayOrder(baseDisplayOrder)
	Icon.baseDisplayOrder = baseDisplayOrder
	Icon.baseDisplayOrderChanged:Fire(baseDisplayOrder)
end

task.defer(Gamepad.start, Icon)
task.defer(Overflow.start, Icon)

for _, v3 in pairs(Icon.container) do
	v3.Parent = playerGui
end

if Icon.isOldTopbar then
	Icon.modifyBaseTheme(require(themes.Classic))
end

function Icon.new()
	local class = {}
	setmetatable(class, Icon)
	local janitor = Janitor.new()
	class.janitor = janitor
	class.themesJanitor = janitor:add(Janitor.new())
	class.singleClickJanitor = janitor:add(Janitor.new())
	class.captionJanitor = janitor:add(Janitor.new())
	class.joinJanitor = janitor:add(Janitor.new())
	class.menuJanitor = janitor:add(Janitor.new())
	class.dropdownJanitor = janitor:add(Janitor.new())
	local UID = Utility.generateUID()
	iconsDictionary[UID] = class
	janitor:add(function()
		iconsDictionary[UID] = nil
	end)
	class.selected = janitor:add(GoodSignal.new())
	class.deselected = janitor:add(GoodSignal.new())
	class.toggled = janitor:add(GoodSignal.new())
	class.viewingStarted = janitor:add(GoodSignal.new())
	class.viewingEnded = janitor:add(GoodSignal.new())
	class.stateChanged = janitor:add(GoodSignal.new())
	class.notified = janitor:add(GoodSignal.new())
	class.noticeStarted = janitor:add(GoodSignal.new())
	class.noticeChanged = janitor:add(GoodSignal.new())
	class.endNotices = janitor:add(GoodSignal.new())
	class.toggleKeyAdded = janitor:add(GoodSignal.new())
	class.fakeToggleKeyChanged = janitor:add(GoodSignal.new())
	class.alignmentChanged = janitor:add(GoodSignal.new())
	class.updateSize = janitor:add(GoodSignal.new())
	class.resizingComplete = janitor:add(GoodSignal.new())
	class.joinedParent = janitor:add(GoodSignal.new())
	class.menuSet = janitor:add(GoodSignal.new())
	class.dropdownSet = janitor:add(GoodSignal.new())
	class.updateMenu = janitor:add(GoodSignal.new())
	class.startMenuUpdate = janitor:add(GoodSignal.new())
	class.childThemeModified = janitor:add(GoodSignal.new())
	class.indicatorSet = janitor:add(GoodSignal.new())
	class.dropdownChildAdded = janitor:add(GoodSignal.new())
	class.menuChildAdded = janitor:add(GoodSignal.new())
	class.iconModule = script2
	class.UID = UID
	class.isEnabled = true
	class.isSelected = false
	class.isViewing = false
	class.joinedFrame = false
	class.parentIconUID = false
	class.deselectWhenOtherIconSelected = true
	class.totalNotices = 0
	class.activeState = "Deselected"
	class.alignment = ""
	class.originalAlignment = ""
	class.appliedTheme = {}
	class.appearance = {}
	class.cachedInstances = {}
	class.cachedNamesToInstances = {}
	class.cachedCollectives = {}
	class.bindedToggleKeys = {}
	class.customBehaviours = {}
	class.toggleItems = {}
	class.bindedEvents = {}
	class.notices = {}
	class.menuIcons = {}
	class.dropdownIcons = {}
	class.childIconsDict = {}
	class.isOldTopbar = Icon.isOldTopbar
	class.creationTime = os.clock()
	local Widget = require(elements.Widget)
	class.widget = janitor:add(Widget(class, Icon))
	class:setAlignment()
	count += 1
	class:setOrder(count)
	class:setTheme(Icon.baseTheme)
	local instance = class:getInstance("ClickRegion")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function handleToggle()
		if class.locked then
			return
		end

		if class.isSelected then
			class:deselect("User", class)
		else
			class:select("User", class)
		end
	end

	local flag = false
	local flag2 = false
	instance.MouseButton1Click:Connect(function()
		if flag then
			return
		end

		flag2 = true
		task.delay(0.01, function()
			flag2 = false
		end)
		handleToggle() -- equivalent call inferred; original call site unknown
	end)
	instance.TouchTap:Connect(function()
		if flag2 then
			return
		end

		flag = true
		task.delay(0.01, function()
			flag = false
		end)
		handleToggle() -- equivalent call inferred; original call site unknown
	end)
	janitor:add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if class.locked then
			return
		end

		if class.bindedToggleKeys[input.KeyCode] and not gameProcessed then
			handleToggle() -- equivalent call inferred; original call site unknown
		end
	end))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function viewingStarted(p)
		if class.locked then
			return
		end

		class.isViewing = true
		class.viewingStarted:Fire(true)

		if not p then
			class:setState("Viewing", "User", class)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function viewingEnded()
		if class.locked then
			return
		end

		class.isViewing = false
		class.viewingEnded:Fire(true)
		class:setState(nil, "User", class)
	end

	class.joinedParent:Connect(function()
		if class.isViewing then
			viewingEnded() -- equivalent call inferred; original call site unknown
		end
	end)
	instance.MouseEnter:Connect(function()
		viewingStarted(not UserInputService.KeyboardEnabled) -- equivalent call inferred; original call site unknown
	end)
	local count2 = 0
	janitor:add(UserInputService.TouchEnded:Connect(viewingEnded))
	instance.MouseLeave:Connect(viewingEnded)
	instance.SelectionGained:Connect(viewingStarted)
	instance.SelectionLost:Connect(viewingEnded)
	instance.MouseButton1Down:Connect(function()
		if not class.locked and UserInputService.TouchEnabled then
			count2 += 1
			local v4 = count2
			task.delay(0.2, function()
				if v4 == count2 then
					viewingStarted(false) -- equivalent call inferred; original call site unknown
				end
			end)
		end
	end)
	instance.MouseButton1Up:Connect(function()
		count2 += 1
	end)
	local instance2 = class:getInstance("IconOverlay")
	class.viewingStarted:Connect(function()
		instance2.Visible = not class.overlayDisabled
	end)
	class.viewingEnded:Connect(function()
		instance2.Visible = false
	end)
	janitor:add(v2:Connect(function(p)
		if p ~= class and class.deselectWhenOtherIconSelected and p.deselectWhenOtherIconSelected then
			class:deselect("AutoDeselect", p)
		end
	end))
	local v4 = debug.info(2, "s")
	local v5 = string.split(v4, ".")
	local game2 = game
	local v6 = nil

	for _, childName in pairs(v5) do
		game2 = game2:FindFirstChild(childName)

		if game2 then
			if game2:IsA("ScreenGui") then
				v6 = game2
			end
		else
			break
		end
	end

	if game2 and v6 and v6.ResetOnSpawn == true then
		Utility.localPlayerRespawned(function()
			class:destroy()
		end)
	end

	class:getInstance("NoticeLabel")
	class.toggled:Connect(function(p)
		class.noticeChanged:Fire(class.totalNotices)

		for k, _ in pairs(class.childIconsDict) do
			local iconByUID = Icon.getIconByUID(k)
			iconByUID.noticeChanged:Fire(iconByUID.totalNotices)

			if p or not iconByUID.isSelected then
				continue
			end

			for _, _ in pairs(iconByUID.childIconsDict) do
				iconByUID:deselect("HideParentFeature", class)
			end
		end
	end)
	class.selected:Connect(function()
		if #class.dropdownIcons > 0 then
			if StarterGui:GetCore("ChatActive") and class.alignment ~= "Right" then
				class.chatWasPreviouslyActive = true
				StarterGui:SetCore("ChatActive", false)
			end

			if StarterGui:GetCoreGuiEnabled("PlayerList") and class.alignment ~= "Left" then
				class.playerlistWasPreviouslyActive = true
				StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
			end
		end
	end)
	class.deselected:Connect(function()
		if class.chatWasPreviouslyActive then
			class.chatWasPreviouslyActive = nil
			StarterGui:SetCore("ChatActive", true)
		end

		if class.playerlistWasPreviouslyActive then
			class.playerlistWasPreviouslyActive = nil
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
		end
	end)
	task.delay(0.1, function()
		if class.activeState == "Deselected" then
			class.stateChanged:Fire("Deselected")
			class:refresh()
		end
	end)
	Icon.iconAdded:Fire(class)
	return class
end

function Icon:setName(name)
	self.widget.Name = name
	self.name = name
	return self
end

function Icon:setState(p, p2, p3)
	local v3 = p or self.isSelected and "Selected" or "Deselected"
	local formatStateName = Utility.formatStateName(v3)

	if self.activeState == formatStateName then
		return
	end

	local isSelected = self.isSelected
	self.activeState = formatStateName

	if formatStateName == "Deselected" then
		self.isSelected = false

		if isSelected then
			self.toggled:Fire(false, p2, p3)
			self.deselected:Fire(p2, p3)
		end

		self:_setToggleItemsVisible(false, p2, p3)
	elseif formatStateName == "Selected" then
		self.isSelected = true

		if not isSelected then
			self.toggled:Fire(true, p2, p3)
			self.selected:Fire(p2, p3)
			v2:Fire(self, p2, p3)
		end

		self:_setToggleItemsVisible(true, p2, p3)
	end

	self.stateChanged:Fire(formatStateName, p2, p3)
end

function Icon:getInstance(p)
	local cachedNamesToInstance = self.cachedNamesToInstances[p]

	if cachedNamesToInstance then
		return cachedNamesToInstance
	end

	local function cacheInstance(p2, instance)
		if not self.cachedInstances[instance] then
			local collective = instance:GetAttribute("Collective")
			local instances = collective and self.cachedCollectives[collective]

			if instances then
				table.insert(instances, instance)
			end

			self.cachedNamesToInstances[p2] = instance
			self.cachedInstances[instance] = true
			instance.Destroying:Once(function()
				self.cachedNamesToInstances[p2] = nil
				self.cachedInstances[instance] = nil
			end)
		end
	end

	local widget = self.widget
	cacheInstance("Widget", widget)

	if p == "Widget" then
		return widget
	end

	local v3 = nil
	local scanChildren

	scanChildren = function(instance)
		for _, child in pairs(instance:GetChildren()) do
			local widgetUID = child:GetAttribute("WidgetUID")

			if not (not widgetUID or widgetUID == self.UID) then
				continue
			end

			local instance2 = Themes.getRealInstance(child) or child
			scanChildren(instance2)

			if not (instance2:IsA("GuiBase") or instance2:IsA("UIBase") or instance2:IsA("ValueBase")) then
				continue
			end

			local name = instance2.Name
			cacheInstance(name, instance2)

			if name == p then
				v3 = instance2
			end
		end
	end

	scanChildren(widget)
	return v3
end

function Icon:getCollective(p2)
	local cachedCollective = self.cachedCollectives[p2]

	if cachedCollective then
		return cachedCollective
	end

	local result = {}

	for k, _ in pairs(self.cachedInstances) do
		if k:GetAttribute("Collective") == p2 then
			table.insert(result, k)
		end
	end

	self.cachedCollectives[p2] = result
	return result
end

function Icon:getInstanceOrCollective(p)
	local instances = {}
	local instance = self:getInstance(p)

	if instance then
		table.insert(instances, instance)
	end

	if #instances == 0 then
		instances = self:getCollective(p)
	end

	return instances
end

function Icon.getStateGroup(p, p2)
	local v3 = p2 or p.activeState
	local v4 = p.appearance[v3]

	if not v4 then
		v4 = {}
		p.appearance[v3] = v4
	end

	return v4
end

function Icon:refreshAppearance(p2, p3)
	Themes.refresh(self, p2, p3)
	return self
end

function Icon:refresh()
	self:refreshAppearance(self.widget)
	self.updateSize:Fire()
	return self
end

function Icon:updateParent()
	local iconByUID = Icon.getIconByUID(self.parentIconUID)

	if iconByUID then
		iconByUID.updateSize:Fire()
	end
end

function Icon:setBehaviour(p, p2, p3, p4)
	local v3 = p .. "-" .. p2
	self.customBehaviours[v3] = p3

	if p4 then
		local instanceOrCollective = self:getInstanceOrCollective(p)

		for _, v4 in pairs(instanceOrCollective) do
			self:refreshAppearance(v4, p2)
		end
	end
end

function Icon:modifyTheme(p2, p3)
	return self, (Themes.modify(self, p2, p3))
end

function Icon:modifyChildTheme(childModifications, childModificationsUID)
	self.childModifications = childModifications
	self.childModificationsUID = childModificationsUID

	for k, _ in pairs(self.childIconsDict) do
		Icon.getIconByUID(k):modifyTheme(childModifications, childModificationsUID)
	end

	self.childThemeModified:Fire()
	return self
end

function Icon.removeModification(p, p2)
	Themes.remove(p, p2)
	return p
end

function Icon.removeModificationWith(p, p2, p3, p4)
	Themes.removeWith(p, p2, p3, p4)
	return p
end

function Icon:setTheme(p2)
	Themes.set(self, p2)
	return self
end

function Icon:setEnabled(p)
	self.isEnabled = p
	self.widget.Visible = p
	self:updateParent()
	return self
end

function Icon:select(p, p2)
	self:setState("Selected", p, p2)
	return self
end

function Icon:deselect(p, p2)
	self:setState("Deselected", p, p2)
	return self
end

function Icon:notify(p, p2)
	if not self.notice then
		local Notice = require(elements.Notice)
		self.notice = Notice(self, Icon)
	end

	self.noticeStarted:Fire(p, p2)
	return self
end

function Icon:clearNotices()
	self.endNotices:Fire()
	return self
end

function Icon:disableOverlay(overlayDisabled)
	self.overlayDisabled = overlayDisabled
	return self
end

Icon.disableStateOverlay = Icon.disableOverlay

function Icon:setImage(p, p2)
	self:modifyTheme({
		"IconImage",
		"Image",
		p,
		p2
	})
	return self
end

function Icon:setLabel(p, p2)
	self:modifyTheme({
		"IconLabel",
		"Text",
		p,
		p2
	})
	return self
end

function Icon:setOrder(p, p2)
	self:modifyTheme({
		"Widget",
		"LayoutOrder",
		p,
		p2
	})
	return self
end

function Icon:setCornerRadius(p, p2)
	self:modifyTheme({
		"IconCorners",
		"CornerRadius",
		p,
		p2
	})
	return self
end

function Icon:align(p, p2)
	local lower = tostring(p):lower()
	local v3 = (lower == "mid" or lower == "centre") and "center" or lower
	local v4 = v3 ~= "left" and v3 ~= "center" and v3 ~= "right" and "left" or v3
	local topbarCentered = v4 == "center" and Icon.container.TopbarCentered or Icon.container.TopbarStandard
	local holders = topbarCentered.Holders
	local v5 = string.upper((string.sub(v4, 1, 1))) .. string.sub(v4, 2)

	if not p2 then
		self.originalAlignment = v5
	end

	local joinedFrame = self.joinedFrame
	local holder = holders[v5]
	self.screenGui = topbarCentered
	self.alignmentHolder = holder

	if not self.isDestroyed then
		self.widget.Parent = joinedFrame or holder
	end

	self.alignment = v5
	self.alignmentChanged:Fire(v5)
	Icon.iconChanged:Fire(self)
	return self
end

Icon.setAlignment = Icon.align

function Icon.setLeft(object2)
	object2:setAlignment("Left")
	return object2
end

function Icon.setMid(object2)
	object2:setAlignment("Center")
	return object2
end

function Icon.setRight(object2)
	object2:setAlignment("Right")
	return object2
end

function Icon:setWidth(p, p2)
	self:modifyTheme({
		"Widget",
		"Size",
		UDim2.fromOffset(p, self.widget.Size.Y.Offset),
		p2
	})
	self:modifyTheme({
		"Widget",
		"DesiredWidth",
		p,
		p2
	})
	return self
end

function Icon:setImageScale(p, p2)
	self:modifyTheme({
		"IconImageScale",
		"Value",
		p,
		p2
	})
	return self
end

function Icon:setImageRatio(p, p2)
	self:modifyTheme({
		"IconImageRatio",
		"AspectRatio",
		p,
		p2
	})
	return self
end

function Icon:setTextSize(p, p2)
	self:modifyTheme({
		"IconLabel",
		"TextSize",
		p,
		p2
	})
	return self
end

function Icon:setTextFont(value2, p, p2, p3)
	local v3 = p or Enum.FontWeight.Regular
	local v4 = p2 or Enum.FontStyle.Normal
	local font = nil
	local typeName = typeof(value2)

	if typeName == "number" then
		font = Font.fromId(value2, v3, v4)
	elseif typeName == "EnumItem" then
		font = Font.fromEnum(value2)
	elseif typeName == "string" and not value2:match("rbxasset") then
		font = Font.fromName(value2, v3, v4)
	end

	self:modifyTheme({
		"IconLabel",
		"FontFace",
		font or Font.new(value2, v3, v4),
		p3
	})
	return self
end

function Icon:bindToggleItem(instance)
	if not (instance:IsA("GuiObject") or instance:IsA("LayerCollector")) then
		error("Toggle item must be a GuiObject or LayerCollector!")
	end

	self.toggleItems[instance] = true
	self:_updateSelectionInstances()
	return self
end

function Icon:unbindToggleItem(p)
	self.toggleItems[p] = nil
	self:_updateSelectionInstances()
	return self
end

function Icon:_updateSelectionInstances()
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

function Icon:_setToggleItemsVisible(p2, _, p3)
	for layerCollector, _ in pairs(self.toggleItems) do
		if not p3 or p3 == self or p3.toggleItems[layerCollector] == nil then
			layerCollector[layerCollector:IsA("LayerCollector") and "Enabled" or "Visible"] = p2
		end
	end
end

function Icon:bindEvent(p2, callback)
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
	self.bindedEvents[p2] = v3:Connect(function(...)
		callback(self, ...)
	end)
	return self
end

function Icon.unbindEvent(p, p2)
	local bindedEvent = p.bindedEvents[p2]

	if bindedEvent then
		bindedEvent:Disconnect()
		p.bindedEvents[p2] = nil
	end

	return p
end

function Icon:bindToggleKey(p)
	assert(typeof(p) == "EnumItem", "argument[1] must be a KeyCode EnumItem!")
	self.bindedToggleKeys[p] = true
	self.toggleKeyAdded:Fire(p)
	self:setCaption("_hotkey_")
	return self
end

function Icon.unbindToggleKey(p, p2)
	assert(typeof(p2) == "EnumItem", "argument[1] must be a KeyCode EnumItem!")
	p.bindedToggleKeys[p2] = nil
	return p
end

function Icon.call(p, callback, ...)
	local v3 = table.pack(...)
	task.spawn(function()
		callback(p, table.unpack(v3))
	end)
	return p
end

function Icon.addToJanitor(p, p2)
	p.janitor:add(p2)
	return p
end

function Icon:lock()
	local instance = self:getInstance("ClickRegion")
	instance.Visible = false
	self.locked = true
	return self
end

function Icon:unlock()
	local instance = self:getInstance("ClickRegion")
	instance.Visible = true
	self.locked = false
	return self
end

function Icon:debounce(duration)
	self:lock()
	task.wait(duration)
	self:unlock()
	return self
end

function Icon:autoDeselect(p2)
	self.deselectWhenOtherIconSelected = p2 == nil or p2
	return self
end

function Icon:oneClick(p)
	local singleClickJanitor = self.singleClickJanitor
	singleClickJanitor:clean()

	if p or p == nil then
		singleClickJanitor:add(self.selected:Connect(function()
			self:deselect("OneClick", self)
		end))
	end

	self.oneClickEnabled = true
	return self
end

function Icon:setCaption(captionText)
	if captionText == "_hotkey_" and self.captionText then
		return self
	end

	local captionJanitor = self.captionJanitor
	self.captionJanitor:clean()

	if captionText and captionText ~= "" then
		local Caption = require(elements.Caption)
		local caption = captionJanitor:add(Caption(self))
		caption:SetAttribute("CaptionText", captionText)
		self.caption = caption
		self.captionText = captionText
		return self
	else
		self.caption = nil
		self.captionText = nil
		return self
	end
end

function Icon:setCaptionHint(fakeToggleKey)
	assert(typeof(fakeToggleKey) == "EnumItem", "argument[1] must be a KeyCode EnumItem!")
	self.fakeToggleKey = fakeToggleKey
	self.fakeToggleKeyChanged:Fire(fakeToggleKey)
	self:setCaption("_hotkey_")
	return self
end

function Icon:leave()
	self.joinJanitor:clean()
	return self
end

function Icon.joinMenu(p, object2)
	Utility.joinFeature(p, object2, object2.menuIcons, object2:getInstance("Menu"))
	object2.menuChildAdded:Fire(p)
	return p
end

function Icon:setMenu(p2)
	self.menuSet:Fire(p2)
	return self
end

function Icon:setFrozenMenu(p)
	self:freezeMenu(p)
	self:setMenu(p)
end

function Icon:freezeMenu()
	self:select("FrozenMenu", self)
	self:bindEvent("deselected", function(object3)
		object3:select("FrozenMenu", self)
	end)
	self:modifyTheme({ "IconSpot", "Visible", false })
end

function Icon.joinDropdown(p, object2)
	object2:getDropdown()
	Utility.joinFeature(p, object2, object2.dropdownIcons, object2:getInstance("DropdownScroller"))
	object2.dropdownChildAdded:Fire(p)
	return p
end

function Icon:getDropdown()
	local dropdown = self.dropdown

	if dropdown then
		return dropdown
	end

	local Dropdown = require(elements.Dropdown)
	dropdown = Dropdown(self)
	self.dropdown = dropdown
	self:clipOutside(dropdown)
	return dropdown
end

function Icon:setDropdown(p)
	self:getDropdown()
	self.dropdownSet:Fire(p)
	return self
end

function Icon:clipOutside(p)
	local clipOutside = Utility.clipOutside(self, p)
	self:refreshAppearance(p)
	return self, clipOutside
end

function Icon:setIndicator(p)
	if not self.indicator then
		local janitor = self.janitor
		local Indicator = require(elements.Indicator)
		self.indicator = janitor:add(Indicator(self, Icon))
	end

	self.indicatorSet:Fire(p)
end

function Icon:destroy()
	if self.isDestroyed then
		return
	end

	self:clearNotices()

	if self.parentIconUID then
		self:leave()
	end

	self.isDestroyed = true
	self.janitor:clean()
	Icon.iconRemoved:Fire(self)
end

Icon.Destroy = Icon.destroy
return Icon