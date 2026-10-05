local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.CONSTANTS)
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ControlsController"))
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController"))
local MatchmakingCountdown = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("MatchmakingCountdown"))
local Teleporting = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Teleporting"))
local Equipment = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Equipment"))
local Shutdown = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Shutdown"))
require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Pages"))
local MobileEditorBar = require(script:WaitForChild("MobileEditorBar"))
local ContextBar = require(script:WaitForChild("ContextBar"))
local MainBar = require(script:WaitForChild("MainBar"))
local Details = require(script:WaitForChild("Details"))
local insetGui = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("InsetGui")
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.InsetGui = insetGui
	self.MainFrame = self.InsetGui:WaitForChild("MainFrame")
	self.Container = self.MainFrame:WaitForChild("Container")
	self.LeftButtonsFrame = self.Container:WaitForChild("LeftButtons")
	self.RightButtonsFrame = self.Container:WaitForChild("RightButtons")
	self.Details = Details.new(self)
	self.MobileEditorBar = MobileEditorBar.new(self)
	self.ContextBar = ContextBar.new(self)
	self.MainBar = MainBar.new(self)
	self._local_fighter = nil
	self:_Init()
	return self
end

function class.IsWithinAnyBar(data, p, p2)
	return data.MobileEditorBar.Bar:IsWithin(p, p2) or data.ContextBar.Bar:IsWithin(p, p2) or data.MainBar.Bar:IsWithin(
		p,
		p2
	)
end

function class:_UpdateMirrored()
	local isInDuel

	if ControlsController.CurrentControls == "Touch" then
		isInDuel = self._local_fighter and (self._local_fighter:Get("IsInDuel") or self._local_fighter:Get("IsInShootingRange") or #self._local_fighter.Items > 0)
	else
		isInDuel = false
	end

	local v = not isInDuel
	local leftButtonsFrame

	if isInDuel then
		leftButtonsFrame = self.LeftButtonsFrame
	else
		leftButtonsFrame = self.RightButtonsFrame
	end

	self.MainBar.Bar:SetMirrored(v)
	self.MainBar.Bar.Frame.Parent = leftButtonsFrame
	self.ContextBar.Bar:SetMirrored(v)
	self.ContextBar.Bar.Frame.Parent = leftButtonsFrame
	local v2 = v and 1 or -1
	self.ContextBar.Bar.Frame.LayoutOrder = v2 * 1
	self.MainBar.Bar.Frame.LayoutOrder = v2 * 2
end

function class:_UpdateVisibility()
	local v = not (Pages.PageSystem.CurrentPage or Teleporting.Enabled or MatchmakingCountdown:IsVisible() or GuiService.MenuIsOpen or Shutdown.Enabled)
	self.Details:SetVisible(v)
	self.MainBar:SetVisible(v and not self.MobileEditorBar.Bar.Frame.Visible)
	self.ContextBar:SetVisible(v and not self.MobileEditorBar.Bar.Frame.Visible)
	self.MobileEditorBar:SetVisible(v and not self.MainBar.Bar.Frame.Visible)
end

function class:_CheckBigInset()
	self.LeftButtonsFrame.Size = UDim2.new(1, 0, 1, -12)
	self.LeftButtonsFrame.Position = UDim2.new(0, 12, 1, 0)
	self.LeftButtonsFrame.AnchorPoint = Vector2.new(0, 1)
	local v = self.MainFrame.AbsoluteSize.Y > 100
	self.Container.Size = v and UDim2.new(0, GuiService.TopbarInset.Width, 0, 58) or UDim2.new(1, 0, 1, 0)
	self.Container.Position = v and UDim2.new(0, GuiService.TopbarInset.Min.X, 0, 0) or UDim2.new(0, 0, 0, 0)
	self.RightButtonsFrame.Size = self.LeftButtonsFrame.Size
	self.RightButtonsFrame.Position = UDim2.new(
		-self.LeftButtonsFrame.Position.X.Scale,
		-self.LeftButtonsFrame.Position.X.Offset,
		self.LeftButtonsFrame.Position.Y.Scale,
		self.LeftButtonsFrame.Position.Y.Offset
	)
	self.RightButtonsFrame.AnchorPoint = self.LeftButtonsFrame.AnchorPoint
end

function class:_HookLocalFighter()
	self._local_fighter = FighterController:WaitForLocalFighter()
	self._local_fighter:GetDataChangedSignal("IsInDuel"):Connect(function()
		self:_UpdateMirrored()
	end)
	self._local_fighter:GetDataChangedSignal("IsInShootingRange"):Connect(function()
		self:_UpdateMirrored()
	end)
	self._local_fighter.ItemAdded:Connect(function()
		self:_UpdateMirrored()
	end)
	self._local_fighter.ItemRemoved:Connect(function()
		self:_UpdateMirrored()
	end)
	self:_UpdateMirrored()
end

function class:_Setup()
	self.MainFrame.Size = UDim2.new(1, 0, 1, 0)
	self.InsetGui.Parent = Players.LocalPlayer.PlayerGui
end

function class:_Init()
	self.MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_CheckBigInset()
	end)
	self.MainBar.Bar.Frame:GetPropertyChangedSignal("Visible"):Connect(function()
		self:_UpdateVisibility()
	end)
	self.MobileEditorBar.Bar.Frame:GetPropertyChangedSignal("Visible"):Connect(function()
		self:_UpdateVisibility()
	end)
	ControlsController.ControlsChanged:Connect(function()
		self:_UpdateMirrored()
	end)
	Equipment.Opened:Connect(function()
		self:_UpdateVisibility()
	end)
	Teleporting.EnabledChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	Shutdown.EnabledChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	Pages.PageSystem.PagesActivity:Connect(function()
		self:_UpdateVisibility()
		task.defer(self._UpdateVisibility, self)
	end)
	MatchmakingCountdown.VisibilityChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(function()
		self:_CheckBigInset()
	end)
	GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(function()
		self:_UpdateVisibility()
	end)
	self:_Setup()
	self:_CheckBigInset()
	self:_UpdateVisibility()
	task.defer(self._HookLocalFighter, self)
end

return class._new()