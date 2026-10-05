local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local MatchmakingController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("MatchmakingController"))
require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local MobileInputs = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("MobileInputs"))
local Teleporting = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Teleporting"))
local Equipment = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Equipment"))
local Queue = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Queue"))
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Pages"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.VisibilityChanged = Signal.new()
	self.OpenedChanged = Signal.new()
	self.Frame = UILibrary:GetTo("MainFrame", "Lobby", "Matchmaking")
	self.Container = self.Frame:WaitForChild("Container")
	self.LeavingFrame = self.Container:WaitForChild("Leaving")
	self.LeavingDotsFrame = self.LeavingFrame:WaitForChild("Dots")
	self.LeaveButton = self.Container:WaitForChild("Leave")
	self.Icon = self.Container:WaitForChild("Icon")
	self.TitleText = self.Container:WaitForChild("Title")
	self.TimerText = self.Container:WaitForChild("Timer")
	self.QueueText = self.Container:WaitForChild("Queue")
	self._current_queue_name = nil
	self._queue_hash = 0
	self._renderstep_connection = nil
	self._is_open = false
	self:_Init()
	return self
end

function class:IsVisible()
	return self.Container.Visible
end

function class:IsOpened()
	return self:IsVisible() and self._is_open
end

function class:_SetIsLeaving(visible)
	self.LeavingFrame.Visible = visible
	self.LeaveButton.Visible = not visible

	if visible then
		self.LeavingDotsFrame:AddTag("UILoadingDots")
	else
		self.LeavingDotsFrame:RemoveTag("UILoadingDots")
	end
end

function class:_SetQueueName(current_queue_name)
	self._queue_hash += 1
	self._current_queue_name = current_queue_name
	local _queue_hash = self._queue_hash
	local matchmakingQueue = DuelLibrary.MatchmakingQueues[self._current_queue_name]
	self.Container.Visible = self._current_queue_name ~= nil
	self.QueueText.Text = not matchmakingQueue and "" or matchmakingQueue.DisplayName or ""
	self.Icon.Image = matchmakingQueue and matchmakingQueue.Image or ""
	self:_SetIsLeaving(false)
	self.VisibilityChanged:Fire()
	self.OpenedChanged:Fire()

	if not self._current_queue_name then
		return
	end

	Utility:CreateSound("rbxassetid://18525513345", 1, 1, script, true, 5)
	task.spawn(function()
		for i = 0, 1e999 do
			if self._queue_hash ~= _queue_hash then
				break
			end

			self.TimerText.Text = Utility:TimeFormat(i)
			wait(1)
		end
	end)
end

function class:_UpdateVisibility()
	self._is_open = not (Pages.PageSystem.CurrentPage or Equipment.IsOpen or Queue:IsVisible() or Teleporting.Enabled or MobileInputs.EditorEnabled or GuiService.MenuIsOpen)
	self.OpenedChanged:Fire()
	self.Container:TweenPosition(
		self._is_open and UDim2.new(0.5, 0, 0.075, 40) or UDim2.new(0.5, 0, -0.2, -40),
		"Out",
		"Quint",
		0.25,
		true
	)

	if self._renderstep_connection then
		self._renderstep_connection:Disconnect()
		self._renderstep_connection = nil
	end

	local v = 0
	local v2 = tick() + 0.5
	self._renderstep_connection = self._is_open and RunService.RenderStepped:Connect(function(_)
		self.Icon.Rotation = math.sin((tick())) * 5

		if tick() < v2 then
			return
		end

		v = (v + 1) % 4
		v2 = tick() + 0.5
		local v3 = self._current_queue_name and DuelLibrary.PlaySources[self._current_queue_name]
		local v4

		if not v3 then
			v4 = "Searching for players"
		elseif v3.DuelLogic == "Zombie Tower" then
			v4 = "Searching for zombies"
		elseif v3.DatabaseInfo.NumTeams * v3.DatabaseInfo.PlayersPerTeam <= 1 then
			v4 = "Waiting for server"
		else
			v4 = "Searching for players"
		end

		self.TitleText.Text = v4 .. string.rep(".", v)
	end)
end

function class:_Init()
	self.LeaveButton.MouseButton1Click:Connect(function()
		self:_SetIsLeaving(true)
		MatchmakingController:TryLeaveQueue()
	end)
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
	Teleporting.EnabledChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	MobileInputs.EditorEnabledChanged:Connect(function()
		self:_UpdateVisibility()
	end)
	GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(function()
		self:_UpdateVisibility()
	end)
	ReplicatedStorage.Remotes.Matchmaking.UpdateQueueStatus.OnClientEvent:Connect(function(...)
		self:_SetQueueName(...)
	end)
	self:_SetQueueName(nil)
	self:_SetIsLeaving(false)
	self:_UpdateVisibility()
	ButtonEffect:Add(self.LeaveButton)
end

return class._new()