local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HotAirBalloonMoveControls"
})
local HotAirBalloon = require(ReplicatedStorage.Modules.Client.Components.Vehicles.HotAirBalloon)
local NotificationController = require(ReplicatedStorage.Modules.Client.UI.NotificationController)
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local GamepadService = game:GetService("GamepadService")
require(ReplicatedStorage.Modules.Client.UI.PanelController)
local localPlayer = Players.LocalPlayer
local _ = {
	STEER_LEFT = "rbxassetid://81558918215949",
	STEER_RIGHT = "rbxassetid://114992047341789",
	STANDING = "rbxassetid://86574451431958"
}

function v:RequestMove(object)
	if self.debounce then
		return
	end

	self.debounce = true
	object:ChangeMovementAngle((self.Instance:GetAttribute("AngleIncrement")))
	task.delay(0.5, function()
		self.debounce = false
	end)
end

function v:StartHold(object2, holdDirection: string)
	if self._isHolding then
		return
	end

	self._isHolding = true
	self._holdDirection = holdDirection
	object2:StartHoldMovement(holdDirection)

	if holdDirection == "left" then
		self:PlayAnimation("rbxassetid://81558918215949")
	elseif holdDirection == "right" then
		self:PlayAnimation("rbxassetid://114992047341789")
	end
end

function v:StopHold(object2)
	if not self._isHolding then
		return
	end

	self._isHolding = false
	self._holdDirection = nil
	object2:StopHoldMovement()
	self:PlayStandingAnimation()
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._animationTracks = {}
	self._currentAnimationTrack = nil
	self._animator = nil
	self._Janitor:Add(localPlayer.CharacterAdded:Connect(function()
		self._animationTracks = {}
		self._currentAnimationTrack = nil
		self._animator = nil
	end))
end

function v:GetCharacterAnimator()
	local character = localPlayer.Character

	if not character then
		return nil
	end

	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid then
		return (humanoid:FindFirstChild("Animator"))
	end

	return nil
end

function v:PlayAnimation(animationId: string)
	local characterAnimator = self:GetCharacterAnimator()

	if not characterAnimator then
		return
	end

	if self._currentAnimationTrack then
		self._currentAnimationTrack:Stop()
		self._currentAnimationTrack = nil
	end

	local track = self._animationTracks[animationId]

	if not track then
		local animation = Instance.new("Animation")
		animation.AnimationId = animationId
		track = characterAnimator:LoadAnimation(animation)
		self._animationTracks[animationId] = track
	end

	local humanoid = localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid")

	if humanoid and humanoid.SeatPart then
		track:Play()
		self._currentAnimationTrack = track
	end
end

function v:PlayStandingAnimation()
	self:PlayAnimation("rbxassetid://86574451431958")
end

