local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuardEscapePrediction = require(ReplicatedStorage.Shared.Modules.GuardAreas.GuardEscapePrediction)
local GuardEscapeRequirement = require(ReplicatedStorage.Shared.Modules.GuardAreas.GuardEscapeRequirement)
local RequiredSpeedSign = require(script.Parent.Parent.Parent.GUI.GuardAreas.RequiredSpeedSign)
local v = nil
local TreadmillUtil = require(ReplicatedStorage.Shared.Util.TreadmillUtil)
local Trove = require(ReplicatedStorage.Packages.Trove)
local t = require(ReplicatedStorage.Packages.t)
local GuardEscapeSignController = {}
GuardEscapeSignController.__index = GuardEscapeSignController
GuardEscapeSignController.__class = "GuardEscapeSignController"

function GuardEscapeSignController.new(areaModel)
	t.strict(t.instanceIsA("Model"))(areaModel)
	local object = setmetatable({}, GuardEscapeSignController)
	object._areaModel = areaModel
	object._destroyed = false
	object._requiredSpeedSign = RequiredSpeedSign.new(areaModel)
	object._trove = Trove.new()
	object._trove:Add(object._requiredSpeedSign)
	object._trove:Add(areaModel:GetAttributeChangedSignal(GuardEscapeRequirement.SIGN_SPEEDS_ATTRIBUTE):Connect(function()
		object:_render()
	end))
	task.spawn(function()
		local SpeedPowerProjection = require(ReplicatedStorage.Client.SpeedPowerProjection)

		if object._destroyed then
			return
		end

		v = SpeedPowerProjection
		object._trove:Add(SpeedPowerProjection.Changed:Connect(function()
			object:_render()
		end))
		object:_render()
	end)
	object:_render()
	return object
end

function GuardEscapeSignController:_render()
	local attribute = self._areaModel:GetAttribute(GuardEscapeRequirement.SIGN_SPEEDS_ATTRIBUTE)

	if v == nil or typeof(attribute) ~= "Vector2" or not (attribute.X >= 0 and attribute.X < 1e999 and attribute.Y >= 0 and attribute.Y < 1e999) then
		self._requiredSpeedSign:SetLoading()
		return
	end

	self._requiredSpeedSign:SetSpeedPowerRequirement(attribute.X)
	self._requiredSpeedSign:SetSlowdownTolerance(GuardEscapePrediction.ResolveSlowdownTolerance(
		attribute.Y,
		TreadmillUtil.SpeedPowerToWalkSpeed(v.ReadProjected())
	))
end

function GuardEscapeSignController:Destroy()
	self._destroyed = true
	self._trove:Destroy()
end

return GuardEscapeSignController