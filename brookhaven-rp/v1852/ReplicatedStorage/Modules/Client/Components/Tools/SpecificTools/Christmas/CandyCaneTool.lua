local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Players = game:GetService("Players")
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local v = Component.new({
	Tag = "CandyCaneTool",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:IsLocalPlayer()
	local parent = self.Instance.Parent
	return parent == Players.LocalPlayer.Backpack or parent == Players.LocalPlayer.Character
end

function v:ResetAnimations()
	if not self.lastHumanoid then
		return
	end

	for _, v2 in pairs(self.lastHumanoid:GetPlayingAnimationTracks()) do
		if not (v2.Name == "WalkAnim" or v2.Name == "RunAnim" or v2.Name == "ToolNoneAnim" or v2.Name == "IdleAnim" or v2.Animation.AnimationId == self.walkAnimation.AnimationId or v2.Animation.AnimationId == self.toolNoneAnimation.AnimationId or v2.Animation.AnimationId == self.idleAnimation.AnimationId or v2.Animation.AnimationId == self.originalWalkAnimation or v2.Animation.AnimationId == self.originalRunAnimation or v2.Animation.AnimationId == self.originalToolNoneAnimation or v2.Animation.AnimationId == self.originalIdleAnimation) then
			continue
		end

		if not (v2.IsPlaying and v2.Animation.AnimationId ~= "rbxassetid://92879499449858") then
			continue
		end

		v2:Stop()
	end

	if self.lastHumanoid:GetState() == Enum.HumanoidStateType.Seated then
		return
	end

	local state = self.lastHumanoid:GetState()

	if state ~= Enum.HumanoidStateType.Landed then
		self.lastHumanoid:ChangeState(Enum.HumanoidStateType.Landed)
		task.delay(0.01, function()
			self.lastHumanoid:ChangeState(state)
		end)
	end
end

function v:Start()
	self.walkAnimation = self.Instance:WaitForChild("WalkAnimation")
	self.toolNoneAnimation = self.Instance:WaitForChild("ToolNoneAnimation")
	self.idleAnimation = self.Instance:WaitForChild("IdleAnimation")
	local instance = self.Instance
	self._Janitor:Add(instance.Equipped:Connect(function()
		local parent = self.Instance.Parent
		self.lastHumanoid = parent.Humanoid
		local animate = parent:WaitForChild("Animate")
		local walk = animate:WaitForChild("walk")
		local run = animate:WaitForChild("run")
		local toolnone = animate:WaitForChild("toolnone")
		local idle = animate:WaitForChild("idle")
		self.WalkAnim = walk:WaitForChild("WalkAnim")
		self.RunAnim = run:WaitForChild("RunAnim")
		self.ToolNoneAnim = toolnone:WaitForChild("ToolNoneAnim")
		self.IdleAnim = idle:WaitForChild("Animation1")
		self.originalWalkAnimation = self.WalkAnim.AnimationId
		self.originalRunAnimation = self.RunAnim.AnimationId
		self.originalToolNoneAnimation = self.ToolNoneAnim.AnimationId
		self.originalIdleAnimation = self.IdleAnim.AnimationId

		if not self:IsLocalPlayer() then
			self:ResetAnimations()
			return
		end

		self.previousWalkAnimation = self.WalkAnim.AnimationId
		self.previousRunAnimation = self.RunAnim.AnimationId
		self.previousToolNoneAnimation = self.ToolNoneAnim.AnimationId
		self.previousIdleAnimation = self.IdleAnim.AnimationId
		self.WalkAnim.AnimationId = self.walkAnimation.AnimationId
		self.RunAnim.AnimationId = self.walkAnimation.AnimationId
		self.ToolNoneAnim.AnimationId = self.toolNoneAnimation.AnimationId
		self.IdleAnim.AnimationId = self.idleAnimation.AnimationId
		self:ResetAnimations()
	end))
	self._Janitor:Add(instance.Unequipped:Connect(function()
		if not self:IsLocalPlayer() then
			self:ResetAnimations()
			return
		end

		if not self.Instance.Parent then
			return
		end

		if self.previousWalkAnimation and self.WalkAnim then
			self.WalkAnim.AnimationId = self.previousWalkAnimation
			self.previousWalkAnimation = nil
			self.WalkAnim = nil
		end

		if self.previousRunAnimation and self.RunAnim then
			self.RunAnim.AnimationId = self.previousRunAnimation
			self.previousRunAnimation = nil
			self.RunAnim = nil
		end

		if self.previousToolNoneAnimation and self.ToolNoneAnim then
			self.ToolNoneAnim.AnimationId = self.previousToolNoneAnimation
			self.previousToolNoneAnimation = nil
			self.ToolNoneAnim = nil
		end

		if self.previousIdleAnimation and self.IdleAnim then
			self.IdleAnim.AnimationId = self.previousIdleAnimation
			self.previousIdleAnimation = nil
			self.IdleAnim = nil
		end

		self:ResetAnimations()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v