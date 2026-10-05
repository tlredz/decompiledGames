local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local VehicleBoostLines = require(ReplicatedStorage.Modules.Client.Components.Vehicles.VehicleBoostLines)
local VehicleSpeedState = require(script.Parent.VehicleSpeedState)
local v = Component.new({
	Tag = "SpeedReactiveBoostLines"
})

function v:Construct()
	self._Janitor = Janitor.new()
	self._isEmitting = false
end

function v:Start()
	local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(
		self.Instance,
		"VehicleSpeedState",
		VehicleSpeedState
	)
	assert(
		waitForAncestorComponent,
		(`SpeedReactiveBoostLines requires a VehicleSpeedState ancestor on {self.Instance:GetFullName()}`)
	)
	self._speedState = waitForAncestorComponent
	self._intensityScale = self.Instance:GetAttribute("BoostLinesIntensityScale") or 1
	self._boostLines = VehicleBoostLines.GetShared()
	self._Janitor:Add(function()
		self:SetIntensity(0)
	end)
	self._Janitor:Add(self._speedState.OnActiveChanged:Connect(function()
		self:Refresh()
	end))
	self._Janitor:Add(self._speedState.OnLocalPlayerOccupantChanged:Connect(function()
		self:Refresh()
	end))
	self:Refresh()
end

function v:Refresh()
	local isEmitting = self._speedState:IsActive() and self._speedState:IsLocalPlayerOccupant()

	if isEmitting == self._isEmitting then
		return
	end

	self._isEmitting = isEmitting

	if not isEmitting then
		self:SetIntensity(0)
	elseif self._boostLines ~= nil then
		self._boostLines:TriggerCameraShake()
	end
end

function v:SetIntensity(p2: number)
	if self._boostLines == nil then
		return
	end

	self._boostLines:SetSourceIntensity(self.Instance, p2, self.Instance)
end

function v:SteppedUpdate()
	if not self._isEmitting then
		return
	end

	self:SetIntensity(VehicleBoostLines.CalculateEffectFactor(self._speedState:GetSpeed(), 1) * self._intensityScale)
end

function v:Stop()
	self._Janitor:Destroy()
end

return v