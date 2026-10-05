local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "PlayAnimationOnContact"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._activeJanitor = self._Janitor:Add(Janitor.new())
	self._activeTrack = nil
	self._recentlyLeft = false
end

function v:Start()
	self._Janitor:Add(self.Instance.Touched:Connect(function(otherPart)
		if self._recentlyLeft or self._activeTrack then
			return
		end

		local character = Players.LocalPlayer.Character

		if not (character and otherPart:IsDescendantOf(character)) then
			return
		end

		self:Use()
	end))
	self._Janitor:Add(UserInputService.JumpRequest:Connect(function()
		self:Leave()
	end))
end

function v:Use()
	local animation = self.Instance:FindFirstChild("Animation")

	if not animation then
		warn("PlayAnimationOnContact:Start() - Animation not found:", self.Instance)
		return
	end

	local character = Players.LocalPlayer.Character
	local humanoid = character:FindFirstChild("Humanoid")

	if not humanoid then
		return
	end

	local animator = humanoid:FindFirstChild("Animator")

	if not (animator and Remotes.invokeServerComponent(self.Instance, "Use")) then
		return
	end

	character:PivotTo(self.Instance.CFrame)
	humanoid.WalkSpeed = 0
	local track = animator:LoadAnimation(animation)
	track:Play()
	self._activeJanitor:Add(humanoid.Died:Once(function()
		self:Leave()
	end))
	self._activeJanitor:Add(function()
		self:Leave()
	end)
	self._activeTrack = track
end

function v:Leave()
	if not self._activeTrack then
		return
	end

	self._activeJanitor:Cleanup()
	local character = Players.LocalPlayer.Character

	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	Remotes.fireServerComponent(self.Instance, "Leave")
	humanoid.WalkSpeed = StarterPlayer.CharacterWalkSpeed
	self._activeTrack:Stop()
	self._activeTrack = nil
	self._recentlyLeft = true
	task.delay(5, function()
		self._recentlyLeft = false
	end)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v