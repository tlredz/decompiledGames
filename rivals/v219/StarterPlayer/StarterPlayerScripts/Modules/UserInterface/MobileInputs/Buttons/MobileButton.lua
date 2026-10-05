local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local InputLibrary = require(ReplicatedStorage.Modules.InputLibrary)
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local MechanicsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("MechanicsController"))
local SettingsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SettingsController"))
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SpectateController"))
require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController"))
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("CameraController"))
local EmoteController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("EmoteController"))
local InfiniteParticles = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("InfiniteParticles"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local mobileButtonCooldownSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("MobileButtonCooldownSlot")
local mobileButton = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("MobileButton")
local MobileButton = {}
MobileButton.__index = MobileButton

function MobileButton.new(buttons, name)
	local self = setmetatable({}, MobileButton)
	self.Buttons = buttons
	self.Name = name
	self.Frame = mobileButton:Clone()
	self.InvisibleFrame = self.Frame:WaitForChild("Invisible")
	self.ResizeIcon = self.Frame:WaitForChild("Resize")
	self.WeaponIcon = self.Frame:WaitForChild("Weapon")
	self.IconContainer = self.Frame:WaitForChild("IconContainer")
	self.Icon = self.IconContainer:WaitForChild("Icon")
	self.AmmoFrame = self.Frame:WaitForChild("Ammo")
	self.AmmoIcon = self.AmmoFrame:WaitForChild("Icon")
	self.AmmoTitle = self.AmmoFrame:WaitForChild("Title")
	self.AmmoTitleStroke = self.AmmoTitle:WaitForChild("UIStroke")
	self._local_fighter = nil
	self._item_index = InputLibrary.MobileInputNameToItemIndex[self.Name]
	self._info = InputLibrary.MobileButtons[self.Name]
	self._is_active = false
	self._is_scoped = false
	self._is_resizing = false
	self._resize_connection = nil
	self._is_dragging = false
	self._drag_connection = nil
	self._drag_delta = nil
	self._drag_original_position = nil
	self._current_cooldown_frame = nil
	self._infinite_particles = InfiniteParticles.new(self.AmmoTitle)
	self:_Init()
	return self
end

function MobileButton:IsReallyVisible()
	return self.Frame.Visible and self.Buttons:IsReallyVisible()
end

function MobileButton.IsWithin(p, p2, p3)
	return UILibrary:IsWithinBounds(p2, p3, p.Frame.AbsolutePosition, p.Frame.AbsoluteSize)
end

function MobileButton:SetScoped(is_scoped)
	if self._is_scoped == is_scoped then
		return
	end

	self._is_scoped = is_scoped
	self:UpdateVisuals()
end

function MobileButton:SetActive(is_active)
	self._is_active = is_active
	self:UpdateVisuals()
end

function MobileButton:Input(p, p2)
	if not p2 and (self.Buttons.MobileInputs.EditorEnabled or not self:_IsVisible(self.Name)) then
		return
	end

	self:SetActive(p)

	if self.Name == "mobile_switchcamerapov" then
		if p then
			CameraController.CameraState:TogglePOV()
		end
	elseif self.Name == "mobile_crouch" and MechanicsController.IsSliding and self:_IsEasySlideEnabled() then
		if p then
			MechanicsController:MobileInput("mobile_jump", true)
		end
	elseif self.Name == "mobile_slide" and MechanicsController.IsSliding then
		if p then
			MechanicsController:MobileInput("mobile_jump", true)
		end
	else
		MechanicsController:MobileInput(self.Name, p)
	end
end

function MobileButton:InputEnded(_)
	if self._is_resizing then
		self._resize_connection:Disconnect()
		self._resize_connection = nil
		self._is_resizing = false
	end

	if self._is_dragging then
		self._drag_connection:Disconnect()
		self._drag_connection = nil
		self._drag_delta = nil
		self._drag_original_position = nil
		self._is_dragging = false
	end
end

function MobileButton:Button1Down(instance)
	self.Buttons.MobileInputs.DoubleTap:ResetTapWindow()

	if self:_IsToggleMode() then
		self:Input(not self._is_active)
		return
	end

	task.spawn(function()
		if not instance then
			return
		end

		while instance.UserInputState ~= Enum.UserInputState.End do
			instance:GetPropertyChangedSignal("UserInputState"):Wait()
		end

		self:Button1Up()
	end)
	self:Input(true)
end

function MobileButton:Button1Up()
	self:Input(false)
end

function MobileButton:UpdateVisuals()
	local v = (self._is_active or self._item_index and self._local_fighter and self._local_fighter.EquippedItem and self._local_fighter.EquippedItem == self._local_fighter.Items[self._item_index]) and not self.Buttons.MobileInputs.EditorEnabled
	local mobileButtonSetting = SettingsController:GetMobileButtonSetting(
		self.Name,
		"Mobile Buttons Transparency",
		"Transparency"
	)

	if self._is_scoped and SettingsController:GetMobileButtonSetting(self.Name, "Opaque Buttons While Scoped") then
		mobileButtonSetting = 0
	elseif v then
		mobileButtonSetting = mobileButtonSetting * 2 - 1
	end

	local imageTransparency = math.clamp(mobileButtonSetting, 0, 1)
	local v3 = math.clamp(mobileButtonSetting * 2, 0, 1)
	local v4 = math.clamp(mobileButtonSetting * 2 - 1, 0, 1)
	self.InvisibleFrame.Visible = not self:_IsVisibleSetting()
	self.IconContainer.ImageTransparency = v3 * 1 + 0
	self.Icon.ImageTransparency = imageTransparency
	self.Icon.ImageColor3 = v and Color3.fromRGB(0, 190, 255) or Color3.fromRGB(0, 0, 0)
	self.WeaponIcon.ImageTransparency = v4 * 1 + 0
	self.AmmoIcon.ImageTransparency = v4 * 1 + 0
	self.AmmoTitle.TextTransparency = v4 * 1 + 0
	self.AmmoTitleStroke.Transparency = v4 * 0.125 + 0.875
end

function MobileButton:UpdateWeaponIcon()
	local _GetClientItem = self:_GetClientItem()
	self.WeaponIcon.Image = not self._item_index and "" or (not self.Buttons.MobileInputs.EditorEnabled and _GetClientItem and true or false) and _GetClientItem.ViewModel:GetImage() or ItemLibrary.Items[CONSTANTS.DEFAULT_WEAPONS[self._item_index]].Image or ""
end

function MobileButton:UpdatePositionAndSize(p)
	self:ResetPositionAndSize()
	local v = p or PlayerDataController:Get("MobileButtonSettings")[PlayerDataController:Get("SettingsProfile")]

	if not v then
		return
	end

	local v2 = v[self.Name]

	if not v2 then
		return
	end

	self.Frame.Position = UDim2.new(0, v2.Position[1], 0, v2.Position[2])
	self.Frame.Size = UDim2.new(0, v2.Size[1], 0, v2.Size[2])
end

function MobileButton:ResetPositionAndSize()
	local v = math.min(self.Buttons.Frame.AbsoluteSize.X, self.Buttons.Frame.AbsoluteSize.Y) <= 500
	local uDim = v and UDim2.new() or UDim2.new(0, 0, 0, -45)
	local v2 = v and 1 or 1.7894736842105263
	local v3 = v and 1 or 1.7142857142857142
	self.Frame.Position = uDim + UDim2.new(
		self._info.DefaultPosition.X.Scale,
		self._info.DefaultPosition.X.Offset * v2,
		self._info.DefaultPosition.Y.Scale,
		self._info.DefaultPosition.Y.Offset * v2
	)
	self.Frame.Size = UDim2.new(0, self._info.DefaultSize.X.Offset * v3, 0, self._info.DefaultSize.Y.Offset * v3)
end

function MobileButton:UpdateVisibility()
	self.Frame.Visible = self:_IsVisible()

	if not self.Frame.Visible then
		self:SetActive(false)
	end
end

function MobileButton:UpdateMobileInputSettings()
	if not (self._info.IsCoreInput or self._info.QuickAttackType) then
		self:Input(false, true)
	end

	self:UpdateVisibility()
end

function MobileButton:Update(p2)
	self._infinite_particles:Update(p2)
end

function MobileButton:_GetClientItem()
	return self._item_index and self._local_fighter and self._local_fighter.Items[self._item_index]
end

function MobileButton:_UpdateAmmo()
	local v = not self.Buttons.MobileInputs.EditorEnabled and self:_GetClientItem()

	if not v then
		self.AmmoFrame.Visible = false
		return
	end

	local ammoVariables, v2, v3, v4 = v:GetAmmoVariables()
	local setting = PlayerDataController:GetSetting("Touch Button Ammo")
	local color = ammoVariables and ammoVariables <= 0 and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 255, 255)
	local v5 = ammoVariables and ammoVariables <= 0 and "rgb(255,50,50)" or "rgb(255,255,255)"
	local v6 = v4 and "∞" or v2 or ""
	local color2 = v2 and v2 <= 0 and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(255, 255, 255)
	local v7 = v2 and v2 <= 0 and "rgb(255,50,50)" or "rgb(255,255,255)"
	self.AmmoFrame.Visible = ammoVariables and setting
	self.AmmoTitle.Text = string.format("<font color=\"%s\">%s</font>", v5, v3 and "∞" or ammoVariables or "") .. (v6 == "" and "" or string.format(
		"<font size=\"8\" color=\"%s\"> %s</font>",
		v7,
		v6
	))
	local ammoIcon = self.AmmoIcon

	if v2 then
		color = color2 or color
	end

	ammoIcon.ImageColor3 = color
	self.AmmoIcon.Image = v.Info.AmmoType and ItemLibrary.Ammos[v.Info.AmmoType].Image or ""
	self._infinite_particles:SetActive(v3, v4)
