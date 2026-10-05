local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController"))
local DoubleTap = {}
DoubleTap.__index = DoubleTap

function DoubleTap.new(mobileInputs)
	local self = setmetatable({}, DoubleTap)
	self.MobileInputs = mobileInputs
	self.Frame = self.MobileInputs.Frame:WaitForChild("DoubleTapArea")
	self._connections = {}
	self._shooting_connection = nil
	self._last_tap = 0
	self:_Init()
	return self
end

function DoubleTap:IsWithin(p2)
	local v = p2 - self.MobileInputs.Frame.AbsolutePosition.X

	if PlayerDataController:GetSetting("Left Handed Touch Controls") then
		return v <= self.MobileInputs.Frame.AbsoluteSize.X / 2
	end

	return self.MobileInputs.Frame.AbsoluteSize.X / 2 <= v
end

function DoubleTap:ResetTapWindow()
	self._last_tap = 0
end

function DoubleTap:UpdateVisuals()
	self.Frame.Visible = self.MobileInputs.EditorEnabled and PlayerDataController:GetSetting("Double Tap Shoot")
	local frame = self.Frame
	local position

	if PlayerDataController:GetSetting("Left Handed Touch Controls") then
		position = UDim2.new(0.5, 0, 0.5, 0)
	else
		position = UDim2.new(1, 0, 0.5, 0)
	end

	frame.Position = position
end

function DoubleTap:VerifyControls(p)
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self._connections = {}
	self:_CancelShootingConnection()
	self:ResetTapWindow()

	if not p then
		return
	end

	table.insert(self._connections, UserInputService.InputBegan:Connect(function(input, _)
		if input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		if self.MobileInputs.EditorEnabled or not self:IsWithin(input.Position.X) or #self.MobileInputs.Buttons:GetButtonsFromPosition(
			input.Position.X,
			input.Position.Y
		) > 0 then
			return
		end

		if tick() - self._last_tap > PlayerDataController:GetSetting("Double Tap Shoot Window") then
			self._last_tap = tick()
			return
		end

		if not PlayerDataController:GetSetting("Double Tap Shoot") and (not FighterController.LocalFighter or FighterController.LocalFighter:Get("IsInDuel") or FighterController.LocalFighter:Get("IsInShootingRange")) then
			return
		end

		self:_CancelShootingConnection()
		self._shooting_connection = input:GetPropertyChangedSignal("UserInputState"):Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				self:_CancelShootingConnection()
				self.MobileInputs.Buttons.Buttons.mobile_shoot:Button1Up()
			end
		end)
		self.MobileInputs.Buttons.Buttons.mobile_shoot:Button1Down()
	end))
end

function DoubleTap:_CancelShootingConnection()
	if self._shooting_connection then
		self._shooting_connection:Disconnect()
		self._shooting_connection = nil
	end
end

function DoubleTap:_Init()
	self.MobileInputs.EditorEnabledChanged:Connect(function()
		self:UpdateVisuals()
	end)
	PlayerDataController:GetSettingChangedSignal("Left Handed Touch Controls"):Connect(function()
		self:UpdateVisuals()
	end)
	PlayerDataController:GetSettingChangedSignal("Double Tap Shoot"):Connect(function()
		self:UpdateVisuals()
	end)
	self:UpdateVisuals()
end

return DoubleTap