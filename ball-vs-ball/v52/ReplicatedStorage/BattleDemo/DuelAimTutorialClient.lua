local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local PlayerData = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("PlayerData"))
local DuelAimTutorialClient = {}
DuelAimTutorialClient.__index = DuelAimTutorialClient
local tweenInfo = TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local tweenInfo2 = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

function DuelAimTutorialClient:new()
	local object = setmetatable({}, DuelAimTutorialClient)
	local guideFrame = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("战斗匹配UI"):WaitForChild("Background"):WaitForChild("瞄准教程")
	local mouseIcon = guideFrame:WaitForChild("鼠标")
	local touchIcon = guideFrame:WaitForChild("手指")
	object.guideFrame = guideFrame
	object.mouseIcon = mouseIcon
	object.touchIcon = touchIcon
	object.gamepadIcon = guideFrame:WaitForChild("左摇杆")
	object.activeIcon = nil
	object.loopTween = nil
	object.fadeTween = nil
	object.fadeConnection = nil
	object.visible = false
	object.accumulatedRadians = 0
	object.everPassed = false
	guideFrame.Visible = false
	mouseIcon.Visible = false
	touchIcon.Visible = false
	object.gamepadIcon.Visible = false

	function self.onSessionBegan()
		object:_onSessionBegan()
	end

	function self.onDirectionChanged(p2: number)
		object:_onDirectionChanged(p2)
	end

	function self.onLocked()
		object:_hide()
	end

	function self.onSessionEnded()
		object:_hide()
	end

	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(function()
		if object.visible then
			object:_show()
		end
	end)
	return object
end

function DuelAimTutorialClient:_pickIcon()
	if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
		return self.gamepadIcon
	end

	if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
		return self.touchIcon
	end

	return self.mouseIcon
end

function DuelAimTutorialClient:_onSessionBegan()
	self.accumulatedRadians = 0

	if self.everPassed or PlayerData.client.hasSeenSeatTutorial() then
		return
	end

	self:_show()
end

function DuelAimTutorialClient:_onDirectionChanged(p: number)
	if self.everPassed or not self.visible then
		return
	end

	self.accumulatedRadians += math.abs(p)

	if self.accumulatedRadians >= 0.2617993877991494 then
		self.everPassed = true
		self:_hide()
	end
end

function DuelAimTutorialClient:_stopTweens()
	if self.loopTween then
		self.loopTween:Cancel()
		self.loopTween = nil
	end

	if self.fadeTween then
		self.fadeTween:Cancel()
		self.fadeTween = nil
	end

	if self.fadeConnection then
		self.fadeConnection:Disconnect()
		self.fadeConnection = nil
	end
end

function DuelAimTutorialClient:_show()
	self:_stopTweens()

	if self.activeIcon then
		self.activeIcon.Visible = false
		self.activeIcon.ImageTransparency = 0
	end

	self.visible = true
	local _pickIcon = self:_pickIcon()
	self.activeIcon = _pickIcon
	_pickIcon.ImageTransparency = 0
	local position

	if _pickIcon == self.gamepadIcon then
		position = UDim2.fromScale(0.5, 0.5)
	else
		position = UDim2.new(_pickIcon.Position.X.Scale, _pickIcon.Position.X.Offset, 0, 0)
	end

	_pickIcon.Position = position
	_pickIcon.Visible = true
	self.guideFrame.Visible = true

	if _pickIcon == self.gamepadIcon then
		return
	end

	local tween = TweenService:Create(_pickIcon, tweenInfo, {
		Position = UDim2.new(_pickIcon.Position.X.Scale, _pickIcon.Position.X.Offset, 1, 0)
	})
	self.loopTween = tween
	tween:Play()
end

function DuelAimTutorialClient:_hide()
	if not self.visible then
		return
	end

	self.visible = false
	self:_stopTweens()
	local activeIcon = self.activeIcon
	self.activeIcon = nil

	if not activeIcon then
		self.guideFrame.Visible = false
		return
	end

	local guideFrame = self.guideFrame
	local tween = TweenService:Create(activeIcon, tweenInfo2, {
		ImageTransparency = 1
	})
	self.fadeTween = tween
	self.fadeConnection = tween.Completed:Connect(function()
		activeIcon.Visible = false
		activeIcon.ImageTransparency = 0
		guideFrame.Visible = false
		self.fadeTween = nil

		if self.fadeConnection then
			self.fadeConnection:Disconnect()
			self.fadeConnection = nil
		end
	end)
	tween:Play()
end

return DuelAimTutorialClient