end

function MobileButton:_GetMobileInputSettingsFromEquippedItem()
	local mobileInputSettings = self._local_fighter and self._local_fighter.EquippedItem and self._local_fighter.EquippedItem:GetMobileInputSettings()
	return mobileInputSettings and mobileInputSettings[InputLibrary.MobileButtons[self.Name].InputName]
end

function MobileButton:_IsEasySlideEnabled()
	return PlayerDataController:GetSetting("Easy Slide Mobile") and not PlayerDataController:GetSetting("MobileButton mobile_slide Enabled")
end

function MobileButton:_IsVisibleSetting()
	return PlayerDataController:GetSetting("MobileButton " .. self.Name .. " Enabled")
end

function MobileButton:_IsToggleMode()
	return self._info.AlwaysToggle or self:_GetMobileInputSettingsFromEquippedItem() == true
end

function MobileButton:_IsVisible()
	if self.Buttons.MobileInputs.EditorEnabled then
		return true
	end

	if not (self._local_fighter and self:_IsVisibleSetting()) then
		return false
	end

	if SpectateController.CurrentDuelSubject then
		if SpectateController.CurrentDuelSubject.DuelInterface.Voting:IsOpen() or not (SpectateController.CurrentDuelSubject.LocalDueler or self._info.VisibleWhileSpectatingForeignDuel) then
			return false
		end
	end

	if not self._info.AlwaysVisible and self:_GetMobileInputSettingsFromEquippedItem() == nil or self._info.HideIfDead and not self._local_fighter:IsAlive() then
		return false
	end

	if self.Name == "mobile_quickmelee" and #self._local_fighter.Items < self._local_fighter:GetQuickAttackIndex(self._info.QuickAttackType) then
		return false
	end

	if self.Name == "mobile_quickutility" and #self._local_fighter.Items < self._local_fighter:GetQuickAttackIndex(self._info.QuickAttackType) or self.Name == "mobile_equipnext" and #self._local_fighter.Items < 2 then
		return false
	end

	if self.Name == "mobile_switchcamerapov" and not CameraController:GetPublicState() and (not SpectateController.CurrentDuelSubject or SpectateController.CurrentDuelSubject.LocalDueler) or self.Name == "mobile_openplayerlist" and not SpectateController.CurrentDuelSubject then
		return false
	end

	if self.Name == "mobile_equipprimary" and #self._local_fighter.Items < 1 or self.Name == "mobile_equipsecondary" and #self._local_fighter.Items < 2 or self.Name == "mobile_equipmelee" and #self._local_fighter.Items < 3 then
		return false
	end

	if self.Name == "mobile_equiputility" and #self._local_fighter.Items < 4 then
		return false
	end

	return (self.Name ~= "mobile_useemote" or EmoteController:CanEmote()) and true or false
