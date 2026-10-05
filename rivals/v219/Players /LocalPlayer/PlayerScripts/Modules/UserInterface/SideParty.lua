local Players = game:GetService("Players")
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Pages"))
local PartyDisplay = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("PartyDisplay"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.IsVisible = false
	self.Frame = UILibrary:GetTo("MainFrame", "Pages", "SideParty")
	self.Container = self.Frame:WaitForChild("Container")
	self.LocalFighter = nil
	self.SidePartyDisplay = PartyDisplay.new(self.Container, true)
	self:_Init()
	return self
end

function class:_UpdateVisibility()
	self.IsVisible = Pages.PageSystem.CurrentPage and not Pages.PageSystem.CurrentPage.HidePartyDisplay and self.LocalFighter and not (self.LocalFighter:Get("IsInDuel") or self.LocalFighter:Get("IsInShootingRange"))
	self.Container:TweenPosition(
		self.IsVisible and UDim2.new(0.05, 0, 0.95, 0) or UDim2.new(-0.15, 0, 0.95, 0),
		"Out",
		"Quint",
		0.25,
		true
	)
end

function class:_HookLocalFighter()
	self.LocalFighter = FighterController:WaitForLocalFighter()
	self.LocalFighter:GetDataChangedSignal("IsInShootingRange"):Connect(function()
		self:_UpdateVisibility()
	end)
	self.LocalFighter:GetDataChangedSignal("IsInDuel"):Connect(function()
		self:_UpdateVisibility()
	end)
	self:_UpdateVisibility()
end

function class:_Init()
	Pages.PageSystem.PageOpened:Connect(function()
		self:_UpdateVisibility()
	end)
	Pages.PageSystem.PageClosed:Connect(function()
		self:_UpdateVisibility()
	end)
	self:_UpdateVisibility()
	task.spawn(self._HookLocalFighter, self)
end

return class._new()