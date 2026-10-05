local parent = script.Parent
require(parent.OrchestratorState)
local TweenService = game:GetService("TweenService")

local function FindKeyframeValues(keyframes, timePosition: number)
	local count = #keyframes

	if count == 0 then
		return nil, nil, 0, nil
	end

	if timePosition <= keyframes[1].Time then
		return keyframes[1].Value, keyframes[1].Value, 0, keyframes[1]
	end

	if keyframes[count].Time <= timePosition then
		return keyframes[count].Value, keyframes[count].Value, 0, keyframes[count]
	end

	local v = 1

	while v + 1 < count do
		local v2 = math.floor((v + count) / 2)

		if keyframes[v2].Time <= timePosition then
			v = v2
		else
			count = v2
		end
	end

	local v2 = keyframes[v]
	local v3 = keyframes[count]
	local v4 = v3.Time - v2.Time

	if v4 <= 0 then
		return v3.Value, v3.Value, 0, v3
	end

	return v2.Value, v3.Value, math.clamp((timePosition - v2.Time) / v4, 0, 1), v2
end

return {
	Create = function(data)
		assert(data.Type ~= "", "A property strip definition needs a Type.")
		return {
			Type = data.Type,
			DisplayName = data.DisplayName,
			ContainsKeyframes = data.ContainsKeyframes,
			HasEditableKeyframes = data.HasEditableKeyframes,
			HasKeyframeEasing = data.HasKeyframeEasing,
			CanAutoCapture = data.CanAutoCapture,
			EditableProperties = data.EditableProperties,
			Supports = data.Supports,
			Capture = data.Capture,
			CaptureStripData = data.CaptureStripData,
			OnStart = data.OnStart,
			OnSuppressed = data.OnSuppressed,
			OnStop = data.OnStop,
			ValidateKeyframe = function(p)
				if data.ValidateKeyframe then
					return data.ValidateKeyframe(p)
				end

				return data.ValidateValue(p.Value)
			end,
			Evaluate = function(data2)
				local interpolated, v, v2, v3 = FindKeyframeValues(data2.Strip.Keyframes, data2.TimePosition)

				if interpolated == nil or v == nil then
					return
				end

				local easingStyle

				if not (data.HasKeyframeEasing == false or not v3) then
					easingStyle = v3.EasingStyle
				end

				if v2 ~= 0 and v3 and data.HasKeyframeEasing ~= false then
					v2 = easingStyle == "Constant" and 0 or TweenService:GetValue(
						v2,
						easingStyle or Enum.EasingStyle.Linear,
						v3.EasingDirection or Enum.EasingDirection.InOut
					)
				end

				if v2 ~= 0 then
					interpolated = data.Interpolate(interpolated, v, v2)
				end

				data.Apply(data2.Target, interpolated, data2)
			end
		}
	end,
	FindKeyframeValues = FindKeyframeValues
}