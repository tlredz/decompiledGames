local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GetColorPropertiesFor = require(ReplicatedStorage.Util.GetColorPropertiesFor)

local function hueShift(value, p)
	local HSV, v, v2 = value:ToHSV()
	return Color3.fromHSV((HSV + p) % 1, v, v2)
end

local function SetProperty(p, p2, p3)
	p[p2] = p3
end

return function(list, p)
	local function processPropsAndAttributes(p2, p3, sequence, callback)
		if typeof(sequence) == "Color3" then
			local HSV, v2, v3 = sequence:ToHSV()
			callback(p2, p3, (Color3.fromHSV((HSV + p) % 1, v2, v3)))
		else
			if typeof(sequence) ~= "ColorSequence" then
				return
			end

			local keypoints = sequence.Keypoints
			local colorSequenceKeypoints = {}

			for _, keypoint in pairs(keypoints) do
				table.insert(
					colorSequenceKeypoints,
					ColorSequenceKeypoint.new(keypoint.Time, hueShift(keypoint.Value, p))
				)
			end

			callback(p2, p3, (ColorSequence.new(colorSequenceKeypoints)))
		end
	end

	for _, v in ipairs(list) do
		local colorPropertiesFor = GetColorPropertiesFor(v)

		if colorPropertiesFor then
			for _, v3 in pairs(colorPropertiesFor) do
				processPropsAndAttributes(v, v3, v[v3], SetProperty)
			end
		end

		local attributes = v:GetAttributes()

		for k, attribute in pairs(attributes) do
			processPropsAndAttributes(v, k, attribute, v.SetAttribute)
		end
	end
end