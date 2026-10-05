local createVector = vector.create
local Flipbook = require(script.Parent.Flipbook)
local TypeRegistry = require(script.Parent.TypeRegistry)
local AxisLinks = require(script.Parent.AxisLinks)
local EventsSchema = require(script.Parent.EventsSchema)
local GetDataRig = require(script.Parent.GetDataRig)

local function safeEnum(p, p2, p3)
	if not p2 then
		return p3
	end

	local success, result = pcall(function()
		return p[p2]
	end)

	if success then
		p3 = result or p3
	end

	return p3
end

local function readAxisLinks(config)
	local v = {
		SizeX = config:GetAttribute("SizeXLinkedTo"),
		SizeY = config:GetAttribute("SizeYLinkedTo"),
		SizeZ = config:GetAttribute("SizeZLinkedTo"),
		RotSpeedX = config:GetAttribute("RotSpeedXLinkedTo"),
		RotSpeedY = config:GetAttribute("RotSpeedYLinkedTo"),
		RotSpeedZ = config:GetAttribute("RotSpeedZLinkedTo"),
		PosOffsetX = config:GetAttribute("PosOffsetXLinkedTo"),
		PosOffsetY = config:GetAttribute("PosOffsetYLinkedTo"),
		PosOffsetZ = config:GetAttribute("PosOffsetZLinkedTo"),
		RotX = config:GetAttribute("RotXLinkedTo"),
		RotY = config:GetAttribute("RotYLinkedTo"),
		RotZ = config:GetAttribute("RotZLinkedTo"),
		PosX = config:GetAttribute("PosXLinkedTo"),
		PosY = config:GetAttribute("PosYLinkedTo"),
		PosZ = config:GetAttribute("PosZLinkedTo")
	}
	return AxisLinks.sanitize(v)
end

