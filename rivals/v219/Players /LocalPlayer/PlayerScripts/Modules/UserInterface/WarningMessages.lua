local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.BetterDebris)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local GlowyBackground = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("GlowyBackground"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local warningCard = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("WarningCard")
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.Frame = UILibrary:GetTo("WarningMessages")
	self._glowy_background = GlowyBackground.new("WarningCard")
	self._message_queue = {}
	self._queue_started = false
	self:_Init()
	return self
end

function class:AddToQueue(p2)
	if p2.HasUnderstood then
		return
	end

	for _, v in pairs(self._message_queue) do
		if v.WarnID == p2.WarnID then
			return
		end
	end

	table.insert(self._message_queue, p2)
	task.defer(self._StartQueue, self)
end

function class:_StartQueue()
	if self._queue_started then
		return
	end

	self._queue_started = true
	self._glowy_background:SetEnabled(true)

	while #self._message_queue > 0 do
		local v = self._message_queue[1]
		local clone = warningCard:Clone()
		clone.Container.Message.Description.Text = v.WarnMessage
		clone.Container.Message.InvisibleDescription.Text = v.WarnMessage
		clone.ZIndex = 9999999
		clone.Parent = self.Frame
		clone.Container.Position = UDim2.new(0.5, 0, 0.6, 0)
		clone.Container:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "Out", "Back", 0.25, true)
		local message = clone.Container.Message
		local description = message.Description
		local invisibleDescription = message.InvisibleDescription

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update_text()
			description.Text = invisibleDescription.Text
			description.Size = UDim2.new(
				0.9,
				0,
				invisibleDescription.Size.Y.Scale * math.ceil(invisibleDescription.TextBounds.X / description.AbsoluteSize.X),
				0
			)
		end

		invisibleDescription:GetPropertyChangedSignal("AbsolutePosition"):Connect(update_text)
		invisibleDescription:GetPropertyChangedSignal("AbsoluteSize"):Connect(update_text)
		invisibleDescription:GetPropertyChangedSignal("TextBounds"):Connect(update_text)
		invisibleDescription:GetPropertyChangedSignal("Text"):Connect(update_text)
		description:GetPropertyChangedSignal("AbsoluteSize"):Connect(update_text)
		update_text() -- equivalent call inferred; original call site unknown
		local button = clone.Container.Button
		local fakeButton = clone.Container.FakeButton
		fakeButton.ResizeEffect.Size = UDim2.new(0, 0, 1, 0)
		fakeButton.ResizeEffect:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", 15, true)
		task.delay(15, function()
			button.Visible = true
			fakeButton.Visible = false
		end)
		ButtonEffect:Add(button, true)
		button.MouseButton1Click:Wait()
		table.remove(self._message_queue, 1)
		clone:Destroy()
		ReplicatedStorage.Remotes.Misc.UnderstoodWarning:FireServer(v.WarnID)
	end

	self._glowy_background:SetEnabled(false)
	self._queue_started = false
end

function class:_UpdateQueue()
	for _, v in pairs(PlayerDataController:Get("ModerationWarningMessages")) do
		self:AddToQueue(v)
	end
end

function class:_Setup()
	self._glowy_background:SetColor("Purple", Color3.fromRGB(80, 67, 0))
	self._glowy_background:SetColor("Purple2", Color3.fromRGB(0, 0, 0))
	self._glowy_background:SetColor("Yellow", Color3.fromRGB(255, 215, 0))
	self._glowy_background:SetParent(self.Frame)
end

function class:_Init()
	PlayerDataController:GetDataChangedSignal("ModerationWarningMessages"):Connect(function()
		self:_UpdateQueue()
	end)
	self:_Setup()
	self:_UpdateQueue()
end

return class._new()