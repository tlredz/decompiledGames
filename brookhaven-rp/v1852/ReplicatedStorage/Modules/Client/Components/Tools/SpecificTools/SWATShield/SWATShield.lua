local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local LinearAnimationSequence = require(ReplicatedStorage.Modules.Client.Components.Tools.Animation.LinearAnimationSequence)
local ShieldGun = require(ReplicatedStorage.Modules.Client.Components.Tools.SpecificTools.SWATShield.ShieldGun)
local localPlayer = Players.LocalPlayer
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local v = Component.new({
	Tag = "SWATShield",
	Extensions = { OnlyRunOnPlayerHotbar }
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = self._Janitor:Add(Janitor.new())
	self._animationSequence = ComponentUtil.GetComponentFromInstance(self.Instance, LinearAnimationSequence)
	self._isEquipped = false
end

function v:_onEquipped()
	if self._isEquipped then
		return
	end

	local parent = self.Instance.Parent

	if localPlayer.Character ~= parent then
		return
	end

	self._isEquipped = true
	self._equipJanitor:Add(self.Instance.Activated:Connect(function()
		if self._animationSequence:GetCurrentAnimation() ~= 3 then
			return
		end

		local weldedGun = parent:FindFirstChild("WeldedGun")

		if not weldedGun then
			return
		end

		ComponentUtil.GetComponentFromInstance(weldedGun, ShieldGun):Shoot()
	end))
end

function v:_onUnequipped()
	self._isEquipped = false
	self._equipJanitor:Cleanup()
end

function v:Start()
	self._Janitor:Add(self.Instance.Equipped:Connect(function()
		self:_onEquipped()
	end))
	self._Janitor:Add(self.Instance.Unequipped:Connect(function()
		self:_onUnequipped()
	end))

	if localPlayer.Character and self.Instance.Parent == localPlayer.Character then
		self:_onEquipped()
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v