return function(p)
	function p.GetData(_, instance)
		local v = {}
		local config = TypeRegistry.getConfig(instance)

		if not config then
			return nil
		end

		local emitParent = instance:FindFirstChild("EmitParent")
		v.EmitParent = emitParent and emitParent:IsA("ObjectValue") and emitParent.Value or nil
		local link = instance:FindFirstChild("Link")
		local link2 = link and link:IsA("ObjectValue") and link.Value or nil
		local linkSource = instance:GetAttribute("LinkSource") or link2 and "Object" or "None"

		if linkSource == "Camera" then
			v.Link = workspace.CurrentCamera
		elseif linkSource == "Object" then
			v.Link = link2
		else
			v.Link = nil
		end

		v.LinkMode = instance:GetAttribute("LinkMode") or "Follow"
		v.RenderTemplate = instance:FindFirstChild("RenderTemplate")
		v.Events = EventsSchema.readEnabled(instance)
		local totalKeyFrames = config:GetAttribute("TotalKeyFrames") or 0
		v.TotalKeyFrames = totalKeyFrames > 0 and totalKeyFrames or 100

		function v.CheckEnabled()
			return config.Parent ~= nil and config:GetAttribute("Enabled") == true
		end

		if instance:IsA("Model") then
			v.PartLife = config:GetAttribute("PartLife") or 0
			v.DirMode = config:GetAttribute("DirMode") or config:GetAttribute("VelocityVectored") and "Local" or "RigidLocal"
			v.VelocityVectored = v.DirMode == "Local"
			v.InvertMotion = config:GetAttribute("InvertMotion") or false
			v.RotMode = config:GetAttribute("RotMode") or "OverLife"
			v.RotOrder = config:GetAttribute("RotOrder") or "Global"
			v.Lifetime = config:GetAttribute("Lifetime") or NumberRange.new(1)
			v.Rate = config:GetAttribute("Rate") or 10
			local normalId = Enum.NormalId
			local emissionDirection = config:GetAttribute("EmissionDirection")
			local top = Enum.NormalId.Top

			if emissionDirection then
				local success, result = pcall(function()
					return normalId[emissionDirection]
				end)

				if success then
					top = result or top
				end
			end

			v.EmissionDirection = top
			v.ParticleData = {
				SpreadAngle = config:GetAttribute("SpreadAngle") or Vector2.new(0, 0),
				Acceleration = config:GetAttribute("Acceleration") or createVector(0, 0, 0),
				Drag = config:GetAttribute("Drag") or 0
			}
			v.Speed = config:GetAttribute("Speed")
			v.Scale = config:GetAttribute("Scale")
			v.Timescale = config:GetAttribute("Timescale")
			v.RotX = config:GetAttribute("RotX") or NumberRange.new(0)
			v.RotY = config:GetAttribute("RotY") or NumberRange.new(0)
			v.RotZ = config:GetAttribute("RotZ") or NumberRange.new(0)
			v.RotXEven = config:GetAttribute("RotXEven") == true
			v.RotYEven = config:GetAttribute("RotYEven") == true
			v.RotZEven = config:GetAttribute("RotZEven") == true
			v.PosX = config:GetAttribute("PosX") or NumberRange.new(0)
			v.PosY = config:GetAttribute("PosY") or NumberRange.new(0)
			v.PosZ = config:GetAttribute("PosZ") or NumberRange.new(0)
			v.PosXEven = config:GetAttribute("PosXEven") == true
			v.PosYEven = config:GetAttribute("PosYEven") == true
			v.PosZEven = config:GetAttribute("PosZEven") == true
			v.PosMode = config:GetAttribute("PosMode") or "Local"
			v.DisplacementMode = config:GetAttribute("DisplacementMode") or "Global"
			v.RotSpeedX = config:GetAttribute("RotSpeedX")
			v.RotSpeedY = config:GetAttribute("RotSpeedY")
			v.RotSpeedZ = config:GetAttribute("RotSpeedZ")
			v.PosOffsetX = config:GetAttribute("PosOffsetX")
			v.PosOffsetY = config:GetAttribute("PosOffsetY")
			v.PosOffsetZ = config:GetAttribute("PosOffsetZ")
			v.Turbulence = config:GetAttribute("Turbulence")
			v.TurbulenceFrequency = config:GetAttribute("TurbulenceFrequency") or 1
			v.Orientation = config:GetAttribute("Orientation") or "None"
			v.ZOffset = config:GetAttribute("ZOffset") or 0
			v.AxisLinks = readAxisLinks(config)
			v.Pool = config:GetAttribute("Pool")
			v.ScaleTextureLength = config:GetAttribute("ScaleTextureLength")
			v.ScaleMotion = config:GetAttribute("ScaleMotion") ~= false
			v.ScaleRotation = config:GetAttribute("ScaleRotation") == true
			return v
		elseif instance:IsA("BlurEffect") then
			v.PartLife = config:GetAttribute("PartLife") or 0
			v.Lifetime = config:GetAttribute("Lifetime") or NumberRange.new(1)
			v.Rate = config:GetAttribute("Rate") or 10
			v.BlurSize = config:GetAttribute("BlurSize")
			v.Timescale = config:GetAttribute("Timescale")
			return v
		elseif instance:IsA("BloomEffect") then
			v.PartLife = config:GetAttribute("PartLife") or 0
			v.Lifetime = config:GetAttribute("Lifetime") or NumberRange.new(1)
			v.Rate = config:GetAttribute("Rate") or 10
			v.BloomIntensity = config:GetAttribute("BloomIntensity")
			v.BloomSize = config:GetAttribute("BloomSize")
			v.BloomThreshold = config:GetAttribute("BloomThreshold")
			v.Timescale = config:GetAttribute("Timescale")
			return v
		elseif instance:IsA("ColorCorrectionEffect") then
			v.PartLife = config:GetAttribute("PartLife") or 0
			v.Lifetime = config:GetAttribute("Lifetime") or NumberRange.new(1)
			v.Rate = config:GetAttribute("Rate") or 10
			v.CCBrightness = config:GetAttribute("CCBrightness")
			v.CCContrast = config:GetAttribute("CCContrast")
			v.CCSaturation = config:GetAttribute("CCSaturation")
			v.CCTintColor = config:GetAttribute("CCTintColor")
			v.Timescale = config:GetAttribute("Timescale")
			return v
		elseif instance:IsA("Atmosphere") then
			v.PartLife = config:GetAttribute("PartLife") or 0
			v.Lifetime = config:GetAttribute("Lifetime") or NumberRange.new(1)
			v.Rate = config:GetAttribute("Rate") or 10
			v.AtmDensity = config:GetAttribute("AtmDensity")
			v.AtmOffset = config:GetAttribute("AtmOffset")
			v.AtmGlare = config:GetAttribute("AtmGlare")
			v.AtmHaze = config:GetAttribute("AtmHaze")
			v.AtmColor = config:GetAttribute("AtmColor")
			v.AtmDecay = config:GetAttribute("AtmDecay")
			v.AtmTimescale = config:GetAttribute("AtmTimescale")
			return v
		elseif instance:IsA("ImageLabel") then
			v.PartLife = config:GetAttribute("PartLife") or 0
			v.Lifetime = config:GetAttribute("Lifetime") or NumberRange.new(1)
			v.Rate = config:GetAttribute("Rate") or 10
			v.ImageTransparency = config:GetAttribute("ImageTransparency")
			v.BackgroundTransparency = config:GetAttribute("BackgroundTransparency")
			v.ImgSpeed = config:GetAttribute("ImgSpeed")
			v.SizeScaleX = config:GetAttribute("SizeScaleX")
			v.SizeScaleY = config:GetAttribute("SizeScaleY")
			v.ImgRotRange = config:GetAttribute("ImgRotRange") or NumberRange.new(0)
			v.ImgRotSpeed = config:GetAttribute("ImgRotSpeed")
			v.ImgRotMode = config:GetAttribute("ImgRotMode") or "OverLife"
			v.ImageColor3 = config:GetAttribute("ImageColor3")
			v.BackgroundColor3 = config:GetAttribute("BackgroundColor3")
			v.Image = config:GetAttribute("Image") or ""
			v.ImgPosition = config:GetAttribute("Position") or UDim2.fromScale(0.5, 0.5)
			v.ImgSizeUDim = config:GetAttribute("ImgSize") or UDim2.fromOffset(100, 100)
			v.ImgAnchorPoint = config:GetAttribute("AnchorPoint") or Vector2.new(0.5, 0.5)
			v.ImgZIndex = config:GetAttribute("ZIndex") or 1
			local scaleType = Enum.ScaleType
			local scaleType2 = config:GetAttribute("ScaleType")
			local stretch = Enum.ScaleType.Stretch

			if scaleType2 then
				local success, result = pcall(function()
					return scaleType[scaleType2]
				end)

				if success then
					stretch = result or stretch
				end
			end

			v.ImgScaleType = stretch
			local resamplerMode = Enum.ResamplerMode
			local resampleMode = config:GetAttribute("ResampleMode")
			local default = Enum.ResamplerMode.Default

			if resampleMode then
				local success, result = pcall(function()
					return resamplerMode[resampleMode]
				end)

				if success then
					default = result or default
				end
			end

			v.ImgResampleMode = default
			v.ImgEmissionAngle = config:GetAttribute("EmissionAngle") or 90
			v.ImgSpreadAngle = config:GetAttribute("ImgSpreadAngle") or 0
			v.ImgAcceleration = config:GetAttribute("ImgAcceleration") or Vector2.new(0, 0)
			v.ImgDrag = config:GetAttribute("ImgDrag") or 0
			v.ImgInvertMotion = config:GetAttribute("ImgInvertMotion") or false
			v.ImgFlipbookSource = config:GetAttribute("ImgFlipbookSource") or "Decals"
			local particleFlipbookMode = Enum.ParticleFlipbookMode
			local imgFlipbookMode = config:GetAttribute("ImgFlipbookMode")
			local loop = Enum.ParticleFlipbookMode.Loop

			if imgFlipbookMode then
				local success, result = pcall(function()
					return particleFlipbookMode[imgFlipbookMode]
				end)

				if success then
					loop = result or loop
				end
			end

			v.ImgFlipbookMode = loop
			v.ImgFlipbookStartRandom = config:GetAttribute("ImgFlipbookStartRandom") or false
			v.ImgGridCols = config:GetAttribute("GridCols") or 8
			v.ImgGridRows = config:GetAttribute("GridRows") or 1
			v.ImgFlipbookFramerate = config:GetAttribute("ImgFlipbookFramerate") or NumberRange.new(10)
			v.ImgFlipbookReverse = config:GetAttribute("ImgFlipbookReverse") or false
			local _SheetSize = config:GetAttribute("_SheetSize")
			local _SheetAsset = config:GetAttribute("_SheetAsset")
			local v2

			if type(v.Image) == "string" then
				v2 = v.Image:match("rbxassetid://(%d+)") or v.Image:match("^(%d+)$") or nil
			end

			if typeof(_SheetSize) == "Vector2" and _SheetAsset and _SheetAsset == v2 then
				v.SheetSize = _SheetSize
			end

			v.ImageFlipbooks = instance:FindFirstChild("ImageFlipbooks")
			v.ImgTimescale = config:GetAttribute("ImgTimescale")
			v.Pool = config:GetAttribute("Pool")
			return v
		elseif instance:IsA("PointLight") then
			v.PartLife = config:GetAttribute("PartLife") or 0
			v.Lifetime = config:GetAttribute("Lifetime") or NumberRange.new(1)
			v.Rate = config:GetAttribute("Rate") or 10
			v.PLRange = config:GetAttribute("PLRange")
			v.PLBrightness = config:GetAttribute("PLBrightness")
			v.PLColor = config:GetAttribute("PLColor")
			v.PLTimescale = config:GetAttribute("PLTimescale")
			v.Shadows = config:GetAttribute("Shadows")
			v.Pool = config:GetAttribute("Pool")
			return v
		elseif instance:IsA("Highlight") then
			v.PartLife = config:GetAttribute("PartLife") or 0
			v.Lifetime = config:GetAttribute("Lifetime") or NumberRange.new(1)
			v.Rate = config:GetAttribute("Rate") or 10
			v.HLFillColor = config:GetAttribute("HLFillColor")
			v.HLFillTransparency = config:GetAttribute("HLFillTransparency")
			v.HLOutlineColor = config:GetAttribute("HLOutlineColor")
			v.HLOutlineTransparency = config:GetAttribute("HLOutlineTransparency")
			v.HLTimescale = config:GetAttribute("HLTimescale")
			local highlightDepthMode = Enum.HighlightDepthMode
			local hLDepthMode = config:GetAttribute("HLDepthMode")
			local alwaysOnTop = Enum.HighlightDepthMode.AlwaysOnTop

			if hLDepthMode then
				local success, result = pcall(function()
					return highlightDepthMode[hLDepthMode]
				end)

				if success then
					alwaysOnTop = result or alwaysOnTop
				end
			end

			v.HLDepthMode = alwaysOnTop
			local adornee = instance:FindFirstChild("Adornee")
			v.Adornee = adornee and adornee:IsA("ObjectValue") and adornee.Value or nil
			v.Pool = config:GetAttribute("Pool")
			return v
		elseif instance:IsA("Trail") then
			v.PartLife = config:GetAttribute("PartLife") or 0
			v.Lifetime = config:GetAttribute("Lifetime") or NumberRange.new(2)
			v.Rate = config:GetAttribute("Rate") or 10
			v.TEmitTimescale = config:GetAttribute("TEmitTimescale")
			v.TEmitBrightness = config:GetAttribute("TEmitBrightness")
			v.TEmitLightEmission = config:GetAttribute("TEmitLightEmission")
			v.TEmitLightInfluence = config:GetAttribute("TEmitLightInfluence")
			v.TEmitTextureLength = config:GetAttribute("TEmitTextureLength")
			v.TEmitMinLength = config:GetAttribute("TEmitMinLength")
			v.TEmitMaxLength = config:GetAttribute("TEmitMaxLength")
			v.TrailLife = config:GetAttribute("TEmitTrailLife") or NumberRange.new(2)
			local particleFlipbookMode = Enum.ParticleFlipbookMode
			local tEmitFlipbookMode = config:GetAttribute("TEmitFlipbookMode")
			local oneShot = Enum.ParticleFlipbookMode.OneShot

			if tEmitFlipbookMode then
				local success, result = pcall(function()
					return particleFlipbookMode[tEmitFlipbookMode]
				end)

				if success then
					oneShot = result or oneShot
				end
			end

			v.TrailFlipbookMode = oneShot
			v.TrailFlipbookFramerate = config:GetAttribute("TEmitFlipbookFramerate") or NumberRange.new(30)
			v.TrailFlipbookStartRandom = config:GetAttribute("TEmitFlipbookStartRandom")
			v.TrailFlipbookReverse = config:GetAttribute("TEmitFlipbookReverse")
			v.TrailFlipbooks = instance:FindFirstChild("TrailFlipbooks")
			v.GraphBlender = instance:FindFirstChild("GraphBlender")
			v.Pool = config:GetAttribute("Pool")
			return v
		elseif instance:IsA("Attachment") then
			v.PartLife = config:GetAttribute("PartLife") or 0
			v.DirMode = config:GetAttribute("DirMode") or config:GetAttribute("VelocityVectored") and "Local" or "RigidLocal"
			v.VelocityVectored = v.DirMode == "Local"
			v.InvertMotion = config:GetAttribute("InvertMotion") or false
			v.RotMode = config:GetAttribute("RotMode") or "OverLife"
			v.RotOrder = config:GetAttribute("RotOrder") or "Global"
			v.Lifetime = config:GetAttribute("Lifetime") or NumberRange.new(1)
			v.Rate = config:GetAttribute("Rate") or 10
			local normalId = Enum.NormalId
			local emissionDirection = config:GetAttribute("EmissionDirection")
			local top = Enum.NormalId.Top

			if emissionDirection then
				local success, result = pcall(function()
					return normalId[emissionDirection]
				end)

				if success then
					top = result or top
				end
			end

			v.EmissionDirection = top
			v.ParticleData = {
				SpreadAngle = config:GetAttribute("SpreadAngle") or Vector2.new(0, 0),
				Acceleration = config:GetAttribute("Acceleration") or createVector(0, 0, 0),
				Drag = config:GetAttribute("Drag") or 0
			}
			v.Speed = config:GetAttribute("Speed")
			v.Timescale = config:GetAttribute("Timescale")
			v.RotX = config:GetAttribute("RotX") or NumberRange.new(0)
			v.RotY = config:GetAttribute("RotY") or NumberRange.new(0)
			v.RotZ = config:GetAttribute("RotZ") or NumberRange.new(0)
			v.RotXEven = config:GetAttribute("RotXEven") == true
			v.RotYEven = config:GetAttribute("RotYEven") == true
			v.RotZEven = config:GetAttribute("RotZEven") == true
			v.PosX = config:GetAttribute("PosX") or NumberRange.new(0)
			v.PosY = config:GetAttribute("PosY") or NumberRange.new(0)
			v.PosZ = config:GetAttribute("PosZ") or NumberRange.new(0)
			v.PosXEven = config:GetAttribute("PosXEven") == true
			v.PosYEven = config:GetAttribute("PosYEven") == true
			v.PosZEven = config:GetAttribute("PosZEven") == true
			v.PosMode = config:GetAttribute("PosMode") or "Local"
			v.DisplacementMode = config:GetAttribute("DisplacementMode") or "Global"
			v.RotSpeedX = config:GetAttribute("RotSpeedX")
			v.RotSpeedY = config:GetAttribute("RotSpeedY")
			v.RotSpeedZ = config:GetAttribute("RotSpeedZ")
			v.PosOffsetX = config:GetAttribute("PosOffsetX")
			v.PosOffsetY = config:GetAttribute("PosOffsetY")
			v.PosOffsetZ = config:GetAttribute("PosOffsetZ")
			v.Turbulence = config:GetAttribute("Turbulence")
			v.TurbulenceFrequency = config:GetAttribute("TurbulenceFrequency") or 1
			v.Orientation = config:GetAttribute("Orientation") or "None"
			v.ZOffset = config:GetAttribute("ZOffset") or 0
			v.AxisLinks = readAxisLinks(config)
			v.Pool = config:GetAttribute("Pool")
			return v
		else
			if instance:IsA("BasePart") and instance:GetAttribute("IsRocks") == true then
				return GetDataRig.readRocks(v, instance, config, safeEnum)
			end

			if instance:IsA("BasePart") and instance:GetAttribute("IsRope") == true then
				v.AxisLinks = readAxisLinks(config)
				return GetDataRig.readRope(v, instance, config, safeEnum)
			end

			if instance:IsA("BasePart") and instance:GetAttribute("IsCameraShake") == true then
				v.PartLife = 0
				v.Lifetime = config:GetAttribute("Lifetime") or NumberRange.new(0.5)
				v.Rate = config:GetAttribute("Rate") or 10
				v.ShakeAmplitude = config:GetAttribute("ShakeAmplitude")
				v.ShakeRotAmplitude = config:GetAttribute("ShakeRotAmplitude")
				v.ShakeFrequency = config:GetAttribute("ShakeFrequency") or 10
				v.ShakeFalloff = config:GetAttribute("ShakeFalloff") or 0
				v.Timescale = config:GetAttribute("Timescale")
				return v
			elseif instance:IsA("BasePart") and instance:GetAttribute("IsLightning") == true then
				v.PartLife = config:GetAttribute("PartLife") or 0
				v.Lifetime = config:GetAttribute("Lifetime") or NumberRange.new(1)
				v.Rate = config:GetAttribute("Rate") or 10
				v.TargetMode = config:GetAttribute("TargetMode") or "Directional"
				local target = instance:FindFirstChild("Target")
				v.Target = target and target:IsA("ObjectValue") and target.Value or nil
				v.Length = config:GetAttribute("Length") or NumberRange.new(20)
				v.GrowthSpeed = config:GetAttribute("GrowthSpeed") or 0
				v.SpreadAngle = config:GetAttribute("SpreadAngle") or Vector2.new(0, 0)
				local normalId = Enum.NormalId
				local emissionDirection = config:GetAttribute("EmissionDirection")
				local top = Enum.NormalId.Top

				if emissionDirection then
					local success, result = pcall(function()
						return normalId[emissionDirection]
					end)

					if success then
						top = result or top
					end
				end

				v.EmissionDirection = top

				local function asRange(value2, p2)
					if typeof(value2) == "NumberRange" then
						return value2
					end

					if typeof(value2) == "number" then
						return NumberRange.new(value2)
					end

					return p2
				end

				local segmentCount = config:GetAttribute("SegmentCount")
				local numberRange = NumberRange.new(12)

				if typeof(segmentCount) == "NumberRange" then
					numberRange = segmentCount
				elseif typeof(segmentCount) == "number" then
					numberRange = NumberRange.new(segmentCount)
				end

				v.SegmentCount = numberRange
				local amplitude = config:GetAttribute("Amplitude")
				local numberRange2 = NumberRange.new(0.15)

				if typeof(amplitude) == "NumberRange" then
					numberRange2 = amplitude
				elseif typeof(amplitude) == "number" then
					numberRange2 = NumberRange.new(amplitude)
				end

				v.Amplitude = numberRange2
				local amplitudeDecay = config:GetAttribute("AmplitudeDecay")
				local numberRange3 = NumberRange.new(0.5)

				if typeof(amplitudeDecay) == "NumberRange" then
					numberRange3 = amplitudeDecay
				elseif typeof(amplitudeDecay) == "number" then
					numberRange3 = NumberRange.new(amplitudeDecay)
				end

				v.AmplitudeDecay = numberRange3
				local jitterRate = config:GetAttribute("JitterRate")
				local numberRange4 = NumberRange.new(15)

				if typeof(jitterRate) == "NumberRange" then
					numberRange4 = jitterRate
				elseif typeof(jitterRate) == "number" then
					numberRange4 = NumberRange.new(jitterRate)
				end

				v.JitterRate = numberRange4
				local forkChance = config:GetAttribute("ForkChance")
				local numberRange5 = NumberRange.new(0)

				if typeof(forkChance) == "NumberRange" then
					numberRange5 = forkChance
				elseif typeof(forkChance) == "number" then
					numberRange5 = NumberRange.new(forkChance)
				end

				v.ForkChance = numberRange5
				local forkDepth = config:GetAttribute("ForkDepth")
				local numberRange6 = NumberRange.new(0)

				if typeof(forkDepth) == "NumberRange" then
					numberRange6 = forkDepth
				elseif typeof(forkDepth) == "number" then
					numberRange6 = NumberRange.new(forkDepth)
				end

				v.ForkDepth = numberRange6
				local forkLengthScale = config:GetAttribute("ForkLengthScale")
				local numberRange7 = NumberRange.new(0.4)

				if typeof(forkLengthScale) == "NumberRange" then
					numberRange7 = forkLengthScale
				elseif typeof(forkLengthScale) == "number" then
					numberRange7 = NumberRange.new(forkLengthScale)
				end

				v.ForkLengthScale = numberRange7
				local sag = config:GetAttribute("Sag")
				local numberRange8 = NumberRange.new(0)

				if typeof(sag) == "NumberRange" then
					numberRange8 = sag
				elseif typeof(sag) == "number" then
					numberRange8 = NumberRange.new(sag)
				end

				v.Sag = numberRange8
				local sagShape = config:GetAttribute("SagShape")
				local numberRange9 = NumberRange.new(1)

				if typeof(sagShape) == "NumberRange" then
					numberRange9 = sagShape
				elseif typeof(sagShape) == "number" then
					numberRange9 = NumberRange.new(sagShape)
				end

				v.SagShape = numberRange9
				local seekRadius = config:GetAttribute("SeekRadius")
				local numberRange10 = NumberRange.new(30)

				if typeof(seekRadius) == "NumberRange" then
					numberRange10 = seekRadius
				elseif typeof(seekRadius) == "number" then
					numberRange10 = NumberRange.new(seekRadius)
				end

				v.SeekRadius = numberRange10
				v.SeekRetarget = config:GetAttribute("SeekRetarget") == true
				v.SeekBias = config:GetAttribute("SeekBias") or 0
				v.RetargetSpeed = config:GetAttribute("RetargetSpeed") or 0
				v.Gradient = config:GetAttribute("Gradient")
				v.ShapeMode = config:GetAttribute("ShapeMode") or "Jitter"
				local scrollSpeed = config:GetAttribute("ScrollSpeed")
				local numberRange11 = NumberRange.new(1)

				if typeof(scrollSpeed) == "NumberRange" then
					numberRange11 = scrollSpeed
				elseif typeof(scrollSpeed) == "number" then
					numberRange11 = NumberRange.new(scrollSpeed)
				end

				v.ScrollSpeed = numberRange11
				local waves = config:GetAttribute("Waves")
				local numberRange12 = NumberRange.new(3)

				if typeof(waves) == "NumberRange" then
					numberRange12 = waves
				elseif typeof(waves) == "number" then
					numberRange12 = NumberRange.new(waves)
				end

				v.Waves = numberRange12
				v.UseShape = config:GetAttribute("UseShape") == true
				local particleEmitterShape = Enum.ParticleEmitterShape
				local shape = config:GetAttribute("Shape")
				local box = Enum.ParticleEmitterShape.Box

				if shape then
					local success, result = pcall(function()
						return particleEmitterShape[shape]
					end)

					if success then
						box = result or box
					end
				end

				v.Shape = box
				local particleEmitterShapeInOut = Enum.ParticleEmitterShapeInOut
				local shapeInOut = config:GetAttribute("ShapeInOut")
				local outward = Enum.ParticleEmitterShapeInOut.Outward

				if shapeInOut then
					local success, result = pcall(function()
						return particleEmitterShapeInOut[shapeInOut]
					end)

					if success then
						outward = result or outward
					end
				end

				v.ShapeInOut = outward
				v.ShapePartial = config:GetAttribute("ShapePartial") or 0
				v.ShapeDirection = config:GetAttribute("ShapeDirection") or "Emitter"
				local shapePart = instance:FindFirstChild("ShapePart")
				v.ShapePart = shapePart and shapePart:IsA("ObjectValue") and shapePart.Value or nil
				v.PosX = config:GetAttribute("PosX") or NumberRange.new(0)
				v.PosY = config:GetAttribute("PosY") or NumberRange.new(0)
				v.PosZ = config:GetAttribute("PosZ") or NumberRange.new(0)
				v.PosXEven = config:GetAttribute("PosXEven") == true
				v.PosYEven = config:GetAttribute("PosYEven") == true
				v.PosZEven = config:GetAttribute("PosZEven") == true
				v.PosMode = config:GetAttribute("PosMode") or "Local"
				v.RotX = config:GetAttribute("RotX") or NumberRange.new(0)
				v.RotY = config:GetAttribute("RotY") or NumberRange.new(0)
				v.RotZ = config:GetAttribute("RotZ") or NumberRange.new(0)
				v.RotXEven = config:GetAttribute("RotXEven") == true
				v.RotYEven = config:GetAttribute("RotYEven") == true
				v.RotZEven = config:GetAttribute("RotZEven") == true
				v.RotOrder = config:GetAttribute("RotOrder") or "Global"
				v.DirMode = config:GetAttribute("DirMode") or "RigidLocal"
				v.AxisLinks = readAxisLinks(config)
				v.Speed = config:GetAttribute("Speed")
				v.Acceleration = config:GetAttribute("Acceleration") or createVector(0, 0, 0)
				v.Drag = config:GetAttribute("Drag") or 0
				v.PosOffsetX = config:GetAttribute("PosOffsetX")
				v.PosOffsetY = config:GetAttribute("PosOffsetY")
				v.PosOffsetZ = config:GetAttribute("PosOffsetZ")
				v.DisplacementMode = config:GetAttribute("DisplacementMode") or "Global"
				v.Turbulence = config:GetAttribute("Turbulence")
				v.TurbulenceFrequency = config:GetAttribute("TurbulenceFrequency") or 1
				v.Color = config:GetAttribute("Color")
				v.Brightness = config:GetAttribute("Brightness")
				v.Transparency = config:GetAttribute("Transparency")
				v.Thickness = config:GetAttribute("Thickness")
				v.Timescale = config:GetAttribute("Timescale")
				v.Pool = config:GetAttribute("Pool")
				return v
			else
				v.PartLife = config:GetAttribute("PartLife") or 0

				if instance:IsA("Beam") then
					v.GraphBlender = instance:FindFirstChild("GraphBlender")
					v.Lifetime = config:GetAttribute("BeamLifetime") or NumberRange.new(1)
					v.Rate = config:GetAttribute("Rate") or 10
					v.BeamFlipbooks = instance:FindFirstChild("BeamFlipbooks")
					local particleFlipbookMode = Enum.ParticleFlipbookMode
					local beamFlipbookMode = config:GetAttribute("BeamFlipbookMode")
					local flipbookMode

					if beamFlipbookMode then
						local success, result = pcall(function()
							return particleFlipbookMode[beamFlipbookMode]
						end)
						flipbookMode = success and result or nil
					end

					v.FlipbookParticle = {
						FlipbookMode = flipbookMode,
						FlipbookFramerate = config:GetAttribute("BeamFlipbookFramerate") or nil,
						FlipbookStartRandom = config:GetAttribute("BeamFlipbookStartRandom") or false,
						FlipbookReverse = config:GetAttribute("BeamFlipbookReverse") or false
					}

					if v.BeamFlipbooks then
						v.CachedBeamTextures = Flipbook.GetSortedBeamTextures(v.BeamFlipbooks)
					end

					v.FaceCamera = config:GetAttribute("FaceCamera")
					v.ZOffset = config:GetAttribute("ZOffset")
					local textureMode = Enum.TextureMode
					local beamTextureMode = config:GetAttribute("BeamTextureMode")
					local textureMode2

					if beamTextureMode then
						local success, result = pcall(function()
							return textureMode[beamTextureMode]
						end)
						textureMode2 = success and result or nil
					end

					v.TextureMode = textureMode2
					v.BeamProps = {
						Brightness = config:GetAttribute("BeamBrightness"),
						CurveSize0 = config:GetAttribute("CurveSize0"),
						CurveSize1 = config:GetAttribute("CurveSize1"),
						Width0 = config:GetAttribute("Width0"),
						Width1 = config:GetAttribute("Width1"),
						LightEmission = config:GetAttribute("LightEmission"),
						LightInfluence = config:GetAttribute("BeamLightInfluence"),
						Segments = config:GetAttribute("Segments"),
						TextureLength = config:GetAttribute("TextureLength"),
						TextureSpeed = config:GetAttribute("TextureSpeed")
					}
					v.BeamTimescale = config:GetAttribute("BeamTimescale")
					v.Pool = config:GetAttribute("Pool")
					return v
				else
					v.MeshFlipbooks = instance:FindFirstChild("MeshFlipbooks")

					if v.MeshFlipbooks then
						v.CachedMeshTextures = Flipbook.GetSortedTextures(v.MeshFlipbooks)
					end

					v.DirMode = config:GetAttribute("DirMode") or config:GetAttribute("VelocityVectored") and "Local" or "RigidLocal"
					v.VelocityVectored = v.DirMode == "Local"
					v.InvertMotion = config:GetAttribute("InvertMotion") or false
					v.RotMode = config:GetAttribute("RotMode") or "OverLife"
					v.RotOrder = config:GetAttribute("RotOrder") or "Global"
					v.Lifetime = config:GetAttribute("Lifetime") or NumberRange.new(1)
					v.Rate = config:GetAttribute("Rate") or 10
					v.AccelerationTowardsInstance = config:GetAttribute("AccelerationTowardsInstance") or false
					v.AccelStrength = config:GetAttribute("AccelStrength") or NumberSequence.new(0)
					local accelTarget = instance:FindFirstChild("AccelTarget")
					local accelTarget2 = accelTarget and accelTarget:IsA("ObjectValue") and accelTarget.Value or nil

					if accelTarget2 and (accelTarget2:IsA("BasePart") or accelTarget2:IsA("Attachment") or accelTarget2:IsA("Camera") or accelTarget2:IsA("Model") or accelTarget2:IsA("Bone")) then
						v.AccelTarget = accelTarget2
					else
						v.AccelTarget = nil
					end

					local shapePart = instance:FindFirstChild("ShapePart")
					local shapePart2 = shapePart and shapePart:IsA("ObjectValue") and shapePart.Value or nil

					if shapePart2 and shapePart2:IsA("BasePart") and shapePart2.Parent then
						v.ShapePart = shapePart2
					else
						v.ShapePart = nil
					end

					local particleEmitterShape = Enum.ParticleEmitterShape
					local shape = config:GetAttribute("Shape")
					local box = Enum.ParticleEmitterShape.Box

					if shape then
						local success, result = pcall(function()
							return particleEmitterShape[shape]
						end)

						if success then
							box = result or box
						end
					end

					v.Shape = box
					local particleEmitterShapeInOut = Enum.ParticleEmitterShapeInOut
					local shapeInOut = config:GetAttribute("ShapeInOut")
					local outward = Enum.ParticleEmitterShapeInOut.Outward

					if shapeInOut then
						local success, result = pcall(function()
							return particleEmitterShapeInOut[shapeInOut]
						end)

						if success then
							outward = result or outward
						end
					end

					v.ShapeInOut = outward
					local normalId = Enum.NormalId
					local emissionDirection = config:GetAttribute("EmissionDirection")
					local top = Enum.NormalId.Top

					if emissionDirection then
						local success, result = pcall(function()
							return normalId[emissionDirection]
						end)

						if success then
							top = result or top
						end
					end

					v.EmissionDirection = top
					v.UseShape = config:GetAttribute("UseShape") == true
					v.LookAtInitially = config:GetAttribute("LookAtInitially") == true
					local particleData = {
						Shape = v.Shape,
						ShapeInOut = v.ShapeInOut,
						ShapePartial = math.clamp(config:GetAttribute("ShapePartial") or 0, 0, 1),
						UseShape = v.UseShape,
						LookAtInitially = v.LookAtInitially,
						EmissionDirection = v.EmissionDirection,
						SpreadAngle = config:GetAttribute("SpreadAngle") or Vector2.new(0, 0),
						Acceleration = config:GetAttribute("Acceleration") or createVector(0, 0, 0),
						Drag = config:GetAttribute("Drag") or 0,
						FlipbookMode = 0,
						FlipbookFramerate = 0,
						FlipbookStartRandom = 0,
						FlipbookReverse = 0
					}
					local particleFlipbookMode = Enum.ParticleFlipbookMode
					local flipbookMode = config:GetAttribute("FlipbookMode")
					local flipbookMode2

					if flipbookMode then
						local success, result = pcall(function()
							return particleFlipbookMode[flipbookMode]
						end)
						flipbookMode2 = success and result or nil
					end

					particleData.FlipbookMode = flipbookMode2
					particleData.FlipbookFramerate = config:GetAttribute("FlipbookFramerate") or nil
					particleData.FlipbookStartRandom = config:GetAttribute("FlipbookStartRandom") or false
					particleData.FlipbookReverse = config:GetAttribute("FlipbookReverse") or false
					v.ParticleData = particleData
					v.Transparency = config:GetAttribute("Transparency")
					v.Color = config:GetAttribute("Color")
					v.Speed = config:GetAttribute("Speed")
					v.Brightness = config:GetAttribute("Brightness")
					v.Timescale = config:GetAttribute("Timescale")
					v.AxisLinks = readAxisLinks(config)
					v.SizeX = config:GetAttribute("SizeX")
					v.SizeY = config:GetAttribute("SizeY")
					v.SizeZ = config:GetAttribute("SizeZ")
					v.RotX = config:GetAttribute("RotX") or NumberRange.new(0)
					v.RotY = config:GetAttribute("RotY") or NumberRange.new(0)
					v.RotZ = config:GetAttribute("RotZ") or NumberRange.new(0)
					v.RotXEven = config:GetAttribute("RotXEven") == true
					v.RotYEven = config:GetAttribute("RotYEven") == true
					v.RotZEven = config:GetAttribute("RotZEven") == true
					v.PosX = config:GetAttribute("PosX") or NumberRange.new(0)
					v.PosY = config:GetAttribute("PosY") or NumberRange.new(0)
					v.PosZ = config:GetAttribute("PosZ") or NumberRange.new(0)
					v.PosXEven = config:GetAttribute("PosXEven") == true
					v.PosYEven = config:GetAttribute("PosYEven") == true
					v.PosZEven = config:GetAttribute("PosZEven") == true
					v.PosMode = config:GetAttribute("PosMode") or "Local"
					v.DisplacementMode = config:GetAttribute("DisplacementMode") or "Global"
					v.RotSpeedX = config:GetAttribute("RotSpeedX")
					v.RotSpeedY = config:GetAttribute("RotSpeedY")
					v.RotSpeedZ = config:GetAttribute("RotSpeedZ")
					v.PosOffsetX = config:GetAttribute("PosOffsetX")
					v.PosOffsetY = config:GetAttribute("PosOffsetY")
					v.PosOffsetZ = config:GetAttribute("PosOffsetZ")
					v.Turbulence = config:GetAttribute("Turbulence")
					v.TurbulenceFrequency = config:GetAttribute("TurbulenceFrequency") or 1
					v.Orientation = config:GetAttribute("Orientation") or "None"
					v.ZOffset = config:GetAttribute("ZOffset") or 0
					v.Pool = config:GetAttribute("Pool")
					return v
				end
			end
		end
	end
end