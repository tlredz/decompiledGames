local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
require(script.Types)
local script2 = script
local Reference = require(script2.Reference)
local object = Reference.getObject()
local value = object and object.Value

if value and value ~= script2 then
	local module = require(value)
	return module
end

if not object then
	Reference.addToReplicatedStorage()
end

local GoodSignal = require(script2.Packages.GoodSignal)
local Janitor = require(script2.Packages.Janitor)
local Utility = require(script2.Utility)
local Themes = require(script2.Features.Themes)
local Gamepad = require(script2.Features.Gamepad)
local Overflow = require(script2.Features.Overflow)
local TopbarPlus = {}
TopbarPlus.__index = TopbarPlus
local localPlayer = Players.LocalPlayer
local themes = script2.Features.Themes
local iconsDictionary = {}
local v2 = GoodSignal.new()
local elements = script2.Elements
local count = 0
local v3 = {
	mobile = Enum.PreferredInput.Touch,
	desktop = Enum.PreferredInput.KeyboardAndMouse,
	console = Enum.PreferredInput.Gamepad
}
TopbarPlus.baseDisplayOrderChanged = GoodSignal.new()
TopbarPlus.baseDisplayOrder = 10
TopbarPlus.baseTheme = require(themes.Default)
TopbarPlus.isOldTopbar = false
TopbarPlus.iconsDictionary = iconsDictionary
TopbarPlus.insetHeightChanged = GoodSignal.new()
local Container = require(elements.Container)
TopbarPlus.container = Container(TopbarPlus)
TopbarPlus.topbarEnabled = true
TopbarPlus.iconAdded = GoodSignal.new()
TopbarPlus.iconRemoved = GoodSignal.new()
TopbarPlus.iconChanged = GoodSignal.new()

function TopbarPlus.getIcons()
	return TopbarPlus.iconsDictionary
end

function TopbarPlus.getIconByUID(p)
	local v4 = TopbarPlus.iconsDictionary[p]
	return v4 or nil
end

function TopbarPlus.getIcon(p)
	local iconByUID = TopbarPlus.getIconByUID(p)

	if iconByUID then
		return iconByUID
	end

	for _, v4 in pairs(iconsDictionary) do
		if v4.name == p then
			return v4
		end
	end

	return nil
end

function TopbarPlus.setTopbarEnabled(topbarEnabled, p)
	if typeof(topbarEnabled) ~= "boolean" then
		topbarEnabled = TopbarPlus.topbarEnabled
	end

	if not p then
		TopbarPlus.topbarEnabled = topbarEnabled
	end

	for _, v4 in pairs(TopbarPlus.container) do
		v4.Enabled = topbarEnabled
	end
end

function TopbarPlus.modifyBaseTheme(p)
	local modifications = Themes.getModifications(p)

	for _, modification in pairs(modifications) do
		for _, v4 in pairs(TopbarPlus.baseTheme) do
			Themes.merge(v4, modification)
		end
	end

	for _, v4 in pairs(iconsDictionary) do
		v4:setTheme(TopbarPlus.baseTheme)
	end
end

function TopbarPlus.setDisplayOrder(baseDisplayOrder)
	TopbarPlus.baseDisplayOrder = baseDisplayOrder
	TopbarPlus.baseDisplayOrderChanged:Fire(baseDisplayOrder)
end

task.defer(Gamepad.start, TopbarPlus)
task.defer(Overflow.start, TopbarPlus)
task.defer(function()
	local playerGui = localPlayer:WaitForChild("PlayerGui")

	for _, v4 in pairs(TopbarPlus.container) do
		v4.Parent = playerGui
	end

	require(script2.Attribute)
end)

