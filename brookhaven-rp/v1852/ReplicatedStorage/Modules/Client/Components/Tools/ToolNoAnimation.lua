local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local LinearAnimationSequence = require(ReplicatedStorage.Modules.Client.Components.Tools.Animation.LinearAnimationSequence)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local v = Component.new({
	Tag = "ToolNoAnimation",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._equippedJanitor = self._Janitor:AddObject(Janitor.new(), "Destroy")
	self.linearAnimationSequence = nil
end

function v:_isOnFirstAnimation()
	if self.linearAnimationSequence == nil then
		return true
	end

	local currentAnimation = self.linearAnimationSequence:GetCurrentAnimation()
	return currentAnimation == nil or currentAnimation == 1
end

function v:Start()
	local instance = self.Instance
	local localPlayer = Players.LocalPlayer

	local function stopMatchingTracks(animator)
		if not self:_isOnFirstAnimation() then
			return
		end

		for _, v2 in animator:GetPlayingAnimationTracks() do
			if v2.Name == "ToolNoneAnim" then
				v2:Stop()
			end
		end
	end

	local function onEquipped()
		self._equippedJanitor:Cleanup()
		local parent = instance.Parent

		if parent == nil or not parent:IsA("Model") or parent ~= localPlayer.Character then
			return
		end

		local humanoid = parent:FindFirstChildOfClass("Humanoid")

		if humanoid == nil then
			return
		end

		local animator = humanoid:FindFirstChildOfClass("Animator")

		if animator == nil then
			return
		end

		stopMatchingTracks(animator)
		self._equippedJanitor:Add(animator.AnimationPlayed:Connect(function(object2)
			if object2.Name == "ToolNoneAnim" and self:_isOnFirstAnimation() then
				object2:Stop()
			end
		end))

		if self.linearAnimationSequence ~= nil then
			self._equippedJanitor:Add(self.linearAnimationSequence.OnAnimationNumberUpdated:Connect(function()
				stopMatchingTracks(animator)
			end))
		end
	end

	local function onUnequipped()
		self._equippedJanitor:Cleanup()
	end

	self.linearAnimationSequence = ComponentUtil.GetComponentFromInstance(instance, LinearAnimationSequence, 5)
	self._Janitor:Add(instance.Equipped:Connect(onEquipped))
	self._Janitor:Add(instance.Unequipped:Connect(onUnequipped))

	if instance.Parent == localPlayer.Character then
		onEquipped()
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v