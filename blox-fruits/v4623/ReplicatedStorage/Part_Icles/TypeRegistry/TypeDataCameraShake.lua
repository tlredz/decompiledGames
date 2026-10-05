local TypeDataCameraShake = {
	CameraShakeProperties = {
		ShakeAmplitude = {
			type = "NumberSequence",
			default = NumberSequence.new(1)
		},
		ShakeRotAmplitude = {
			type = "NumberSequence",
			default = NumberSequence.new(0.6)
		},
		Timescale = {
			type = "NumberSequence",
			default = NumberSequence.new(1)
		},
		ShakeFrequency = {
			type = "number",
			default = 10
		},
		ShakeFalloff = {
			type = "number",
			default = 0,
			nonNegative = true
		},
		Lifetime = {
			type = "NumberRange",
			default = NumberRange.new(0.5)
		},
		Rate = {
			type = "number",
			default = 10
		},
		Enabled = {
			type = "boolean",
			default = false
		},
		TotalKeyFrames = {
			type = "number",
			default = 100
		}
	}
}
TypeDataCameraShake.Types = {
	CameraShake = {
		classCheck = function(part)
			local isA = part:IsA("BasePart")

			if isA then
				if part:GetAttribute("IsCameraShake") == true then
					isA = part:FindFirstChild("PartIcleProperties") ~= nil
				else
					isA = false
				end
			end

			return isA
		end,
		pDataType = "CameraShake",
		uiSection = "Camera Shakes",
		properties = TypeDataCameraShake.CameraShakeProperties,
		resize = {
			scaleGraphs = { "ShakeAmplitude" },
			scaleNumbers = { "ShakeFalloff" }
		},
		retime = {
			multiplyNumbers = { "Rate", "ShakeFrequency" },
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
				name = "Shake",
				props = {
					"ShakeAmplitude",
					"ShakeRotAmplitude",
					"ShakeFrequency",
					"ShakeFalloff"
				}
			},
			{
				name = "Advanced",
				props = { "TotalKeyFrames", "Timescale" }
			},
			{
				name = "Events",
				props = { "OnEmit", "OnDeath", "OnDestruction" }
			}
		}
	}
}
return TypeDataCameraShake