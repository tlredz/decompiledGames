local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Signal = require(ReplicatedStorage.Modules.Signal)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local SpinControls = {}
SpinControls.__index = SpinControls

function SpinControls.new(equipment)
	local self = setmetatable({}, SpinControls)
	self.MouseDownChanged = Signal.new()
	self.Equipment = equipment
	self._connections = {}
	self._frame = Instance.new("ImageButton")
	self._is_mouse_down = nil
	self._last_position = nil
	self._velocity = Vector2.zero
	self._rad = Vector2.zero
	self._last_state = nil
	self._start_resetting = nil
	self:_Init()
	return self
end

function SpinControls:IsMouseDown()
	return self._is_mouse_down
end

function SpinControls:GetCFrame()
	return CFrame.Angles(0, self._rad.X, 0) * CFrame.Angles(self._rad.Y, 0, 0)
end

function SpinControls:Update(_)
	if self._velocity.Magnitude <= 0.001 and not self._is_mouse_down then
		if self._start_resetting and tick() <= self._start_resetting then
			return
		end

		if self._rad.X < -3.141592653589793 then
			self._rad = Vector2.new(self._rad.X + 6.283185307179586, self._rad.Y)
		elseif self._rad.X > 3.141592653589793 then
			self._rad = Vector2.new(self._rad.X - 6.283185307179586, self._rad.Y)
		end

		if self._rad.Y < -3.141592653589793 then
			self._rad = Vector2.new(self._rad.X, self._rad.Y + 6.283185307179586)
		elseif self._rad.Y > 3.141592653589793 then
			self._rad = Vector2.new(self._rad.X, self._rad.Y - 6.283185307179586)
		end

		local v = 1 - (not self._start_resetting and 1 or math.clamp(((tick() - self._start_resetting) / 4) ^ 2, 0, 1)) * 0.05
		self._rad *= v
	else
		self._start_resetting = tick() + 0
		self._velocity *= 0.975
		self:_Increment(self._velocity)
	end
end

function SpinControls:OnStateChanged()
	self:_CheckResetSpin()
end

function SpinControls:OnOpen()
	self._frame.Parent = self.Equipment.IsOpen and UILibrary.MainGui or nil
	self:_VerifyControls()
end

function SpinControls:_CheckResetSpin()
	local stateID = self.Equipment:GetStateID()

	if stateID == self._last_state then
		return
	end

	self._last_state = stateID
	self._velocity = Vector2.zero
	self._rad = Vector2.zero
end

function SpinControls:_IsDisabled()
	local selectedWeapon = self.Equipment:GetSelectedWeapon()
	local weaponData = PlayerDataController:GetWeaponData(selectedWeapon)
	return selectedWeapon and not weaponData
end

function SpinControls:_GetMouseLocation()
	return UILibrary:GetMouseLocation()
end

function SpinControls:_Increment(p2)
	self._rad += p2
	self._rad = Vector2.new(self._rad.X % 6.283185307179586, self._rad.Y % 6.283185307179586)
end

function SpinControls:_VerifyControls()
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self._connections = {}

	if not self.Equipment.IsOpen then
		return
	end

	self._last_position = nil
	self._velocity = Vector2.zero
	self._is_mouse_down = nil
	self.MouseDownChanged:Fire()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function sanity_check(input)
		if ControlsController.CurrentControls == "Touch" then
			return input ~= self._is_mouse_down
		end

		return not self._is_mouse_down
	end

	table.insert(self._connections, self._frame.InputBegan:Connect(function(is_mouse_down)
		if self:_IsDisabled() or self._is_mouse_down then
			return
		end

		if is_mouse_down.UserInputType == Enum.UserInputType.MouseButton1 or is_mouse_down.UserInputType == Enum.UserInputType.MouseButton2 or is_mouse_down.UserInputType == Enum.UserInputType.Touch then
			self._last_position = nil
			self._velocity = Vector2.zero
			self._is_mouse_down = is_mouse_down
			self.MouseDownChanged:Fire()
		end
	end))
	table.insert(self._connections, UserInputService.InputEnded:Connect(function(input)
		-- equivalent call inferred; original call site unknown
		if sanity_check(input) then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
			self._is_mouse_down = nil
			self.MouseDownChanged:Fire()

			if self._last_position then
				self._velocity = (self:_GetMouseLocation() - self._last_position) / 400
			end
		end
	end))
	table.insert(self._connections, UserInputService.InputChanged:Connect(function(input)
		-- equivalent call inferred; original call site unknown
		if sanity_check(input) then
			return
		end

		local _GetMouseLocation = self:_GetMouseLocation()

		if self._last_position then
			self:_Increment((_GetMouseLocation - self._last_position) / 800 * (ControlsController.CurrentControls == "Touch" and 3 or 1))
		end

		self._last_position = _GetMouseLocation
	end))
end

function SpinControls:_Setup()
	self._frame.Name = "EquipmentSpinControls"
	self._frame.AnchorPoint = Vector2.new(0.5, 0.5)
	self._frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	self._frame.Size = UDim2.new(1, 0, 1, 0)
	self._frame.Image = ""
	self._frame.BackgroundTransparency = 1
	self._frame.ZIndex = -1000
	self._frame.Visible = true
end

function SpinControls:_Init()
	self:_Setup()
end

return SpinControls