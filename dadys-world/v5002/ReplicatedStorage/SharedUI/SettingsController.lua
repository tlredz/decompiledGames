local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local UIController = require(ReplicatedStorage.SharedUtils.UIController)
local object = setmetatable({}, UIController)
object.__index = object
local touchEnabled = UserInputService.TouchEnabled
local Network = require(ReplicatedStorage.SharedUtils.Network)
local MenuManager = require(ReplicatedStorage.SharedUtils.MenuManager)
local HapticEffectsController = require(ReplicatedStorage.SharedUtils.HapticEffectsController)
local Universe = require(ReplicatedStorage.SharedUtils.Universe)
local PlayerSettings = require(ReplicatedStorage.SharedData.PlayerSettings)
local SettingsFlags = require(ReplicatedStorage.SharedUtils.SettingsFlags)
local InputService = require(ReplicatedStorage.SharedUtils.InputService)
local KeyCodeNames = require(ReplicatedStorage.SharedUtils.KeyCodeNames)
local Maid = require(ReplicatedStorage.SharedUtils.Maid)
local CameraModeController = require(ReplicatedStorage.SharedUtils.CameraModeController)
local v = Universe:IsGame() and "ScreenGui" or "MainGui"
local v2 = {
	"General",
	"Graphics",
	"Controls",
	"Accessibility"
}
local windowHandler = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("WindowHandler")
local module = windowHandler and require(windowHandler)
local color = Color3.fromRGB(198, 58, 58)
local color2 = Color3.fromRGB(255, 255, 255)
local v3 = {
	default = function(p)
		return (tostring(p))
	end,
	boolean = function(flag: boolean)
		if flag then
			return "<font color=\"rgb(150,255,150)\">ON</font>"
		end

		return "<font color=\"rgb(255,150,150)\">OFF</font>"
	end,
	slider = function(p: number)
		return string.format("<font color=\"rgb(255,184,62)\">%d%%</font>", (math.clamp(tonumber(p) or 0, 0, 100)))
	end,
	string = function(p: string)
		return (tostring(p))
	end,
	choice = function(p: string)
		return string.format("<font color=\"rgb(255,184,62)\">%s</font>", string.upper((tostring(p))))
	end
}

