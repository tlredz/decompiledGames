local createVector = vector.create

local function asRange(value, p)
	if typeof(value) == "NumberRange" then
		return value
	end

	if typeof(value) == "number" then
		return NumberRange.new(value)
	end

	return p
end

local GetDataRig = {}

function GetDataRig:readRocks(_, instance, callback)
	self.PartLife = instance:GetAttribute("PartLife") or 0
	self.Lifetime = instance:GetAttribute("Lifetime") or NumberRange.new(3)
	self.Rate = instance:GetAttribute("Rate") or 2
	self.BurstMode = instance:GetAttribute("BurstMode") or "Directional"
	self.EmissionDirection = callback(Enum.NormalId, instance:GetAttribute("EmissionDirection"), Enum.NormalId.Top)
	self.SpreadAngle = instance:GetAttribute("SpreadAngle") or Vector2.new(25, 25)
	self.Speed = instance:GetAttribute("Speed")
	local chunkCount = instance:GetAttribute("ChunkCount")
	local numberRange = NumberRange.new(6, 10)

	if typeof(chunkCount) == "NumberRange" then
		numberRange = chunkCount
	elseif typeof(chunkCount) == "number" then
		numberRange = NumberRange.new(chunkCount)
	end

	self.ChunkCount = numberRange
	local chunkScale = instance:GetAttribute("ChunkScale")
	local numberRange2 = NumberRange.new(0.5, 1.5)

	if typeof(chunkScale) == "NumberRange" then
		numberRange2 = chunkScale
	elseif typeof(chunkScale) == "number" then
		numberRange2 = NumberRange.new(chunkScale)
	end

	self.ChunkScale = numberRange2
	local posX = instance:GetAttribute("PosX")
	local numberRange3 = NumberRange.new(0)

	if typeof(posX) == "NumberRange" then
		numberRange3 = posX
	elseif typeof(posX) == "number" then
		numberRange3 = NumberRange.new(posX)
	end

	self.PosX = numberRange3
	local posY = instance:GetAttribute("PosY")
	local numberRange4 = NumberRange.new(0)

	if typeof(posY) == "NumberRange" then
		numberRange4 = posY
	elseif typeof(posY) == "number" then
		numberRange4 = NumberRange.new(posY)
	end

	self.PosY = numberRange4
	local posZ = instance:GetAttribute("PosZ")
	local numberRange5 = NumberRange.new(0)

	if typeof(posZ) == "NumberRange" then
		numberRange5 = posZ
	elseif typeof(posZ) == "number" then
		numberRange5 = NumberRange.new(posZ)
	end

	self.PosZ = numberRange5
	self.PosMode = instance:GetAttribute("PosMode") or "Local"
	self.PosXEven = instance:GetAttribute("PosXEven") == true
	self.PosYEven = instance:GetAttribute("PosYEven") == true
	self.PosZEven = instance:GetAttribute("PosZEven") == true
	self.Gravity = instance:GetAttribute("Gravity") or 196.2
	local bounciness = instance:GetAttribute("Bounciness")
	local numberRange6 = NumberRange.new(0.3, 0.5)

	if typeof(bounciness) == "NumberRange" then
		numberRange6 = bounciness
	elseif typeof(bounciness) == "number" then
		numberRange6 = NumberRange.new(bounciness)
	end

	self.Bounciness = numberRange6
	self.Friction = instance:GetAttribute("Friction") or 0.3
	local tumbleSpeed = instance:GetAttribute("TumbleSpeed")
	local numberRange7 = NumberRange.new(90, 360)

	if typeof(tumbleSpeed) == "NumberRange" then
		numberRange7 = tumbleSpeed
	elseif typeof(tumbleSpeed) == "number" then
		numberRange7 = NumberRange.new(tumbleSpeed)
	end

	self.TumbleSpeed = numberRange7
	self.SinkOut = instance:GetAttribute("SinkOut") ~= false
	self.InheritFloor = instance:GetAttribute("InheritFloor") == true
	self.Scale = instance:GetAttribute("Scale")
	self.Color = instance:GetAttribute("Color")
	self.Brightness = instance:GetAttribute("Brightness")
	self.Transparency = instance:GetAttribute("Transparency")
	self.Timescale = instance:GetAttribute("Timescale")
	self.Pool = instance:GetAttribute("Pool")
	return self
end

