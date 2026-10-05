local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = Component.new({
	Tag = "AnimatedJumpscare"
})
local ClientZoneEmitter = require(ReplicatedStorage.Modules.Client.Components.World.ClientZoneEmitter)

function v:Construct()
	self._Janitor = Janitor.new()
	self._BeginJumpscareJanitor = Janitor.new()
	self._Janitor:Add(self._BeginJumpscareJanitor)
	self.debounceTimestamp = 0
	self.debounceDuration = 10
	self.OnJumpscare = Signal.new()
	self._Janitor:Add(self.OnJumpscare)
end

function v:CheckDebounce()
	return tick() - self.debounceTimestamp >= self.debounceDuration
end

function v:Jumpscare()
	if self.isJumpscaring then
		return
	end

	self.isJumpscaring = true

	if not self.animTrack then
		local jumpscareAnimationLink = self.Instance:FindFirstChild("JumpscareAnimationLink")
		local animationController = self.Instance:FindFirstChildOfClass("AnimationController")

		if jumpscareAnimationLink and animationController then
			self.animTrack = animationController:WaitForChild("Animator"):LoadAnimation(jumpscareAnimationLink.Value)
		end
	end

	if self.clickDetectorInstance then
		self.clickDetectorInstance.Parent = nil
	end

	local jumpscareSoundLink = self.Instance:FindFirstChild("JumpscareSoundLink")

	if jumpscareSoundLink and jumpscareSoundLink.Value then
		local value = jumpscareSoundLink.Value
		local v2

		if value:IsA("Folder") then
			v2 = value:GetChildren()[math.random(1, #value:GetChildren())]
		else
			v2 = jumpscareSoundLink.Value
		end

		local clone = v2:Clone()
		clone.Parent = jumpscareSoundLink.Value.Parent
		clone.PlaybackSpeed *= 1 + math.random(-self.pitchVariance * 100, self.pitchVariance * 100) / 100
		Debris:AddItem(clone, clone.TimeLength * clone.PlaybackSpeed + 0.5)

		if self.fadeInTime then
			local volume = clone.Volume
			clone.Volume = 0
			TweenService:Create(clone, TweenInfo.new(self.fadeInTime, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Volume = volume
			}):Play()
		end

		clone:Play()
	end

	self.debounceTimestamp = tick()

	if self.animDelay then
		task.wait(self.animDelay)

		if not (self.Instance and self.Instance.Parent) then
			self.isJumpscaring = false
			return
		end
	end

	if self.animTrack then
		self.animTrack:Play()
	end

	self.OnJumpscare:Fire()
	task.delay(self.debounceDuration, function()
		if self.clickDetectorInstance then
			self.clickDetectorInstance.Parent = self.clickDetectorParent
		end
	end)
	self.isJumpscaring = false
end

function v:ReconnectJumpscareListeners()
	self._BeginJumpscareJanitor:Cleanup()

	if self.zoneLink and self.zoneLink.Value then
		local expect = ClientZoneEmitter:WaitForInstance(self.zoneLink.Value):expect()
		self._BeginJumpscareJanitor:Add(expect.PlayerEntered:Connect(function()
			if not self:CheckDebounce() then
				return
			end

			self:Jumpscare()
		end))
	end

	if self.clicker and self.clicker.Value then
		self.clickDetectorInstance = self.clicker.Value
		self.clickDetectorParent = self.clickDetectorInstance.Parent
		self._BeginJumpscareJanitor:Add(self.clicker.Value.MouseClick:Connect(function()
			if not self:CheckDebounce() then
				return
			end

			self:Jumpscare()
		end))
	end
end

function v:Start()
	self.debounceDuration = self.Instance:GetAttribute("JumpscareDebounce") or 10
	self.pitchVariance = self.Instance:GetAttribute("PitchVariance") or 0.2
	self.animDelay = self.Instance:GetAttribute("AnimationDelay")
	self.fadeInTime = self.Instance:GetAttribute("SoundFadeIn")
	task.spawn(function()
		self.clicker = self.Instance:WaitForChild("JumpscareClickDetectorLink", 30)

		if self.clicker then
			self._Janitor:Add(self.clicker:GetPropertyChangedSignal("Value"):Connect(function()
				self:ReconnectJumpscareListeners()
			end))
			self:ReconnectJumpscareListeners()
		end
	end)
	task.spawn(function()
		self.zoneLink = self.Instance:WaitForChild("JumpscareZoneLink", 30)

		if self.zoneLink then
			self._Janitor:Add(self.zoneLink:GetPropertyChangedSignal("Value"):Connect(function()
				self:ReconnectJumpscareListeners()
			end))
			self:ReconnectJumpscareListeners()
		end
	end)
end

function v:Stop()
	self._Janitor:Destroy()
	self.clickDetectorParent = nil
end

return v