-- equivalent calls inferred from this helper; original call sites unknown
local function getStringValue(p, p2: string)
	return (v3[p2] or v3.default)(p)
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function roundNearest(p: number, p2: number)
	return (p + p2 * 0.5) // p2 * p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function color3ToString(backgroundColor3: Color3)
	return string.format(
		"%d,%d,%d",
		math.round(backgroundColor3.R * 255),
		math.round(backgroundColor3.G * 255),
		(math.round(backgroundColor3.B * 255))
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stringToColor3(value: string)
	local parts = (value or ""):split(",")
	local v4 = tonumber(parts[1]) or 0
	local v5 = tonumber(parts[2]) or 0
	local v6 = tonumber(parts[3]) or 0
	return Color3.fromRGB(v4, v5, v6)
end

local function getSettingValue(p, value: string)
	local parts = value:split(".")
	local settings = p.Data.Settings

	while #parts > 1 do
		settings = settings[table.remove(parts, 1)]

		if not settings then
			return nil
		end
	end

	return SettingsFlags:GetEffective(settings[parts[1]], value)
end

local function makeListenPath(value: string)
	local result = { "Settings" }

	for _, v4 in ipairs(value:split(".")) do
		result[#result + 1] = v4
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bindActivate(p, onActivated)
	if not p then
		return
	end

	p.Activated:Connect(onActivated)
	InputService:RegisterActivation(p, onActivated)
end

function object:hoverSound()
	local hover = SoundService:FindFirstChild("UI"):FindFirstChild("Hover"):FindFirstChild("Hover")

	if hover and self.initiatedComplete then
		local clone = hover:Clone()
		clone.Parent = hover.Parent
		clone:Play()
		Debris:AddItem(clone, hover.TimeLength + 1)
	end
end

function object:_setHudMenuVisible(visible: boolean)
	if not Universe:IsGame() then
		return
	end

	local menu = self.gui.Parent and self.gui.Parent:FindFirstChild("Menu")

	if menu then
		menu.Visible = visible
	end
end

function object:Open(_)
	GuiService.AutoSelectGuiEnabled = false

	if not self._inputMenuActive then
		self._inputMenuActive = true
		InputService:OpenMenu("Settings")

		if not self._menuNavRelease then
			self._menuNavRelease = InputService:RequestContext("MenuNav")
		end
	end

	if module then
		module.open(self.gui)
	else
		self.gui.Visible = true
	end

	self:_setHudMenuVisible(false)
	self:_enterGamepadNav()

	if self._repaintKeybinds then
		self._repaintKeybinds()
	end

	if self._settingsBlur then
		TweenService:Create(self._settingsBlur, TweenInfo.new(0.3), {
			Size = 10
		}):Play()
	end

	local topbar = self.gui and self.gui:FindFirstChild("Topbar")
	local bottombar = self.gui and self.gui:FindFirstChild("Bottombar")

	if topbar then
		topbar.AnchorPoint = Vector2.new(0.5, 1)
		TweenService:Create(topbar, TweenInfo.new(0.1), {
			AnchorPoint = Vector2.new(0.5, 0)
		}):Play()
	end

	if bottombar then
		bottombar.AnchorPoint = Vector2.new(0.5, 0)
		TweenService:Create(bottombar, TweenInfo.new(0.1), {
			AnchorPoint = Vector2.new(0.5, 1)
		}):Play()
	end
end

function object:_teardownMenuInput()
	if not self._inputMenuActive then
		return
	end

	self._inputMenuActive = false

	if self._confirmCancel then
		self._confirmCancel()
	end

	if self._stopKeybindCapture then
		self._stopKeybindCapture()
	end

	self:_exitGamepadNav()
	InputService:CloseMenu("Settings")

	if self._menuNavRelease then
		self._menuNavRelease()
		self._menuNavRelease = nil
	end
end

function object:Close(_)
	GuiService.AutoSelectGuiEnabled = true

	if self._settingsBlur then
		TweenService:Create(self._settingsBlur, TweenInfo.new(0.3), {
			Size = 0
		}):Play()
	end

	self:_teardownMenuInput()

	if module then
		module.close(self.gui)
	else
		self.gui.Visible = false
	end

	self:_setHudMenuVisible(true)
end

function object.init()
	local child = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild(v)
	local v4 = UIController.new(child:FindFirstChild("Settings"))
	setmetatable(v4, object)
	local settingsBlur = Lighting:FindFirstChild("SettingsBlur")

	if not settingsBlur then
		settingsBlur = Instance.new("BlurEffect")
		settingsBlur.Name = "SettingsBlur"
		settingsBlur.Size = 0
		settingsBlur.Parent = Lighting
	end

	v4._settingsBlur = settingsBlur

	if module then
		module.register(v4.gui, v4.gui:FindFirstChild("ExitButton", true), {
			closeButtons = true,
			keepInfoVisible = false
		})
		local exitButton = v4.gui:FindFirstChild("ExitButton", true)

		if exitButton then
			local function fn()
				MenuManager:Close("SettingsController")
			end

			bindActivate(exitButton, fn) -- equivalent call inferred; original call site unknown
		end
	else
		local exitButton = v4.gui:FindFirstChild("ExitButton", true)

		if exitButton then
			local function fn()
				MenuManager:Close("SettingsController")
			end

			bindActivate(exitButton, fn) -- equivalent call inferred; original call site unknown
		end
	end

	v4.gui:GetPropertyChangedSignal("Visible"):Connect(function()
		if not v4.gui.Visible then
			v4:_teardownMenuInput()
		end
	end)

	if touchEnabled then
		local margin = v4.gui:WaitForChild("Margin")
		local navigation = margin and margin:WaitForChild("Navigation")
		local exitButton = v4.gui:FindFirstChild("ExitButton", true)
		local textLabel = margin and margin:WaitForChild("TextLabel")
		local uIPadding = margin and margin:WaitForChild("UIPadding")

		if navigation then
			navigation.Position = UDim2.fromScale(0.26, 0.044)
		end

		if Universe:IsGame() and exitButton then
			exitButton.Visible = not touchEnabled
		end

		if textLabel then
			textLabel.Visible = not touchEnabled
		end

		uIPadding.PaddingTop = UDim.new(0, 20)
		uIPadding.PaddingRight = UDim.new(0, 0)
		uIPadding.PaddingLeft = UDim.new(0, 0)
		uIPadding.PaddingBottom = UDim.new(0, 0)
		local topbar = v4.gui and v4.gui:FindFirstChild("Topbar")
		local bottombar = v4.gui and v4.gui:FindFirstChild("Bottombar")

		if topbar then
			topbar.Visible = not touchEnabled
		end

		if bottombar then
			bottombar.Visible = not touchEnabled
		end
	end

	if Universe:IsLobby() then
		local background = v4.gui:FindFirstChild("Background")
		background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	end

	CameraModeController.Init()
	v4:_initPages()
	v4:_initNavigation()
	v4:_initGamepadNav()
	v4:_initInfoPanel()
	v4:_initButtons(child)
	v4:_initActions()
	v4:_initData()
	MenuManager:Register("SettingsController", v4, {
		isOverlay = false
	})
	task.delay(8, function()
		v4.initiatedComplete = true
	end)
	return v4
end

function object:_initPages()
	local pages = self.map.Pages
	local template = pages:FindFirstChild("Template")

	if not template then
		warn("[SettingsController] Pages.Template not found – cannot generate tabs")
		return
	end

	local margin = template:FindFirstChild("Margin")
	local scrollingFrame = margin and margin:FindFirstChild("ScrollingFrame")
	local guiObjectsByName = {}

	if scrollingFrame then
		for _, guiObject in ipairs(scrollingFrame:GetChildren()) do
			if not guiObject:IsA("GuiObject") then
				continue
			end

			guiObjectsByName[guiObject.Name] = guiObject
			guiObject.Parent = nil
		end
	end

	template.Parent = nil
	self._settingTemplates = guiObjectsByName
	self._tabFrames = {}

	for _, name in ipairs(v2) do
		if not PlayerSettings.Tabs[name] then
			continue
		end

		local clone = template:Clone()
		clone.Name = name
		clone.Parent = pages
		self._tabFrames[name] = clone
		local margin2 = clone:FindFirstChild("Margin")
		local scrollingFrame2 = margin2 and margin2:FindFirstChild("ScrollingFrame")
		local scrolling = margin2 and margin2:FindFirstChild("Scrolling")

		if scrollingFrame2 and scrolling then
			self.tweens.customScrollbar(scrolling, scrollingFrame2)
		end
	end

	self:_setupPages()
	self.gui:GetAttributeChangedSignal("CurrentPage"):Connect(function()
		local currentPage = self.gui:GetAttribute("CurrentPage")
		local margin2 = self:FindPage(currentPage):FindFirstChild("Margin")
		local scrollingFrame2 = margin2 and margin2:FindFirstChild("ScrollingFrame")
		local v4 = nil
		local layoutOrder = 300

		if scrollingFrame2 then
			for _, button in ipairs(scrollingFrame2:GetChildren()) do
				if not button:IsA("ImageButton") or string.find(button.Name, "Header") or not (button.LayoutOrder < layoutOrder) then
					continue
				end

				layoutOrder = button.LayoutOrder
				v4 = button
			end
		end

		self:_closeColorDropdown()

		if v4 then
			self.gui:SetAttribute("SelectedProperty", v4.Name)
		end

		local navigation = self.map.Navigation

		for _, button in ipairs(navigation:GetChildren()) do
			if not button:IsA("ImageButton") then
				continue
			end

			local uIStroke = button:WaitForChild("Display"):WaitForChild("Background"):WaitForChild("UIStroke")
			uIStroke.Color = button.Name == currentPage and Color3.fromRGB(255, 255, 255) or Color3.new(0, 0, 0)
			local selected = button and button:FindFirstChild("Selected")

			if selected then
				selected.Visible = button.Name == currentPage
			end
		end
	end)
end

function object:_initNavigation()
	local navigation = self.map.Navigation

	if not navigation then
		warn("[SettingsController] Margin.Navigation not found")
		return
	end

	for _, button in ipairs(navigation:GetChildren()) do
		if not button:IsA("ImageButton") then
			continue
		end

		self:BindTab(button, button.Name)

		if not button:FindFirstChild("UIScale") then
			local uIScale = Instance.new("UIScale")
			uIScale.Parent = button
		end

		self.styleController:Apply(button, "Shared.Default.button")
	end
end

function object:_initGamepadNav()
	self._navConns = {}
	self._tabButtons = {}
	self._tabNames = {}
	local navigation = self.map and self.map.Navigation

	if navigation then
		for _, childName in ipairs(v2) do
			local button = navigation:FindFirstChild(childName)

			if not (button and button:IsA("GuiButton")) then
				continue
			end

			self._tabButtons[childName] = button
			self._tabNames[#self._tabNames + 1] = childName
		end
	end

	InputService:OnReady(function()
		InputService:OnAction("SettingsTabLeft", function()
			if self._inputMenuActive then
				self:_cycleTab(-1)
			end
		end)
		InputService:OnAction("SettingsTabRight", function()
			if self._inputMenuActive then
				self:_cycleTab(1)
			end
		end)
		InputService:OnAction("MenuBack", function()
			if not self._inputMenuActive then
				return
			end

			if self._confirmCancel then
				self._confirmCancel()
			else
				MenuManager:Back()
			end
		end)
	end)
end

function object:_currentTabName()
	return self.gui:GetAttribute("CurrentCategory") or self.activePage and self.activePage.Name
end

function object:_focusPageContent(p: string?)
	if not p then
		return
	end

	task.defer(function()
		if not self._inputMenuActive or self._keybindCapturing then
			return
		end

		local folder = self:FindPage(p)
		local v4 = nil
		local v5 = 1e999

		if folder then
			for _, button in ipairs(folder:GetDescendants()) do
				if not (button:IsA("GuiButton") and button.Visible and button.Selectable) then
					continue
				end

				local Y = button.AbsolutePosition.Y

				if not (Y < v5) then
					continue
				end

				v4 = button
				v5 = Y
			end
		end

		if object:_isGamepadActive() then
			GuiService.SelectedObject = v4 or self._tabButtons[p] or GuiService.SelectedObject
		end
	end)
end

function object:_cycleTab(p: number)
	local _tabNames = {}

	for _, _tabName in ipairs(self._tabNames) do
		if SettingsFlags:IsTabEnabled(_tabName) then
			_tabNames[#_tabNames + 1] = _tabName
		end
	end

	if #_tabNames == 0 then
		return
	end

	local v4 = _tabNames[((table.find(_tabNames, self:_currentTabName()) or 1) - 1 + p) % #_tabNames + 1]
	self:ShowPage(v4)
	self:_focusPageContent(v4)
end

function object:_isGamepadActive()
	return UserInputService.PreferredInput == Enum.PreferredInput.Gamepad
end

function object:_syncGamepadSelection()
	if not self._inputMenuActive or self._keybindCapturing then
		return
	end

	if self:_isGamepadActive() then
		local selectedObject = GuiService.SelectedObject

		if not (selectedObject and selectedObject:IsDescendantOf(self.gui)) then
			self:_focusPageContent(self:_currentTabName() or self._tabNames[1])
		end
	elseif GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(self.gui) then
		GuiService.SelectedObject = nil
	end
end

function object:_enterGamepadNav()
	self._navConns[#self._navConns + 1] = UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
		self:_syncGamepadSelection()
	end)
	self:_syncGamepadSelection()
end

function object:_exitGamepadNav()
	for _, connection in ipairs(self._navConns or {}) do
		connection:Disconnect()
	end

	self._navConns = {}

	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(self.gui) then
		GuiService.SelectedObject = nil
	end
end

function object:_initInfoPanel()
	self._settingButtons = {}
	self._currentPreviewKey = nil
	self._settingRenderers = {}
	self._flagRows = {}
	self._controlHost = nil
	self._openDropdown = nil
	local preview = self.map.Preview

	if not preview then
		return
	end

	self._preview = preview
	self.gui:GetAttributeChangedSignal("SelectedProperty"):Connect(function()
		local selectedProperty = self.gui:GetAttribute("SelectedProperty")
		local v4 = self._currentPreviewKey and self._settingButtons[self._currentPreviewKey]

		if v4 then
			v4:SetAttribute("Previewing", nil)
		end

		self._currentPreviewKey = selectedProperty
		local v5 = selectedProperty and self._settingButtons[selectedProperty]

		if v5 then
			v5:SetAttribute("Previewing", true)
		end

		self:_updatePreview(preview, selectedProperty)
	end)
end

function object:_resolveData(value: string)
	local selected = self._keybindPreview and self._keybindPreview[value]

	if selected then
		return selected
	end

	local parts = value:split(".")
	local v5 = PlayerSettings.Hierarchy[parts[1]]

	if v5 and #parts > 1 then
		return v5[parts[2]]
	end

	return v5
end

function object:_shownValueFor(p2: string)
	if self._myReplica then
		return getSettingValue(self._myReplica, p2)
	end

	return nil
end

function object:_refreshOverlay(p)
	local _preview = self._preview
	local _currentPreviewKey = self._currentPreviewKey

	if not (_preview and _currentPreviewKey) then
		return
	end

	local _resolveData = self:_resolveData(_currentPreviewKey)
	local previewWindow = _resolveData and _resolveData.PreviewWindow
	local previewImage = _preview:FindFirstChild("PreviewImage")

	if _resolveData and _resolveData.Type == "color" then
		local previewHighlight = previewImage and previewImage:FindFirstChild("PreviewHighlight")
		local v4 = previewHighlight and previewHighlight.Visible and self:_shownValueFor(_currentPreviewKey)

		if v4 then
			previewHighlight.ImageColor3 = stringToColor3(v4)
		end
	end

	previewImage.ImageTransparency = 0

	if not (previewWindow and previewWindow.ImageOverlay) then
		return
	end

	if p == nil then
		p = self:_shownValueFor(_currentPreviewKey)
	end

	previewWindow.ImageOverlay(_preview, p)
end

function object:_updatePreview(instance, selectedProperty: string)
	if not selectedProperty or selectedProperty == "" then
		return
	end

	local _resolveData = self:_resolveData(selectedProperty)
	local previewWindow = _resolveData and _resolveData.PreviewWindow
	instance:SetAttribute("SelectedProperty", selectedProperty)

	if _resolveData then
		instance:SetAttribute("DisplayText", _resolveData.DisplayText or "")
		instance:SetAttribute("SettingType", _resolveData.Type or "")
	end

	local parent = instance.Parent
	local title = parent and parent:FindFirstChild("Title")
	local description = parent and parent:FindFirstChild("Description")

	if title and title:IsA("TextLabel") then
		title.Text = not _resolveData and "" or _resolveData.DisplayText or ""
	end

	if description and description:IsA("TextLabel") then
		description.RichText = true
		description.Text = not previewWindow and "" or previewWindow.Description or ""
	end

	local previewImage = instance:FindFirstChild("PreviewImage")
	local previewHighlight = previewImage and previewImage:FindFirstChild("PreviewHighlight")
	local v4 = previewWindow and previewWindow.PreviewImage ~= nil
	instance.Visible = v4 and true or false

	if v4 and previewImage then
		previewImage.Image = previewWindow.PreviewImage
	end

	if previewHighlight then
		if previewWindow and previewWindow.HighlightImage then
			previewHighlight.Image = previewWindow.HighlightImage
			previewHighlight.Visible = true
		else
			previewHighlight.Visible = false
		end
	end

	if previewHighlight then
		previewHighlight.ImageColor3 = Color3.new(1, 1, 1)
		local v5 = previewHighlight.Visible and _resolveData and _resolveData.Type == "color" and self:_shownValueFor(selectedProperty)

		if v5 then
			previewHighlight.ImageColor3 = stringToColor3(v5)
		end
	end

	self:_refreshOverlay()
end

function object:_initButtons(instance)
	local settingsButton

	if Universe:IsGame() then
		settingsButton = instance:WaitForChild("SettingsButton", 30)
		local info = workspace:WaitForChild("Info")
		local gameStarted = info and info:WaitForChild("GameStarted")
		gameStarted.Changed:Connect(function()
			task.delay(3, function()
				if settingsButton and gameStarted then
					settingsButton.Visible = gameStarted.Value
				end
			end)
		end)
	else
		local menu = instance:WaitForChild("Menu", 30)
		settingsButton = menu and menu:WaitForChild("SettingsButton", 30)

		if settingsButton then
			local GuiAnimations = require(ReplicatedStorage.Modules.GuiAnimations)

			if GuiAnimations then
				GuiAnimations.SetupButtonAnimationsSimple(settingsButton)
			end
		end
	end

	if not settingsButton then
		warn("[SettingsController] SettingsButton not found – HUD toggle disabled")
		return
	end

	self.styleController:Apply(settingsButton, "Shared.Default.button")

	local function fn()
		if MenuManager:IsOpen("SettingsController") then
			MenuManager:Close("SettingsController")
		else
			MenuManager:Open("SettingsController")
		end
	end

	bindActivate(settingsButton, fn) -- equivalent call inferred; original call site unknown
end

function object:_initActions()
	local function descend(child, ...)
		for _, childName in ipairs({ ... }) do
			child = child and child:FindFirstChild(childName)
		end

		return child
	end

	local v4 = descend(self.gui, "Margin", "InfoPanel", "Margin", "Context", "Margin")
	local apply = v4 and v4:FindFirstChild("Apply")

	if apply then
		apply.Visible = false
	end

	self._resetButton = v4 and v4:FindFirstChild("Reset")

	if self._resetButton then
		local v5 = descend(self._resetButton, "Display", "Background")

		if v5 then
			v5.BackgroundColor3 = color
		end

		local textLabel = self._resetButton:FindFirstChildWhichIsA("TextLabel", true)

		if textLabel then
			textLabel.TextColor3 = color2
		end

		if not textLabel:FindFirstChild("UIScale") then
			local uIScale = Instance.new("UIScale")
			uIScale.Parent = textLabel
		end

		self.styleController:Apply(self._resetButton, "Shared.Default.button")

		local function fn()
			if self._confirmOpen then
				return
			end

			local _currentTabName = self:_currentTabName()

			if not _currentTabName then
				return
			end

			local _collectTabResetPaths = self:_collectTabResetPaths(_currentTabName)
			local v6 = self:_tabHasKeybinds(_currentTabName) and self._repaintKeybinds ~= nil
			local v7

			if _currentTabName == "General" then
				v7 = self._resetRoleplayName ~= nil
			else
				v7 = false
			end

			if #_collectTabResetPaths == 0 and not (v6 or v7) then
				return
			end

			self:_showConfirm(string.format("Reset %s settings to default?", _currentTabName), "Yes", "No", function()
				if #_collectTabResetPaths > 0 then
					Network:Post("ResetSettings", _collectTabResetPaths)

					for _, _collectTabResetPath in ipairs(_collectTabResetPaths) do
						local _settingRenderer = self._settingRenderers[_collectTabResetPath]
						local _resolveData = self:_resolveData(_collectTabResetPath)

						if _settingRenderer and _resolveData and _resolveData.DefaultValue ~= nil then
							_settingRenderer(_resolveData.DefaultValue)
						end
					end
				end

				if v6 then
					InputService:ResetAll()
				end

				if v7 then
					self._resetRoleplayName()
				end

				self:_refreshOverlay()
			end)
		end

		bindActivate(self._resetButton, fn) -- equivalent call inferred; original call site unknown
	end
end

function object:_collectTabResetPaths(p: string)
	local v4 = {}
	local tab = PlayerSettings.Tabs[p]

	if not tab then
		return v4
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function consider(p2: string, data)
		if data.HideFromPlayer or data.Type == "control" or data.DefaultValue == nil then
			return
		end

		v4[#v4 + 1] = p2
	end

	for _, v5 in ipairs(tab) do
		local v6 = PlayerSettings.Hierarchy[v5]

		if not v6 then
			continue
		end

		if v6.Type then
			consider(v5, v6) -- equivalent call inferred; original call site unknown
		else
			for k, v7 in pairs(v6) do
				if not (type(v7) == "table" and v7.Type) then
					continue
				end

				consider(v5 .. "." .. k, v7) -- equivalent call inferred; original call site unknown
			end
		end
	end

	return v4
end

function object:_tabHasKeybinds(p: string)
	local tab = PlayerSettings.Tabs[p]

	if not tab then
		return false
	end

	for _, v4 in ipairs(tab) do
		local v5 = PlayerSettings.Hierarchy[v4]

		if v5 and v5.Type == "control" then
			return true
		end
	end

	return false
end

function object:_showConfirm(text: string, text2: string, value: string, callback)
	if self._confirmOpen then
		return
	end

	local parent = self.gui.Parent
	local purchaseDialogTemplate = parent and parent:FindFirstChild("PurchaseDialogTemplate")

	if not purchaseDialogTemplate then
		warn("[SettingsController] PurchaseDialogTemplate not found; cannot show confirm dialog")
		return
	end

	self._confirmOpen = true
	local clone = purchaseDialogTemplate:Clone()
	clone.Name = "SettingsConfirmDialog"
	local title = clone:FindFirstChild("Title")

	if title then
		title.Text = text
	end

	local description = clone:FindFirstChild("Description")

	if description then
		description.Text = ""
	end

	for _, childName in ipairs({ "TokenButton", "ReadyUp" }) do
		local child = clone:FindFirstChild(childName)

		if child then
			child.Visible = false
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function labelButton(cancelButton, text3)
		if not cancelButton then
			return
		end

		local title2 = cancelButton:FindFirstChild("Title")

		if title2 and title2:IsA("TextLabel") then
			title2.Text = text3
			title2.TextTransparency = 0
		else
			cancelButton.Text = text3
			cancelButton.TextTransparency = 0
			cancelButton.TextScaled = true
		end

		cancelButton.Visible = true
	end

	local ichorButton = clone:FindFirstChild("IchorButton")
	local cancelButton = clone:FindFirstChild("CancelButton")
	local exit = clone:FindFirstChild("Exit")

	for _, v4 in ipairs({ ichorButton, cancelButton, exit }) do
		if not v4 then
			continue
		end

		v4.SelectionBehaviorUp = Enum.SelectionBehavior.Stop
		v4.SelectionBehaviorDown = Enum.SelectionBehavior.Stop
		v4.SelectionBehaviorLeft = Enum.SelectionBehavior.Stop
		v4.SelectionBehaviorRight = Enum.SelectionBehavior.Stop
	end

	if exit then
		exit.NextSelectionDown = cancelButton
		exit.NextSelectionLeft = cancelButton
		exit.NextSelectionRight = ichorButton
		exit.NextSelectionUp = cancelButton
	end

	labelButton(cancelButton, value or "Cancel") -- equivalent call inferred; original call site unknown
	local priceFrame = ichorButton:WaitForChild("PriceFrame")
	priceFrame.Visible = false
	local clone2 = cancelButton:WaitForChild("Title"):Clone()
	clone2.Text = text2
	clone2.Parent = ichorButton
	local selectedObject = GuiService.SelectedObject
	local characterRemovingConnection = nil
	local cleanup

	cleanup = function()
		self._confirmOpen = false

		if characterRemovingConnection then
			characterRemovingConnection:Disconnect()
			characterRemovingConnection = nil
		end

		if self._confirmCancel == cleanup then
			self._confirmCancel = nil
		end

		clone:Destroy()

		if self:_isGamepadActive() and selectedObject and selectedObject.Parent then
			GuiService.SelectedObject = selectedObject
		end
	end

	self._confirmCancel = cleanup
	characterRemovingConnection = Players.LocalPlayer.CharacterRemoving:Connect(cleanup)

	if ichorButton then
		local function fn()
			self._confirmOpen = false

			if characterRemovingConnection then
				characterRemovingConnection:Disconnect()
				characterRemovingConnection = nil
			end

			if self._confirmCancel == cleanup then
				self._confirmCancel = nil
			end

			clone:Destroy()

			if self:_isGamepadActive() and selectedObject and selectedObject.Parent then
				GuiService.SelectedObject = selectedObject
			end

			if callback then
				callback()
			end
		end

		bindActivate(ichorButton, fn) -- equivalent call inferred; original call site unknown
	end

	if cancelButton and cancelButton then
		cancelButton.Activated:Connect(cleanup)
		InputService:RegisterActivation(cancelButton, cleanup)
	end

	if exit and exit then
		exit.Activated:Connect(cleanup)
		InputService:RegisterActivation(exit, cleanup)
	end

	clone.Visible = true
	clone.Parent = parent

	if ichorButton and self:_isGamepadActive() then
		ichorButton.Selectable = true
		GuiService.SelectedObject = ichorButton
	end
end

function object:_setRowsVisible(p2: string, flag: boolean)
	local v4 = self._flagRows and self._flagRows[p2]

	if not v4 then
		return
	end

	for _, guiObject in ipairs(v4) do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		guiObject.Visible = flag
		guiObject.Active = flag

		if guiObject:IsA("GuiButton") then
			guiObject.Selectable = flag
		end
	end
end

function object:_applyFlagVisibility()
	for k in pairs(self._flagRows or {}) do
		self:_setRowsVisible(k, SettingsFlags:IsEnabled(k))
	end

	local _controlHost = self._controlHost

	if _controlHost and SettingsFlags:IsEnabled(_controlHost.dotPath) and not (self._flagRows[_controlHost.dotPath] or self._controlBuildPending) then
		local v4 = {}

		for _, child in ipairs(_controlHost.frame:GetChildren()) do
			v4[child] = true
		end

		self._controlBuildPending = true

		if not self:_loadControls(_controlHost.frame, _controlHost.data, function()
			self._controlBuildPending = nil
			local children = {}

			for _, child in ipairs(_controlHost.frame:GetChildren()) do
				if not v4[child] then
					children[#children + 1] = child
				end
			end

			if #children == 0 then
				return
			end

			self._flagRows[_controlHost.dotPath] = children
			self:_setRowsVisible(_controlHost.dotPath, SettingsFlags:IsEnabled(_controlHost.dotPath))
		end) then
			self._controlBuildPending = nil
		end
	end

	local navigation = self.map and self.map.Navigation

	if navigation then
		for _, guiObject in ipairs(navigation:GetChildren()) do
			if not (guiObject:IsA("GuiObject") and self._tabFrames and self._tabFrames[guiObject.Name]) then
				continue
			end

			local isTabEnabled = SettingsFlags:IsTabEnabled(guiObject.Name)
			guiObject.Visible = isTabEnabled
			guiObject.Active = isTabEnabled

			if guiObject:IsA("GuiButton") then
				guiObject.Selectable = isTabEnabled
			end
		end
	end

	local _currentTabName = self:_currentTabName()

	if _currentTabName and not SettingsFlags:IsTabEnabled(_currentTabName) then
		for _, v4 in ipairs(self._tabNames or {}) do
			if not SettingsFlags:IsTabEnabled(v4) then
				continue
			end

			self:ShowPage(v4)
			return
		end
	end
end

function object:_initData()
	local modules = ReplicatedStorage.Modules
	require(modules:FindFirstChild("MyDataController") or modules:FindFirstChild("ClientUI"):WaitForChild("MyDataController")):onReplicaReady(function(myReplica)
		if not (myReplica and myReplica.Data) then
			return
		end

		self._myReplica = myReplica

		for _, v4 in ipairs(v2) do
			local tab = PlayerSettings.Tabs[v4]
			local _tabFrame = self._tabFrames[v4]

			if not (tab and _tabFrame) then
				continue
			end

			local scrollingFrame = _tabFrame:FindFirstChild("Margin") and _tabFrame.Margin:FindFirstChild("ScrollingFrame")

			if not scrollingFrame then
				continue
			end

			scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
			scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			scrollingFrame.CanvasSize = UDim2.new()

			for _, v5 in ipairs(tab) do
				local v6 = PlayerSettings.Hierarchy[v5]

				if not v6 then
					continue
				end

				if v6.Type then
					self:_loadSetting(myReplica, scrollingFrame, v5, v6)
				else
					for k, v7 in pairs(v6) do
						if type(v7) == "table" and v7.Type then
							self:_loadSetting(myReplica, scrollingFrame, v5 .. "." .. k, v7)
						end
					end
				end
			end

			if v4 == "General" and Universe:IsRoleplay() then
				self:_loadRoleplayName(scrollingFrame)
			end

			if v4 == "General" then
				self:ShowPage("General")
			end
		end

		self:_applyFlagVisibility()

		if not self._flagsConn then
			self._flagsConn = SettingsFlags.Changed:Connect(function()
				self:_applyFlagVisibility()
			end)
		end
	end)
end

function object:_loadSetting(object3, parent, name: string, data)
	if data.HideFromPlayer then
		return
	end

	local v4 = {}

	for _, child in ipairs(parent:GetChildren()) do
		v4[child] = true
	end

	local function registerCreated()
		local children = {}

		for _, child in ipairs(parent:GetChildren()) do
			if not v4[child] then
				children[#children + 1] = child
			end
		end

		self._flagRows[name] = children
		self:_setRowsVisible(name, SettingsFlags:IsEnabled(name))
	end

	if data.Type == "control" then
		self._controlHost = {
			frame = parent,
			data = data,
			dotPath = name
		}

		if SettingsFlags:IsEnabled(name) then
			self._controlBuildPending = true

			if not self:_loadControls(parent, data, function()
				self._controlBuildPending = nil
				registerCreated()

				if #self._flagRows[name] == 0 then
					self._flagRows[name] = nil
				end
			end) then
				self._controlBuildPending = nil
			end
		end
	else
		if not (data.Type and data.DisplayText) then
			return
		end

		local v5 = self._settingTemplates[data.Type] or self._settingTemplates.boolean

		if not v5 then
			warn("[SettingsController] No template found for type:", data.Type)
			return
		end

		local clone = v5:Clone()
		clone.Name = name
		clone.LayoutOrder = data.LayoutOrder or 99
		clone.ZIndex = 100 - (5 + clone.LayoutOrder)
		local textLabel = clone:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			textLabel.RichText = true
			textLabel.Text = data.DisplayText:format("")
		end

		self._settingButtons[name] = clone
		local background = clone:WaitForChild("Display"):WaitForChild("Background")

		local function updatePreviewVisual(p)
			local previewing = clone:GetAttribute("Previewing") == true
			background.BackgroundColor3 = previewing and Color3.fromRGB(177, 177, 177) or Color3.fromRGB(74, 74, 74)

			if previewing and p then
				self:hoverSound()
			end
		end

		clone:GetAttributeChangedSignal("Previewing"):Connect(function()
			updatePreviewVisual(true)
		end)
		updatePreviewVisual()

		if clone:IsA("GuiObject") then
			clone.MouseEnter:Connect(function()
				if self._openDropdown then
					return
				end

				self.gui:SetAttribute("SelectedProperty", name)
			end)
			clone.SelectionGained:Connect(function()
				self.gui:SetAttribute("SelectedProperty", name)
			end)

			local function fn()
				self.gui:SetAttribute("SelectedProperty", name)
			end

			bindActivate(clone, fn) -- equivalent call inferred; original call site unknown
		end

		if data.Type == "slider" then
			self:_loadSlider(clone, object3, data, name)
		elseif data.Type == "color" then
			self:_loadColor(clone, object3, data, name)
		elseif data.Type == "action" then
			self:_loadAction(clone, data, name)
		elseif data.Type == "choice" then
			self:_loadChoice(clone, object3, data, name)
		else
			self:_loadBoolean(clone, object3, data, name)
		end

		local function addHeader(header: string)
			local clone2 = v5:Clone()
			clone2.Name = "Header_" .. header
			clone2.LayoutOrder = data.LayoutOrder
			clone2.Selectable = false
			clone2.Active = false
			clone2.Interactable = false
			local property = clone2:FindFirstChild("Property")

			if property then
				property:Destroy()
			end

			local display = clone2:FindFirstChild("Display")

			if display then
				display:Destroy()
			end

			local textLabel2 = clone2:FindFirstChildWhichIsA("TextLabel")

			if textLabel2 then
				textLabel2.Text = string.upper(header)
				textLabel2.TextColor3 = Color3.fromRGB(255, 196, 87)
			end

			clone2.Parent = parent
		end

		if data.Header then
			addHeader(data.Header)
		end

		clone:GetAttributeChangedSignal("Disabled"):Connect(function()
			local disabled = clone:GetAttribute("Disabled")
			local parent2 = clone:FindFirstChild("Disabled")

			if not parent2 then
				parent2 = Instance.new("Frame")
				parent2.Size = UDim2.fromScale(1, 1)
				parent2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
				parent2.BackgroundTransparency = 0.5
				parent2.Visible = false
				parent2.Name = "Disabled"
				parent2.ZIndex = 100
				parent2.Parent = clone
				local uICorner = Instance.new("UICorner")
				uICorner.CornerRadius = UDim.new(1, 0)
				uICorner.Parent = parent2
			end

			clone.Interactable = not disabled

			if parent2 then
				parent2.Visible = disabled
			end
		end)

		if data.Dependency then
			clone:SetAttribute("Disabled", true)
			local dependency = data.Dependency
			local setting = dependency.Setting
			local value = dependency.Value

			local function updateDisabled()
				clone:SetAttribute("Disabled", self:_shownValueFor(setting) ~= value)
			end

			object3:ListenToChange(makeListenPath(setting), updateDisabled)
			clone:SetAttribute("Disabled", self:_shownValueFor(setting) ~= value)
		else
			clone:SetAttribute("Disabled", false)
		end

		clone.Parent = parent
		registerCreated()
	end
end

function object:_loadBoolean(instance, object3, p, selectedProperty: string)
	local property = instance:FindFirstChild("Property")
	local value = property and property:FindFirstChild("Value")
	local textLabel = instance:FindFirstChildWhichIsA("TextLabel")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setLabels(p2)
		local stringValue = getStringValue(p2, "boolean") -- equivalent call inferred; original call site unknown

		if textLabel then
			textLabel.RichText = true
			textLabel.Text = p.DisplayText
		end

		if value then
			value.RichText = true
			value.Text = stringValue
		end
	end

	local settingValue = getSettingValue(object3, selectedProperty)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function render(p2)
		settingValue = p2
		setLabels(p2) -- equivalent call inferred; original call site unknown

		if p.OnChangeClient then
			p.OnChangeClient(p2)
		end

		if self._currentPreviewKey == selectedProperty then
			self:_refreshOverlay(p2)
		end
	end

	self._settingRenderers[selectedProperty] = render

	local function action()
		self:_closeColorDropdown()
		self.gui:SetAttribute("SelectedProperty", selectedProperty)
		local v4 = not settingValue
		render(v4) -- equivalent call inferred; original call site unknown
		Network:Post("SetSetting", selectedProperty, v4)
	end

	bindActivate(instance, action) -- equivalent call inferred; original call site unknown

	if property then
		local next = property:FindFirstChild("Next")

		if next and next then
			next.Activated:Connect(action)
			InputService:RegisterActivation(next, action)
		end

		local previous = property:FindFirstChild("Previous")

		if previous and previous then
			previous.Activated:Connect(action)
			InputService:RegisterActivation(previous, action)
		end
	end

	object3:ListenToChange(makeListenPath(selectedProperty), function()
		render(getSettingValue(object3, selectedProperty)) -- equivalent call inferred; original call site unknown
	end)
	render(settingValue) -- equivalent call inferred; original call site unknown
end

function object:_loadChoice(instance, object3, data, selectedProperty: string)
	local property = instance:FindFirstChild("Property")
	local value = property and property:FindFirstChild("Value")
	local textLabel = instance:FindFirstChildWhichIsA("TextLabel")
	local options = data.Options or {}

	if textLabel then
		textLabel.RichText = true
		textLabel.Text = data.DisplayText
	end

	local v4 = nil

	local function render(defaultValue)
		if not table.find(options, defaultValue) then
			defaultValue = data.DefaultValue
		end

		v4 = defaultValue

		if value then
			value.RichText = true
			value.Text = (v3.choice or v3.default)(defaultValue)
		end

		if data.OnChangeClient then
			data.OnChangeClient(defaultValue)
		end

		if self._currentPreviewKey == selectedProperty then
			self:_refreshOverlay(defaultValue)
		end
	end

	self._settingRenderers[selectedProperty] = render

	local function step(p: number)
		return function()
			self:_closeColorDropdown()
			self.gui:SetAttribute("SelectedProperty", selectedProperty)

			if #options == 0 then
				return
			end

			local index = table.find(options, v4) or 1
			local option = options[(index - 1 + p) % #options + 1]
			render(option)
			Network:Post("SetSetting", selectedProperty, option)
		end
	end

	local v5 = 1

	local function fn()
		self:_closeColorDropdown()
		self.gui:SetAttribute("SelectedProperty", selectedProperty)

		if #options == 0 then
			return
		end

		local index = table.find(options, v4) or 1
		local option = options[(index - 1 + v5) % #options + 1]
		render(option)
		Network:Post("SetSetting", selectedProperty, option)
	end

	bindActivate(instance, fn) -- equivalent call inferred; original call site unknown

	if property then
		local next = property:FindFirstChild("Next")

		if next then
			local v6 = 1

			local function fn2()
				self:_closeColorDropdown()
				self.gui:SetAttribute("SelectedProperty", selectedProperty)

				if #options == 0 then
					return
				end

				local index = table.find(options, v4) or 1
				local option = options[(index - 1 + v6) % #options + 1]
				render(option)
				Network:Post("SetSetting", selectedProperty, option)
			end

			bindActivate(next, fn2) -- equivalent call inferred; original call site unknown
		end

		local previous = property:FindFirstChild("Previous")

		if previous then
			local v6 = -1

			local function fn2()
				self:_closeColorDropdown()
				self.gui:SetAttribute("SelectedProperty", selectedProperty)

				if #options == 0 then
					return
				end

				local index = table.find(options, v4) or 1
				local option = options[(index - 1 + v6) % #options + 1]
				render(option)
				Network:Post("SetSetting", selectedProperty, option)
			end

			bindActivate(previous, fn2) -- equivalent call inferred; original call site unknown
		end
	end

	object3:ListenToChange(makeListenPath(selectedProperty), function()
		render(getSettingValue(object3, selectedProperty))
	end)
	render(getSettingValue(object3, selectedProperty))
end

function object:_loadAction(instance, data, selectedProperty: string)
	local property = instance:FindFirstChild("Property")
	local value = property and property:FindFirstChild("Value")
	local textLabel = instance:FindFirstChildWhichIsA("TextLabel")

	if textLabel then
		textLabel.RichText = true
		textLabel.Text = data.DisplayText
	end

	if value then
		value.RichText = true
		value.Text = data.ValueText or "<font color=\"rgb(255,184,62)\">ENTER</font>"
	end

	if property then
		local next = property:FindFirstChild("Next")

		if next then
			next.Visible = false
		end

		local previous = property:FindFirstChild("Previous")

		if previous then
			previous.Visible = false
		end

		if not property:FindFirstChild("Padding") then
			local frame = Instance.new("Frame")
			frame.Name = "Padding"
			frame.BackgroundTransparency = 1
			frame.LayoutOrder = 2
			frame.Size = UDim2.fromScale(1, 1)
			local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
			uIAspectRatioConstraint.AspectRatio = 0.6
			uIAspectRatioConstraint.Parent = frame
			frame.Parent = property
		end
	end

	local function fn()
		self:_closeColorDropdown()
		self.gui:SetAttribute("SelectedProperty", selectedProperty)
		local onActivateClient = data.OnActivateClient

		if not onActivateClient then
			warn("[SettingsController] action setting has no OnActivateClient:", selectedProperty)
			return
		end

		if data.CloseOnActivate then
			MenuManager:Close("SettingsController")
		end

		local success, result = pcall(onActivateClient)

		if not success then
			warn("[SettingsController] action setting errored:", selectedProperty, result)
		end
	end

	bindActivate(instance, fn) -- equivalent call inferred; original call site unknown
end

function object:_loadSlider(instance, object2, data, p2: string)
	local property = instance:FindFirstChild("Property")
	local textLabel = instance:FindFirstChildWhichIsA("TextLabel")
	local value = property and property:FindFirstChild("Value")
	local scrolling = property and property:FindFirstChild("Scrolling")
	local thumb = scrolling and scrolling:FindFirstChild("Thumb")
	local uIDragDetector = thumb and thumb:FindFirstChild("UIDragDetector")
	local fakeButton = scrolling and scrolling:FindFirstChild("FakeButton")
	local fill = scrolling and scrolling:FindFirstChild("Fill")
	local snapTo = data.SnapTo or 1

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateText(p3: number)
		local stringValue = getStringValue(p3, "slider") -- equivalent call inferred; original call site unknown

		if textLabel then
			textLabel.RichText = true
			textLabel.Text = data.DisplayText:format(stringValue)
		end

		if value then
			value.RichText = true
			value.Text = stringValue
		end
	end

	local function setAlpha(value2: number)
		local v4 = math.clamp(value2, 0, 1)

		if fill then
			fill.Size = UDim2.fromScale(v4, 1)
		end

		if thumb then
			thumb.Position = UDim2.fromScale(v4, 0.5)
		end

		if fakeButton then
			fakeButton.Position = UDim2.fromScale(v4, 0.5)
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		local v4 = getSettingValue(object2, p2) or 0
		updateText(v4) -- equivalent call inferred; original call site unknown
		setAlpha(v4 / 100)
		instance:SetAttribute("Value", v4 / 100)

		if data.OnChangeClient then
			data.OnChangeClient(v4)
		end
	end

	self._settingRenderers[p2] = function(value2)
		local v4 = value2 or 0
		updateText(v4) -- equivalent call inferred; original call site unknown
		setAlpha(v4 / 100)
		instance:SetAttribute("Value", v4 / 100)
	end

	instance:GetAttributeChangedSignal("Value"):Connect(function()
		local v6 = roundNearest(math.clamp((instance:GetAttribute("Value") or 0) * 100, 0, 100) // 1, snapTo)
		updateText(v6) -- equivalent call inferred; original call site unknown
		setAlpha(v6 / 100)
	end)

	if uIDragDetector then
		uIDragDetector.DragContinue:Connect(function(point: Vector2)
			if not scrolling then
				return
			end

			local v4 = point.X - scrolling.AbsolutePosition.X
			local X = scrolling.AbsoluteSize.X
			local v5 = X <= 0 and 1 or X
			instance:SetAttribute("Value", (math.clamp(v4 / v5, 0, 1)))
		end)
		uIDragDetector.DragEnd:Connect(function()
			local v6 = roundNearest(math.clamp((instance:GetAttribute("Value") or 0) * 100, 0, 100) // 1, snapTo)
			HapticEffectsController:Play("ImpactEcho", v6)
			Network:Post("SetSetting", p2, v6)
		end)
	end

	local subtract = property and property:FindFirstChild("Subtract")
	local add = property and property:FindFirstChild("Add")

	local function stepSlider(p3: number)
		local v4 = math.clamp((instance:GetAttribute("Value") or 0) + p3 * (snapTo / 100), 0, 1)
		instance:SetAttribute("Value", v4)
		local v7 = roundNearest(math.clamp(v4 * 100, 0, 100) // 1, snapTo)
		HapticEffectsController:Play("ImpactEcho", v7)
		Network:Post("SetSetting", p2, v7)
	end

	if subtract then
		local function fn()
			stepSlider(-1)
		end

		bindActivate(subtract, fn) -- equivalent call inferred; original call site unknown
	end

	if add then
		local function fn()
			stepSlider(1)
		end

		bindActivate(add, fn) -- equivalent call inferred; original call site unknown
	end

	object2:ListenToChange(makeListenPath(p2), function()
		update() -- equivalent call inferred; original call site unknown
	end)
	update() -- equivalent call inferred; original call site unknown
end

function object:_initColorDropdownOverlay(instance)
	instance.Visible = false

	if self._colorDropdownOverlay then
		return
	end

	local margin = self.gui:FindFirstChild("Margin")
	local pages = margin and margin:FindFirstChild("Pages")

	if not pages then
		warn("[SettingsController] _initColorDropdownOverlay: self.gui.Margin.Pages not found")
		return
	end

	local clone = instance:Clone()
	clone.Name = "DropdownColor"
	clone.Visible = false
	clone.ZIndex = 200
	clone.Parent = pages
	self._colorDropdownOverlay = clone
	self._colorDropdownMaid = Maid.new()

	for _, button in ipairs(clone:GetChildren()) do
		if not button:IsA("GuiButton") then
			continue
		end

		button.Active = true
		local backgroundColor3 = button.BackgroundColor3
		local v4 = color3ToString(backgroundColor3) -- equivalent call inferred; original call site unknown

		local function previewOption()
			local _colorDropdownActive = self._colorDropdownActive

			if not _colorDropdownActive then
				return
			end

			_colorDropdownActive.preview.BackgroundColor3 = backgroundColor3
		end

		local function restorePreview()
			local _colorDropdownActive = self._colorDropdownActive

			if not _colorDropdownActive then
				return
			end

			local preview = _colorDropdownActive.preview
			preview.BackgroundColor3 = stringToColor3(_colorDropdownActive.shownValue())
		end

		button.MouseEnter:Connect(previewOption)
		button.MouseLeave:Connect(restorePreview)
		button.SelectionGained:Connect(previewOption)
		button.SelectionLost:Connect(restorePreview)

		local function fn()
			local _colorDropdownActive = self._colorDropdownActive

			if not _colorDropdownActive then
				return
			end

			_colorDropdownActive.renderPreview(v4)
			Network:Post("SetSetting", _colorDropdownActive.dotPath, v4)
			self:_closeColorDropdown()
		end

		bindActivate(button, fn) -- equivalent call inferred; original call site unknown
	end
end

function object:_openColorDropdown(colorDropdownActive, previousDropdownParent, p)
	local _colorDropdownOverlay = self._colorDropdownOverlay

	if not _colorDropdownOverlay then
		return
	end

	self._colorDropdownActive = colorDropdownActive
	self._colorDropdownActivePath = colorDropdownActive.dotPath
	self._openDropdown = _colorDropdownOverlay
	self._previousDropdownParent = previousDropdownParent
	self._colorDropdownMaid:DoCleaning()
	local parent = previousDropdownParent and previousDropdownParent.Parent and previousDropdownParent.Parent.Parent

	if parent and parent:IsA("ScrollingFrame") then
		self._colorDropdownMaid:GiveTask(parent:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			self:_closeColorDropdown()
		end))
	end

	local dotPath = colorDropdownActive.dotPath
	local parent2 = _colorDropdownOverlay.Parent
	task.defer(function()
		if self._colorDropdownActivePath ~= dotPath then
			return
		end

		local positionInParent = self.tweens.getPositionInParent(p, parent2)
		local sizeInParent = self.tweens.getSizeInParent(p, parent2)
		local sizeInParent2 = self.tweens.getSizeInParent(previousDropdownParent, parent2)
		local anchorPoint = p.AnchorPoint

		if positionInParent.Y.Scale + sizeInParent.Y.Scale > 1 then
			_colorDropdownOverlay.AnchorPoint = Vector2.new(anchorPoint.X, 1)
			_colorDropdownOverlay.Position = UDim2.fromScale(
				positionInParent.X.Scale,
				positionInParent.Y.Scale - sizeInParent2.Y.Scale / 1.3
			)
		else
			_colorDropdownOverlay.AnchorPoint = anchorPoint
			_colorDropdownOverlay.Position = positionInParent
		end

		_colorDropdownOverlay.Size = sizeInParent
		_colorDropdownOverlay.Visible = true

		if object:_isGamepadActive() then
			GuiService.SelectedObject = _colorDropdownOverlay:FindFirstChildWhichIsA("ImageButton")
		end
	end)
end

function object:_closeColorDropdown()
	local _colorDropdownOverlay = self._colorDropdownOverlay

	if self._previousDropdownParent and object:_isGamepadActive() then
		GuiService.SelectedObject = self._previousDropdownParent
	end

	if _colorDropdownOverlay then
		_colorDropdownOverlay.Visible = false
	end

	if self._colorDropdownMaid then
		self._colorDropdownMaid:DoCleaning()
	end

	self._colorDropdownActive = nil
	self._colorDropdownActivePath = nil
	self._openDropdown = nil
	self._previousDropdownParent = nil
end

function object:_loadColor(instance, object3, data, selectedProperty: string)
	instance.Selectable = false
	local property = instance:FindFirstChild("Property")
	local dropdownBox = property and property:FindFirstChild("DropdownBox")
	local preview = property and property:FindFirstChild("Preview")
	local textLabel = instance:FindFirstChildWhichIsA("TextLabel")

	if not (property and dropdownBox and preview) then
		warn("[SettingsController] Color setting missing Property/DropdownBox/Preview:", selectedProperty)
		return
	end

	self:_initColorDropdownOverlay(dropdownBox)
	property.Active = true
	property.SelectionGained:Connect(function()
		self.gui:SetAttribute("SelectedProperty", selectedProperty)
	end)

	local function shownValue()
		return getSettingValue(object3, selectedProperty) or data.DefaultValue or "255,255,255"
	end

	local function renderPreview(value: string)
		preview.BackgroundColor3 = stringToColor3(value)

		if textLabel then
			textLabel.RichText = true
			textLabel.Text = data.DisplayText:format(value)
		end

		if self._preview then
			local previewImage = self._preview:FindFirstChild("PreviewImage")
			local previewHighlight = previewImage and previewImage:FindFirstChild("PreviewHighlight")

			if previewHighlight then
				previewHighlight.ImageColor3 = stringToColor3(value)
			end
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyReplica()
		renderPreview(getSettingValue(object3, selectedProperty) or data.DefaultValue or "255,255,255")

		if data.OnChangeClient then
			data.OnChangeClient(getSettingValue(object3, selectedProperty))
		end
	end

	self._settingRenderers[selectedProperty] = renderPreview

	local function fn()
		if self._colorDropdownActivePath == selectedProperty then
			self:_closeColorDropdown()
			return
		end

		self:_closeColorDropdown()
		self:_openColorDropdown({
			preview = preview,
			dotPath = selectedProperty,
			frame = instance,
			myReplica = object3,
			shownValue = shownValue,
			renderPreview = renderPreview
		}, property, dropdownBox)
	end

	bindActivate(property, fn) -- equivalent call inferred; original call site unknown
	object3:ListenToChange(makeListenPath(selectedProperty), function()
		applyReplica() -- equivalent call inferred; original call site unknown
	end)
	applyReplica() -- equivalent call inferred; original call site unknown
end

function object:_loadRoleplayName(parent)
	local string2 = self._settingTemplates and self._settingTemplates.string

	if not string2 then
		warn("[SettingsController] 'string' template not found – roleplay name field skipped")
		return
	end

	local modules = ReplicatedStorage:FindFirstChild("Modules")
	local network = modules and modules:FindFirstChild("Network")
	local module2 = network and require(network)

	if not module2 then
		warn("[SettingsController] Modules.Network not found – roleplay name field skipped")
		return
	end

	local clone = string2:Clone()
	local property = clone:FindFirstChild("Property")
	local textBox = property and property:FindFirstChildWhichIsA("TextBox")

	if textBox then
		clone.Name = "RoleplayName"
		clone.LayoutOrder = 10
		clone.ZIndex = 100 - (5 + clone.LayoutOrder)
		clone.Selectable = false
		local textLabel = clone:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			textLabel.RichText = false
			textLabel.Text = "Roleplay Name"
		end

		self._keybindPreview = self._keybindPreview or {}
		self._keybindPreview.RoleplayName = {
			DisplayText = "Roleplay Name",
			Type = "string",
			PreviewWindow = {
				Description = "Set the name shown above your character while roleplaying. Leave it blank to use your display name. This isn't saved — it resets when you leave."
			}
		}
		self._settingButtons.RoleplayName = clone
		local background = clone:WaitForChild("Display"):WaitForChild("Background")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updatePreviewVisual()
			background.BackgroundColor3 = clone:GetAttribute("Previewing") == true and Color3.fromRGB(177, 177, 177) or Color3.fromRGB(
				74,
				74,
				74
			)
		end

		clone:GetAttributeChangedSignal("Previewing"):Connect(updatePreviewVisual)
		updatePreviewVisual() -- equivalent call inferred; original call site unknown

		local function focusPreview()
			self.gui:SetAttribute("SelectedProperty", "RoleplayName")
		end

		clone.MouseEnter:Connect(focusPreview)
		textBox.MouseEnter:Connect(focusPreview)
		textBox.Focused:Connect(focusPreview)
		textBox.SelectionGained:Connect(focusPreview)
		local localPlayer = Players.LocalPlayer
		local character = localPlayer.Character
		local rPName = character and character:GetAttribute("RPName")
		textBox.PlaceholderText = localPlayer.DisplayName

		if typeof(rPName) ~= "string" or rPName == "" or not rPName then
			rPName = localPlayer.DisplayName
		end

		textBox.Text = rPName

		-- equivalent calls inferred from this helper; original call sites unknown
		local function commit(displayName)
			local setRPName = module2:Get("SetRPName", displayName)
			local v4 = textBox

			if typeof(setRPName) == "string" and setRPName ~= "" and setRPName then
				displayName = setRPName
			end

			v4.Text = displayName
		end

		textBox.FocusLost:Connect(function()
			local displayName = textBox.Text:gsub("[<>]", ""):match("^%s*(.-)%s*$") or ""

			if displayName == "" or not displayName then
				displayName = localPlayer.DisplayName
			end

			local setRPName = module2:Get("SetRPName", displayName)
			local v4 = textBox

			if typeof(setRPName) == "string" and setRPName ~= "" and setRPName then
				displayName = setRPName
			end

			v4.Text = displayName
		end)

		function self._resetRoleplayName()
			commit(localPlayer.DisplayName) -- equivalent call inferred; original call site unknown
		end

		clone.Parent = parent
	else
		warn("[SettingsController] 'string' template missing Property.TextBox – roleplay name field skipped")
		clone:Destroy()
	end
end

local v4 = {
	chip = Color3.fromRGB(74, 74, 74),
	wait = Color3.fromRGB(86, 86, 40),
	danger = Color3.fromRGB(150, 60, 60),
	swap = Color3.fromRGB(58, 104, 140)
}
local v5 = {
	"Movement",
	"Gameplay",
	"Abilities",
	"UI",
	"Items",
	"Stickers"
}

function object:_loadControls(p, p2, callback)
	local control = self._settingTemplates and self._settingTemplates.control

	if control then
		InputService:OnReady(function()
			self:_buildControlRows(p, control, p2.LayoutOrder or 50)

			if callback then
				callback()
			end
		end)
		return true
	end

	warn("[SettingsController] 'control' template not found – keybind rows skipped")
	return false
end

function object:_buildControlRows(parent, instance, p: number)
	self._keybindPreview = self._keybindPreview or {}
	parent.ScrollingDirection = Enum.ScrollingDirection.Y
	parent.AutomaticCanvasSize = Enum.AutomaticSize.Y
	parent.CanvasSize = UDim2.new()
	local inputEndedConnection = nil
	local v6 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cancelReenableGate()
		if inputEndedConnection then
			inputEndedConnection:Disconnect()
			inputEndedConnection = nil
		end

		v6 = nil
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function reenableNavContexts()
		if not self._inputMenuActive then
			return
		end

		InputService:SetContextEnabled("Settings", true)

		if not self._menuNavRelease then
			self._menuNavRelease = InputService:RequestContext("MenuNav")
		end
	end

	local v7 = nil

	local function stopCapture(p2)
		if v7 then
			if v7.conn then
				v7.conn:Disconnect()
			end

			if v7.paint then
				v7.paint()
			end
		end

		v7 = nil
		self._keybindCapturing = false
		InputService:SetContextEnabled("Capture", false)
		cancelReenableGate() -- equivalent call inferred; original call site unknown

		if self._inputMenuActive then
			if p2 then
				local v8 = {}
				v6 = v8
				inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
					if not (v6 == v8 and input.KeyCode == p2) then
						return
					end

					cancelReenableGate() -- equivalent call inferred; original call site unknown
					reenableNavContexts() -- equivalent call inferred; original call site unknown
				end)
				task.delay(1, function()
					if v6 ~= v8 then
						return
					end

					cancelReenableGate() -- equivalent call inferred; original call site unknown
					reenableNavContexts() -- equivalent call inferred; original call site unknown
				end)
			else
				reenableNavContexts() -- equivalent call inferred; original call site unknown
			end
		end

		if self._capturingSlot then
			GuiService.AutoSelectGuiEnabled = true

			if object:_isGamepadActive() then
				GuiService.SelectedObject = self._capturingSlot
			end

			self._capturingSlot = nil
		end
	end

	self._stopKeybindCapture = stopCapture
	local paints = {}
	InputService.BindingChanged:Connect(function()
		for _, v8 in ipairs(paints) do
			v8()
		end
	end)

	function self._repaintKeybinds()
		for _, v8 in ipairs(paints) do
			v8()
		end
	end

	local function wireSlot(capturingSlot, p2, action: string, p3: string)
		local textLabel = capturingSlot:FindFirstChild("TextLabel")
		local v8

		if textLabel then
			v8 = textLabel or capturingSlot
		else
			v8 = capturingSlot
		end

		local function paint()
			local binding = InputService:GetBinding(action, p3)
			local glyph = p2 and InputService:GetGlyph(action, p3) or ""

			if p2 then
				p2.Visible = glyph ~= ""

				if glyph ~= "" then
					p2.Image = glyph
				end
			end

			v8.Text = p2 and glyph ~= "" and "" or KeyCodeNames.toDisplay(binding) or "—"
			capturingSlot.Display.Background.BackgroundColor3 = v4.chip
		end

		paints[#paints + 1] = paint

		local function fn()
			stopCapture()

			if p2 then
				p2.Visible = false
			end

			capturingSlot.Display.Background.BackgroundColor3 = v4.wait
			local v10 = {
				paint = paint
			}
			v10.conn = UserInputService.InputBegan:Connect(function(input)
				if v7 ~= v10 then
					return
				end

				if input.KeyCode == Enum.KeyCode.Escape then
					stopCapture()
					paint()
				else
					local v11 = input.UserInputType == Enum.UserInputType.Keyboard
					local v12 = string.find(input.UserInputType.Name, "Gamepad") ~= nil

					if p3 == "Gamepad" and v12 or p3 == "Keyboard" and v11 then
						local v13, v14 = InputService:SetBinding(action, p3, input.KeyCode.Name)
						local v16

						if v13 and p3 == "Gamepad" then
							v16 = input.KeyCode or nil
						end

						stopCapture(v16)

						if v13 then
							paint()

							if v14 then
								v8.Text = tostring(v14)
								capturingSlot.Display.Background.BackgroundColor3 = v4.swap
								task.delay(1.5, paint)
							end
						else
							v8.Text = "X " .. tostring(v14)
							capturingSlot.Display.Background.BackgroundColor3 = v4.danger
							task.delay(1.5, paint)
						end
					end
				end
			end)
			v7 = v10
			self._keybindCapturing = true
			InputService:SetContextEnabled("Capture", true)
			InputService:SetContextEnabled("Settings", false)

			if self._menuNavRelease then
				self._menuNavRelease()
				self._menuNavRelease = nil
			end

			self._capturingSlot = capturingSlot
			GuiService.AutoSelectGuiEnabled = false
			GuiService.SelectedObject = nil
			task.spawn(function()
				for i = 6, 1, -1 do
					if v7 ~= v10 then
						return
					end

					v8.Text = string.format("Press… %ds", i)
					task.wait(1)
				end

				if v7 == v10 then
					stopCapture()
					paint()
				end
			end)
		end

		bindActivate(capturingSlot, fn) -- equivalent call inferred; original call site unknown
		paint()
	end

	local layoutOrder = p

	local function addHeader(value: string)
		local clone = instance:Clone()
		clone.Name = "Header_" .. value
		clone.LayoutOrder = layoutOrder
		clone.Selectable = false
		clone.Active = false
		clone.Interactable = false
		layoutOrder += 1
		local property = clone:FindFirstChild("Property")

		if property then
			property:Destroy()
		end

		local display = clone:FindFirstChild("Display")

		if display then
			display:Destroy()
		end

		local textLabel = clone:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			textLabel.Text = string.upper(value)
			textLabel.TextColor3 = Color3.fromRGB(255, 196, 87)
		end

		clone.Parent = parent
	end

	local function addActionRow(p2)
		local clone = instance:Clone()
		clone.Name = "Keybind_" .. p2.action
		clone.LayoutOrder = layoutOrder
		layoutOrder += 1
		local textLabel = clone:FindFirstChildWhichIsA("TextLabel")

		if textLabel then
			textLabel.Text = p2.displayName or p2.action
		end

		local property = clone:FindFirstChild("Property")
		local keyboard = property and property:FindFirstChild("Keyboard")
		local gamepad = property and property:FindFirstChild("Gamepad")
		local glyph = gamepad and gamepad:FindFirstChild("Glyph")
		local reset = property and property:FindFirstChild("Reset")

		if reset then
			reset:Destroy()
			reset = nil
		end

		if glyph then
			glyph.AnchorPoint = Vector2.new(0.5, 0.5)
			glyph.Position = UDim2.fromScale(0.5, 0.5)
			glyph.Size = UDim2.new(1, -4, 1, -4)
			glyph.ScaleType = Enum.ScaleType.Fit
		end

		if gamepad and not gamepad:FindFirstChildOfClass("UISizeConstraint") then
			local uISizeConstraint = Instance.new("UISizeConstraint")
			uISizeConstraint.MinSize = Vector2.new(40, 0)
			uISizeConstraint.Parent = gamepad
		end

		if keyboard then
			wireSlot(keyboard, nil, p2.action, "Keyboard")
		end

		if gamepad then
			wireSlot(gamepad, glyph, p2.action, "Gamepad")
		end

		local v9 = {
			["Interact / Stop"] = "Rebinds the Interact and Stop action, applies instantly.",
			["Stats Panel"] = "Rebinds the Stats pop-up menu, applies instantly.",
			["Sticker Inventory"] = "Rebinds the Sticker Inventory, applies instantly.",
			["Sticker Wheel"] = "Rebinds the Sticker Wheel, applies instantly.",
			["Stickers: Page Left"] = "Rebinds the Sticker Wheel navigate left action, applies instantly.",
			["Stickers: Page Right"] = "Rebinds the Sticker Wheel navigate right action, applies instantly.",
			["Reset All Controls"] = "Restores all control keybinds across keyboard and gamepad to default settings. Removes all custom controls."
		}
		local v10 = "Keybind:" .. p2.action
		local displayName = p2.displayName or p2.action
		self._keybindPreview[v10] = {
			DisplayText = displayName,
			Type = "control",
			PreviewWindow = {
				Description = v9[displayName] and v9[displayName] or string.format(
					"Rebinds the %s action, applies instantly.",
					displayName
				)
			}
		}
		self._settingButtons[v10] = clone
		local background = clone:FindFirstChild("Display") and clone.Display:FindFirstChild("Background")

		if background then
			local function updateTint(p3)
				background.BackgroundColor3 = clone:GetAttribute("Previewing") == true and Color3.fromRGB(177, 177, 177) or Color3.fromRGB(
					74,
					74,
					74
				)

				if clone:GetAttribute("Previewing") == true and p3 then
					self:hoverSound()
				end
			end

			clone:GetAttributeChangedSignal("Previewing"):Connect(function()
				updateTint(true)
			end)
			updateTint()
		end

		local function focusPreview()
			self.gui:SetAttribute("SelectedProperty", v10)
		end

		local v11 = { clone }

		if keyboard then
			v11[#v11 + 1] = keyboard
		end

		if gamepad then
			v11[#v11 + 1] = gamepad
		end

		if reset then
			v11[#v11 + 1] = reset
		end

		for _, v12 in ipairs(v11) do
			v12.MouseEnter:Connect(focusPreview)
			v12.SelectionGained:Connect(focusPreview)
		end

		clone.Parent = parent
	end

	local remappableActions = InputService:GetRemappableActions()
	local v9 = {}

	local function emitCategory(p2: string)
		local remappableAction = remappableActions[p2]

		if not remappableAction then
			return
		end

		v9[p2] = true
		addHeader(p2)

		for _, v10 in ipairs(remappableAction) do
			addActionRow(v10)
		end
	end

	for _, v10 in ipairs(v5) do
		emitCategory(v10)
	end

	for k in pairs(remappableActions) do
		if not v9[k] then
			emitCategory(k)
		end
	end
end

function object.SetActivePage(p: string)
	local settings = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild(v):FindFirstChild("Settings")
	local pages = settings and settings:FindFirstChild("Margin") and settings.Margin:FindFirstChild("Pages")

	if not pages then
		return false
	end

	local flag = false

	for _, child in ipairs(pages:GetChildren()) do
		child.Visible = child.Name == p

		if child.Visible then
			flag = true
		end
	end

	if flag then
		settings:SetAttribute("CurrentPage", p)
		settings:SetAttribute("CurrentCategory", p)
	end

	return flag
end

return object