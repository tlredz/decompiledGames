local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local MatchmakingController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("MatchmakingController"))
local Matchmaking = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Lobby"):WaitForChild("Matchmaking"))
local MobileInputs = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("MobileInputs"))
local Teleporting = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Teleporting"))
local Equipment = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Equipment"))
local Queue = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Queue"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Pages"))
local PartyDisplay = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("PartyDisplay"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.IsVisible = false
	self.Frame = UILibrary:GetTo("MainFrame", "Lobby", "Party")
	self.BottomDisplayFrame = self.Frame:WaitForChild("BottomDisplay")
	self.BottomDisplayContainer = self.BottomDisplayFrame:WaitForChild("Container")
	self.BottomDisplayLayout = self.BottomDisplayContainer:WaitForChild("Layout")
	self.BottomPartyDisplay = PartyDisplay.new(self.BottomDisplayContainer)
	self._last_tween = nil
	self:_Init()
	return self
end

function class:_UpdateVisibility()
	if self._last_tween then
		self._last_tween:Pause()
		self._last_tween = nil
	end

	local isVisible2 = not (Pages.PageSystem.CurrentPage or Equipment.IsOpen or Queue:IsVisible() or Teleporting.Enabled or MobileInputs.EditorEnabled or GuiService.MenuIsOpen)
	local isVisible = Matchmaking:IsVisible()
	local isRematchAvailable = MatchmakingController:IsRematchAvailable()
	local center

	if isVisible then
		center = Enum.HorizontalAlignment.Center
	else
		center = Enum.HorizontalAlignment.Left
	end

	local vector

	if isVisible then
		vector = Vector2.new(0.5, 0.5)
	else
		vector = Vector2.new(0, 0)
	end

	local uDim

	if isVisible and isVisible2 then
		uDim = UDim2.new(0.5, 0, 0.5, 0)
	elseif isVisible and not isVisible2 then
		uDim = UDim2.new(0.5, 0, 7, 0)
	elseif isVisible2 and isRematchAvailable then
		uDim = UDim2.new(2.75, 0, -1.25, 0)
	elseif isVisible2 then
		uDim = UDim2.new(2.75, 0, 0, 0)
	else
		uDim = UDim2.new(2.75, 0, 7, 0)
	end

	self.IsVisible = isVisible2
	self.BottomDisplayLayout.HorizontalAlignment = center
	self._last_tween = TweenService:Create(
		self.BottomDisplayContainer,
		TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{
			Position = uDim,
			AnchorPoint = vector
		}
	)
	self._last_tween:Play()
end

function class:_Init()
	Equipment.Opened:Connect(function()
		self:_UpdateVisibility()
	end)
	Pages.PageSystem.PageOpened:Connect(function()
		self:_UpdateVisibility()
	end)
	Pages.PageSystem.PageClosed:Connect(function()
		self:_UpdateVisibility()
	end)
	Queue.VisibilityChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	Matchmaking.VisibilityChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	Teleporting.EnabledChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	MobileInputs.EditorEnabledChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	MatchmakingController.RematchDetailsChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(function()
		self:_UpdateVisibility()
	end)
	self:_UpdateVisibility()
end

return class._new()