end

function MobileButton:_UpdateCameraSinking()
	self.Frame.Active = not SettingsController:GetMobileButtonSetting(
		self.Name,
		"Camera Mobile Button Sinking",
		"Camera Sinking"
	)
end

function MobileButton:_UpdateEditorVisuals()
	self.ResizeIcon.Visible = self.Buttons.MobileInputs.EditorEnabled

	if self._current_cooldown_frame then
		self._current_cooldown_frame.Visible = not self.Buttons.MobileInputs.EditorEnabled
	end
end

function MobileButton:_SetupEditorLogic()
	local function update_resize()
		local v = self.Frame.AbsolutePosition + self.Frame.AbsoluteSize * self.Frame.AnchorPoint - UILibrary:GetMouseLocation()
		local v2 = math.max(math.sqrt(v.X ^ 2 + v.Y ^ 2) * 2, 35)
		self.Frame.Size = UDim2.new(0, v2, 0, v2)
	end

	local position = nil

	local function update_drag(p)
		self._drag_delta += not position and createVector(0, 0, 0) or p.Position - position
		position = p.Position
		self.Frame.Position = UDim2.new(
			0,
			math.clamp(self._drag_original_position.X + self._drag_delta.X, 0, self.Buttons.Frame.AbsoluteSize.X),
			0,
			(math.clamp(self._drag_original_position.Y + self._drag_delta.Y, 0, self.Buttons.Frame.AbsoluteSize.Y))
		)
	end

	self.Frame.Resize.MouseButton1Down:Connect(function()
		if not self.Buttons.MobileInputs.EditorEnabled or self._is_resizing then
			return
		end

		self.Buttons.MobileInputs.EditorLogic:PendEdits()
		self._is_resizing = true
		self._resize_connection = RunService.RenderStepped:Connect(update_resize)
	end)
	self.Frame.MouseButton1Down:Connect(function()
		if not self.Buttons.MobileInputs.EditorEnabled or self._is_dragging then
			return
		end

		self.Buttons.MobileInputs.EditorLogic:PendEdits()
		position = nil
		self._is_dragging = true
		self._drag_original_position = self.Frame.AbsolutePosition + self.Frame.AbsoluteSize * self.Frame.AnchorPoint - self.Buttons.Frame.AbsolutePosition
		self._drag_delta = createVector(0, 0, 0)
		self._drag_connection = UserInputService.InputChanged:Connect(update_drag)
	end)
