local TypeDataModel = {
	ModelProperties = {
		Speed = {
			type = "NumberSequence",
			default = NumberSequence.new(0)
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
		Turbulence = {
			type = "NumberSequence",
			default = NumberSequence.new(0)
		},
		TurbulenceFrequency = {
			type = "number",
			default = 1
		},
		RotSpeedX = {
			type = "NumberSequence",
			default = NumberSequence.new(0)
		},
		RotSpeedY = {
			type = "NumberSequence",
			default = NumberSequence.new(0)
		},
		RotSpeedZ = {
			type = "NumberSequence",
			default = NumberSequence.new(0)
		},
		Scale = {
			type = "NumberSequence",
			default = NumberSequence.new(1),
			nonNegative = true
		},
		Timescale = {
			type = "NumberSequence",
			default = NumberSequence.new(1)
		},
		Lifetime = {
			type = "NumberRange",
			default = NumberRange.new(1)
		},
		Rate = {
			type = "number",
			default = 10
		},
		Drag = {
			type = "number",
			default = 0
		},
		Acceleration = {
			type = "Vector3",
			default = vector.create(0, 0, 0)
		},
		SpreadAngle = {
			type = "Vector2",
			default = Vector2.new(0, 0)
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
		PosMode = {
			type = "string",
			default = "Local"
		},
		RotMode = {
			type = "string",
			default = "OverLife"
		},
		RotOrder = {
			type = "string",
			default = "Global"
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
		VelocityVectored = {
			type = "boolean",
			default = false
		},
		DirMode = {
			type = "string",
			default = "RigidLocal"
		},
		DisplacementMode = {
			type = "string",
			default = "Global"
		},
		InvertMotion = {
			type = "boolean",
			default = false
		},
		Enabled = {
			type = "boolean",
			default = false
		},
		ScaleTextureLength = {
			type = "boolean",
			default = true
		},
		ScaleMotion = {
			type = "boolean",
			default = true
		},
		ScaleRotation = {
			type = "boolean",
			default = false
		},
		EmissionDirection = {
			type = "enum",
			enumType = "NormalId",
			default = Enum.NormalId.Top
		},
		Orientation = {
			type = "string",
			default = "None"
		},
		ZOffset = {
			type = "number",
			default = 0
		},
		RotSpeedXLinkedTo = {
			type = "string",
			default = ""
		},
		RotSpeedYLinkedTo = {
			type = "string",
			default = ""
		},
		RotSpeedZLinkedTo = {
			type = "string",
			default = ""
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
		RotationEvenCycle = {
			type = "NumberRange",
			default = NumberRange.new(0)
		},
		Pool = {
			type = "boolean",
			default = false
		}
	}
}
TypeDataModel.Types = {
	Model = {
		classCheck = function(model)
			return model:IsA("Model")
		end,
		pDataType = "Model",
		uiSection = "Models",
		properties = TypeDataModel.ModelProperties,
		resize = {
			scaleGraphs = {
				"Speed",
				"Scale",
				"PosOffsetX",
				"PosOffsetY",
				"PosOffsetZ",
				"Turbulence"
			},
			scaleVectors = { "Acceleration" },
			scaleRanges = { "PosX", "PosY", "PosZ" }
		},
		retime = {
			multiplyNumbers = { "Rate", "Drag", "TurbulenceFrequency" },
			divideRanges = { "Lifetime" },
			multiplyGraphs = { "Speed" },
			rotSpeedGraphs = { "RotSpeedX", "RotSpeedY", "RotSpeedZ" },
			squareVectors = { "Acceleration" }
		},
		clipboard = {
			{
				name = "Spawning",
				props = {
					"Rate",
					"Lifetime",
					"SpreadAngle",
					"EmissionDirection",
					"PosX",
					"PosY",
					"PosZ",
					"PosXEven",
					"PosYEven",
					"PosZEven",
					"PositionEvenCycle",
					"PosMode",
					"Orientation",
					"ZOffset"
				}
			},
			{
				name = "Emission",
				props = { "EmitCount", "EmitDelay", "EmitDuration" }
			},
			{
				name = "Scale",
				props = {
					"Scale",
					"ScaleTextureLength",
					"ScaleMotion",
					"ScaleRotation"
				}
			},
			{
				name = "Movement",
				props = {
					"Speed",
					"PosOffsetX",
					"PosOffsetY",
					"PosOffsetZ",
					"Turbulence",
					"TurbulenceFrequency",
					"RotMode",
					"RotOrder",
					"RotSpeedX",
					"RotSpeedY",
					"RotSpeedZ",
					"Acceleration",
					"Drag",
					"DirMode",
					"DisplacementMode",
					"InvertMotion",
					"Timescale"
				}
			},
			{
				name = "Advanced",
				props = {
					"TotalKeyFrames",
					"PartLife",
					"RotX",
					"RotY",
					"RotZ",
					"RotXEven",
					"RotYEven",
					"RotZEven",
					"RotationEvenCycle",
					"Pool"
				}
			},
			{
				name = "Events",
				props = {
					"OnEmit",
					"OnDeath",
					"OnDestruction",
					"OnHit"
				}
			}
		}
	}
}
return TypeDataModel