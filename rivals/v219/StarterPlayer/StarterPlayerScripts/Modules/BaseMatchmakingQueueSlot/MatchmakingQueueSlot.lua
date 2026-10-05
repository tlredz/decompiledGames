local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local MatchmakingController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("MatchmakingController"))
local BaseMatchmakingQueueSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("BaseMatchmakingQueueSlot"))
local matchmakingQueueSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("MatchmakingQueueSlot")
local object = setmetatable({}, BaseMatchmakingQueueSlot)
object.__index = object

function object.new(queueName, container)
	assert(DuelLibrary.MatchmakingQueues[queueName], queueName)
	local self = setmetatable(
		BaseMatchmakingQueueSlot.new(matchmakingQueueSlot:Clone(), nil, queueName == CONSTANTS.BEGINNER_QUEUE_NAME),
		object
	)
	self.QueueStatus = Signal.new()
	self.QueueName = queueName
	self.Container = container
	self._queue_info = DuelLibrary.MatchmakingQueues[self.QueueName]
	self._y_scale = self.Container:GetAttribute("YScale") or 1
	self:_Init()
	return self
end

function object.Destroy(p)
	p.QueueStatus:Destroy()
	BaseMatchmakingQueueSlot.Destroy(p)
end

function object:_Setup()
	self.Container.BackgroundTransparency = 1
	self.Container.BorderSizePixel = 0
	self.Frame.Button.Title.Size = UDim2.new(
		self.Frame.Button.Title.Size.X.Scale,
		self.Frame.Button.Title.Size.X.Offset,
		self.Frame.Button.Title.Size.Y.Scale * self._y_scale,
		self.Frame.Button.Title.Size.Y.Offset * self._y_scale
	)
	self.Frame.Button.Title.Position = UDim2.new(
		self.Frame.Button.Title.Position.X.Scale,
		self.Frame.Button.Title.Position.X.Offset,
		0.5 + (self.Frame.Button.Title.Position.Y.Scale - 0.5) * self._y_scale,
		0.5 + (self.Frame.Button.Title.Position.Y.Offset - 0.5) * self._y_scale
	)
	self.Frame.Button.Description.Size = UDim2.new(
		self.Frame.Button.Description.Size.X.Scale,
		self.Frame.Button.Description.Size.X.Offset,
		self.Frame.Button.Description.Size.Y.Scale * self._y_scale,
		self.Frame.Button.Description.Size.Y.Offset * self._y_scale
	)
	self.Frame.Button.Description.Position = UDim2.new(
		self.Frame.Button.Description.Position.X.Scale,
		self.Frame.Button.Description.Position.X.Offset,
		0.5 + (self.Frame.Button.Description.Position.Y.Scale - 0.5) * self._y_scale,
		0.5 + (self.Frame.Button.Description.Position.Y.Offset - 0.5) * self._y_scale
	)
	self.Frame.Button.BottomLeft.Size = UDim2.new(
		self.Frame.Button.BottomLeft.Size.X.Scale * self._y_scale,
		self.Frame.Button.BottomLeft.Size.X.Offset * self._y_scale,
		self.Frame.Button.BottomLeft.Size.Y.Scale * self._y_scale,
		self.Frame.Button.BottomLeft.Size.Y.Offset * self._y_scale
	)
	local areStreaksDisabled = self._queue_info and self._queue_info.AreStreaksDisabled
	self.Frame.Button.Thumbnail.Image = not self._queue_info and "" or self._queue_info.Thumbnail or ""
	self.Frame.Button.Description.Text = not self._queue_info and "" or self._queue_info.Description or ""
	self.Frame.Button.Title.Text = not self._queue_info and "" or self._queue_info.DisplayName or ""
	self.Frame.Button.Title.Position = self.Frame.Button.Description.Text == "" and UDim2.new(0.5, 0, 0.5, 0) or self.Frame.Button.Title.Position
	self.Frame.Button.BottomLeft.StreaksDisabled.Visible = areStreaksDisabled and areStreaksDisabled() or false
	self.Frame.Parent = self.Container
end

function object:_Init()
	self.Clicked:Connect(function()
		self.QueueStatus:Fire(MatchmakingController:QueueInto(self.QueueName))
	end)
	self:_Setup()
end

return object