function GetDataRig:readRope(instance, instance2, callback)
	self.PartLife = instance2:GetAttribute("PartLife") or 0
	self.Lifetime = instance2:GetAttribute("Lifetime") or NumberRange.new(2)
	self.Rate = instance2:GetAttribute("Rate") or 1
	local segmentCount = instance2:GetAttribute("SegmentCount")
	local numberRange = NumberRange.new(12)

	if typeof(segmentCount) == "NumberRange" then
		numberRange = segmentCount
	elseif typeof(segmentCount) == "number" then
		numberRange = NumberRange.new(segmentCount)
	end

	self.SegmentCount = numberRange
	self.PinMode = instance2:GetAttribute("PinMode") or "BothEnds"
	local target = instance:FindFirstChild("Target")
	self.Target = target and target:IsA("ObjectValue") and target.Value or nil
	local ropeLength = instance2:GetAttribute("RopeLength")
	local numberRange2 = NumberRange.new(0)

	if typeof(ropeLength) == "NumberRange" then
		numberRange2 = ropeLength
	elseif typeof(ropeLength) == "number" then
		numberRange2 = NumberRange.new(ropeLength)
	end

	self.RopeLength = numberRange2
	self.Slack = instance2:GetAttribute("Slack") or 1.2
	self.Stiffness = instance2:GetAttribute("Stiffness") or 4
	self.Damping = instance2:GetAttribute("Damping") or 0.03
	self.Gravity = instance2:GetAttribute("Gravity") or createVector(0, -40, 0)
	local windAmplitude = instance2:GetAttribute("WindAmplitude")
	local numberRange3 = NumberRange.new(0)

	if typeof(windAmplitude) == "NumberRange" then
		numberRange3 = windAmplitude
	elseif typeof(windAmplitude) == "number" then
		numberRange3 = NumberRange.new(windAmplitude)
	end

	self.WindAmplitude = numberRange3
	self.WindFrequency = instance2:GetAttribute("WindFrequency") or 2
	self.SpawnTarget = instance2:GetAttribute("SpawnTarget") or "Start"
	local posX = instance2:GetAttribute("PosX")
	local numberRange4 = NumberRange.new(0)

	if typeof(posX) == "NumberRange" then
		numberRange4 = posX
	elseif typeof(posX) == "number" then
		numberRange4 = NumberRange.new(posX)
	end

	self.PosX = numberRange4
	local posY = instance2:GetAttribute("PosY")
	local numberRange5 = NumberRange.new(0)

	if typeof(posY) == "NumberRange" then
		numberRange5 = posY
	elseif typeof(posY) == "number" then
		numberRange5 = NumberRange.new(posY)
	end

	self.PosY = numberRange5
	local posZ = instance2:GetAttribute("PosZ")
	local numberRange6 = NumberRange.new(0)

	if typeof(posZ) == "NumberRange" then
		numberRange6 = posZ
	elseif typeof(posZ) == "number" then
		numberRange6 = NumberRange.new(posZ)
	end

	self.PosZ = numberRange6
	self.PosXEven = instance2:GetAttribute("PosXEven") == true
	self.PosYEven = instance2:GetAttribute("PosYEven") == true
	self.PosZEven = instance2:GetAttribute("PosZEven") == true
	self.PosMode = instance2:GetAttribute("PosMode") or "Local"
	local rotX = instance2:GetAttribute("RotX")
	local numberRange7 = NumberRange.new(0)

	if typeof(rotX) == "NumberRange" then
		numberRange7 = rotX
	elseif typeof(rotX) == "number" then
		numberRange7 = NumberRange.new(rotX)
	end

	self.RotX = numberRange7
	local rotY = instance2:GetAttribute("RotY")
	local numberRange8 = NumberRange.new(0)

	if typeof(rotY) == "NumberRange" then
		numberRange8 = rotY
	elseif typeof(rotY) == "number" then
		numberRange8 = NumberRange.new(rotY)
	end

	self.RotY = numberRange8
	local rotZ = instance2:GetAttribute("RotZ")
	local numberRange9 = NumberRange.new(0)

	if typeof(rotZ) == "NumberRange" then
		numberRange9 = rotZ
	elseif typeof(rotZ) == "number" then
		numberRange9 = NumberRange.new(rotZ)
	end

	self.RotZ = numberRange9
	self.RotXEven = instance2:GetAttribute("RotXEven") == true
	self.RotYEven = instance2:GetAttribute("RotYEven") == true
	self.RotZEven = instance2:GetAttribute("RotZEven") == true
	self.RotOrder = instance2:GetAttribute("RotOrder") or "Global"
	self.GrowIn = instance2:GetAttribute("GrowIn") or 0
	self.DeathMode = instance2:GetAttribute("DeathMode") or "None"
	self.DeathWindow = instance2:GetAttribute("DeathWindow") or 0.2
	self.BendStiffness = instance2:GetAttribute("BendStiffness") or 0
	self.ThicknessProfile = instance2:GetAttribute("ThicknessProfile")
	self.MotionDirection = callback(Enum.NormalId, instance2:GetAttribute("MotionDirection"), Enum.NormalId.Front)
	self.MotionTarget = instance2:GetAttribute("MotionTarget") or "Start"
	self.Speed = instance2:GetAttribute("Speed")
	self.Acceleration = instance2:GetAttribute("Acceleration") or createVector(0, 0, 0)
	self.Drag = instance2:GetAttribute("Drag") or 0
	self.PosOffsetX = instance2:GetAttribute("PosOffsetX")
	self.PosOffsetY = instance2:GetAttribute("PosOffsetY")
	self.PosOffsetZ = instance2:GetAttribute("PosOffsetZ")
	self.Turbulence = instance2:GetAttribute("Turbulence")
	self.TurbulenceFrequency = instance2:GetAttribute("TurbulenceFrequency") or 1
	self.DisplacementMode = instance2:GetAttribute("DisplacementMode") or "Global"
	local launchSpeed = instance2:GetAttribute("LaunchSpeed")
	local numberRange10 = NumberRange.new(40)

	if typeof(launchSpeed) == "NumberRange" then
		numberRange10 = launchSpeed
	elseif typeof(launchSpeed) == "number" then
		numberRange10 = NumberRange.new(launchSpeed)
	end

	self.LaunchSpeed = numberRange10
	self.EmissionDirection = callback(Enum.NormalId, instance2:GetAttribute("EmissionDirection"), Enum.NormalId.Front)
	self.SpreadAngle = instance2:GetAttribute("SpreadAngle") or Vector2.new(0, 0)
	self.Color = instance2:GetAttribute("Color")
	self.Brightness = instance2:GetAttribute("Brightness")
	self.Transparency = instance2:GetAttribute("Transparency")
	self.Thickness = instance2:GetAttribute("Thickness")
	self.Timescale = instance2:GetAttribute("Timescale")
	self.Pool = instance2:GetAttribute("Pool")
	return self
end

return GetDataRig