local TypeDataScreen = {
	BlurProperties = {
		Size = {
			type = "NumberSequence",
			default = NumberSequence.new(10),
			attrName = "BlurSize",
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
		TotalKeyFrames = {
			type = "number",
			default = 100
		},
		PartLife = {
			type = "number",
			default = 0
		},
		Enabled = {
			type = "boolean",
			default = false
		}
	},
	BloomProperties = {
		Intensity = {
			type = "NumberSequence",
			default = NumberSequence.new(0.4),
			attrName = "BloomIntensity",
			nonNegative = true
		},
		Size = {
			type = "NumberSequence",
			default = NumberSequence.new(24),
			attrName = "BloomSize",
			nonNegative = true
		},
		Threshold = {
			type = "NumberSequence",
			default = NumberSequence.new(0.95),
			attrName = "BloomThreshold",
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
		TotalKeyFrames = {
			type = "number",
			default = 100
		},
		PartLife = {
			type = "number",
			default = 0
		},
		Enabled = {
			type = "boolean",
			default = false
		}
	},
	ColorCorrectionProperties = {
		Brightness = {
			type = "NumberSequence",
			default = NumberSequence.new(0),
			attrName = "CCBrightness"
		},
		Contrast = {
			type = "NumberSequence",
			default = NumberSequence.new(0),
			attrName = "CCContrast"
		},
		Saturation = {
			type = "NumberSequence",
			default = NumberSequence.new(0),
			attrName = "CCSaturation"
		},
		TintColor = {
			type = "ColorSequence",
			default = ColorSequence.new(Color3.new(1, 1, 1)),
			attrName = "CCTintColor"
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
		TotalKeyFrames = {
			type = "number",
			default = 100
		},
		PartLife = {
			type = "number",
			default = 0
		},
		Enabled = {
			type = "boolean",
			default = false
		}
	},
	AtmosphereProperties = {
		Density = {
			type = "NumberSequence",
			default = NumberSequence.new(0.3),
			attrName = "AtmDensity",
			nonNegative = true
		},
		Offset = {
			type = "NumberSequence",
			default = NumberSequence.new(0.25),
			attrName = "AtmOffset",
			nonNegative = true
		},
		Glare = {
			type = "NumberSequence",
			default = NumberSequence.new(0),
			attrName = "AtmGlare",
			nonNegative = true
		},
		Haze = {
			type = "NumberSequence",
			default = NumberSequence.new(0),
			attrName = "AtmHaze",
			nonNegative = true
		},
		Color = {
			type = "ColorSequence",
			default = ColorSequence.new(Color3.new(0.78, 0.78, 0.78)),
			attrName = "AtmColor"
		},
		Decay = {
			type = "ColorSequence",
			default = ColorSequence.new(Color3.new(0.416, 0.471, 0.541)),
			attrName = "AtmDecay"
		},
		Timescale = {
			type = "NumberSequence",
			default = NumberSequence.new(1),
			attrName = "AtmTimescale"
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
			default = 0
		},
		Enabled = {
			type = "boolean",
			default = false
		}
	},
	ImageLabelProperties = {
		ImageTransparency = {
			type = "NumberSequence",
			default = NumberSequence.new(0)
		},
		BackgroundTransparency = {
			type = "NumberSequence",
			default = NumberSequence.new(1)
		},
		Speed = {
			type = "NumberSequence",
			default = NumberSequence.new(0),
			attrName = "ImgSpeed",
			nonNegative = true
		},
		SizeScaleX = {
			type = "NumberSequence",
			default = NumberSequence.new(1),
			nonNegative = true
		},
		SizeScaleY = {
			type = "NumberSequence",
			default = NumberSequence.new(1),
			nonNegative = true
		},
		RotRange = {
			type = "NumberRange",
			default = NumberRange.new(0),
			attrName = "ImgRotRange"
		},
		RotSpeed = {
			type = "NumberSequence",
			default = NumberSequence.new(0),
			attrName = "ImgRotSpeed"
		},
		RotMode = {
			type = "string",
			default = "OverLife",
			attrName = "ImgRotMode"
		},
		ImageColor3 = {
			type = "ColorSequence",
			default = ColorSequence.new(Color3.new(1, 1, 1))
		},
		BackgroundColor3 = {
			type = "ColorSequence",
			default = ColorSequence.new(Color3.new(1, 1, 1))
		},
		Image = {
			type = "string",
			default = ""
		},
		Position = {
			type = "UDim2",
			default = UDim2.fromScale(0.5, 0.5)
		},
		Size = {
			type = "UDim2",
			default = UDim2.fromOffset(100, 100),
			attrName = "ImgSize"
		},
		AnchorPoint = {
			type = "Vector2",
			default = Vector2.new(0.5, 0.5)
		},
		ZIndex = {
			type = "number",
			default = 1
		},
		ScaleType = {
			type = "enum",
			enumType = "ScaleType",
			default = Enum.ScaleType.Stretch
		},
		ResampleMode = {
			type = "enum",
			enumType = "ResamplerMode",
			default = Enum.ResamplerMode.Default
		},
		EmissionAngle = {
			type = "number",
			default = 90
		},
		SpreadAngle = {
			type = "number",
			default = 0,
			attrName = "ImgSpreadAngle"
		},
		Acceleration = {
			type = "Vector2",
			default = Vector2.new(0, 0),
			attrName = "ImgAcceleration"
		},
		Drag = {
			type = "number",
			default = 0,
			attrName = "ImgDrag"
		},
		InvertMotion = {
			type = "boolean",
			default = false,
			attrName = "ImgInvertMotion"
		},
		FlipbookSource = {
			type = "string",
			default = "Decals",
			attrName = "ImgFlipbookSource"
		},
		FlipbookMode = {
			type = "enum",
			enumType = "ParticleFlipbookMode",
			default = Enum.ParticleFlipbookMode.Loop,
			attrName = "ImgFlipbookMode"
		},
		FlipbookStartRandom = {
			type = "boolean",
			default = false,
			attrName = "ImgFlipbookStartRandom"
		},
		GridCols = {
			type = "number",
			default = 8
		},
		GridRows = {
			type = "number",
			default = 1
		},
		FlipbookFramerate = {
			type = "NumberRange",
			default = NumberRange.new(10),
			attrName = "ImgFlipbookFramerate"
		},
		FlipbookReverse = {
			type = "boolean",
			default = false,
			attrName = "ImgFlipbookReverse"
		},
		Timescale = {
			type = "NumberSequence",
			default = NumberSequence.new(1),
			attrName = "ImgTimescale"
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
			default = 0
		},
		Enabled = {
			type = "boolean",
			default = false
		}
	}
}
TypeDataScreen.Types = {
	Blur = {
		classCheck = function(blurEffect)
			return blurEffect:IsA("BlurEffect")
		end,
		pDataType = "Blur",
		uiSection = "Blurs",
		properties = TypeDataScreen.BlurProperties,
		resize = {
			scaleGraphs = { "Size" }
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
				props = { "Size" }
			},
			{
				name = "Advanced",
				props = { "TotalKeyFrames", "PartLife", "Timescale" }
			},
			{
				name = "Events",
				props = { "OnEmit", "OnDeath", "OnDestruction" }
			}
		}
	},
	Bloom = {
		classCheck = function(bloomEffect)
			return bloomEffect:IsA("BloomEffect")
		end,
		pDataType = "Bloom",
		uiSection = "Blooms",
		properties = TypeDataScreen.BloomProperties,
		resize = {
			scaleGraphs = { "Size" }
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
				props = { "Intensity", "Size", "Threshold" }
			},
			{
				name = "Advanced",
				props = { "TotalKeyFrames", "PartLife", "Timescale" }
			},
			{
				name = "Events",
				props = { "OnEmit", "OnDeath", "OnDestruction" }
			}
		}
	},
	ColorCorrection = {
		classCheck = function(colorCorrectionEffect)
			return colorCorrectionEffect:IsA("ColorCorrectionEffect")
		end,
		pDataType = "ColorCorrection",
		uiSection = "ColorCorrections",
		properties = TypeDataScreen.ColorCorrectionProperties,
		resize = {},
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
					"Brightness",
					"Contrast",
					"Saturation",
					"TintColor"
				}
			},
			{
				name = "Advanced",
				props = { "TotalKeyFrames", "PartLife", "Timescale" }
			},
			{
				name = "Events",
				props = { "OnEmit", "OnDeath", "OnDestruction" }
			}
		}
	},
	Atmosphere = {
		classCheck = function(atmosphere)
			return atmosphere:IsA("Atmosphere")
		end,
		pDataType = "Atmosphere",
		uiSection = "Atmospheres",
		properties = TypeDataScreen.AtmosphereProperties,
		resize = {},
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
					"Density",
					"Offset",
					"Glare",
					"Haze",
					"Color",
					"Decay"
				}
			},
			{
				name = "Advanced",
				props = { "TotalKeyFrames", "PartLife", "Timescale" }
			},
			{
				name = "Events",
				props = { "OnEmit", "OnDeath", "OnDestruction" }
			}
		}
	},
	ImageLabel = {
		classCheck = function(image)
			return image:IsA("ImageLabel")
		end,
		pDataType = "ImageLabel",
		uiSection = "ImageLabels",
		properties = TypeDataScreen.ImageLabelProperties,
		resize = {
			scaleGraphs = { "Speed", "SizeScaleX", "SizeScaleY" },
			scaleVectors = { "Acceleration" },
			scaleUDim2s = { "Position", "Size" }
		},
		retime = {
			multiplyNumbers = { "Rate", "Drag" },
			divideRanges = { "Lifetime" },
			multiplyRanges = { "FlipbookFramerate" },
			multiplyGraphs = { "Speed", "RotSpeed" },
			squareVectors = { "Acceleration" }
		},
		clipboard = {
			{
				name = "Spawning",
				props = {
					"Rate",
					"Lifetime",
					"RotRange",
					"RotSpeed",
					"RotMode"
				}
			},
			{
				name = "Emission",
				props = { "EmitCount", "EmitDelay", "EmitDuration" }
			},
			{
				name = "Appearance",
				props = {
					"Image",
					"ImageColor3",
					"ImageTransparency",
					"BackgroundColor3",
					"BackgroundTransparency",
					"ScaleType",
					"ResampleMode"
				}
			},
			{
				name = "Layout",
				props = {
					"Position",
					"Size",
					"SizeScaleX",
					"SizeScaleY",
					"AnchorPoint",
					"ZIndex"
				}
			},
			{
				name = "Motion",
				props = {
					"Speed",
					"EmissionAngle",
					"SpreadAngle",
					"Acceleration",
					"Drag",
					"InvertMotion"
				}
			},
			{
				name = "Flipbook",
				props = {
					"FlipbookSource",
					"FlipbookMode",
					"FlipbookStartRandom",
					"GridCols",
					"GridRows",
					"FlipbookFramerate",
					"FlipbookReverse"
				}
			},
			{
				name = "Advanced",
				props = { "TotalKeyFrames", "PartLife", "Timescale" }
			},
			{
				name = "Events",
				props = { "OnEmit", "OnDeath", "OnDestruction" }
			}
		}
	}
}
return TypeDataScreen