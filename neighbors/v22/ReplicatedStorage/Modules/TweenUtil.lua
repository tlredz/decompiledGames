local TweenService = game:GetService("TweenService")

local function lerpColorSequence(sequence, item, p: number)
	local colorSequenceKeypoints = {}

	for k, keypoint in next, sequence.Keypoints, nil do
		local keypoint2 = item.Keypoints[k]
		table.insert(
			colorSequenceKeypoints,
			ColorSequenceKeypoint.new(keypoint.Time, keypoint.Value:Lerp(keypoint2.Value, p))
		)
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

local function lerpColorSequenceToFlat(sequence, item: Color3, p: number)
	local colorSequenceKeypoints = {}

	for _, keypoint in next, sequence.Keypoints, nil do
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(keypoint.Time, keypoint.Value:Lerp(item, p)))
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

return {
	Create = function(self, p, p2, items)
		local numberValue = Instance.new("NumberValue")
		local tween = TweenService:Create(numberValue, p2, {
			Value = 1
		})
		local v = {}

		for k, _ in next, items, nil do
			v[k] = p[k]
		end

		numberValue:GetPropertyChangedSignal("Value"):Connect(function()
			local v2 = math.clamp(numberValue.Value, 0, 1)

			for k, item in next, items, nil do
				local v3 = v[k]
				local typeName = typeof(v3)
				local v4 = nil

				if typeName == "number" then
					v4 = math.lerp(v3, item, v2)
				elseif typeName == "Color3" or typeName == "Vector3" or typeName == "CFrame" then
					v4 = v3:Lerp(item, v2)
				elseif typeName == "ColorSequence" then
					if typeof(item) == "ColorSequence" then
						v4 = lerpColorSequence(v3, item, v2)
					else
						v4 = lerpColorSequenceToFlat(v3, item, v2)
					end
				end

				p[k] = v4
			end
		end)
		tween.Completed:Once(function()
			numberValue:Destroy()
		end)
		return tween
	end
}