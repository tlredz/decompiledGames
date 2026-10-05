local v = {
	{
		Name = "CreditsGradient",
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(252, 255, 53)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(242, 216, 76))
		}),
		Rotation = 90
	},
	{
		Name = "ExplosionGradient",
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(59, 52, 252)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(238, 152, 109))
		}),
		Rotation = 45
	},
	{
		Name = "LegendaryGradient",
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(247, 107, 28)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(250, 217, 97))
		}),
		Rotation = 45
	},
	{
		Name = "LimitedGradient",
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(52, 37, 175)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(197, 108, 214))
		}),
		Rotation = 45
	},
	{
		Name = "NormalGradient",
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(162, 162, 162)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(238, 238, 238))
		}),
		Rotation = 45
	},
	{
		Name = "RareGradient",
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(3, 108, 218)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(21, 245, 253))
		}),
		Rotation = 45
	},
	{
		Name = "UniqueGradient",
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 18, 118)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(243, 98, 101))
		}),
		Rotation = 45
	},
	{
		Name = "SecretGradient",
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(114, 222, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(55, 111, 167))
		}),
		Rotation = 45
	},
	{
		Name = "__MythicGradient",
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(245, 81, 95)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(161, 5, 29))
		}),
		Rotation = 45
	}
}
local ColorsUtil = {
	GetColorGradient = function(_, p: string)
		local v2 = GetGradientData(p)

		if not v2 then
			return
		end

		local uIGradient = Instance.new("UIGradient")
		uIGradient.Name = v2.Name
		uIGradient.Color = v2.Color
		uIGradient.Rotation = v2.Rotation
		return uIGradient
	end
}

function GetGradientData(p: string)
	for _, v2 in ipairs(v) do
		if v2.Name == p then
			return v2
		end
	end
end

function ColorsUtil:YellowToPurple(color: Color3)
	local HSV, v2, v3 = color:ToHSV()

	if HSV >= 0.06 and HSV <= 0.15 and v2 >= 0.6 then
		HSV = (HSV + 0.8) % 1
	end

	return Color3.fromHSV(HSV, v2, v3)
end

function ColorsUtil:YellowToPurpleInstance(instance)
	if instance:IsA("ParticleEmitter") or instance:IsA("Trail") then
		local keypoints = instance.Color.Keypoints
		table.create(#keypoints)

		for k, keypoint in keypoints do
			keypoints[k] = ColorSequenceKeypoint.new(keypoint.Time, self:YellowToPurple(keypoint.Value))
		end

		if #keypoints > 0 then
			instance.Color = ColorSequence.new(keypoints)
		end
	elseif instance:IsA("BasePart") then
		instance.Color = self:YellowToPurple(instance.Color)
	end

	for _, child in instance:GetChildren() do
		self:YellowToPurpleInstance(child)
	end
end

return ColorsUtil