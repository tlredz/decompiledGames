local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2:WaitForChild("UserInputService"))
local ContentProvider = game:GetService("ContentProvider")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
require3(script.Types)
local script2 = script
local v2 = require3(script2.Reference)
local object = v2.getObject()
local value = object and object.Value

if value and value ~= script2 then
	return (require3(value))
end

if not object then
	v2.addToReplicatedStorage()
end

local v3 = require3(script2.Packages.GoodSignal)
local v4 = require3(script2.Packages.Janitor)
local v5 = require3(script2.Utility)
local v6 = require3(script2.Features.Themes)
local v7 = require3(script2.Features.Gamepad)
local v8 = require3(script2.Features.Overflow)
local Icon = {}
Icon.__index = Icon
local localPlayer = Players.LocalPlayer
local themes = script2.Features.Themes
local iconsDictionary = {}
local v10 = v3.new()
local elements = script2.Elements
local count = 0
local v11 = {
	mobile = Enum.PreferredInput.Touch,
	desktop = Enum.PreferredInput.KeyboardAndMouse,
	console = Enum.PreferredInput.Gamepad
}
Icon.baseDisplayOrderChanged = v3.new()
Icon.baseDisplayOrder = 10
Icon.baseTheme = require3(themes.Default)
Icon.isOldTopbar = false
Icon.iconsDictionary = iconsDictionary
Icon.insetHeightChanged = v3.new()
Icon.container = require3(elements.Container)(Icon)
Icon.topbarEnabled = true
Icon.iconAdded = v3.new()
Icon.iconRemoved = v3.new()
Icon.iconChanged = v3.new()

function Icon.getIcons()
	return Icon.iconsDictionary
end

function Icon.getIconByUID(p)
	local v12 = Icon.iconsDictionary[p]
	return v12 or nil
end

function Icon.getIcon(p)
	local iconByUID = Icon.getIconByUID(p)

	if iconByUID then
		return iconByUID
	end

	for _, v12 in pairs(iconsDictionary) do
		if v12.name == p then
			return v12
		end
	end

	return nil
end

function Icon.setTopbarEnabled(topbarEnabled, p)
	if typeof(topbarEnabled) ~= "boolean" then
		topbarEnabled = Icon.topbarEnabled
	end

	if not p then
		Icon.topbarEnabled = topbarEnabled
	end

	for _, v12 in pairs(Icon.container) do
		v12.Enabled = topbarEnabled
	end
end

function Icon.modifyBaseTheme(p)
	local modifications = v6.getModifications(p)

	for _, modification in pairs(modifications) do
		for _, v12 in pairs(Icon.baseTheme) do
			v6.merge(v12, modification)
		end
	end

	for _, v12 in pairs(iconsDictionary) do
		v12:setTheme(Icon.baseTheme)
	end
end

function Icon.setDisplayOrder(baseDisplayOrder)
	Icon.baseDisplayOrder = baseDisplayOrder
	Icon.baseDisplayOrderChanged:Fire(baseDisplayOrder)
end

task.defer(v7.start, Icon)
task.defer(v8.start, Icon)
task.defer(function()
	local playerGui = localPlayer:WaitForChild("PlayerGui")

	for _, v12 in pairs(Icon.container) do
		v12.Parent = playerGui
	end

	require3(script2.Attribute)
end)