end

function MobileButton:_HookFighter()
	self._local_fighter = MechanicsController:WaitForLocalFighter()
	self._local_fighter:GetDataChangedSignal("InfiniteAmmo"):Connect(function()
		self:_UpdateAmmo()
	end)
	self._local_fighter:GetDataChangedSignal("InfiniteAmmoReserve"):Connect(function()
		self:_UpdateAmmo()
	end)
	PlayerDataController:GetSettingChangedSignal("Touch Button Ammo"):Connect(function()
		self:_UpdateAmmo()
	end)

	if self._item_index then
		local connections = {}
		local v = {}
		local connections2 = {}
		local v2 = nil

		local function cleanup_cooldown_effect()
			for _, connection in pairs(connections) do
				connection:Disconnect()
			end

			for _, v3 in pairs(v) do
				v3:Destroy()
			end

			connections = {}
			v = {}
			self._current_cooldown_frame = nil
		end

		local function cooldown_effect(p)
			if p.IsReversed then
				return
			end

			cleanup_cooldown_effect()
			local variables, v3, v4 = p.GetVariables()
			local transparency = SettingsController:GetMobileButtonSetting(
				self.Name,
				"Mobile Buttons Transparency",
				"Transparency"
			) * 2 - 1
			local clone = mobileButtonCooldownSlot:Clone()
			clone.Right.Frame.UIStroke.Transparency = transparency
			clone.Left.Frame.UIStroke.Transparency = transparency
			clone.Icon.Image = ""
			clone.Parent = self.Frame
			BetterDebris:AddItem(clone, variables)
			table.insert(v, clone)
			self._current_cooldown_frame = clone
			local uIGradient = clone.Right.Frame.UIStroke.UIGradient
			local uIGradient2 = clone.Left.Frame.UIStroke.UIGradient

			-- equivalent calls inferred from this helper; original call sites unknown
			local function set(value)
				local v6 = 1 - value
				local v7 = math.clamp(v6 * 2, 0, 1)
				local v8 = math.clamp(v6 * 2 - 1, 0, 1)
				uIGradient.Rotation = v7 * 180 + -180
				uIGradient2.Rotation = v8 * 180 + 0
			end

			local numberValue = Instance.new("NumberValue")
			numberValue.Value = v3
			table.insert(v, numberValue)
			table.insert(connections, numberValue:GetPropertyChangedSignal("Value"):Connect(function()
				set(numberValue.Value) -- equivalent call inferred; original call site unknown
			end))
			TweenService:Create(
				numberValue,
				TweenInfo.new(variables, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
				{
					Value = v4
				}
			):Play()
			self:_UpdateEditorVisuals()
		end

		local function update_client_item()
			local item = self._local_fighter.Items[self._item_index]

			if item == v2 then
				return
			end

			cleanup_cooldown_effect()

			for _, connection in pairs(connections) do
				connection:Disconnect()
			end

			connections2 = {}
			v2 = item
			self:_UpdateAmmo()

			if not v2 then
				return
			end

			table.insert(connections2, v2:GetDataChangedSignal("Ammo"):Connect(function()
				self:_UpdateAmmo()
			end))
			table.insert(connections2, v2:GetDataChangedSignal("AmmoReserve"):Connect(function()
				self:_UpdateAmmo()
			end))
			table.insert(connections2, v2.EquipFailedEffect:Connect(function()
				if not self:IsReallyVisible() then
					return
				end

				self.WeaponIcon.ImageColor3 = Color3.fromRGB(127, 0, 0)
				self.WeaponIcon.Position = UDim2.new(0.5, 0, 0.75, 0)
				TweenService:Create(
					self.WeaponIcon,
					TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						ImageColor3 = Color3.fromRGB(255, 255, 255),
						Position = UDim2.new(0.5, 0, 0.5, 0)
					}
				):Play()
				Utility:CreateSound("rbxassetid://17153811469", 2, 1, script, true, 5)
			end))
			table.insert(connections2, v2.Cooldowns.CooldownAdded:Connect(cooldown_effect))

			for _, cooldown in pairs(v2.Cooldowns.Cooldowns) do
				task.spawn(cooldown_effect, cooldown)
			end
		end

		self._local_fighter.ItemAdded:Connect(update_client_item)
		self._local_fighter.ItemRemoved:Connect(update_client_item)
		update_client_item()
	end

	self:UpdateVisibility()
	self:UpdateVisuals()
	self:UpdateWeaponIcon()