function TopbarPlus.new()
	local class = {}
	setmetatable(class, TopbarPlus)
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
	class.setNotice = janitor:add(GoodSignal.new())
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
	class.enabled = class.isEnabled
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
	class.creationTime = os.clock()
	local Widget = require(elements.Widget)
	class.widget = janitor:add(Widget(class, TopbarPlus))
	class:setAlignment()
	count += 1
	local v5 = count * 0.01 + 1
	class:setOrder(v5, "deselected")
	class:setOrder(v5, "selected")
	class:setTheme(TopbarPlus.baseTheme)
	local instance = class:getInstance("ClickRegion")
	local v6 = false
	local v7 = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function handleToggle()
		if class.locked then
			return
		end

		local now = tick()

		if now - v7 < 0.1 then
			return
		end

		v7 = now

		if class.isSelected then
			class:deselect("User", class)
		else
			class:select("User", class)
		end
	end

	instance.MouseButton1Click:Connect(function()
		v6 = true
		handleToggle() -- equivalent call inferred; original call site unknown
	end)
	instance.TouchTap:Connect(function()
		if not v6 then
			handleToggle() -- equivalent call inferred; original call site unknown
		end
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
		viewingStarted(UserInputService.PreferredInput ~= v3.desktop) -- equivalent call inferred; original call site unknown
	end)
	local count2 = 0
	janitor:add(UserInputService.TouchEnded:Connect(viewingEnded))
	instance.MouseLeave:Connect(viewingEnded)
	instance.SelectionGained:Connect(viewingStarted)
	instance.SelectionLost:Connect(viewingEnded)
	instance.MouseButton1Down:Connect(function()
		if not class.locked and UserInputService.PreferredInput == v3.mobile then
			count2 += 1
			local v8 = count2
			task.delay(0.2, function()
				if v8 == count2 then
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
	local v8 = debug.info(2, "s")
	local v9 = string.split(v8, ".")
	local game2 = game
	local originsScreenGui = nil

	for _, childName in pairs(v9) do
		game2 = game2:FindFirstChild(childName)

		if game2 then
			if game2:IsA("ScreenGui") then
				originsScreenGui = game2
			end
		else
			break
		end
	end

	if game2 and originsScreenGui and originsScreenGui.ResetOnSpawn == true then
		class.originsScreenGui = originsScreenGui
		Utility.localPlayerRespawned(function()
			class:destroy()
		end)
	end

	class.toggled:Connect(function(p)
		class.noticeChanged:Fire(class.totalNotices)

		for k, _ in pairs(class.childIconsDict) do
			local iconByUID = TopbarPlus.getIconByUID(k)
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
	TopbarPlus.iconAdded:Fire(class)
	return class
end

function TopbarPlus:setName(name)
	self.widget.Name = name
	self.name = name
	return self
end

function TopbarPlus:setState(p, p2, p3)
	local v4 = p or self.isSelected and "Selected" or "Deselected"
	local formatStateName = Utility.formatStateName(v4)

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

function TopbarPlus:getInstance(p)
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

	local v4 = nil
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
				v4 = instance2
			end
		end
	end

	scanChildren(widget)
	return v4
end

function TopbarPlus:getCollective(p2)
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

function TopbarPlus:getInstanceOrCollective(p)
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

function TopbarPlus.getStateGroup(p, p2)
	local v4 = p2 or p.activeState
	local v5 = p.appearance[v4]

	if not v5 then
		v5 = {}
		p.appearance[v4] = v5
	end

	return v5
end

function TopbarPlus:refreshAppearance(p2, p3)
	Themes.refresh(self, p2, p3)
	return self
end

function TopbarPlus:refresh()
	self:refreshAppearance(self.widget)
	self.updateSize:Fire()
	return self
end

function TopbarPlus:updateParent()
	local iconByUID = TopbarPlus.getIconByUID(self.parentIconUID)

	if iconByUID then
		iconByUID.updateSize:Fire()
	end
end

function TopbarPlus:setBehaviour(p, p2, p3, p4)
	local v4 = p .. "-" .. p2
	self.customBehaviours[v4] = p3

	if p4 then
		local instanceOrCollective = self:getInstanceOrCollective(p)

		for _, v5 in pairs(instanceOrCollective) do
			self:refreshAppearance(v5, p2)
		end
	end
end

function TopbarPlus:modifyTheme(p2, p3)
	return self, (Themes.modify(self, p2, p3))
end

function TopbarPlus:modifyChildTheme(childModifications, childModificationsUID)
	self.childModifications = childModifications
	self.childModificationsUID = childModificationsUID

	for k, _ in pairs(self.childIconsDict) do
		TopbarPlus.getIconByUID(k):modifyTheme(childModifications, childModificationsUID)
	end

	self.childThemeModified:Fire()
	return self
end

function TopbarPlus.removeModification(p, p2)
	Themes.remove(p, p2)
	return p
end

function TopbarPlus.removeModificationWith(p, p2, p3, p4)
	Themes.removeWith(p, p2, p3, p4)
	return p
end

function TopbarPlus:setTheme(p2)
	Themes.set(self, p2)
	return self
end

function TopbarPlus:setEnabled(p)
	self.isEnabled = p
	self.enabled = self.isEnabled
	self.widget.Visible = p
	self:updateParent()
	return self
end

function TopbarPlus:select(p, p2)
	self:setState("Selected", p, p2)
	return self
end

function TopbarPlus:deselect(p, p2)
	self:setState("Deselected", p, p2)
	return self
end

function TopbarPlus:setNotify(totalNotices: number)
	if not self.notice then
		local Notice = require(elements.Notice)
		self.notice = Notice(self, TopbarPlus)
	end

	self.totalNotices = totalNotices
	self.noticeChanged:Fire(self.totalNotices)
	return self
end

function TopbarPlus:notify(p, p2)
	if not self.notice then
		local Notice = require(elements.Notice)
		self.notice = Notice(self, TopbarPlus)
	end

	self.noticeStarted:Fire(p, p2)
	return self
end

function TopbarPlus:clearNotices()
	self.endNotices:Fire()
	return self
end

function TopbarPlus:disableOverlay(overlayDisabled)
	self.overlayDisabled = overlayDisabled
	return self
end

TopbarPlus.disableStateOverlay = TopbarPlus.disableOverlay

function TopbarPlus:setImage(p, p2)
	self:modifyTheme({
		"IconImage",
		"Image",
		p,
		p2
	})
	task.spawn(function()
		local v4

		if tonumber(p) then
			v4 = `rbxassetid://{p}`
		else
			v4 = p
		end

		if ContentProvider:GetAssetFetchStatus(v4) ~= Enum.AssetFetchStatus.Success then
			pcall(ContentProvider.PreloadAsync, ContentProvider, { v4 })
		end
	end)
	return self
end

function TopbarPlus:setLabel(p, p2)
	self:modifyTheme({
		"IconLabel",
		"Text",
		p,
		p2
	})
	return self
end

function TopbarPlus:setOrder(p, p2)
	local v4 = p * 100
	self:modifyTheme({
		"IconSpot",
		"LayoutOrder",
		v4,
		p2
	})
	self:modifyTheme({
		"Widget",
		"LayoutOrder",
		v4,
		p2
	})
	return self
end

function TopbarPlus:setCornerRadius(p, p2)
	self:modifyTheme({
		"IconCorners",
		"CornerRadius",
		p,
		p2
	})
	return self
end

function TopbarPlus:align(p, p2)
	local lower = tostring(p):lower()
	local v4 = (lower == "mid" or lower == "centre") and "center" or lower
	local v5 = v4 ~= "left" and v4 ~= "center" and v4 ~= "right" and "left" or v4
	local topbarCentered = v5 == "center" and TopbarPlus.container.TopbarCentered or TopbarPlus.container.TopbarStandard
	local holders = topbarCentered.Holders
	local v6 = string.upper((string.sub(v5, 1, 1))) .. string.sub(v5, 2)

	if not p2 then
		self.originalAlignment = v6
	end

	local joinedFrame = self.joinedFrame
	local holder = holders[v6]
	self.screenGui = topbarCentered
	self.alignmentHolder = holder

	if not self.isDestroyed then
		self.widget.Parent = joinedFrame or holder
	end

	self.alignment = v6
	self.alignmentChanged:Fire(v6)
	TopbarPlus.iconChanged:Fire(self)
	return self
end

TopbarPlus.setAlignment = TopbarPlus.align

function TopbarPlus.setLeft(object2)
	object2:setAlignment("Left")
	return object2
end

function TopbarPlus.setMid(object2)
	object2:setAlignment("Center")
	return object2
end

function TopbarPlus.setRight(object2)
	object2:setAlignment("Right")
	return object2
end

function TopbarPlus:setWidth(p, p2)
	self:modifyTheme({
		"Widget",
		"DesiredWidth",
		p,
		p2
	})
	return self
end

function TopbarPlus:setImageScale(p, p2)
	self:modifyTheme({
		"IconImageScale",
		"Value",
		p,
		p2
	})
	return self
end

function TopbarPlus:setImageRatio(p, p2)
	self:modifyTheme({
		"IconImageRatio",
		"AspectRatio",
		p,
		p2
	})
	return self
end

function TopbarPlus:setTextSize(p, p2)
	self:modifyTheme({
		"IconLabel",
		"TextSize",
		p,
		p2
	})
	return self
end

function TopbarPlus:setTextFont(value2, p, p2, p3)
	local v4 = p or Enum.FontWeight.Regular
	local v5 = p2 or Enum.FontStyle.Normal
	local font = nil
	local typeName = typeof(value2)

	if typeName == "number" then
		font = Font.fromId(value2, v4, v5)
	elseif typeName == "EnumItem" then
		font = Font.fromEnum(value2)
	elseif typeName == "string" and not value2:match("rbxasset") then
		font = Font.fromName(value2, v4, v5)
	end

	self:modifyTheme({
		"IconLabel",
		"FontFace",
		font or Font.new(value2, v4, v5),
		p3
	})
	return self
end

function TopbarPlus:setTextColor(color, p)
	if color == nil or color == "" or type(color) ~= "userdata" or typeof(color) ~= "Color3" then
		if color ~= nil and color ~= "" then
			warn("setTextColor item must be a Color3 value! Changed the color to white.")
		end

		color = Color3.fromRGB(255, 255, 255)
	end

	self:modifyTheme({
		"IconLabel",
		"TextColor3",
		color,
		p
	})
	return self
end

function TopbarPlus:bindToggleItem(instance)
	if not (instance:IsA("GuiObject") or instance:IsA("LayerCollector")) then
		error("Toggle item must be a GuiObject or LayerCollector!")
	end

	self.toggleItems[instance] = true
	self:_updateSelectionInstances()
	return self
end

function TopbarPlus:unbindToggleItem(p)
	self.toggleItems[p] = nil
	self:_updateSelectionInstances()
	return self
end

function TopbarPlus:_updateSelectionInstances()
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

function TopbarPlus:_setToggleItemsVisible(p2, _, p3)
	for layerCollector, _ in pairs(self.toggleItems) do
		if not p3 or p3 == self or p3.toggleItems[layerCollector] == nil then
			layerCollector[layerCollector:IsA("LayerCollector") and "Enabled" or "Visible"] = p2
		end
	end
end

function TopbarPlus:bindEvent(p2, callback)
	local v4 = self[p2]
	local connect

	if v4 then
		if typeof(v4) == "table" then
			connect = v4.Connect
		else
			connect = false
		end
	else
		connect = v4
	end

	assert(connect, "argument[1] must be a valid topbarplus icon event name!")
	assert(typeof(callback) == "function", "argument[2] must be a function!")
	self.bindedEvents[p2] = v4:Connect(function(...)
		callback(self, ...)
	end)
	return self
end

function TopbarPlus.unbindEvent(p, p2)
	local bindedEvent = p.bindedEvents[p2]

	if bindedEvent then
		bindedEvent:Disconnect()
		p.bindedEvents[p2] = nil
	end

	return p
end

function TopbarPlus:bindToggleKey(p)
	assert(typeof(p) == "EnumItem", "argument[1] must be a KeyCode EnumItem!")
	self.bindedToggleKeys[p] = true
	self.toggleKeyAdded:Fire(p)
	self:setCaption("_hotkey_")
	return self
end

function TopbarPlus.unbindToggleKey(p, p2)
	assert(typeof(p2) == "EnumItem", "argument[1] must be a KeyCode EnumItem!")
	p.bindedToggleKeys[p2] = nil
	return p
end

function TopbarPlus.call(p, callback, ...)
	local v4 = table.pack(...)
	task.spawn(function()
		callback(p, table.unpack(v4))
	end)
	return p
end

function TopbarPlus:addToJanitor(p2, p3, p4)
	self.janitor:add(p2, p3, p4)
	return self
end

function TopbarPlus:lock()
	local instance = self:getInstance("ClickRegion")
	instance.Visible = false
	self.locked = true
	return self
end

function TopbarPlus:unlock()
	local instance = self:getInstance("ClickRegion")
	instance.Visible = true
	self.locked = false
	return self
end

function TopbarPlus:debounce(duration)
	self:lock()
	task.wait(duration)
	self:unlock()
	return self
end

function TopbarPlus:autoDeselect(p2)
	self.deselectWhenOtherIconSelected = p2 == nil or p2
	return self
end

function TopbarPlus:oneClick(p)
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

function TopbarPlus:setCaption(captionText)
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

function TopbarPlus:setCaptionHint(fakeToggleKey)
	assert(typeof(fakeToggleKey) == "EnumItem", "argument[1] must be a KeyCode EnumItem!")
	self.fakeToggleKey = fakeToggleKey
	self.fakeToggleKeyChanged:Fire(fakeToggleKey)
	self:setCaption("_hotkey_")
	return self
end

function TopbarPlus:leave()
	self.joinJanitor:clean()
	return self
end

function TopbarPlus.joinMenu(p, object2)
	Utility.joinFeature(p, object2, object2.menuIcons, object2:getInstance("Menu"))
	object2.menuChildAdded:Fire(p)
	return p
end

function TopbarPlus:setMenu(p2)
	self.menuSet:Fire(p2)
	return self
end

function TopbarPlus:setFixedMenu(p)
	self:freezeMenu(p)
	self:setMenu(p)
end

TopbarPlus.setFrozenMenu = TopbarPlus.setFixedMenu

function TopbarPlus:freezeMenu()
	self:select("FrozenMenu", self)
	self:bindEvent("deselected", function(object3)
		object3:select("FrozenMenu", self)
	end)
	self:modifyTheme({ "IconSpot", "Visible", false })
end

function TopbarPlus.joinDropdown(p, object2)
	object2:getDropdown()
	Utility.joinFeature(p, object2, object2.dropdownIcons, object2:getInstance("DropdownScroller"))
	object2.dropdownChildAdded:Fire(p)
	return p
end

function TopbarPlus:getDropdown()
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

function TopbarPlus:setDropdown(p)
	self:getDropdown()
	self.dropdownSet:Fire(p)
	return self
end

function TopbarPlus:clipOutside(p)
	local clipOutside = Utility.clipOutside(self, p)
	self:refreshAppearance(p)
	return self, clipOutside
end

function TopbarPlus:setIndicator(p)
	if not self.indicator then
		local janitor = self.janitor
		local Indicator = require(elements.Indicator)
		self.indicator = janitor:add(Indicator(self, TopbarPlus))
	end

	self.indicatorSet:Fire(p)
end

function TopbarPlus:convertLabelToNumberSpinner(state, callback)
	task.defer(function()
		local instance = self:getInstance("IconLabel")
		instance.Transparency = 1
		state.Parent = instance.Parent
		state.Size = UDim2.fromScale(1, 1)
		state.AnchorPoint = Vector2.new(0.5, 0.5)
		state.Position = UDim2.new(0.5, 0, 0.5, 0)
		state.TextXAlignment = Enum.TextXAlignment.Center
		state.ClipsDescendants = false

		for _, propertyName in ipairs({
			"FontFace",
			"BorderSizePixel",
			"BorderColor3",
			"Rotation",
			"TextStrokeTransparency",
			"TextStrokeColor3",
			"TextStrokeTransparency",
			"TextColor3"
		}) do
			state[propertyName] = instance[propertyName]
			local v4 = propertyName
			self:addToJanitor(instance:GetPropertyChangedSignal(propertyName):Connect(function()
				state[v4] = instance[v4]
			end))
		end

		local function getSpinnerSizeAndDigitCount()
			local total = 0
			local count2 = 0

			for _, child in state.Frame:GetChildren() do
				local name = string.lower(child.Name)

				if name == "digit" then
					total += child.AbsoluteSize.X
					count2 += 1
				elseif (name == "prefix" or name == "suffix" or name == "comma") and child.Text ~= "" then
					total += child.AbsoluteSize.X
					count2 += 1
				end
			end

			return total, count2
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getLabelParentContainerXSize()
			local parent = instance.Parent
			local parent2 = parent and parent.Parent

			if parent2 == nil then
				return 0
			end

			if parent2.IconImage.Visible == true then
				return state.Frame.AbsoluteSize.X + instance.Parent.Parent.IconImage.AbsoluteSize.X
			end

			return parent2.AbsoluteSize.X
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getNumberSpinnerXSize()
			return state.Frame.AbsoluteSize.X
		end

		local function adjustSize()
			local spinnerSizeAndDigitCount, v4 = getSpinnerSizeAndDigitCount()

			if v4 < 18 then
				self:setLabel(state.Value)
			end

			local numberSpinnerXSize = getNumberSpinnerXSize() -- equivalent call inferred; original call site unknown

			while spinnerSizeAndDigitCount < numberSpinnerXSize and self.isDestroyed ~= true do
				task.wait(0.05)

				if v4 > 0 and v4 < 8 then
					state.TextSize = instance.TextSize
					break
				end

				state.TextSize += 1
				numberSpinnerXSize = getNumberSpinnerXSize()
				spinnerSizeAndDigitCount, v4 = getSpinnerSizeAndDigitCount()
			end

			local labelParentContainerXSize = getLabelParentContainerXSize() -- equivalent call inferred; original call site unknown

			while labelParentContainerXSize < spinnerSizeAndDigitCount and self.isDestroyed ~= true do
				task.wait(0.05)

				if v4 < 8 and v4 > 0 then
					state.TextSize = instance.TextSize
					break
				end

				state.TextSize -= 1
				local parent = instance.Parent
				local parent2 = parent and parent.Parent

				if parent2 == nil then
					labelParentContainerXSize = 0
				elseif parent2.IconImage.Visible == true then
					labelParentContainerXSize = getNumberSpinnerXSize() + instance.Parent.Parent.IconImage.AbsoluteSize.X
				else
					labelParentContainerXSize = parent2.AbsoluteSize.X
				end

				spinnerSizeAndDigitCount, v4 = getSpinnerSizeAndDigitCount()
			end
		end

		self:addToJanitor(state.Frame.ChildAdded:Connect(adjustSize))
		self:addToJanitor(state.Frame.ChildRemoved:Connect(adjustSize))
		self:addToJanitor(self.iconAdded:Connect(function()
			task.wait(1)
			adjustSize()
		end))
		self:updateParent()
		state.Name = "LabelSpinner"
		state.Prefix = "$"
		state.Commas = true
		state.Decimals = 0
		state.Duration = 0.25
		state.Value = 10
		task.wait(0.2)

		if typeof(callback) == "function" then
			callback()
		end
	end)
	return self
end

function TopbarPlus:destroy()
	if self.isDestroyed then
		return
	end

	self:clearNotices()

	if self.parentIconUID then
		self:leave()
	end

	self.isDestroyed = true
	self.janitor:clean()
	TopbarPlus.iconRemoved:Fire(self)
end

TopbarPlus.Destroy = TopbarPlus.destroy
return TopbarPlus