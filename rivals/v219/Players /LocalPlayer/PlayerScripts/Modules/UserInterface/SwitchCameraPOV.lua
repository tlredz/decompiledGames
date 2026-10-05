local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.CONSTANTS)
require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ControlsController"))
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("CameraController"))
require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Pages"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.Frame = UILibrary:GetTo("MainFrame", "BottomStack", "SwitchCameraPOV")
	self.Container = self.Frame:WaitForChild("Container")
	self.Title = self.Container:WaitForChild("Title")
	self.KeybindIcon = self.Container:WaitForChild("Keybind")
	self._effect_hash = 0
	self:_Init()
	return self
end

function class:_SwitchEffect() end

function class:_UpdateControls()
	self.KeybindIcon.Visible = ControlsController.CurrentControls ~= "Touch"
end

function class:_Init()
	CameraController.POVStateChanged:Connect(function(_, _, p)
		if p then
			self:_SwitchEffect()
		end
	end)
	ControlsController.ControlsChanged:Connect(function()
		self:_UpdateControls()
	end)
	self:_UpdateControls()
end

return class._new()