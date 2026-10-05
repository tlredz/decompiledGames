local createVector = vector.create
local TypeData = {
	PartProperties = {
		Brightness = {
			type = "NumberSequence",
			default = NumberSequence.new(1)
		},
		Color = {
			type = "ColorSequence",
			default = ColorSequence.new(Color3.new(1, 1, 1))
		},
		SizeX = {
			type = "NumberSequence",
			default = NumberSequence.new(1)
		},
		SizeY = {
			type = "NumberSequence",
			default = NumberSequence.new(1)
		},
		SizeZ = {
			type = "NumberSequence",
			default = NumberSequence.new(1)
		},
		Transparency = {
			type = "NumberSequence",
			default = NumberSequence.new(0)
		},
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
			default = createVector(0, 0, 0)
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
		ShapePartial = {
			type = "number",
			default = 0
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
		AccelerationTowardsInstance = {
			type = "boolean",
			default = false
		},
		AccelStrength = {
			type = "NumberSequence",
			default = NumberSequence.new(0)
		},
		SizeXLinkedTo = {
			type = "string",
			default = ""
		},
		SizeYLinkedTo = {
			type = "string",
			default = ""
		},
		SizeZLinkedTo = {
			type = "string",
			default = ""
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
		UseShape = {
			type = "boolean",
			default = false
		},
		LookAtInitially = {
			type = "boolean",
			default = false
		},
		Shape = {
			type = "enum",
			enumType = "ParticleEmitterShape",
			default = Enum.ParticleEmitterShape.Box
		},
		ShapeInOut = {
			type = "enum",
			enumType = "ParticleEmitterShapeInOut",
			default = Enum.ParticleEmitterShapeInOut.Outward
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
		FlipbookMode = {
			type = "enum",
			enumType = "ParticleFlipbookMode",
			default = Enum.ParticleFlipbookMode.OneShot
		},
		FlipbookFramerate = {
			type = "NumberRange",
			default = NumberRange.new(30)
		},
		FlipbookStartRandom = {
			type = "boolean",
			default = false
		},
		FlipbookReverse = {
			type = "boolean",
			default = false
		},
		Pool = {
			type = "boolean",
			default = false
		}
	},
	BeamProperties = {
		Brightness = {
			type = "NumberSequence",
			default = NumberSequence.new(1),
			attrName = "BeamBrightness"
		},
		Width0 = {
			type = "NumberSequence",
			default = NumberSequence.new(1)
		},
		Width1 = {
			type = "NumberSequence",
			default = NumberSequence.new(1)
		},
		CurveSize0 = {
			type = "NumberSequence",
			default = NumberSequence.new(0)
		},
		CurveSize1 = {
			type = "NumberSequence",
			default = NumberSequence.new(0)
		},
		LightEmission = {
			type = "NumberSequence",
			default = NumberSequence.new(0)
		},
		LightInfluence = {
			type = "NumberSequence",
			default = NumberSequence.new(0),
			attrName = "BeamLightInfluence"
		},
		Segments = {
			type = "NumberSequence",
			default = NumberSequence.new(10)
		},
		TextureLength = {
			type = "NumberSequence",
			default = NumberSequence.new(1)
		},
		TextureSpeed = {
			type = "NumberSequence",
			default = NumberSequence.new(1)
		},
		Timescale = {
			type = "NumberSequence",
			default = NumberSequence.new(1),
			attrName = "BeamTimescale"
		},
		Lifetime = {
			type = "NumberRange",
			default = NumberRange.new(1),
			attrName = "BeamLifetime"
		},
		Rate = {
			type = "number",
			default = 10
		},
		TotalKeyFrames = {
			type = "number",
			default = 100
		},
		Enabled = {
			type = "boolean",
			default = false
		},
		FaceCamera = {
			type = "boolean",
			default = false
		},
		ZOffset = {
			type = "number",
			default = 0
		},
		TextureMode = {
			type = "enum",
			enumType = "TextureMode",
			default = Enum.TextureMode.Stretch,
			attrName = "BeamTextureMode"
		},
		FlipbookMode = {
			type = "enum",
			enumType = "ParticleFlipbookMode",
			default = Enum.ParticleFlipbookMode.OneShot,
			attrName = "BeamFlipbookMode"
		},
		FlipbookFramerate = {
			type = "NumberRange",
			default = NumberRange.new(30),
			attrName = "BeamFlipbookFramerate"
		},
		FlipbookStartRandom = {
			type = "boolean",
			default = false,
			attrName = "BeamFlipbookStartRandom"
		},
		FlipbookReverse = {
			type = "boolean",
			default = false,
			attrName = "BeamFlipbookReverse"
		},
		Pool = {
			type = "boolean",
			default = false
		}
	}
}
local TypeDataScreen = require(script.Parent.TypeDataScreen)
TypeData.BlurProperties = TypeDataScreen.BlurProperties
TypeData.BloomProperties = TypeDataScreen.BloomProperties
TypeData.ColorCorrectionProperties = TypeDataScreen.ColorCorrectionProperties
TypeData.AtmosphereProperties = TypeDataScreen.AtmosphereProperties
TypeData.ImageLabelProperties = TypeDataScreen.ImageLabelProperties
TypeData.PointLightProperties = {
	Range = {
		type = "NumberSequence",
		default = NumberSequence.new(8),
		attrName = "PLRange"
	},
	Brightness = {
		type = "NumberSequence",
		default = NumberSequence.new(1),
		attrName = "PLBrightness"
	},
	Color = {
		type = "ColorSequence",
		default = ColorSequence.new(Color3.new(1, 1, 1)),
		attrName = "PLColor"
	},
	Timescale = {
		type = "NumberSequence",
		default = NumberSequence.new(1),
		attrName = "PLTimescale"
	},
	Lifetime = {
		type = "NumberRange",
		default = NumberRange.new(1)
	},
	Rate = {
		type = "number",
		default = 10
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
	Enabled = {
		type = "boolean",
		default = false
	},
	Shadows = {
		type = "boolean",
		default = false
	},
	Pool = {
		type = "boolean",
		default = false
	}
}
TypeData.HighlightProperties = {
	FillColor = {
		type = "ColorSequence",
		default = ColorSequence.new(Color3.new(1, 1, 1)),
		attrName = "HLFillColor"
	},
	FillTransparency = {
		type = "NumberSequence",
		default = NumberSequence.new(0),
		attrName = "HLFillTransparency"
	},
	OutlineColor = {
		type = "ColorSequence",
		default = ColorSequence.new(Color3.new(1, 1, 1)),
		attrName = "HLOutlineColor"
	},
	OutlineTransparency = {
		type = "NumberSequence",
		default = NumberSequence.new(0),
		attrName = "HLOutlineTransparency"
	},
	Timescale = {
		type = "NumberSequence",
		default = NumberSequence.new(1),
		attrName = "HLTimescale"
	},
	Lifetime = {
		type = "NumberRange",
		default = NumberRange.new(1)
	},
	Rate = {
		type = "number",
		default = 10
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
	DepthMode = {
		type = "enum",
		enumType = "HighlightDepthMode",
		default = Enum.HighlightDepthMode.AlwaysOnTop,
		attrName = "HLDepthMode"
	},
	Enabled = {
		type = "boolean",
		default = false
	},
	Pool = {
		type = "boolean",
		default = false
	}
}
TypeData.TrailEmitterProperties = {
	Lifetime = {
		type = "NumberRange",
		default = NumberRange.new(2)
	},
	TrailLife = {
		type = "NumberRange",
		default = NumberRange.new(2),
		attrName = "TEmitTrailLife"
	},
	Rate = {
		type = "number",
		default = 10
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
	Timescale = {
		type = "NumberSequence",
		default = NumberSequence.new(1),
		attrName = "TEmitTimescale"
	},
	Brightness = {
		type = "NumberSequence",
		default = NumberSequence.new(1),
		attrName = "TEmitBrightness"
	},
	LightEmission = {
		type = "NumberSequence",
		default = NumberSequence.new(0),
		attrName = "TEmitLightEmission"
	},
	LightInfluence = {
		type = "NumberSequence",
		default = NumberSequence.new(1),
		attrName = "TEmitLightInfluence"
	},
	TextureLength = {
		type = "NumberSequence",
		default = NumberSequence.new(1),
		attrName = "TEmitTextureLength",
		nonNegative = true
	},
	MinLength = {
		type = "NumberSequence",
		default = NumberSequence.new(0.1),
		attrName = "TEmitMinLength",
		nonNegative = true
	},
	MaxLength = {
		type = "NumberSequence",
		default = NumberSequence.new(0),
		attrName = "TEmitMaxLength",
		nonNegative = true
	},
	Enabled = {
		type = "boolean",
		default = false
	},
	TrailFlipbookMode = {
		type = "enum",
		enumType = "ParticleFlipbookMode",
		default = Enum.ParticleFlipbookMode.OneShot,
		attrName = "TEmitFlipbookMode"
	},
	TrailFlipbookFramerate = {
		type = "NumberRange",
		default = NumberRange.new(30),
		attrName = "TEmitFlipbookFramerate"
	},
	TrailFlipbookStartRandom = {
		type = "boolean",
		default = false,
		attrName = "TEmitFlipbookStartRandom"
	},
	TrailFlipbookReverse = {
		type = "boolean",
		default = false,
		attrName = "TEmitFlipbookReverse"
	},
	Pool = {
		type = "boolean",
		default = false
	}
}
TypeData.BeamNativeProperties = {
	Transparency = {
		type = "NumberSequence",
		default = NumberSequence.new(0)
	},
	Color = {
		type = "ColorSequence",
		default = ColorSequence.new(Color3.new(1, 1, 1))
	},
	Brightness = {
		type = "number",
		default = 1
	},
	Width0 = {
		type = "number",
		default = 1
	},
	Width1 = {
		type = "number",
		default = 1
	},
	CurveSize0 = {
		type = "number",
		default = 0
	},
	CurveSize1 = {
		type = "number",
		default = 0
	},
	LightEmission = {
		type = "number",
		default = 0
	},
	LightInfluence = {
		type = "number",
		default = 0
	},
	Segments = {
		type = "number",
		default = 10,
		nonNegative = true
	},
	TextureLength = {
		type = "number",
		default = 1
	},
	TextureSpeed = {
		type = "number",
		default = 1
	},
	ZOffset = {
		type = "number",
		default = 0
	},
	Texture = {
		type = "string",
		default = ""
	},
	TextureMode = {
		type = "enum",
		enumType = "TextureMode",
		default = Enum.TextureMode.Stretch
	},
	FaceCamera = {
		type = "boolean",
		default = false
	},
	Enabled = {
		type = "boolean",
		default = true
	}
}
TypeData.TrailProperties = {
	Transparency = {
		type = "NumberSequence",
		default = NumberSequence.new(0.5)
	},
	WidthScale = {
		type = "NumberSequence",
		default = NumberSequence.new(1)
	},
	Color = {
		type = "ColorSequence",
		default = ColorSequence.new(Color3.new(1, 1, 1))
	},
	Brightness = {
		type = "number",
		default = 1
	},
	LightEmission = {
		type = "number",
		default = 0
	},
	LightInfluence = {
		type = "number",
		default = 1
	},
	TextureLength = {
		type = "number",
		default = 1
	},
	Lifetime = {
		type = "number",
		default = 2
	},
	MinLength = {
		type = "number",
		default = 0.1
	},
	MaxLength = {
		type = "number",
		default = 0
	},
	Duration = {
		type = "string",
		default = "2",
		attribute = true,
		attrName = "EmitDuration"
	},
	Enabled = {
		type = "boolean",
		default = true
	},
	FaceCamera = {
		type = "boolean",
		default = false
	},
	TextureMode = {
		type = "enum",
		enumType = "TextureMode",
		default = Enum.TextureMode.Stretch
	}
}
TypeData.AttachmentProperties = {
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
		default = createVector(0, 0, 0)
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
TypeData.Types = {
	Part = {
		classCheck = function(part)
			return part:IsA("BasePart") and not (part:GetAttribute("IsLightning") or part:GetAttribute("IsCameraShake") or part:GetAttribute("IsRocks") or part:GetAttribute("IsRope"))
		end,
		pDataType = "Part",
		uiSection = "Meshes",
		properties = TypeData.PartProperties,
		resize = {
			scaleGraphs = {
				"SizeX",
				"SizeY",
				"SizeZ",
				"Speed",
				"AccelStrength",
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
			multiplyRanges = { "FlipbookFramerate" },
			multiplyGraphs = { "Speed" },
			rotSpeedGraphs = { "RotSpeedX", "RotSpeedY", "RotSpeedZ" },
			squareVectors = { "Acceleration" },
			squareGraphs = { "AccelStrength" }
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
				name = "Appearance",
				props = {
					"Brightness",
					"Color",
					"SizeX",
					"SizeY",
					"SizeZ",
					"Transparency",
					"Material"
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
					"AccelerationTowardsInstance",
					"AccelStrength",
					"Timescale"
				}
			},
			{
				name = "Shape",
				props = {
					"UseShape",
					"Shape",
					"ShapeInOut",
					"ShapePartial",
					"LookAtInitially"
				}
			},
			{
				name = "Flipbook",
				props = {
					"FlipbookMode",
					"FlipbookFramerate",
					"FlipbookStartRandom",
					"FlipbookReverse"
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
	},
	Beam = {
		classCheck = function(beam)
			return beam:IsA("Beam") and beam:FindFirstChild("PartIcleProperties") ~= nil
		end,
		pDataType = "Beam",
		uiSection = "Beams",
		properties = TypeData.BeamProperties,
		resize = {
			scaleGraphs = {
				"Width0",
				"Width1",
				"CurveSize0",
				"CurveSize1",
				"Segments"
			}
		},
		retime = {
			multiplyNumbers = { "Rate" },
			divideRanges = { "Lifetime" },
			multiplyRanges = { "FlipbookFramerate" },
			multiplyGraphs = { "TextureSpeed" }
		},
		clipboard = {
			{
				name = "Spawning",
				props = { "Rate", "Lifetime" }
			},
			{
				name = "Emission",
				props = { "EmitCount", "EmitDelay", "EmitDuration" }
			},
			{
				name = "Appearance",
				props = {
					"Brightness",
					"Width0",
					"Width1",
					"LightEmission",
					"LightInfluence",
					"ZOffset"
				}
			},
			{
				name = "Geometry",
				props = {
					"CurveSize0",
					"CurveSize1",
					"Segments",
					"TextureLength",
					"TextureSpeed",
					"TextureMode",
					"FaceCamera"
				}
			},
			{
				name = "Flipbook",
				props = {
					"FlipbookMode",
					"FlipbookFramerate",
					"FlipbookStartRandom",
					"FlipbookReverse"
				}
			},
			{
				name = "Advanced",
				props = { "TotalKeyFrames", "Timescale", "Pool" }
			},
			{
				name = "Blender",
				props = { "Blender" }
			},
			{
				name = "Events",
				props = { "OnEmit", "OnDeath", "OnDestruction" }
			}
		}
	},
	PointLight = {
		classCheck = function(light)
			return light:IsA("PointLight")
		end,
		pDataType = "PointLight",
		uiSection = "PointLights",
		properties = TypeData.PointLightProperties,
		resize = {
			scaleGraphs = { "Range" }
		},
		retime = {
			multiplyNumbers = { "Rate" },
			divideRanges = { "Lifetime" }
		},
		clipboard = {
			{
				name = "Spawning",
				props = { "Rate", "Lifetime" }
			},
			{
				name = "Emission",
				props = { "EmitCount", "EmitDelay", "EmitDuration" }
			},
			{
				name = "Appearance",
				props = {
					"Range",
					"Brightness",
					"Color",
					"Shadows"
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
	},
	Highlight = {
		classCheck = function(highlight)
			return highlight:IsA("Highlight")
		end,
		pDataType = "Highlight",
		uiSection = "Highlights",
		properties = TypeData.HighlightProperties,
		retime = {
			multiplyNumbers = { "Rate" },
			divideRanges = { "Lifetime" }
		},
		clipboard = {
			{
				name = "Spawning",
				props = { "Rate", "Lifetime" }
			},
			{
				name = "Emission",
				props = { "EmitCount", "EmitDelay", "EmitDuration" }
			},
			{
				name = "Appearance",
				props = {
					"FillColor",
					"FillTransparency",
					"OutlineColor",
					"OutlineTransparency",
					"DepthMode"
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
	},
	TrailEmitter = {
		classCheck = function(trail)
			return trail:IsA("Trail") and trail:FindFirstChild("PartIcleProperties") ~= nil
		end,
		pDataType = "TrailEmitter",
		uiSection = "TrailEmitters",
		properties = TypeData.TrailEmitterProperties,
		resize = {
			scaleGraphs = { "MinLength", "MaxLength" }
		},
		retime = {
			multiplyNumbers = { "Rate" },
			divideRanges = { "Lifetime", "TrailLife" },
			multiplyRanges = { "TrailFlipbookFramerate" }
		},
		clipboard = {
			{
				name = "Spawning",
				props = { "Rate", "Lifetime" }
			},
			{
				name = "Emission",
				props = { "EmitCount", "EmitDelay", "EmitDuration" }
			},
			{
				name = "Appearance",
				props = {
					"Brightness",
					"LightEmission",
					"LightInfluence",
					"Texture",
					"TextureMode",
					"FaceCamera"
				}
			},
			{
				name = "Geometry",
				props = { "TextureLength", "MinLength", "MaxLength" }
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
	},
	BeamNative = {
		classCheck = function(beam)
			return beam:IsA("Beam") and beam:FindFirstChild("PartIcleProperties") == nil
		end,
		pDataType = "BeamNative",
		uiSection = "BeamNatives",
		directAccess = true,
		properties = TypeData.BeamNativeProperties,
		resize = {
			scaleNumbers = {
				"Width0",
				"Width1",
				"CurveSize0",
				"CurveSize1"
			}
		},
		retime = {
			multiplyNumbers = { "TextureSpeed" }
		},
		clipboard = {
			{
				name = "Appearance",
				props = {
					"Brightness",
					"Color",
					"Transparency",
					"LightEmission",
					"LightInfluence",
					"ZOffset"
				}
			},
			{
				name = "Geometry",
				props = {
					"Width0",
					"Width1",
					"CurveSize0",
					"CurveSize1",
					"Segments",
					"TextureLength",
					"TextureSpeed",
					"TextureMode",
					"FaceCamera"
				}
			},
			{
				name = "Texture",
				props = { "Texture" }
			}
		}
	},
	Trail = {
		classCheck = function(trail)
			return trail:IsA("Trail") and trail:FindFirstChild("PartIcleProperties") == nil
		end,
		pDataType = "Trail",
		uiSection = "Trails",
		directAccess = true,
		properties = TypeData.TrailProperties,
		resize = {
			scaleGraphs = { "WidthScale" }
		},
		retime = {
			divideNumbers = { "Lifetime" }
		},
		clipboard = {
			{
				name = "Spawning",
				props = { "Lifetime" }
			},
			{
				name = "Emission",
				props = { "Duration" }
			},
			{
				name = "Appearance",
				props = {
					"Brightness",
					"Transparency",
					"Color",
					"WidthScale",
					"LightEmission",
					"LightInfluence"
				}
			},
			{
				name = "Geometry",
				props = {
					"MinLength",
					"MaxLength",
					"TextureLength",
					"TextureMode",
					"FaceCamera"
				}
			}
		}
	},
	Attachment = {
		classCheck = function(attachment)
			return attachment:IsA("Attachment")
		end,
		pDataType = "Attachment",
		uiSection = "Attachments",
		properties = TypeData.AttachmentProperties,
		resize = {
			scaleGraphs = {
				"Speed",
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

for k, type in pairs(TypeDataScreen.Types) do
	TypeData.Types[k] = type
end

local TypeDataLightning = require(script.Parent.TypeDataLightning)
TypeData.LightningProperties = TypeDataLightning.LightningProperties

for k, type in pairs(TypeDataLightning.Types) do
	TypeData.Types[k] = type
end

local TypeDataModel = require(script.Parent.TypeDataModel)
TypeData.ModelProperties = TypeDataModel.ModelProperties

for k, type in pairs(TypeDataModel.Types) do
	TypeData.Types[k] = type
end

local TypeDataCameraShake = require(script.Parent.TypeDataCameraShake)
TypeData.CameraShakeProperties = TypeDataCameraShake.CameraShakeProperties

for k, type in pairs(TypeDataCameraShake.Types) do
	TypeData.Types[k] = type
end

local TypeDataRocks = require(script.Parent.TypeDataRocks)
TypeData.RocksProperties = TypeDataRocks.RocksProperties

for k, type in pairs(TypeDataRocks.Types) do
	TypeData.Types[k] = type
end

local TypeDataRope = require(script.Parent.TypeDataRope)
TypeData.RopeProperties = TypeDataRope.RopeProperties

for k, type in pairs(TypeDataRope.Types) do
	TypeData.Types[k] = type
end

return TypeData