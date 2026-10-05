local createVector = vector.create
local TypeDataRope = {
	RopeProperties = {
		Color = {
			type = "ColorSequence",
			default = ColorSequence.new(Color3.fromRGB(255, 255, 255))
		},
		Brightness = {
			type = "NumberSequence",
			default = NumberSequence.new(1)
		},
		Transparency = {
			type = "NumberSequence",
			default = NumberSequence.new(0)
		},
		Thickness = {
			type = "NumberSequence",
			default = NumberSequence.new(0.15)
		},
		Timescale = {
			type = "NumberSequence",
			default = NumberSequence.new(1)
		},
		Lifetime = {
			type = "NumberRange",
			default = NumberRange.new(2)
		},
		Rate = {
			type = "number",
			default = 1
		},
		Enabled = {
			type = "boolean",
			default = false
		},
		SegmentCount = {
			type = "NumberRange",
			default = NumberRange.new(12),
			nonNegative = true
		},
		PinMode = {
			type = "string",
			default = "BothEnds"
		},
		RopeLength = {
			type = "NumberRange",
			default = NumberRange.new(0)
		},
		Slack = {
			type = "number",
			default = 1.2,
			nonNegative = true
		},
		MotionTarget = {
			type = "string",
			default = "Start"
		},
		Speed = {
			type = "NumberSequence",
			default = NumberSequence.new(0)
		},
		Acceleration = {
			type = "Vector3",
			default = createVector(0, 0, 0)
		},
		Drag = {
			type = "number",
			default = 0
		},
		PosOffsetX = {
			type = "NumberSequence",
			default = NumberSequence.new(0)
		},
		PosOffsetY = {
			type = "NumberSequence",
			default = NumberSequence.new(0)
		},
		PosOffsetZ = {
			type = "NumberSequence",
			default = NumberSequence.new(0)
		},
		PosOffsetXLinkedTo = {
			type = "string",
			default = ""
		},
		PosOffsetYLinkedTo = {
			type = "string",
			default = ""
		},
		PosOffsetZLinkedTo = {
			type = "string",
			default = ""
		},
		Turbulence = {
			type = "NumberSequence",
			default = NumberSequence.new(0)
		},
		TurbulenceFrequency = {
			type = "number",
			default = 1
		},
		DisplacementMode = {
			type = "string",
			default = "Global"
		},
		SpawnTarget = {
			type = "string",
			default = "Start"
		},
		PosX = {
			type = "NumberRange",
			default = NumberRange.new(0)
		},
		PosY = {
			type = "NumberRange",
			default = NumberRange.new(0)
		},
		PosZ = {
			type = "NumberRange",
			default = NumberRange.new(0)
		},
		PosXEven = {
			type = "boolean",
			default = false
		},
		PosYEven = {
			type = "boolean",
			default = false
		},
		PosZEven = {
			type = "boolean",
			default = false
		},
		PositionEvenCycle = {
			type = "NumberRange",
			default = NumberRange.new(0)
		},
		PosXLinkedTo = {
			type = "string",
			default = ""
		},
		PosYLinkedTo = {
			type = "string",
			default = ""
		},
		PosZLinkedTo = {
			type = "string",
			default = ""
		},
		PosMode = {
			type = "string",
			default = "Local"
		},
		RotX = {
			type = "NumberRange",
			default = NumberRange.new(0)
		},
		RotY = {
			type = "NumberRange",
			default = NumberRange.new(0)
		},
		RotZ = {
			type = "NumberRange",
			default = NumberRange.new(0)
		},
		RotXEven = {
			type = "boolean",
			default = false
		},
		RotYEven = {
			type = "boolean",
			default = false
		},
		RotZEven = {
			type = "boolean",
			default = false
		},
		RotationEvenCycle = {
			type = "NumberRange",
			default = NumberRange.new(0)
		},
		RotXLinkedTo = {
			type = "string",
			default = ""
		},
		RotYLinkedTo = {
			type = "string",
			default = ""
		},
		RotZLinkedTo = {
			type = "string",
			default = ""
		},
		RotOrder = {
			type = "string",
			default = "Global"
		},
		EmissionDirection = {
			type = "enum",
			enumType = "NormalId",
			default = Enum.NormalId.Front
		},
		SpreadAngle = {
			type = "Vector2",
			default = Vector2.new(0, 0)
		},
		GrowIn = {
			type = "number",
			default = 0,
			nonNegative = true
		},
		DeathMode = {
			type = "string",
			default = "None"
		},
		DeathWindow = {
			type = "number",
			default = 0.2,
			nonNegative = true
		},
		BendStiffness = {
			type = "number",
			default = 0,
			nonNegative = true
		},
		ThicknessProfile = {
			type = "NumberSequence",
			default = NumberSequence.new(1)
		},
		MotionDirection = {
			type = "enum",
			enumType = "NormalId",
			default = Enum.NormalId.Front
		},
		LaunchSpeed = {
			type = "NumberRange",
			default = NumberRange.new(40),
			nonNegative = true
		},
		Stiffness = {
			type = "number",
			default = 4,
			nonNegative = true
		},
		Damping = {
			type = "number",
			default = 0.03,
			nonNegative = true
		},
		Gravity = {
			type = "Vector3",
			default = createVector(0, -40, 0)
		},
		WindAmplitude = {
			type = "NumberRange",
			default = NumberRange.new(0)
		},
		WindFrequency = {
			type = "number",
			default = 2
		},
		TotalKeyFrames = {
			type = "number",
			default = 100
		},
		PartLife = {
			type = "number",
			default = 0,
			nonNegative = true
		},
		Pool = {
			type = "boolean",
			default = false
		}
	}
}
TypeDataRope.Types = {
	Rope = {
		classCheck = function(part)
			local isA = part:IsA("BasePart")

			if isA then
				if part:GetAttribute("IsRope") == true then
					isA = part:FindFirstChild("PartIcleProperties") ~= nil
				else
					isA = false
				end
			end

			return isA
		end,
		pDataType = "Rope",
		uiSection = "Ropes",
		properties = TypeDataRope.RopeProperties,
		resize = {
			scaleGraphs = {
				"Thickness",
				"PosOffsetX",
				"PosOffsetY",
				"PosOffsetZ",
				"Turbulence",
				"Speed"
			},
			scaleRanges = {
				"RopeLength",
				"WindAmplitude",
				"LaunchSpeed",
				"PosX",
				"PosY",
				"PosZ"
			},
			scaleVectors = { "Gravity", "Acceleration" }
		},
		retime = {
			multiplyNumbers = {
				"Rate",
				"WindFrequency",
				"TurbulenceFrequency",
				"Drag"
			},
			multiplyRanges = { "LaunchSpeed" },
			multiplyGraphs = { "Speed" },
			squareVectors = { "Gravity", "Acceleration" },
			divideRanges = { "Lifetime" }
		},
		clipboard = {
			{
				name = "Spawning",
				props = {
					"Rate",
					"Lifetime",
					"PinMode",
					"RopeLength",
					"Slack",
					"SegmentCount",
					"SpawnTarget",
					"PosX",
					"PosY",
					"PosZ",
					"PosXEven",
					"PosYEven",
					"PosZEven",
					"PositionEvenCycle",
					"PosMode",
					"RotX",
					"RotY",
					"RotZ",
					"RotXEven",
					"RotYEven",
					"RotZEven",
					"RotationEvenCycle",
					"RotOrder",
					"EmissionDirection",
					"SpreadAngle",
					"GrowIn",
					"DeathMode",
					"DeathWindow"
				}
			},
			{
				name = "Emission",
				props = { "EmitCount", "EmitDelay", "EmitDuration" }
			},
			{
				name = "Physics",
				props = {
					"Stiffness",
					"BendStiffness",
					"Damping",
					"Gravity",
					"WindAmplitude",
					"WindFrequency"
				}
			},
			{
				name = "Motion",
				props = {
					"MotionTarget",
					"Speed",
					"MotionDirection",
					"Acceleration",
					"Drag",
					"PosOffsetX",
					"PosOffsetY",
					"PosOffsetZ",
					"Turbulence",
					"TurbulenceFrequency",
					"DisplacementMode",
					"LaunchSpeed"
				}
			},
			{
				name = "Appearance",
				props = {
					"Color",
					"Brightness",
					"Transparency",
					"Thickness",
					"ThicknessProfile",
					"Material"
				}
			},
			{
				name = "Advanced",
				props = {
					"TotalKeyFrames",
					"PartLife",
					"Timescale",
					"Pool"
				}
			},
			{
				name = "Events",
				props = { "OnEmit", "OnDeath", "OnDestruction" }
			}
		}
	}
}
return TypeDataRope