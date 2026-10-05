local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.CONSTANTS)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Signal = require(ReplicatedStorage.Modules.Signal)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local color = Color3.fromRGB(200, 200, 200)
local color2 = Color3.fromRGB(255, 255, 255)
local BaseMatchmakingQueueSlot = {}
BaseMatchmakingQueueSlot.__index = BaseMatchmakingQueueSlot

function BaseMatchmakingQueueSlot.new(frame, value, p)
	local self = setmetatable({}, BaseMatchmakingQueueSlot)
	self.Clicked = Signal.new()
	self.Frame = frame
	self._destroyed = false
	self._stroke_thickness = value or 4
	self._always_bright = p or false
	self._hover_hash = 0
	self._tween_alpha = 0
	self:_Init()
	return self
end

function BaseMatchmakingQueueSlot:Set(p)
	if self._destroyed then
		return
	end

	local v = self._always_bright and 1 or p
	self.Frame.Button.Thumbnail.ImageTransparency = 0.375 - 0.375 * v
	self.Frame.Button.Thumbnail.ImageColor3 = color:Lerp(color2, v)
	self.Frame.Button.Stroke.Size = UDim2.new(
		1,
		2 - self._stroke_thickness * 2 * p,
		1,
		2 - self._stroke_thickness * 2 * p
	)
	self.Frame.Button.Stroke.UIStroke.Thickness = self._stroke_thickness * p
end

function BaseMatchmakingQueueSlot:Tween(p)
	if self._destroyed then
		return
	end

	self._hover_hash += 1
	local _hover_hash = self._hover_hash
	Utility:RenderstepForLoop(self._tween_alpha, p, 0.15 * (p < self._tween_alpha and -1 or 1), function(tween_alpha)
		if _hover_hash ~= self._hover_hash or self._destroyed then
			return true
		end

		self._tween_alpha = tween_alpha
		self:Set(1 - (1 - self._tween_alpha) ^ 3)
	end)
end

function BaseMatchmakingQueueSlot:Destroy()
	self._destroyed = true
	self.Clicked:Destroy()
	self.Frame:Destroy()
end

function BaseMatchmakingQueueSlot:_Init()
	self.Frame.Button.MouseLeave:Connect(function()
		self:Tween(0)
	end)
	self.Frame.Button.SelectionLost:Connect(function()
		self:Tween(0)
	end)
	self.Frame.Button.MouseEnter:Connect(function()
		self:Tween(1)
	end)
	self.Frame.Button.SelectionGained:Connect(function()
		self:Tween(1)
	end)
	self.Frame.Button.MouseButton1Click:Connect(function()
		self.Clicked:Fire()
	end)
	self:Set(0)
	ButtonEffect:Add(self.Frame.Button, nil, {
		ReleaseRatio = 0.975,
		HoverRatio = 0.975
	})
end

return BaseMatchmakingQueueSlot