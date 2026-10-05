local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local InputLibrary = require(ReplicatedStorage.Modules.InputLibrary)
local EnumLibrary = require(ReplicatedStorage.Modules.EnumLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local MechanicsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("MechanicsController"))
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SpectateController"))
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("CameraController"))
local EmoteController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("EmoteController"))
local MobileButton = require(script:WaitForChild("MobileButton"))
local Buttons = {}
Buttons.__index = Buttons

function Buttons.new(mobileInputs)
	local self = setmetatable({}, Buttons)
	self.MobileInputs = mobileInputs
	self.Frame = self.MobileInputs.Frame:WaitForChild("Buttons")
	self.Buttons = {}
	self._generated = false
	self._hooked_fighter = false
	self._local_fighter = nil
	self._connections = {}
	self._duel_subject_connections = {}
	self:_Init()
	return self
end

function Buttons:IsReallyVisible()
	return self.Frame.Visible and self.MobileInputs.Frame.Visible
end

function Buttons:GetButtonsFromPosition(p2, p3)
	local Inset = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Inset)

	if Inset:IsWithinAnyBar(p2, p3) then
		return {}
	end

	local buttons = {}

	for _, button in pairs(self.Buttons) do
		if button:IsReallyVisible() and button:IsWithin(p2, p3) then
			table.insert(buttons, button)
		end
	end

	return buttons
end

function Buttons:GetCurrentProfile()
	local result = {}

	for k, button in pairs(self.Buttons) do
		local v = button.Frame.AbsolutePosition + button.Frame.AbsoluteSize * button.Frame.AnchorPoint - self.Frame.AbsolutePosition
		result[k] = {
			Position = { v.X, v.Y },
			Size = { button.Frame.Size.X.Offset, button.Frame.Size.Y.Offset }
		}
	end

	return result
end

function Buttons:EncryptProfile()
	return EnumLibrary:EncryptTable(self:GetCurrentProfile())
end

function Buttons:VerifyControls(p)
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	for _, _duel_subject_connection in pairs(self._duel_subject_connections) do
		_duel_subject_connection:Disconnect()
	end

	self._connections = {}
	self._duel_subject_connections = {}

	if self._generated then
		MechanicsController:MobileInput("mobile_shoot", false)
	end

	if not p then
		return
	end

	self:_GenerateButtons()
	task.spawn(self._HookFighter, self)
	table.insert(self._connections, RunService.RenderStepped:Connect(function(dt)
		for _, button in pairs(self.Buttons) do
			button:Update(dt)
		end
	end))
	table.insert(self._connections, CameraController.ActiveStateChanged:Connect(function(_)
		self:_UpdateVisibilities()
	end))
	table.insert(self._connections, EmoteController.CanEmoteChanged:Connect(function()
		self:_UpdateVisibilities()
	end))
	table.insert(self._connections, PlayerDataController:GetDataChangedSignal("SettingsProfile"):Connect(function()
		self:_UpdatePositionsAndSizes()
	end))
	table.insert(self._connections, PlayerDataController:GetDataChangedSignal("MobileButtonSettings"):Connect(function()
		self:_UpdatePositionsAndSizes()
	end))

	local function update_duel_subject()
		for _, _duel_subject_connection in pairs(self._duel_subject_connections) do
			_duel_subject_connection:Disconnect()
		end

		self._duel_subject_connections = {}
		self:_UpdateVisibilities()

		if not SpectateController.CurrentDuelSubject then
			return
		end

		table.insert(
			self._duel_subject_connections,
			SpectateController.CurrentDuelSubject.DuelInterface.Voting.VisibilityChanged:Connect(function()
				self:_UpdateVisibilities()
			end)
		)
	end

	table.insert(self._connections, SpectateController.DuelSubjectChanged:Connect(update_duel_subject))
	update_duel_subject()
	table.insert(self._connections, UserInputService.InputBegan:Connect(function(input, _)
		if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end

		local buttonsFromPosition = self:GetButtonsFromPosition(input.Position.X, input.Position.Y)

		for _, v in pairs(buttonsFromPosition) do
			v:Button1Down(input)
		end
	end))
	table.insert(self._connections, UserInputService.InputEnded:Connect(function(input, _)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			for _, button in pairs(self.Buttons) do
				button:InputEnded(input)
			end
		end
	end))
	table.insert(self._connections, MechanicsController.StateChanged:Connect(function(_)
		if self:IsReallyVisible() and not MechanicsController.IsCrouching then
			self.Buttons.mobile_crouch:Input(false, true)
		end
	end))
