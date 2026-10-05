local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local InteractionPrompt = require(ReplicatedStorage.Modules.Client.Components.Interactions.InteractionPrompt)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local PlayerModule = require(Players.LocalPlayer.PlayerScripts.PlayerModule)
local controls = PlayerModule:GetControls()
local v = Component.new({
	Tag = "ClimableRope"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._lastUpdate = 0
	self._lastControlValueSent = 0
	self._isClimbing = false
	self._previousPosition = createVector(0, 0, 0)
end

function v:Start()
	local bottom = self.Instance:WaitForChild("Bottom")
	self._Janitor:AddPromise(InteractionPrompt:WaitForInstance(bottom):andThen(function(interactionPrompt)
		self._interactionPrompt = interactionPrompt
		self._Janitor:Add(interactionPrompt.Interacted:Connect(function()
			Remotes.fireServerComponent(self.Instance, "StartClimbing")
		end))
		self:UpdateOccupied()
		self._Janitor:Add(self.Instance:GetAttributeChangedSignal("Occupant"):Connect(function()
			self:UpdateOccupied()
		end))
	end))
	self._Janitor:Add(UserInputService.JumpRequest:Connect(function()
		if self._isClimbing then
			Remotes.fireServerComponent(self.Instance, "StopClimbing")
		end
	end))
	self._Janitor:Add(Players.LocalPlayer.CharacterAdded:Connect(function()
		self._tracks = self:LoadAnimations()
	end))

	if Players.LocalPlayer.Character then
		self._tracks = self:LoadAnimations()
	end
end

function v:UpdateOccupied()
	local occupant = self.Instance:GetAttribute("Occupant")
	self._interactionPrompt:SetEnabled(occupant == nil)
	local v2 = occupant == Players.LocalPlayer.UserId

	if v2 and not self._isClimbing then
		self:StartClimb()
	elseif not v2 and self._isClimbing then
		self:StopClimb()
	end
end

function v:StartClimb()
	if self._isClimbing then
		return
	end

	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoid = character:WaitForChild("Humanoid")

	if not humanoid then
		return
	end

	self._isClimbing = true
	self._tracks.HangIdle:Play()
	self._tracks.HangLegSwing:Play()
	humanoid.PlatformStand = true
end

function v:StopClimb()
	if not self._isClimbing then
		return
	end

	self._isClimbing = false

	for _, _track in self._tracks do
		_track:Stop()
	end

	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoid = character:WaitForChild("Humanoid")

	if not humanoid then
		return
	end

	humanoid.PlatformStand = false
end

function v:UpdateAnimations()
	if not self._isClimbing then
		return
	end

	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local pivot = self.Instance:FindFirstChild("MainAttachment"):GetPivot()
	local position = character:GetPivot().Position
	local v2 = math.clamp(pivot:VectorToObjectSpace(position - self._previousPosition).Z / -0.2, 0, 1)
	self._tracks.HangLegSwing:Play(0.5, v2)
	self._tracks.HangIdle:Play(0.5, 1 - v2)
	self._previousPosition = position
end

function v:SteppedUpdate()
	if not self._isClimbing then
		return
	end

	self:UpdateAnimations()
	local now = os.clock()

	if now - self._lastUpdate < 0.2 then
		return
	end

	local moveVector = controls:GetMoveVector()
	local lastControlValueSent = math.round(moveVector.Z / 0.1) * 0.1

	if lastControlValueSent ~= self._lastControlValueSent then
		self._lastControlValueSent = lastControlValueSent
		self._lastUpdate = now
		Remotes.fireServerComponent(self.Instance, "SetMoveDirection", -lastControlValueSent)
	end

	if moveVector.Z < 0 then
		if not self._tracks.Climbing.IsPlaying then
			self._tracks.Climbing:Play()
		end

		if self._tracks.SlideDown.IsPlaying then
			self._tracks.SlideDown:Stop()
		end

		self._tracks.Climbing:AdjustSpeed(moveVector.Z / -1)
	elseif moveVector.Z > 0 then
		if self._tracks.Climbing.IsPlaying then
			self._tracks.Climbing:Stop()
		end

		if not self._tracks.SlideDown.IsPlaying then
			self._tracks.SlideDown:Play()
		end

		self._tracks.SlideDown:AdjustSpeed(moveVector.Z / 1)
	else
		if self._tracks.Climbing.IsPlaying then
			self._tracks.Climbing:Stop()
		end

		if self._tracks.SlideDown.IsPlaying then
			self._tracks.SlideDown:Stop()
		end
	end
end

function v:LoadAnimations()
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoid = character:WaitForChild("Humanoid")

	if not humanoid then
		return
	end

	local animator = humanoid:WaitForChild("Animator")

	if not animator then
		return
	end

	local tracksByName = {}

	for _, animation in self.Instance:WaitForChild("Animations"):GetChildren() do
		tracksByName[animation.Name] = animator:LoadAnimation(animation)
	end

	tracksByName.HangIdle.Priority = Enum.AnimationPriority.Action2
	tracksByName.HangLegSwing.Priority = Enum.AnimationPriority.Action3
	tracksByName.Climbing.Priority = Enum.AnimationPriority.Action4
	tracksByName.SlideDown.Priority = Enum.AnimationPriority.Action4
	return tracksByName
end

function v:Stop()
	self:StopClimb()
	self._Janitor:Destroy()
end

return v