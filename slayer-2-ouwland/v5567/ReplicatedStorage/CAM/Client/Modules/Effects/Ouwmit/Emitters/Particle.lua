local utilities = script.Parent.Parent.Utilities
local OuwmitUtility = require(utilities.OuwmitUtility)
require(utilities.Types)
local Tween = require(utilities.Tween)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ParticleBudget = require(ReplicatedStorage.CAM.Client.Modules.Effects.ParticleBudget)
return function(clone, data)
	local color = OuwmitUtility.GetColor(clone, data)

	if data ~= nil and data.Parent ~= nil then
		clone = clone:Clone()
		clone.Parent = data.Parent
		task.delay(data.Lifetime, clone.Destroy, clone)
	end

	if color ~= nil then
		clone.Color = color
	end

	local durationScale = OuwmitUtility.DurationScale(data)

	if durationScale ~= 1 then
		OuwmitUtility.ScaleLifetime(clone, durationScale)
	end

	local v = OuwmitUtility.GetAttribute(clone, "EmitDelay", 0) * durationScale
	local attribute = OuwmitUtility.GetAttribute(clone, "EmitCount", 1)
	local v2 = (data ~= nil and data.Duration or OuwmitUtility.GetAttribute(clone, "EmitDuration", 0)) * durationScale
	local v3 = v2 > 0

	if clone.Enabled then
		clone.Enabled = false
	end

	local function Do()
		if v3 then
			clone.Enabled = true
		end

		local v4 = OuwmitUtility.GetAttribute(clone, "TimeScale_Duration", 0.1) * durationScale
		local attribute2 = OuwmitUtility.GetAttribute(clone, "TimeScale_Start", clone.TimeScale)
		local attribute3 = OuwmitUtility.GetAttribute(clone, "TimeScale_End", clone.TimeScale)

		if attribute2 == attribute3 then
			if attribute2 ~= 1 then
				clone.TimeScale = attribute2
			end
		else
			Tween.new(
				OuwmitUtility.GetAttribute(clone, "TimeScale_Curve", OuwmitUtility.default_bezier),
				v4,
				function(value, p)
					clone.TimeScale = OuwmitUtility.lerp(attribute2, attribute3, (math.clamp(value, 0, 1)))
					return p
				end
			)
		end

		if attribute ~= nil and attribute > 0 then
			ParticleBudget.Emit(clone, attribute, data and data.Owner)
		end

		if v3 then
			task.delay(v2, function()
				clone.Enabled = false
			end)
		end
	end

	if v > 0 then
		task.delay(v, Do)
	else
		Do()
	end
end