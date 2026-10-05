-- equivalent calls inferred from this helper; original call sites unknown
local function hueShift(value: Color3, p, p2, p3)
	local HSV, v, v2 = value:ToHSV()
	return Color3.fromHSV((HSV + p) % 1, p2 or v, p3 or v2)
end

local function tryAdjust(instance, color: Color3, p)
	if instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") then
		local HSV, v, v2 = color:ToHSV()
		local keypoints = instance.Color.Keypoints
		local colorSequenceKeypoints = {}

		for _, keypoint in pairs(keypoints) do
			local HSV2, v3, v4 = keypoint.Value:ToHSV()
			local v5 = HSV - HSV2
			table.insert(
				colorSequenceKeypoints,
				ColorSequenceKeypoint.new(
					keypoint.Time,
					hueShift(keypoint.Value, v5, p == 2 and v or v3, p == 2 and v2 or v4)
				)
			)
		end

		instance.Color = ColorSequence.new(colorSequenceKeypoints)
		return true
	else
		if not (instance:IsA("BasePart") or instance:IsA("PointLight") or instance:IsA("SurfaceLight") or instance:IsA("SpotLight")) then
			return
		end

		local HSV, v, v2 = color:ToHSV()
		local HSV2, v3, v4 = instance.Color:ToHSV()
		local v5 = HSV - HSV2
		instance.Color = hueShift(instance.Color, v5, p == 2 and v or v3, p == 2 and v2 or v4)
		return true
	end
end

local function scan(folder, color: Color3, value)
	local v = value or 1

	if tryAdjust(folder, color, v) then
		return
	end

	for _, descendant in pairs(folder:GetDescendants()) do
		tryAdjust(descendant, color, v)
	end
end

return scan