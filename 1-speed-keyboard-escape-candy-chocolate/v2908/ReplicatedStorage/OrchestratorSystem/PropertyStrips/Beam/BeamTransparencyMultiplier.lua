local parent = script.Parent.Parent.Parent
local PropertyStripBuilder = require(parent.PropertyStripBuilder)

local function ApplyMultiplier(data, value: number)
	local v = math.clamp(value, 0, 1)
	local numberSequenceKeypoints = table.create(#data.Keypoints)

	for _, keypoint in data.Keypoints do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(
				keypoint.Time,
				keypoint.Value + (1 - keypoint.Value) * v,
				keypoint.Envelope * (1 - v)
			)
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

return PropertyStripBuilder.Create({
	Type = "BeamTransparencyMultiplier",
	DisplayName = "Transparency Multiplier",
	EditableProperties = {
		{
			Path = { "Value" },
			DisplayName = "Multiplier",
			ValueType = "number",
			Min = 0,
			Max = 1,
			Step = 0.01
		}
	},
	Supports = function(beam)
		return beam:IsA("Beam")
	end,
	ValidateValue = function(value: number)
		if type(value) == "number" and value == value and not (value < 0 or value > 1) then
			return true, nil
		end

		return false, "BeamTransparencyMultiplier keyframes must contain a number Value between 0 and 1."
	end,
	Capture = function(_)
		return 0
	end,
	CaptureStripData = function(p)
		return p.Transparency
	end,
	Interpolate = function(p: number, p2: number, p3: number)
		return p + (p2 - p) * p3
	end,
	Apply = function(self, p2: number, p3)
		local data = p3.Strip.Data

		if typeof(data) ~= "NumberSequence" then
			return
		end

		self.Transparency = ApplyMultiplier(data, p2)
	end
})