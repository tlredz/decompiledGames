local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Signal = require(ReplicatedStorage.Modules.Signal)
local Notifications = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Notifications"))
local NotificationSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("NotificationSlot"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.NotificationQueued = Signal.new()
	self.NotificationAdded = Signal.new()
	self.CloseButton = self.PageFrame:WaitForChild("Close")
	self.List = self.PageFrame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.SlotsFrame = self.Container:WaitForChild("Slots")
	self.SlotsContainer = self.SlotsFrame:WaitForChild("Container")
	self.SlotsLayout = self.SlotsContainer:WaitForChild("Layout")
	self._layout_order = 0
	self._notification_queue = {}
	self._notification_slots = {}
	self._notification_queued_debounce = false
	self._notification_added_debounce = false
	self:_Init()
	return self
end

function object:GetNumNewNotifications()
	return #self._notification_queue
end

function object:GetNumOldNotifications()
	return #self._notification_slots
end

function object:GetNumNotifications()
	return self:GetNumNewNotifications() + self:GetNumOldNotifications()
end

function object:AddNotification(list)
	self._layout_order += 1
	local v = NotificationSlot.new(list[1], list[2], list[3], list[4], list[5])
	v.Frame.LayoutOrder = -self._layout_order
	v.Frame.ZIndex = -self._layout_order
	v:SetParent(self.SlotsContainer)
	v:UpdateAge()
	table.insert(self._notification_slots, 1, v)
	local v2 = table.remove(self._notification_slots, 50)

	if v2 then
		v2:Destroy()
	end

	self._notification_added_debounce = true
	task.defer(function()
		if not self._notification_added_debounce then
			return
		end

		self._notification_added_debounce = false
		self.NotificationAdded:Fire()
	end)
	self:UpdateAges()
end

function object:QueueNotification(...)
	local nows = { ... }
	nows[5] = tick()

	if self._is_open then
		self:AddNotification(nows)
		return
	end

	table.insert(self._notification_queue, nows)
	self._notification_queued_debounce = true
	task.defer(function()
		if not self._notification_queued_debounce then
			return
		end

		self._notification_queued_debounce = false
		self.NotificationQueued:Fire()
	end)
end

function object:GenerateQueue()
	for i = math.max(1, #self._notification_queue - 50), #self._notification_queue do
		self:AddNotification(self._notification_queue[i])
	end

	self._notification_queue = {}
end

function object:UpdateAges()
	for _, _notification_slot in pairs(self._notification_slots) do
		_notification_slot:UpdateAge()
	end
end

function object:Open(...)
	Page.Open(self, ...)
	self:GenerateQueue()
	self:UpdateAges()
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
		self.List.Active = self.Layout.AbsoluteContentSize.Y >= self.List.AbsoluteSize.Y
	end)
	self.SlotsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self.SlotsFrame.Size = UDim2.new(1, 0, 0, self.SlotsLayout.AbsoluteContentSize.Y)
	end)
	Notifications.NotificationSent:Connect(function(...)
		self:QueueNotification(...)
	end)
	ButtonEffect:Add(self.CloseButton)
end

return object._new()