function v:Start()
	self._Janitor:Add(HotAirBalloon.OnTakeControl:Connect(function(object2)
		self._pilotSeat = object2:GetPilotSeat()
		self:PlayStandingAnimation()

		if UserInputService.GamepadEnabled and not self._hasShownControllerNotification then
			NotificationController.NotifyCenter("Rotate the Hot Air Balloon using L2 and R2", 4)
			self._hasShownControllerNotification = true
		end

		self._holdInputBeganConnection = self._Janitor:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			local v2 = input.KeyCode == Enum.KeyCode.A
			local v3 = input.KeyCode == Enum.KeyCode.D

			if v2 then
				if self._isHolding and self._holdDirection ~= "left" then
					self:StopHold(object2)
				end

				self:StartHold(object2, "left")
			elseif v3 then
				if self._isHolding and self._holdDirection ~= "right" then
					self:StopHold(object2)
				end

				self:StartHold(object2, "right")
			end
		end))
		self._holdInputEndedConnection = self._Janitor:Add(UserInputService.InputEnded:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end

			local v2 = input.KeyCode == Enum.KeyCode.A
			local v3 = input.KeyCode == Enum.KeyCode.D

			if v2 or v3 then
				self:StopHold(object2)
			end
		end))
		self._holdGamepadBeganConnection = self._Janitor:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed or GamepadService.GamepadCursorEnabled or input.UserInputType ~= Enum.UserInputType.Gamepad1 and not string.match(
				tostring(input.UserInputType),
				"Gamepad"
			) then
				return
			end

			local v2 = input.KeyCode == Enum.KeyCode.ButtonL2
			local v3 = input.KeyCode == Enum.KeyCode.ButtonR2

			if v2 then
				if not self._isHolding or self._holdDirection ~= "left" then
					if self._isHolding then
						self:StopHold(object2)
					end

					self:StartHold(object2, "left")
				end
			elseif v3 and (not self._isHolding or self._holdDirection ~= "right") then
				if self._isHolding then
					self:StopHold(object2)
				end

				self:StartHold(object2, "right")
			end
		end))
		self._holdGamepadEndedConnection = self._Janitor:Add(UserInputService.InputEnded:Connect(function(input, gameProcessed)
			if gameProcessed or GamepadService.GamepadCursorEnabled or input.UserInputType ~= Enum.UserInputType.Gamepad1 and not string.match(
				tostring(input.UserInputType),
				"Gamepad"
			) then
				return
			end

			local v2 = input.KeyCode == Enum.KeyCode.ButtonL2
			local v3 = input.KeyCode == Enum.KeyCode.ButtonR2

			if v2 and self._isHolding and self._holdDirection == "left" then
				self:StopHold(object2)
			elseif v3 and self._isHolding and self._holdDirection == "right" then
				self:StopHold(object2)
			end
		end))
		local rotateLeft = self.Instance.MobileControls:FindFirstChild("RotateLeft")
		local rotateRight = self.Instance.MobileControls:FindFirstChild("RotateRight")

		if rotateLeft then
			self._rotateLeftDownConnection = self._Janitor:Add(rotateLeft.MouseButton1Down:Connect(function()
				self:StartHold(object2, "left")
			end))
			self._rotateLeftUpConnection = self._Janitor:Add(rotateLeft.MouseButton1Up:Connect(function()
				self:StopHold(object2)
			end))
			self._rotateLeftLeaveConnection = self._Janitor:Add(rotateLeft.MouseLeave:Connect(function()
				if self._isHolding and self._holdDirection == "left" then
					self:StopHold(object2)
				end
			end))
		end

		if rotateRight then
			self._rotateRightDownConnection = self._Janitor:Add(rotateRight.MouseButton1Down:Connect(function()
				self:StartHold(object2, "right")
			end))
			self._rotateRightUpConnection = self._Janitor:Add(rotateRight.MouseButton1Up:Connect(function()
				self:StopHold(object2)
			end))
			self._rotateRightLeaveConnection = self._Janitor:Add(rotateRight.MouseLeave:Connect(function()
				if self._isHolding and self._holdDirection == "right" then
					self:StopHold(object2)
				end
			end))
		end
	end))
	self._Janitor:Add(HotAirBalloon.OnReleaseControl:Connect(function()
		if self._isHolding then
			self._isHolding = false
			self._holdDirection = nil
		end

		if self._currentAnimationTrack then
			self._currentAnimationTrack:Stop(0.15)
			self._currentAnimationTrack = nil
		end

		if self._clickConnection then
			self._clickConnection:Disconnect()
			self._clickConnection = nil
		end

		if self._holdInputBeganConnection then
			self._holdInputBeganConnection:Disconnect()
			self._holdInputBeganConnection = nil
		end

		if self._holdInputEndedConnection then
			self._holdInputEndedConnection:Disconnect()
			self._holdInputEndedConnection = nil
		end

		if self._holdGamepadBeganConnection then
			self._holdGamepadBeganConnection:Disconnect()
			self._holdGamepadBeganConnection = nil
		end

		if self._holdGamepadEndedConnection then
			self._holdGamepadEndedConnection:Disconnect()
			self._holdGamepadEndedConnection = nil
		end

		if self._rotateLeftDownConnection then
			self._rotateLeftDownConnection:Disconnect()
			self._rotateLeftDownConnection = nil
		end

		if self._rotateLeftUpConnection then
			self._rotateLeftUpConnection:Disconnect()
			self._rotateLeftUpConnection = nil
		end

		if self._rotateLeftLeaveConnection then
			self._rotateLeftLeaveConnection:Disconnect()
			self._rotateLeftLeaveConnection = nil
		end

		if self._rotateRightDownConnection then
			self._rotateRightDownConnection:Disconnect()
			self._rotateRightDownConnection = nil
		end

		if self._rotateRightUpConnection then
			self._rotateRightUpConnection:Disconnect()
			self._rotateRightUpConnection = nil
		end

		if self._rotateRightLeaveConnection then
			self._rotateRightLeaveConnection:Disconnect()
			self._rotateRightLeaveConnection = nil
		end
	end))
	local humanoid = localPlayer.Character:FindFirstChild("Humanoid")

	if humanoid then
		self._Janitor:Add(humanoid:GetPropertyChangedSignal("SeatPart"):Connect(function()
			if self._currentAnimationTrack then
				self._currentAnimationTrack:Stop()
				self._currentAnimationTrack = nil
			end
		end))
	end
end

function v:Stop()
	if self._currentAnimationTrack then
		self._currentAnimationTrack:Stop()
		self._currentAnimationTrack = nil
	end

	self._animationTracks = {}
	self._Janitor:Destroy()
end

return v