end

function MobileButton:_HookPages()
	local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Pages"))
	Pages.PageSystem.PagesActivity:Connect(function()
		self:Button1Up()
	end)
end

function MobileButton:_Setup()
	self.Frame.Name = self.Name
	self.Icon.Image = self._item_index and "rbxassetid://16793449322" or self._info.Image

	if self.Name == "mobile_crouch" then
		local function update_icon()
			if not MechanicsController.IsSliding then
				task.spawn(MechanicsController.MobileInput, MechanicsController, "mobile_jump", false)
			end

			self.Icon.Image = not self:_IsEasySlideEnabled() and self._info.Image or MechanicsController.IsSliding and InputLibrary.MobileButtons.mobile_jump.Image or MechanicsController.IsSprinting and InputLibrary.MobileButtons.mobile_slide.Image or self._info.Image
		end

		MechanicsController.StateChanged:Connect(update_icon)
		update_icon()
	elseif self.Name == "mobile_slide" then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function update_icon()
			self.Icon.Image = MechanicsController.IsSliding and InputLibrary.MobileButtons.mobile_jump.Image or self._info.Image
		end

		MechanicsController.StateChanged:Connect(update_icon)
		update_icon() -- equivalent call inferred; original call site unknown
	end
end

function MobileButton:_Init()
	self.Buttons.MobileInputs.EditorEnabledChanged:Connect(function()
		self:_UpdateEditorVisuals()
		self:UpdateVisuals()
	end)
	PlayerDataController:GetSettingChangedSignal("MobileButton " .. self.Name .. " Enabled"):Connect(function()
		self:UpdateVisuals()
		self:UpdateVisibility()
	end)
	PlayerDataController:GetSettingChangedSignal("Camera Mobile Button Sinking"):Connect(function()
		self:_UpdateCameraSinking()
	end)
	PlayerDataController:GetSettingChangedSignal("MobileButton " .. self.Name .. " Camera Sinking"):Connect(function()
		self:_UpdateCameraSinking()
	end)
	PlayerDataController:GetSettingChangedSignal("Mobile Buttons Transparency"):Connect(function()
		self:UpdateVisuals()
	end)
	PlayerDataController:GetSettingChangedSignal("MobileButton " .. self.Name .. " Transparency"):Connect(function()
		self:UpdateVisuals()
	end)
	PlayerDataController:GetSettingChangedSignal("MobileButton " .. self.Name .. " Override"):Connect(function()
		self:_UpdateCameraSinking()
		self:UpdateVisuals()
	end)
	self:_Setup()
	self:_SetupEditorLogic()
	self:_UpdateEditorVisuals()
	self:_UpdateCameraSinking()
	self:_UpdateAmmo()
	self:UpdateVisuals()
	self:UpdateWeaponIcon()
	self:UpdatePositionAndSize()
	self:UpdateVisibility()
	task.defer(self._HookPages, self)
	task.defer(self._HookFighter, self)
end

return MobileButton