function Icon.new()
	local class = {}
	setmetatable(class, Icon)
	local janitor = v4.new()
	class.janitor = janitor
	class.themesJanitor = janitor:add(v4.new())
	class.singleClickJanitor = janitor:add(v4.new())
	class.captionJanitor = janitor:add(v4.new())
	class.joinJanitor = janitor:add(v4.new())
	class.menuJanitor = janitor:add(v4.new())
	class.dropdownJanitor = janitor:add(v4.new())
	local UID = v5.generateUID()
	iconsDictionary[UID] = class
	janitor:add(function()
		iconsDictionary[UID] = nil
	end)
	class.selected = janitor:add(v3.new())
	class.deselected = janitor:add(v3.new())
	class.toggled = janitor:add(v3.new())
	class.viewingStarted = janitor:add(v3.new())
	class.viewingEnded = janitor:add(v3.new())
	class.stateChanged = janitor:add(v3.new())
	class.notified = janitor:add(v3.new())
	class.noticeStarted = janitor:add(v3.new())
	class.noticeChanged = janitor:add(v3.new())
	class.endNotices = janitor:add(v3.new())
	class.toggleKeyAdded = janitor:add(v3.new())
	class.fakeToggleKeyChanged = janitor:add(v3.new())
	class.alignmentChanged = janitor:add(v3.new())
	class.updateSize = janitor:add(v3.new())
	class.resizingComplete = janitor:add(v3.new())
	class.joinedParent = janitor:add(v3.new())
	class.menuSet = janitor:add(v3.new())
	class.dropdownSet = janitor:add(v3.new())
	class.updateMenu = janitor:add(v3.new())
	class.startMenuUpdate = janitor:add(v3.new())
	class.childThemeModified = janitor:add(v3.new())
	class.indicatorSet = janitor:add(v3.new())
	class.dropdownChildAdded = janitor:add(v3.new())
	class.menuChildAdded = janitor:add(v3.new())
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
	class.widget = janitor:add(require3(elements.Widget)(class, Icon))
	class:setAlignment()
	count += 1
	local v13 = count * 0.01 + 1
	class:setOrder(v13, "deselected")
	class:setOrder(v13, "selected")
	class:setTheme(Icon.baseTheme)
	local instance = class:getInstance("ClickRegion")
	local v14 = false
	local v15 = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function handleToggle()
		if class.locked then
			return
		end

		local now = tick()

		if now - v15 < 0.1 then
			return
		end

		v15 = now

		if class.isSelected then
			class:deselect("User", class)
		else
			class:select("User", class)
		end
	end

	instance.MouseButton1Click:Connect(function()
		v14 = true
		handleToggle() -- equivalent call inferred; original call site unknown
	end)
	instance.TouchTap:Connect(function()
		if not v14 then
			handleToggle() -- equivalent call inferred; original call site unknown
		end
	end)
	janitor:add(v.InputBegan:Connect(function(input, gameProcessed)
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
		viewingStarted(v.PreferredInput ~= v11.desktop) -- equivalent call inferred; original call site unknown
	end)
	local count2 = 0
	janitor:add(v.TouchEnded:Connect(viewingEnded))
	instance.MouseLeave:Connect(viewingEnded)
	instance.SelectionGained:Connect(viewingStarted)
	instance.SelectionLost:Connect(viewingEnded)
	instance.MouseButton1Down:Connect(function()
		if not class.locked and v.PreferredInput == v11.mobile then
			count2 += 1
			local v16 = count2
			task.delay(0.2, function()
				if v16 == count2 then
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
	janitor:add(v10:Connect(function(p)
		if p ~= class and class.deselectWhenOtherIconSelected and p.deselectWhenOtherIconSelected then
			class:deselect("AutoDeselect", p)
		end
	end))
	local v16 = debug.info(2, "s")
	local v17 = string.split(v16, ".")
	local game2 = game
	local originsScreenGui = nil

	for _, childName in pairs(v17) do
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
		v5.localPlayerRespawned(function()
			class:destroy()
		end)
	end

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
	local v12 = p or self.isSelected and "Selected" or "Deselected"
	local formatStateName = v5.formatStateName(v12)

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
			v10:Fire(self, p2, p3)
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

	local v12 = nil
	local scanChildren

	scanChildren = function(instance)
		for _, child in pairs(instance:GetChildren()) do
			local widgetUID = child:GetAttribute("WidgetUID")

			if not (not widgetUID or widgetUID == self.UID) then
				continue
			end

			local instance2 = v6.getRealInstance(child) or child
			scanChildren(instance2)

			if not (instance2:IsA("GuiBase") or instance2:IsA("UIBase") or instance2:IsA("ValueBase")) then
				continue
			end

			local name = instance2.Name
			cacheInstance(name, instance2)

			if name == p then
				v12 = instance2
			end
		end
	end

	scanChildren(widget)
	return v12
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
	local v12 = p2 or p.activeState
	local v13 = p.appearance[v12]

	if not v13 then
		v13 = {}
		p.appearance[v12] = v13
	end

	return v13
end

function Icon:refreshAppearance(p2, p3)
	v6.refresh(self, p2, p3)
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
	local v12 = p .. "-" .. p2
	self.customBehaviours[v12] = p3

	if p4 then
		local instanceOrCollective = self:getInstanceOrCollective(p)

		for _, v13 in pairs(instanceOrCollective) do
			self:refreshAppearance(v13, p2)
		end
	end
end

function Icon:modifyTheme(p2, p3)
	return self, (v6.modify(self, p2, p3))
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
	v6.remove(p, p2)
	return p
end

function Icon.removeModificationWith(p, p2, p3, p4)
	v6.removeWith(p, p2, p3, p4)
	return p
end

function Icon:setTheme(p2)
	v6.set(self, p2)
	return self
end

function Icon:setEnabled(p)
	self.isEnabled = p
	self.enabled = self.isEnabled
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
		self.notice = require3(elements.Notice)(self, Icon)
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
	task.spawn(function()
		local v12

		if tonumber(p) then
			v12 = `rbxassetid://{p}`
		else
			v12 = p
		end

		if ContentProvider:GetAssetFetchStatus(v12) ~= Enum.AssetFetchStatus.Success then
			pcall(ContentProvider.PreloadAsync, ContentProvider, { v12 })
		end
	end)
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
	local v12 = p * 100
	self:modifyTheme({
		"IconSpot",
		"LayoutOrder",
		v12,
		p2
	})
	self:modifyTheme({
		"Widget",
		"LayoutOrder",
		v12,
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
	local v12 = (lower == "mid" or lower == "centre") and "center" or lower
	local v13 = v12 ~= "left" and v12 ~= "center" and v12 ~= "right" and "left" or v12
	local topbarCentered = v13 == "center" and Icon.container.TopbarCentered or Icon.container.TopbarStandard
	local holders = topbarCentered.Holders
	local v14 = string.upper((string.sub(v13, 1, 1))) .. string.sub(v13, 2)

	if not p2 then
		self.originalAlignment = v14
	end

	local joinedFrame = self.joinedFrame
	local holder = holders[v14]
	self.screenGui = topbarCentered
	self.alignmentHolder = holder

	if not self.isDestroyed then
		self.widget.Parent = joinedFrame or holder
	end

	self.alignment = v14
	self.alignmentChanged:Fire(v14)
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
	local v12 = p or Enum.FontWeight.Regular
	local v13 = p2 or Enum.FontStyle.Normal
	local font = nil
	local typeName = typeof(value2)

	if typeName == "number" then
		font = Font.fromId(value2, v12, v13)
	elseif typeName == "EnumItem" then
		font = Font.fromEnum(value2)
	elseif typeName == "string" and not value2:match("rbxasset") then
		font = Font.fromName(value2, v12, v13)
	end

	self:modifyTheme({
		"IconLabel",
		"FontFace",
		font or Font.new(value2, v12, v13),
		p3
	})
	return self
end

function Icon:setTextColor(color, p)
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
	local v12 = self[p2]
	local connect

	if v12 then
		if typeof(v12) == "table" then
			connect = v12.Connect
		else
			connect = false
		end
	else
		connect = v12
	end

	assert(connect, "argument[1] must be a valid topbarplus icon event name!")
	assert(typeof(callback) == "function", "argument[2] must be a function!")
	self.bindedEvents[p2] = v12:Connect(function(...)
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
	local v12 = table.pack(...)
	task.spawn(function()
		callback(p, table.unpack(v12))
	end)
	return p
end

function Icon:addToJanitor(p2, p3, p4)
	self.janitor:add(p2, p3, p4)
	return self
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
		local caption = captionJanitor:add(require3(elements.Caption)(self))
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
	v5.joinFeature(p, object2, object2.menuIcons, object2:getInstance("Menu"))
	object2.menuChildAdded:Fire(p)
	return p
end

function Icon:setMenu(p2)
	self.menuSet:Fire(p2)
	return self
end

function Icon:setFixedMenu(p)
	self:freezeMenu(p)
	self:setMenu(p)
end

Icon.setFrozenMenu = Icon.setFixedMenu

function Icon:freezeMenu()
	self:select("FrozenMenu", self)
	self:bindEvent("deselected", function(object3)
		object3:select("FrozenMenu", self)
	end)
	self:modifyTheme({ "IconSpot", "Visible", false })
end

function Icon.joinDropdown(p, object2)
	object2:getDropdown()
	v5.joinFeature(p, object2, object2.dropdownIcons, object2:getInstance("DropdownScroller"))
	object2.dropdownChildAdded:Fire(p)
	return p
end

function Icon:getDropdown()
	local dropdown = self.dropdown

	if not dropdown then
		dropdown = require3(elements.Dropdown)(self)
		self.dropdown = dropdown
		self:clipOutside(dropdown)
	end

	return dropdown
end

function Icon:setDropdown(p)
	self:getDropdown()
	self.dropdownSet:Fire(p)
	return self
end

function Icon:clipOutside(p)
	local clipOutside = v5.clipOutside(self, p)
	self:refreshAppearance(p)
	return self, clipOutside
end

function Icon:setIndicator(p)
	if not self.indicator then
		self.indicator = self.janitor:add(require3(elements.Indicator)(self, Icon))
	end

	self.indicatorSet:Fire(p)
end

function Icon:convertLabelToNumberSpinner(state, callback)
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
			local v12 = propertyName
			self:addToJanitor(instance:GetPropertyChangedSignal(propertyName):Connect(function()
				state[v12] = instance[v12]
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
			local spinnerSizeAndDigitCount, v12 = getSpinnerSizeAndDigitCount()

			if v12 < 18 then
				self:setLabel(state.Value)
			end

			local numberSpinnerXSize = getNumberSpinnerXSize() -- equivalent call inferred; original call site unknown

			while spinnerSizeAndDigitCount < numberSpinnerXSize and self.isDestroyed ~= true do
				task.wait(0.05)

				if v12 > 0 and v12 < 8 then
					state.TextSize = instance.TextSize
					break
				end

				state.TextSize += 1
				numberSpinnerXSize = getNumberSpinnerXSize()
				spinnerSizeAndDigitCount, v12 = getSpinnerSizeAndDigitCount()
			end

			local labelParentContainerXSize = getLabelParentContainerXSize() -- equivalent call inferred; original call site unknown

			while labelParentContainerXSize < spinnerSizeAndDigitCount and self.isDestroyed ~= true do
				task.wait(0.05)

				if v12 < 8 and v12 > 0 then
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

				spinnerSizeAndDigitCount, v12 = getSpinnerSizeAndDigitCount()
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