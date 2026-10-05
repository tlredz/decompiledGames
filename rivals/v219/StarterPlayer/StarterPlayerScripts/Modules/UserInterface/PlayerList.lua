local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local InputLibrary = require(ReplicatedStorage.Modules.InputLibrary)
local Signal = require(ReplicatedStorage.Modules.Signal)
require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local ControlsController = require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local MatchmakingCountdown = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("MatchmakingCountdown"))
local MobileInputs = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("MobileInputs"))
local Teleporting = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Teleporting"))
local Equipment = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Equipment"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Pages"))
local Queue = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Queue"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local Elements = require(script:WaitForChild("Elements"))
local Inspect = require(script:WaitForChild("Inspect"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.OpenedChanged = Signal.new()
	self.ClosedByInputsChanged = Signal.new()
	self.BaseVisibilityChanged = Signal.new()
	self.Frame = UILibrary:GetTo("PlayerList")
	self.Container = self.Frame:WaitForChild("Container")
	self.IsOpen = nil
	self.ClosedByInputs = false
	self.Elements = Elements.new(self)
	self.Inspect = Inspect.new(self)
	self._local_fighter = nil
	self._opened_connections = {}
	self._is_disabled = false
	self._scale = 1
	self:_Init()
	return self
end

function class:GetBaseVisibility()
	local v = not (MobileInputs.EditorEnabled or Teleporting.Enabled or SpectateController.CurrentDuelSubject or Equipment.IsOpen or Pages.PageSystem.CurrentPage or MatchmakingCountdown:IsVisible() or GuiService.MenuIsOpen or Queue:IsVisible())

	if v then
		local isInShootingRange = self._local_fighter and self._local_fighter:Get("IsInShootingRange")
		return not isInShootingRange
	end

	return v
end

function class:SetDisabled(is_disabled)
	if is_disabled == self._is_disabled then
		return
	end

	self._is_disabled = is_disabled
	self:_UpdateVisibility()
end

function class:SetScale(scale)
	self._scale = scale
	self.Container.Size = UDim2.new(self._scale, 0, self._scale, 0)
	self:_UpdateSize()
	self.Inspect:SetScale(scale)
end

function class:SetClosedByInputs(closedByInputs)
	self.ClosedByInputs = closedByInputs
	self.ClosedByInputsChanged:Fire()
end

function class:SetIsFriend(p2, p3)
	for k, playerListSlot in pairs(self.Elements.PlayerListSlots) do
		if k.Player == p2 then
			playerListSlot:SetIsFriend(p3)
		end
	end
end

function class:SetIsBlocked(p2, p3)
	for k, playerListSlot in pairs(self.Elements.PlayerListSlots) do
		if k.Player == p2 then
			playerListSlot:SetIsBlocked(p3)
		end
	end
end

function class:SetRequestDuration(p2, ...)
	local playerListSlot = self.Elements:GetPlayerListSlot(p2)

	if playerListSlot then
		playerListSlot:SetRequestDuration(...)
	end
end

function class.SelectPlayerExternally(p, p2)
	p.Inspect:SelectPlayer(p.Elements:GetPlayerListSlot(p2))
end

function class:OnOpened()
	self:AddOpenedConnection(self.Frame.Parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateSize()
	end))
	self:AddOpenedConnection(GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(function()
		self:_UpdatePosition()
	end))
	self:_UpdateSize()
	self:_UpdatePosition()
	self.Elements:OnOpened()
	self.Inspect:OnOpened()
end

function class:AddOpenedConnection(p2)
	table.insert(self._opened_connections, p2)
end

function class:_IsVisibleRegardlessOfInputs()
	return self:GetBaseVisibility() and not self._is_disabled
end

function class:_UpdateSize()
	self.Frame.Size = UDim2.new(0, math.min(320, self.Frame.Parent.AbsoluteSize.X * 0.5), 0.5 * self._scale, 0)
end

function class:_UpdatePosition()
	self.Container.Position = UDim2.new(1, 0, 0, GuiService.TopbarInset.Height)
end

function class:_UpdateVisibility()
	self.BaseVisibilityChanged:Fire()
	local isOpen = self:_IsVisibleRegardlessOfInputs() and not self.ClosedByInputs

	if isOpen == self.IsOpen then
		return
	end

	self.IsOpen = isOpen
	self.OpenedChanged:Fire()
	task.defer(
		self.Frame.TweenPosition,
		self.Frame,
		self.IsOpen and UDim2.new(1, -10, 0, 10) or UDim2.new(1, 650, 0, 10),
		"Out",
		"Quint",
		0.25,
		true
	)

	if self.IsOpen then
		self:OnOpened()
		return
	end

	for _, _opened_connection in pairs(self._opened_connections) do
		_opened_connection:Disconnect()
	end

	self._opened_connections = {}
end

function class:_HookGetCore(p, onEvent)
	task.spawn(function()
		local v = nil

		while not v do
			local success, core = pcall(StarterGui.GetCore, StarterGui, p)

			if success then
				v = core
				break
			else
				wait(1)
			end
		end

		v.Event:Connect(onEvent)
	end)
end

function class:_HookLocalFighter()
	self._local_fighter = FighterController:WaitForLocalFighter()
	self._local_fighter:GetDataChangedSignal("IsInShootingRange"):Connect(function()
		self:_UpdateVisibility()
	end)
	self:_UpdateVisibility()
end

function class:_Init()
	self.ClosedByInputsChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	self:_HookGetCore("PlayerFriendedEvent", function(p)
		self:SetIsFriend(p, true)
	end)
	self:_HookGetCore("PlayerUnfriendedEvent", function(p)
		self:SetIsFriend(p, false)
	end)
	self:_HookGetCore("PlayerBlockedEvent", function(p)
		self:SetIsBlocked(p, true)
	end)
	self:_HookGetCore("PlayerUnblockedEvent", function(p)
		self:SetIsBlocked(p, false)
	end)
	ControlsController.ControlsChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	SpectateController.DuelSubjectChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	Equipment.Opened:Connect(function()
		self:_UpdateVisibility()
	end)
	Pages.PageSystem.PagesActivity:Connect(function()
		self:_UpdateVisibility()
	end)
	Teleporting.EnabledChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	MobileInputs.EditorEnabledChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	MatchmakingCountdown.VisibilityChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(function()
		self:_UpdateVisibility()
	end)
	Queue.VisibilityChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and self:_IsVisibleRegardlessOfInputs() and InputLibrary:InputIs(input, "OpenPlayerList") and not UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
			self:SetClosedByInputs(not self.ClosedByInputs)
		end
	end)
	self:_UpdateSize()
	self:_UpdatePosition()
	self:_UpdateVisibility()
	task.defer(self._HookLocalFighter, self)
end

return class._new()