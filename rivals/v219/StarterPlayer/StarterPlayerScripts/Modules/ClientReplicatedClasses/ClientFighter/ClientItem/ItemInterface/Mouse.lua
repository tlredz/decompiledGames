local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
game:GetService("GuiService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Spring = require(ReplicatedStorage.Modules.Spring)
require(ReplicatedStorage.Modules.Signal)
require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local MouseCrosshair = require(script:WaitForChild("MouseCrosshair"))
local Scope = require(script:WaitForChild("Scope"))
local mouseCooldownSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("MouseCooldownSlot")
local Mouse = {}
Mouse.__index = Mouse

function Mouse.new(itemInterface)
	local self = setmetatable({}, Mouse)
	self.ItemInterface = itemInterface
	self.Frame = self.ItemInterface.Frame:WaitForChild("Mouse")
	self.CooldownsFrame = self.Frame:WaitForChild("Cooldowns")
	self.MouseCrosshair = MouseCrosshair.new(self)
	self.Scope = Scope.new(self)
	self._connections = {}
	self._slide_spring = Spring.new(0, 0.875, 20)
	self:_Init()
	return self
end

function Mouse:SetVisible(visible)
	self.Frame.Visible = visible
end

function Mouse:Refresh()
	local v = UserInputService.MouseIconEnabled and CameraController:GetPublicState() == CameraController.CameraState.States.ThirdPersonUnlockedMouse
	self.MouseCrosshair.Crosshair:SetVisible(CONSTANTS.DEVICE ~= "VR" and not v)
	self.CooldownsFrame.Visible = CONSTANTS.DEVICE ~= "VR"
	self.Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
end

function Mouse:Update(p, data2, p2)
	if not data2.IsSpectating then
		return
	end

	self._slide_spring.Target = data2.IsSliding and data2.IsFirstPerson and not self.MouseCrosshair.Crosshair:IsStatic() and 1 or 0
	self._slide_spring.Value = self._slide_spring.Target > self._slide_spring.Value and self._slide_spring.Target or self._slide_spring.Value
	local value = self._slide_spring.Value
	local uDim = UDim2.new()
	local cframe = CameraController.ViewModelOffsetCFrame * CameraController.ShakeCFrame

	if data2.IsFirstPerson and cframe ~= CFrame.identity and not self.MouseCrosshair.Crosshair:IsStatic() then
		local v = workspace.CurrentCamera.CFrame * cframe:Inverse() * CFrame.new(0, 0, -100)
		local worldToScreenPoint = workspace.CurrentCamera:WorldToScreenPoint(v.Position)
		uDim = UDim2.new(
			0,
			worldToScreenPoint.X - data2.MouseLocation.X,
			0,
			worldToScreenPoint.Y - data2.MouseLocation.Y
		)
	end

	local screenPointToPosition = UILibrary:ScreenPointToPosition(
		data2.MouseLocation,
		self.ItemInterface.Frame.AbsolutePosition
	)
	self.Frame.Position = UDim2.new(0, screenPointToPosition.X, 0, screenPointToPosition.Y) + uDim
	self.Frame.Rotation = math.floor(value * 20 + 0.5)
	self.MouseCrosshair:Update(p, data2, p2)
	self.Scope:Update(p, data2, p2)
end

function Mouse:Destroy()
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self.MouseCrosshair:Destroy()
	self.Scope:Destroy()
end

function Mouse:_CooldownEffect(data)
	local variables, v, v2 = data.GetVariables()
	local clone = mouseCooldownSlot:Clone()
	clone.Icon.Image = data.Image
	clone.Icon.Container.Icon.Image = data.Image
	clone.Icon.Container.Size = UDim2.new(v, 0, 1, 0)
	clone.Bar.Bar.Size = UDim2.new(v, 0, 1.5, 0)
	clone.Parent = self.CooldownsFrame
	table.insert(data.Cleanup, clone)
	BetterDebris:AddItem(clone, variables)
	TweenService:Create(
		clone.Icon.Container,
		TweenInfo.new(variables, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
		{
			Size = UDim2.new(v2, 0, 1, 0)
		}
	):Play()
	TweenService:Create(clone.Bar.Bar, TweenInfo.new(variables, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
		Size = UDim2.new(v2, 0, 1.5, 0)
	}):Play()
end

function Mouse:_Init()
	self.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:Refresh()
	end)
	table.insert(self._connections, self.ItemInterface.ClientItem.Cooldowns.CooldownAdded:Connect(function(p)
		self:_CooldownEffect(p)
	end))

	for _, cooldown in pairs(self.ItemInterface.ClientItem.Cooldowns.Cooldowns) do
		task.spawn(self._CooldownEffect, self, cooldown)
	end
end

return Mouse