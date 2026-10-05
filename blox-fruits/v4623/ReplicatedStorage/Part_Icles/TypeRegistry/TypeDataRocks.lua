local TypeDataRocks = {
	RocksProperties = {
		Scale = {
			type = "NumberSequence",
			default = NumberSequence.new(1),
			nonNegative = true
		},
		Brightness = {
			type = "NumberSequence",
			default = NumberSequence.new(1)
		},
		Transparency = {
			type = "NumberSequence",
			default = NumberSequence.new(0)
		},
		Timescale = {
			type = "NumberSequence",
			default = NumberSequence.new(1)
		},
		Color = {
			type = "ColorSequence",
			default = ColorSequence.new(Color3.fromRGB(255, 255, 255))
		},
		Speed = {
			type = "NumberSequence",
			default = NumberSequence.new(30)
		},
		Lifetime = {
			type = "NumberRange",
			default = NumberRange.new(3)
		},
		Rate = {
			type = "number",
			default = 2
		},
		Enabled = {
			type = "boolean",
			default = false
		},
		BurstMode = {
			type = "string",
			default = "Directional"
		},
		SpreadAngle = {
			type = "Vector2",
			default = Vector2.new(25, 25)
		},
		ChunkCount = {
			type = "NumberRange",
			default = NumberRange.new(6, 10),
			nonNegative = true
		},
		ChunkScale = {
			type = "NumberRange",
			default = NumberRange.new(0.5, 1.5),
			nonNegative = true
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
		Gravity = {
			type = "number",
			default = 196.2
		},
		Bounciness = {
			type = "NumberRange",
			default = NumberRange.new(0.3, 0.5),
			nonNegative = true
		},
		Friction = {
			type = "number",
			default = 0.3,
			nonNegative = true
		},
		TumbleSpeed = {
			type = "NumberRange",
			default = NumberRange.new(90, 360)
		},
		SinkOut = {
			type = "boolean",
			default = true
		},
		InheritFloor = {
			type = "boolean",
			default = false
		},
		EmissionDirection = {
			type = "enum",
			enumType = "NormalId",
			default = Enum.NormalId.Top
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
			default = true
		}
	}
}
TypeDataRocks.Types = {
	Rocks = {
		classCheck = function(part)
			local isA = part:IsA("BasePart")

			if isA then
				if part:GetAttribute("IsRocks") == true then
					isA = part:FindFirstChild("PartIcleProperties") ~= nil
				else
					isA = false
				end
			end

			return isA
		end,
		pDataType = "Rocks",
		uiSection = "Rocks",
		properties = TypeDataRocks.RocksProperties,
		resize = {
			scaleGraphs = { "Speed" },
			scaleRanges = {
				"PosX",
				"PosY",
				"PosZ",
				"ChunkScale"
			},
			scaleNumbers = { "Gravity" }
		},
		retime = {
			multiplyNumbers = { "Rate" },
			multiplyGraphs = { "Speed" },
			multiplyRanges = { "TumbleSpeed" },
			squareNumbers = { "Gravity" },
			divideRanges = { "Lifetime" }
		},
		clipboard = {
			{
				name = "Spawning",
				props = {
					"Rate",
					"Lifetime",
					"BurstMode",
					"EmissionDirection",
					"SpreadAngle",
					"ChunkCount",
					"ChunkScale",
					"PosX",
					"PosY",
					"PosZ",
					"PosXEven",
					"PosYEven",
					"PosZEven",
					"PosMode"
				}
			},
			{
				name = "Emission",
				props = { "EmitCount", "EmitDelay", "EmitDuration" }
			},
			{
				name = "Physics",
				props = {
					"Speed",
					"Gravity",
					"Bounciness",
					"Friction",
					"TumbleSpeed",
					"SinkOut",
					"InheritFloor"
				}
			},
			{
				name = "Appearance",
				props = {
					"Color",
					"Brightness",
					"Transparency",
					"Scale",
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
return TypeDataRocks