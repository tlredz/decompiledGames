local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Signal = require(ReplicatedStorage.Modules.Signal)
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ControlsController"))
local SettingsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SettingsController"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local EditorLogic = require(script:WaitForChild("EditorLogic"))
local DoubleTap = require(script:WaitForChild("DoubleTap"))
local Joystick = require(script:WaitForChild("Joystick"))
local Buttons = require(script:WaitForChild("Buttons"))
Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("MobileButton")
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.EditorEnabledChanged = Signal.new()
	self.Frame = UILibrary:GetTo("MobileInputs")
	self.EditorEnabled = false
	self.DoubleTap = DoubleTap.new(self)
	self.Joystick = Joystick.new(self)
	self.Buttons = Buttons.new(self)
	self.EditorLogic = EditorLogic.new(self)
	self:_Init()
	return self
end

function class.SwitchProfile(p, value)
	assert(typeof(value) == "number")
	p.EditorLogic:ApplyEdits()
	SettingsController:SwitchSettingsProfile(value)
end

function class:_IsEnabled()
	return ControlsController.CurrentControls == "Touch"
end

function class:_VerifyControls()
	local _IsEnabled = self:_IsEnabled()
	self.EditorLogic:SetEnabled(false)
	self.DoubleTap:VerifyControls(_IsEnabled)
	self.Buttons:VerifyControls(_IsEnabled)
end

function class:_SetupVisibility()
	local EliminatedEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("EliminatedEffect"))
	local Equipment = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("Equipment"))
	local Pages = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("Pages"))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		self.Frame.Visible = self:_IsEnabled() and not EliminatedEffect:IsVisible() and not (Equipment.IsOpen or Pages.PageSystem.CurrentPage)
	end

	ControlsController.ControlsChanged:Connect(update)
	EliminatedEffect.VisibilityChanged:Connect(update)
	Pages.PageSystem.PagesActivity:Connect(update)
	Equipment.Opened:Connect(update)
	update() -- equivalent call inferred; original call site unknown
end

function class:_Init()
	self.EditorLogic.EnabledChanged:Connect(function()
		self.EditorEnabled = self.EditorLogic.Enabled
		self.EditorEnabledChanged:Fire()
	end)
	ControlsController.ControlsChanged:Connect(function()
		self:_VerifyControls()
	end)
	task.defer(self._SetupVisibility, self)
	task.defer(self._VerifyControls, self)
end

return class._new()