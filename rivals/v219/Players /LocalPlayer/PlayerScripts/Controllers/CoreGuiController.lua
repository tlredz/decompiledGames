local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local MobileInputs = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("MobileInputs"))
local Teleporting = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("Teleporting"))
local PlayerList = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("PlayerList"))
local Equipment = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("Equipment"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface"):WaitForChild("Pages"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.LocalFighter = nil
	self:_Init()
	return self
end

function class:_UpdatePlayerList()
	PlayerList:SetScale(GuiService.ViewportDisplaySize == Enum.DisplaySize.Small and 0.75 or 1)
	PlayerList:SetDisabled(false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
end

function class:_UpdateTouchControls()
	GuiService.TouchControlsEnabled = not (Equipment.IsOpen or Pages.PageSystem.CurrentPage)
end

function class:_UpdateChat()
	local v = not (Teleporting.Enabled or MobileInputs.EditorEnabled)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, v or false)
end

function class:_UpdateLoop()
	while true do
		pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.EmotesMenu, false)
		pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.Health, false)
		task.defer(self._UpdatePlayerList, self)
		task.defer(self._UpdateChat, self)
		wait(1)
	end
end

function class:_Init()
	Teleporting.EnabledChanged:Connect(function()
		self:_UpdateChat()
	end)
	MobileInputs.EditorEnabledChanged:Connect(function()
		self:_UpdateChat()
	end)
	PlayerList.BaseVisibilityChanged:Connect(function()
		self:_UpdatePlayerList()
	end)
	GuiService:GetPropertyChangedSignal("ViewportDisplaySize"):Connect(function()
		self:_UpdatePlayerList()
	end)
	ControlsController.ControlsChanged:Connect(function()
		self:_UpdatePlayerList()
	end)
	Equipment.Opened:Connect(function()
		self:_UpdateTouchControls()
	end)
	Pages.PageSystem.PagesActivity:Connect(function()
		self:_UpdateTouchControls()
	end)
	task.defer(self._UpdateLoop, self)
	task.defer(self._UpdateChat, self)
	task.defer(self._UpdatePlayerList, self)
	task.defer(self._UpdateTouchControls, self)
end

return class._new()