local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local v = Component.new({
	Tag = "BaseballTool",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = Janitor.new()
	self.holdTrack = nil
	self.shootTrack = nil
	self.humanoid = nil
	self.isThrowing = false
	self.isEquipped = false
end

function v:PlayHoldAnimation()
	if self.shootTrack ~= nil and self.shootTrack.IsPlaying then
		self.shootTrack:Stop(0.1)
	end

	if self.holdTrack ~= nil and self.holdTrack.IsPlaying == false then
		self.holdTrack:Play(0.1, 1, 1)
	end
end

function v:PlayShootAnimation()
	if self.holdTrack ~= nil and self.holdTrack.IsPlaying then
		self.holdTrack:Stop(0.1)
	end

	if self.shootTrack ~= nil then
		self.shootTrack:Play(0.05, 1, 1)
	end
end

function v:StopAllAnimations()
	if self.holdTrack ~= nil then
		self.holdTrack:Stop()
	end

	if self.shootTrack ~= nil then
		self.shootTrack:Stop()
	end
end

function v:OnEquip()
	self._equipJanitor:Cleanup()
	self.isThrowing = false
	self.isEquipped = true
	local instance = self.Instance
	local parent = instance.Parent

	if parent == nil then
		return
	end

	local humanoid = parent:FindFirstChildOfClass("Humanoid")

	if humanoid == nil then
		return
	end

	self.humanoid = humanoid
	local holdAnim = instance:FindFirstChild("HoldAnim")

	if holdAnim ~= nil and holdAnim:IsA("Animation") then
		self.holdTrack = humanoid:LoadAnimation(holdAnim)
	end

	local shootAnim = instance:FindFirstChild("ShootAnim")

	if shootAnim ~= nil and shootAnim:IsA("Animation") then
		self.shootTrack = humanoid:LoadAnimation(shootAnim)
	end

	self:PlayHoldAnimation()
	local mouse = Players.LocalPlayer:GetMouse()
	self._equipJanitor:Add(instance.Activated:Connect(function()
		if not (self.isThrowing ~= true and instance.Enabled == true) then
			return
		end

		self.isThrowing = true
		self:PlayShootAnimation()
		Remotes.fireServerComponent(self.Instance, "ThrowBaseball", mouse.Hit.Position)
		task.delay(2, function()
			self.isThrowing = false

			if self.isEquipped == true then
				self:PlayHoldAnimation()
			end
		end)
	end))
	self._equipJanitor:Add(humanoid.Died:Connect(function()
		self:StopAllAnimations()
	end))
end

function v:OnUnequip()
	self._equipJanitor:Cleanup()
	self.isThrowing = false
	self.isEquipped = false

	if self.holdTrack ~= nil then
		self.holdTrack:Stop()
		self.holdTrack = nil
	end

	if self.shootTrack ~= nil then
		self.shootTrack:Stop()
		self.shootTrack = nil
	end

	self.humanoid = nil
end

function v:Start()
	local instance = self.Instance
	self._Janitor:Add(instance.Equipped:Connect(function()
		self:OnEquip()
	end))
	self._Janitor:Add(instance.Unequipped:Connect(function()
		self:OnUnequip()
	end))
end

function v:Stop()
	self:OnUnequip()
	self._Janitor:Destroy()
	self._equipJanitor:Destroy()
end

return v