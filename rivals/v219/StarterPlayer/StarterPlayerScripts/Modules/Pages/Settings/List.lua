local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GamepadService = game:GetService("GamepadService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local PermissionsLibrary = require(ReplicatedStorage.Modules.PermissionsLibrary)
local SettingsLibrary = require(ReplicatedStorage.Modules.SettingsLibrary)
local BountyLibrary = require(ReplicatedStorage.Modules.BountyLibrary)
local InputLibrary = require(ReplicatedStorage.Modules.InputLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local SettingsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SettingsController"))
local Inset = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Inset"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local settingInputHotkeysDivider = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("SettingInputHotkeysDivider")
local settingInputHotkeysSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("SettingInputHotkeysSlot")
local settingHotkeySlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("SettingHotkeySlot")
local settings = Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Settings")
local List = {}
List.__index = List

function List.new(page)
	local self = setmetatable({}, List)
	self.Hovered = Signal.new()
	self.ResetSettings = Signal.new()
	self.Page = page
	self.Frame = self.Page.Container:WaitForChild("Settings")
	self.WaitingFrame = self.Frame:WaitForChild("Waiting")
	self.DotsFrame = self.WaitingFrame:WaitForChild("Dots")
	self.Container = self.Frame:WaitForChild("Container")
	self.HotkeyHeaderFrame = self.Container:WaitForChild("HotkeyHeader")
	self.List = self.Container:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.HotkeyTopFrame = self.Container:WaitForChild("HotkeyTop")
	self.HotkeyBottomFrame = self.Container:WaitForChild("HotkeyBottom")
	self.ResetDefaultFrame = self.Container:WaitForChild("ResetDefault")
	self.ResetDefaultContainer = self.ResetDefaultFrame:WaitForChild("Container")
	self.ResetDefaultButton = self.ResetDefaultContainer:WaitForChild("Controls"):WaitForChild("Confirm"):WaitForChild("Button")
	self.ResetDefaultDescription = self.ResetDefaultContainer:WaitForChild("Details"):WaitForChild("Display"):WaitForChild("Description")
	self.MobileEditorFrame = self.Container:WaitForChild("MobileEditor")
	self.MobileEditorButton = self.MobileEditorFrame:WaitForChild("Container"):WaitForChild("Controls"):WaitForChild("Confirm"):WaitForChild("Button")
	self.SettingObjects = {}
	self._setting_objects_by_section = {}
	self._input_hotkeys_slots = {}
	self._is_listening_for_hotkey = false
	self._last_reset_click = 0
	self:_Init()
	return self
end

function List:SetPage(value)
	local frame = self.Frame
	local size

	if value == "Hotkeys" then
		size = UDim2.new(0.85, 0, 0.9, 0)
	else
		size = UDim2.new(0.5, 0, 0.9, 0)
	end

	frame.Size = size
	local list = self.List
	local position

	if value == "Hotkeys" then
		position = UDim2.new(0.5, 0, 0.075, 0)
	else
		position = UDim2.new(0.5, 0, 0, 0)
	end

	list.Position = position
	self.List.CanvasPosition = Vector2.zero
	local layout = self.Layout
	local padding

	if value == "Hotkeys" then
		padding = UDim.new(0, 0)
	else
		padding = UDim.new(0.01, 0)
	end

	layout.Padding = padding
	self.HotkeyHeaderFrame.Visible = value == "Hotkeys"
	self.HotkeyTopFrame.Visible = value == "Hotkeys"
	self.HotkeyBottomFrame.Visible = value == "Hotkeys"
	local resetDefaultFrame = self.ResetDefaultFrame
	local size2

	if value == "Hotkeys" then
		size2 = UDim2.new(1, 0, 0.11764705882352942, 0)
	else
		size2 = UDim2.new(1, 0, 0.2, 0)
	end

	resetDefaultFrame.Size = size2
	local resetDefaultContainer = self.ResetDefaultContainer
	local size3

	if value == "Hotkeys" then
		size3 = UDim2.new(0.5882352941176471, 0, 0.6, 0)
	else
		size3 = UDim2.new(1, 0, 0.6, 0)
	end

	resetDefaultContainer.Size = size3
	self.ResetDefaultDescription.Text = string.format(
		"Double tap to reset your %s settings back to default",
		value or "???"
	)
	self.MobileEditorFrame.Visible = value == "Touch"

	for k, v6 in pairs(self._setting_objects_by_section) do
		for _, v7 in pairs(v6) do
			local settingFrame = v7.SettingFrame
			local parent

			if value == k then
				parent = self.Container
			end

			settingFrame.Parent = parent
		end
	end

	for _, _input_hotkeys_slot in pairs(self._input_hotkeys_slots) do
		local parent

		if value == "Hotkeys" then
			parent = self.Container
		end

		_input_hotkeys_slot.Parent = parent
	end
end

function List.Close(p)
	for _, settingObject in pairs(p.SettingObjects) do
		if settingObject.SettingsInfo.InputType ~= "Color" then
			continue
		end

		settingObject:SetOpen(false)
		settingObject:CancelInputs(false)
	end
end

function List:_UpdateSize()
	self.List.Size = UDim2.new(
		1,
		0,
		0,
		UILibrary.MainGui.AbsolutePosition.Y + UILibrary.MainGui.AbsoluteSize.Y - self.List.AbsolutePosition.Y
	)
end

function List:_GenerateHotkeys()
	for k, v in pairs(SettingsLibrary.HOTKEYS_GUIDE) do
		local visible2 = k % 2 == 0

		if v == "Divider" then
			local clone = settingInputHotkeysDivider:Clone()
			clone.AlternateBackground.Visible = visible2
			clone.LayoutOrder = k
			clone.Parent = self.Container
			table.insert(self._input_hotkeys_slots, clone)
		else
			local input = InputLibrary.Inputs[v]
			local v3 = {}
			local clone = settingInputHotkeysSlot:Clone()
			clone.AlternateBackground.Visible = visible2
			clone.Title.Text = input.DisplayName
			clone.Icon.Image = input.Image
			clone.LayoutOrder = k
			table.insert(self._input_hotkeys_slots, clone)

			local function update_reset_button()
				local flag = false

				for k2, v7 in pairs(v3) do
					if PlayerDataController:GetSetting(v7[2]) == SettingsLibrary.Info[v7[2]].DefaultValue then
						continue
					end

					flag = true
					break
				end

				clone.Reset.Visible = flag
				local icon = clone.Icon
				local position

				if flag then
					position = UDim2.new(0.15, 0, 0.5, 0)
				else
					position = UDim2.new(0.1, 0, 0.5, 0)
				end

				icon.Position = position
				local title = clone.Title
				local position2

				if flag then
					position2 = UDim2.new(0.175, 0, 0.5, 0)
				else
					position2 = UDim2.new(0.125, 0, 0.5, 0)
				end

				title.Position = position2
			end

			local v6 = v3
			clone.Reset.MouseButton1Click:Connect(function()
				local v7 = {}

				for k2, v8 in pairs(v6) do
					table.insert(v7, { v8[2], SettingsLibrary.Info[v8[2]].DefaultValue })
				end

				SettingsController:ChangeSettings(v7)
			end)
			ButtonEffect:Add(clone.Reset)
			local update_reset_button2 = update_reset_button

			local function setup(state2, p)
				local v7 = SettingsLibrary.Info[p]
				local connections = {}
				local v8 = nil

				local function set_text(enumName)
					if enumName == v8 then
						return
					end

					v8 = enumName
					local inputEnumFromName = enumName and Utility:GetInputEnumFromName(enumName)
					state2.Listening.Visible = false
					state2.Keybind.Visible = true
					state2.Keybind:RemoveTag("UIKeybindContainer")

					if inputEnumFromName then
						state2.Keybind:SetAttribute("EnumType", (tostring(inputEnumFromName.EnumType)))
						state2.Keybind:SetAttribute("EnumName", enumName)
						state2.Keybind:AddTag("UIKeybindContainer")
					end
				end

				local function set_action_buttons_visible(visible)
					local visible3 = PlayerDataController:GetSetting(p) ~= "nil"
					state2.Edit.Size = visible3 and UDim2.new(0.5, 0, 1, 0) or UDim2.new(1, 0, 1, 0)
					state2.Edit.BackgroundHalf.Visible = visible3
					state2.Edit.BackgroundFull.Visible = not visible3
					state2.Edit.Visible = visible
					state2.Unbind.Visible = visible3 and visible
				end

				local function clear_listen_connections()
					for k2, connection in pairs(connections) do
						connection:Disconnect()
					end

					connections = {}
					self._is_listening_for_hotkey = false
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local function input_value(p2)
					clear_listen_connections()
					state2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
					v8 = nil
					set_text(p2)
					SettingsController:ChangeSetting(p, p2)
				end

				state2.Edit.MouseButton1Click:Connect(function()
					set_action_buttons_visible(false)
					clear_listen_connections()
					self._is_listening_for_hotkey = true
					v8 = nil
					table.insert(connections, UserInputService.InputBegan:Connect(function(input2)
						local name

						if input2.UserInputType == Enum.UserInputType.MouseButton1 and (GamepadService.GamepadCursorEnabled or GuiService.SelectedObject) then
							name = Enum.KeyCode.ButtonR2.Name
						elseif input2.KeyCode == Enum.KeyCode.Unknown then
							name = input2.UserInputType.Name
						else
							name = input2.KeyCode.Name
						end

						input_value(v7.VerifyInput(name)) -- equivalent call inferred; original call site unknown
					end))
					state2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					state2.Keybind.Visible = false
					state2.Listening.Visible = true
					GuiService.SelectedObject = nil
				end)
				state2.Unbind.MouseButton1Click:Connect(function()
					set_action_buttons_visible(false)
					SettingsController:ChangeSetting(p, nil)
				end)
				state2.MouseEnter:Connect(function()
					if #connections == 0 then
						set_action_buttons_visible(true)
					end
				end)
				state2.MouseLeave:Connect(function()
					set_action_buttons_visible(false)
				end)

				-- equivalent calls inferred from this helper; original call sites unknown
				local function update()
					set_text(PlayerDataController:GetSetting(p))
					update_reset_button2()
				end

				PlayerDataController:GetSettingChangedSignal(p):Connect(update)
				update() -- equivalent call inferred; original call site unknown
			end

			for k2, v7 in pairs(InputLibrary.HOTKEY_FORMATS) do
				for k3, formatString in pairs(v7) do
					local parent = clone[k2 .. k3]
					local v9 = string.format(formatString, v)
					local clone2 = settingHotkeySlot:Clone()
					clone2.Listening.Visible = false
					clone2.Edit.Visible = false
					clone2.Unbind.Visible = false
					clone2.Parent = parent
					table.insert(v3, { parent, v9 })
					task.defer(setup, clone2, v9)
				end
			end

			if k % 3 == 0 then
				RunService.RenderStepped:Wait()
			end
		end
	end
end

function List:_GenerateSettings()
	local clone = table.clone(SettingsLibrary.DEPENDENCIES)

	for _, orderBySection in pairs(SettingsLibrary.OrderBySections) do
		local flag = false

		for k, v in pairs(orderBySection) do
			if not (v.InputType ~= "Hotkey" and (v.Name ~= "Bounty Rewards Disabled" or BountyLibrary.Players[tostring(Players.LocalPlayer.UserId)])) then
				continue
			end

			if not ((not table.find(SettingsLibrary.STAFF_SETTINGS, v.Name) or PlayerDataController:IsNosniyGamesTeamMember()) and (v.Name ~= "Staff Team Tools Disabled Leads" or not PermissionsLibrary.USE_GROUP_ROLES_INSTEAD_OF_DATASTORES)) then
				continue
			end

			local v2 = clone[v.Name]
			local module = require(settings:WaitForChild(v.InputType))
			local v3 = module.new(v)
			v3:OverrideDescription("")
			v3.SettingFrame.LayoutOrder = k
			self._setting_objects_by_section[v.Section] = self._setting_objects_by_section[v.Section] or {}
			self._setting_objects_by_section[v.Section][v.Name] = v3
			self.SettingObjects[v.Name] = v3
			v3.Hovered:Connect(function()
				self.Hovered:Fire(v3)
			end)

			if v3.SettingsInfo.InputType == "Divider" then
				flag = true

				if k > 1 then
					v3:SetDividerSpacing(1.5)
				end
			elseif flag then
				v3:Scale(0.95)
			end

			if v2 then
				if not v2[3] then
					local name = v.Name
					local v5 = flag and 1 or 0

					while clone[name] do
						name = clone[name][1]
						v5 += 1
					end

					v3:Scale(1 - v5 * 0.05)
				end

				local is_visible
				local is_visible2 = is_visible

				is_visible = function(p)
					local v5 = PlayerDataController:GetSetting(clone[p][1]) == clone[p][2]

					if clone[p][4] then
						v5 = not v5
					end

					if v5 or clone[p][2] == "any" then
						return not clone[clone[p][1]] or is_visible2(clone[p][1])
					else
						return false
					end
				end

				-- equivalent calls inferred from this helper; original call sites unknown
				local v5 = v3
				local is_visible3 = is_visible
				local v6 = v

				local function update_visibility()
					v5.SettingFrame.Visible = is_visible3(v6.Name)
				end

				PlayerDataController:GetDataChangedSignal("SettingsProfile"):Connect(update_visibility)
				local hook
				local update_visibility2 = update_visibility
				local hook2 = hook

				hook = function(p)
					PlayerDataController:GetSettingChangedSignal(p):Connect(update_visibility2)

					if clone[p] then
						hook2(clone[p][1])
					end
				end

				local v7 = v2[1]
				PlayerDataController:GetSettingChangedSignal(v7):Connect(update_visibility)

				if clone[v7] then
					hook(clone[v7][1])
				end

				update_visibility() -- equivalent call inferred; original call site unknown
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local v5 = v3
			local v6 = v

			local function update()
				v5:SetValue(PlayerDataController:GetSetting(v6.Name), true, true)
			end

			PlayerDataController:GetSettingChangedSignal(v.Name):Connect(update)
			PlayerDataController:GetDataChangedSignal("SettingsProfile"):Connect(update)
			update() -- equivalent call inferred; original call site unknown
			local v7 = v
			local v8 = v3
			v3.Replicate:Connect(function()
				SettingsController:ChangeSetting(v7.Name, v8.Value)
			end)

			if v3.SettingsInfo.InputType == "Slider" or v3.SettingsInfo.InputType == "Color" then
				local v9 = v
				v3.SliderChanged:Connect(function(p)
					PlayerDataController.SettingsSliderChanged:Fire(v9.Name, p)
				end)
			end

			if k % 3 == 0 then
				RunService.RenderStepped:Wait()
			end
		end
	end
end

function List:_Generate()
	self.DotsFrame:AddTag("UILoadingDots")
	self.WaitingFrame.Visible = true
	self.Container.Visible = false
	self:_GenerateSettings()
	self:_GenerateHotkeys()
	self:SetPage(self.Page.CurrentPage)
	self.DotsFrame:RemoveTag("UILoadingDots")
	self.WaitingFrame.Visible = false
	self.Container.Visible = true
end

function List:_Init()
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
	end)
	self.List:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateSize()
	end)
	self.ResetDefaultButton.MouseButton1Click:Connect(function()
		if tick() < self._last_reset_click + 0.5 then
			self.ResetSettings:Fire()
		else
			self._last_reset_click = tick()
		end
	end)
	self.MobileEditorButton.MouseButton1Click:Connect(function()
		self.Page.Closed:Fire()
		task.defer(Inset.MobileEditorBar.SetVisible, Inset.MobileEditorBar, true, nil, true)
	end)
	UILibrary.MainGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateSize()
	end)
	UILibrary.MainGui:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateSize()
	end)
	GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
		if self.Page:IsOpen() and self._is_listening_for_hotkey then
			task.defer(function()
				GuiService.SelectedObject = nil
			end)
		end
	end)
	task.spawn(self._Generate, self)
	self:_UpdateSize()
	ButtonEffect:Add(self.ResetDefaultButton)
	ButtonEffect:Add(self.MobileEditorButton)
end

return List