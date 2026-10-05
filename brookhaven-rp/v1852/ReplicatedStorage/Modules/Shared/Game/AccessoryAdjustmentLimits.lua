local AccessoryAdjustmentLimits = {
	POSITION_MIN = -0.2,
	POSITION_MAX = 0.2,
	ROTATION_MIN = -30,
	ROTATION_MAX = 30,
	SCALE_MIN = 0.8,
	SCALE_MAX = 1.2
}

function AccessoryAdjustmentLimits.clampPosition(data)
	local POSITION_MIN = AccessoryAdjustmentLimits.POSITION_MIN
	local POSITION_MAX = AccessoryAdjustmentLimits.POSITION_MAX
	return {
		X = math.clamp(data.X, POSITION_MIN, POSITION_MAX),
		Y = math.clamp(data.Y, POSITION_MIN, POSITION_MAX),
		Z = math.clamp(data.Z, POSITION_MIN, POSITION_MAX)
	}
end

function AccessoryAdjustmentLimits.clampRotation(data)
	local ROTATION_MIN = AccessoryAdjustmentLimits.ROTATION_MIN
	local ROTATION_MAX = AccessoryAdjustmentLimits.ROTATION_MAX
	return {
		X = math.clamp(data.X, ROTATION_MIN, ROTATION_MAX),
		Y = math.clamp(data.Y, ROTATION_MIN, ROTATION_MAX),
		Z = math.clamp(data.Z, ROTATION_MIN, ROTATION_MAX)
	}
end

function AccessoryAdjustmentLimits.clampScale(data)
	local SCALE_MIN = AccessoryAdjustmentLimits.SCALE_MIN
	local SCALE_MAX = AccessoryAdjustmentLimits.SCALE_MAX
	return {
		X = math.clamp(data.X, SCALE_MIN, SCALE_MAX),
		Y = math.clamp(data.Y, SCALE_MIN, SCALE_MAX),
		Z = math.clamp(data.Z, SCALE_MIN, SCALE_MAX)
	}
end

return AccessoryAdjustmentLimits