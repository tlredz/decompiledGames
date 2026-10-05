local Players = game:GetService("Players")
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules.UILibrary)
local Spectators = {}
Spectators.__index = Spectators

function Spectators.new(fighterInterface)
	local self = setmetatable({}, Spectators)
	self.FighterInterface = fighterInterface
	self.Frame = self.FighterInterface.BottomRight.Container:WaitForChild("Spectators")
	self.Icon = self.Frame:WaitForChild("Icon")
	self.Title = self.Frame:WaitForChild("Value")
	self.Background = self.Frame:WaitForChild("Background")
	self.BackgroundGradient = self.Background:WaitForChild("UIGradient")
	self._connections = {}
	self:_Init()
	return self
end

function Spectators:UpdateParent()
	task.defer(pcall, function()
		local v = PlayerDataController:GetSetting("Spectators Display") == "Bottom Center"
		local v2 = PlayerDataController:GetSetting("Spectators Display") == "Bottom Left"
		self.Icon.Position = v2 and UDim2.new(0.162, 0, 0.5, 0) or UDim2.new(0.838, 0, 0.5, 0)
		self.Title.Position = v2 and UDim2.new(0.162, 0, 0.5, 0) or UDim2.new(0.838, 0, 0.5, 0)
		self.Icon.AnchorPoint = v2 and Vector2.new(1, 0.5) or Vector2.new(0, 0.5)
		self.Title.AnchorPoint = v2 and Vector2.new(0, 0.5) or Vector2.new(1, 0.5)
		self.Title.TextXAlignment = v2 and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
		self.BackgroundGradient.Rotation = v2 and 0 or 180
		self.Frame.Parent = v and self.FighterInterface.BottomCenter.Container or v2 and self.FighterInterface.BottomLeft.Container or self.FighterInterface.BottomRight.Container
		self:Refresh()
		self:_UpdateBackground()
	end)
end

function Spectators:Refresh()
	local numSpectators = self.FighterInterface.ClientFighter:Get("NumSpectators")
	local frame = self.Frame
	frame.Visible = numSpectators > 0 and PlayerDataController:GetSetting("Spectators Display") ~= "Disabled"
	self.Title.Text = numSpectators
	self:_UpdateBackground()
end

function Spectators:Destroy()
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self._connections = {}
end

function Spectators:_UpdateBackground()
	local v = math.min(
		self.Frame.AbsolutePosition.X - UILibrary.MainGui.AbsolutePosition.X,
		UILibrary.MainGui.AbsolutePosition.X + UILibrary.MainGui.AbsoluteSize.X - (self.Frame.AbsolutePosition.X + self.Frame.AbsoluteSize.X)
	) * 2
	self.Background.Size = UDim2.new(1, v, 0.875, 0)
	local v2 = PlayerDataController:GetSetting("Padded HUD") == "Using Controller" and ControlsController.CurrentControls == "Gamepad" or PlayerDataController:GetSetting("Padded HUD") == "Always On"
	local v3 = PlayerDataController:GetSetting("Spectators Display") ~= "Bottom Center"
	self.Background.Visible = v3 and not v2
end

function Spectators:_Init()
	self.Frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateBackground()
	end)
	self.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateBackground()
	end)
	table.insert(self._connections, UILibrary.MainGui:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
		self:_UpdateBackground()
	end))
	table.insert(self._connections, UILibrary.MainGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateBackground()
	end))
	self:UpdateParent()
	self:_UpdateBackground()
end

return Spectators