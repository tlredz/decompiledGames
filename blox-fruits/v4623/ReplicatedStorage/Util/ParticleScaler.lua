local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local function scaleNumberSequence(keypoints, p)
	if typeof(keypoints) ~= "table" then
		keypoints = keypoints.Keypoints
	end

	local numberSequenceKeypoints = {}

	for _, keypoint in pairs(keypoints) do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p, keypoint.Envelope)
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local function preScaleParticle(instance, p, p2)
	instance.Size = scaleNumberSequence(instance.Size, p)
	local acceleration = instance.Acceleration
	instance.Acceleration = Vector3.new(acceleration.X * p, acceleration.Y * p, acceleration.Z * p)
	local speed = instance.Speed
	instance.Speed = NumberRange.new(speed.Min * p, speed.Max * p)
	local emitCount = instance:GetAttribute("EmitCount")

	if emitCount and not p2 then
		instance:SetAttribute("EmitCount", emitCount * p)
	end
end

return {
	NumberRange = scaleNumberRange,
	Acceleration = scaleAcceleration,
	NumberSequence = scaleNumberSequence,
	Particle = preScaleParticle
}