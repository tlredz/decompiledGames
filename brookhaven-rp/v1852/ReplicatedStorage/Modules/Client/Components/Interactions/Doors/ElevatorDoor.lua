local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "ElevatorDoor"
})
require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

function v:Construct()
	self._Janitor = Janitor.new()
	self.isOpened = self.Instance:GetAttribute("IsOpened")
	self.leftDoor = self.Instance:WaitForChild("LeftDoor")
	self.rightDoor = self.Instance:WaitForChild("RightDoor")
	self.leftDoorCFrame = self.leftDoor.CFrame
	self.rightDoorCFrame = self.rightDoor.CFrame
	self.leftDoorSize = self.leftDoor.Size
	self.rightDoorSize = self.rightDoor.Size
end

function v:SetOpen()
	self.leftDoor.CFrame = self.leftDoorCFrame * CFrame.new(0, 0, -self.leftDoorSize.Z * 2)
	self.rightDoor.CFrame = self.rightDoorCFrame * CFrame.new(0, 0, -self.rightDoorSize.Z)
	self.leftDoor.Size = Vector3.new(self.leftDoorSize.X, self.leftDoorSize.Y, 0)
	self.rightDoor.Size = Vector3.new(self.rightDoorSize.X, self.rightDoorSize.Y, 0)
	self.leftDoor.Transparency = 1
	self.rightDoor.Transparency = 1
end

function v:SetClosed()
	self.leftDoor.CFrame = self.leftDoorCFrame
	self.rightDoor.CFrame = self.rightDoorCFrame
	self.leftDoor.Size = self.leftDoorSize
	self.rightDoor.Size = self.rightDoorSize
end

function v:CancelTweens()
	if self.leftTween then
		self.leftTween:Cancel()
	end

	if self.rightTween then
		self.rightTween:Cancel()
	end
end

function v:OpenSequence()
	self:CancelTweens()
	self.Instance:FindFirstChild("Center"):FindFirstChild("DoorToggle"):Play()
	local tween = TweenService:Create(self.leftDoor, tweenInfo, {
		CFrame = self.leftDoorCFrame * CFrame.new(0, 0, -self.leftDoorSize.Z * 2),
		Size = Vector3.new(self.leftDoorSize.X, self.leftDoorSize.Y, 0),
		Transparency = 1
	})
	local tween2 = TweenService:Create(self.rightDoor, tweenInfo2, {
		CFrame = self.rightDoorCFrame * CFrame.new(0, 0, -self.rightDoorSize.Z),
		Size = Vector3.new(self.rightDoorSize.X, self.rightDoorSize.Y, 0),
		Transparency = 1
	})
	tween:Play()
	tween2:Play()
	self.leftTween = self._Janitor:Add(tween, "Cancel", "leftTween")
	self.rightTween = self._Janitor:Add(tween2, "Cancel", "rightTween")
end

function v:CloseSequence()
	self:CancelTweens()
	self.Instance:FindFirstChild("Center"):FindFirstChild("DoorToggle"):Play()
	self.leftDoor.Transparency = 0
	self.rightDoor.Transparency = 0
	local tween = TweenService:Create(self.leftDoor, tweenInfo, {
		CFrame = self.leftDoorCFrame,
		Size = self.leftDoorSize,
		Transparency = 0
	})
	local tween2 = TweenService:Create(self.rightDoor, tweenInfo, {
		CFrame = self.rightDoorCFrame,
		Size = self.rightDoorSize,
		Transparency = 0
	})
	tween:Play()
	tween2:Play()
	self.leftTween = self._Janitor:Add(tween, "Cancel", "leftTween")
	self.rightTween = self._Janitor:Add(tween2, "Cancel", "rightTween")
end

function v:Start()
	local instance = self.Instance
	self._Janitor:Add(instance:GetAttributeChangedSignal("IsOpen"):Connect(function()
		if instance:GetAttribute("IsOpen") then
			self:OpenSequence()
		else
			self:CloseSequence()
		end
	end))

	if self.Instance:GetAttribute("IsOpen") then
		self:SetOpen()
	else
		self:SetClosed()
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v