end

function Buttons:UpdatePositionsAndSizes(...)
	self:_UpdatePositionsAndSizes(...)
end

function Buttons:_UpdateWeaponIcons(...)
	for _, button in pairs(self.Buttons) do
		button:UpdateWeaponIcon(...)
	end
end

function Buttons:_UpdatePositionsAndSizes(...)
	for _, button in pairs(self.Buttons) do
		button:UpdatePositionAndSize(...)
	end
end

function Buttons:_UpdateVisibilities(...)
	for _, button in pairs(self.Buttons) do
		button:UpdateVisibility(...)
	end
end

function Buttons:_UpdateMobileInputSettings(...)
	for _, button in pairs(self.Buttons) do
		button:UpdateMobileInputSettings(...)
	end
end

function Buttons:_GenerateButtons()
	if self._generated then
		return
	end

	self._generated = true

	for k in pairs(InputLibrary.MobileButtons) do
		local v = MobileButton.new(self, k)
		v.Frame.Parent = self.Frame
		self.Buttons[v.Name] = v
	end

	self.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdatePositionsAndSizes()
	end)
end

function Buttons:_HookFighter()
	if self._hooked_fighter then
		return
	end

	self._hooked_fighter = true
	self._local_fighter = MechanicsController:WaitForLocalFighter()

	local function check_scoped()
		local v = false

		for k in pairs(self._local_fighter:GetEquippedItems()) do
			if not (k.ItemInterface and k.ItemInterface:IsScopeActive()) then
				continue
			end

			v = true
			break
		end

		for _, button in pairs(self.Buttons) do
			button:SetScoped(v)
		end
	end

	self._local_fighter.EquippedItemChanged:Connect(check_scoped)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function item_interface_added(itemInterface, p)
		itemInterface.Mouse.Scope.ActiveChanged:Connect(check_scoped)

		if not p then
			check_scoped()
		end
	end

	local function client_item_added(data, p)
		data.ToggleOffMobileInputButton:Connect(function(p2)
			self.Buttons[p2]:Button1Up()
		end)
		data.InterfaceAdded:Connect(item_interface_added)

		if data.ItemInterface then
			item_interface_added(data.ItemInterface, p) -- equivalent call inferred; original call site unknown
		end
	end

	self._local_fighter.ItemAdded:Connect(client_item_added)

	for _, item in pairs(self._local_fighter.Items) do
		task.spawn(client_item_added, item, true)
	end

	task.defer(check_scoped)
	self._local_fighter.EquippedItemChanged:Connect(function()
		self:_UpdateMobileInputSettings()
	end)
	self._local_fighter.HealthChanged:Connect(function()
		self:_UpdateVisibilities()
	end)
	self._local_fighter.EntityAdded:Connect(function()
		self:_UpdateVisibilities()
	end)
	self._local_fighter.Died:Connect(function()
		self:_UpdateVisibilities()
	end)
	self._local_fighter:GetDataChangedSignal("IsInDuel"):Connect(function()
		self:_UpdateVisibilities()
	end)
	self._local_fighter:GetDataChangedSignal("QuickAttackOverrides"):Connect(function()
		self:_UpdateVisibilities()
	end)
	self._local_fighter.ItemAdded:Connect(function()
		self:_UpdateWeaponIcons()
	end)
	self._local_fighter.ItemRemoved:Connect(function()
		self:_UpdateWeaponIcons()
	end)
	self:_UpdateWeaponIcons()
end

function Buttons._HookTouchGui(_)
	local jumpButton = Utility:SilentWaitForChild(Players.LocalPlayer:WaitForChild("PlayerGui"), "TouchGui"):WaitForChild("TouchControlFrame"):WaitForChild("JumpButton")
	task.defer(jumpButton.Destroy, jumpButton)
end

function Buttons:_Init()
	self.MobileInputs.EditorEnabledChanged:Connect(function()
		self:_UpdateVisibilities()
		self:_UpdateWeaponIcons()
	end)
	task.defer(self._HookTouchGui, self)
end

return Buttons