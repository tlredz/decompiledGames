local createVector = vector.create
local AssetWanderArea = require(script.Parent.AssetWanderArea)
local AssetWanderMotion = {
	YawFromFlatDirection = function(vector2: Vector3)
		return (math.atan2(-vector2.X, -vector2.Z))
	end,
	ShortestYawDelta = function(p: number, p2: number)
		local v = p2 - p
		return (math.atan2(math.sin(v), (math.cos(v))))
	end
}

function AssetWanderMotion.StepYawToward(p: number, p2: number, p3: number)
	local shortestYawDelta = AssetWanderMotion.ShortestYawDelta(p, p2)
	local v = p3 * 3.839724354387525
	local v2 = math.clamp(shortestYawDelta, -v, v)
	return p + v2, v2
end

function AssetWanderMotion.StepMoveToward(p: number, cframe: CFrame, vector2: Vector3, p2: number)
	local position = cframe.Position
	local v = vector2 - position
	local vector3 = Vector3.new(v.X, 0, v.Z)
	local magnitude = vector3.Magnitude

	if magnitude <= 0 then
		return cframe, false, 0
	end

	local v2 = math.min(magnitude, p2 * p)
	local unit = vector3.Unit
	local lookVector = cframe.LookVector
	local vector4 = Vector3.new(lookVector.X, 0, lookVector.Z)
	local v3

	if vector4.Magnitude > 0 then
		v3 = vector4.Unit
	else
		v3 = unit
	end

	local yawFromFlatDirection = AssetWanderMotion.YawFromFlatDirection(v3)
	local yawFromFlatDirection2 = AssetWanderMotion.YawFromFlatDirection(unit)
	local v4, v5 = AssetWanderMotion.StepYawToward(yawFromFlatDirection, yawFromFlatDirection2, p)
	local v6 = math.clamp(
		(math.cos((math.abs((AssetWanderMotion.ShortestYawDelta(v4, yawFromFlatDirection2))))) - 0.2) / 0.8,
		0,
		1
	)
	local v7 = position + unit * v2 * v6
	return CFrame.new(v7) * CFrame.Angles(0, v4, 0), v6 > 0 or math.abs(v5) > 0.008726646259971648, p2 * v6
end

function AssetWanderMotion.FaceOwnerCFrame(cframe: CFrame, vector2: Vector3, p: number, flag: boolean?)
	local position = cframe.Position
	local vector3 = Vector3.new(vector2.X - position.X, 0, vector2.Z - position.Z)

	if vector3.Magnitude <= 0 then
		return cframe
	end

	local lookVector = cframe.LookVector
	local vector4 = Vector3.new(lookVector.X, 0, lookVector.Z)
	assert(vector4.Magnitude > 0, "Asset wander CFrame must have a horizontal facing direction")
	local yawFromFlatDirection = AssetWanderMotion.YawFromFlatDirection(vector4.Unit)
	local yawFromFlatDirection2 = AssetWanderMotion.YawFromFlatDirection(vector3.Unit)

	if flag ~= true then
		yawFromFlatDirection2 = AssetWanderMotion.StepYawToward(yawFromFlatDirection, yawFromFlatDirection2, p)
	end

	return CFrame.new(position) * CFrame.Angles(0, yawFromFlatDirection2, 0)
end

function AssetWanderMotion.StepFollowOwner(p, p2: number, cframe: CFrame, vector2: Vector3, vector3: Vector3, p3: number, p4: number)
	local pointNearOwner = AssetWanderArea.PointNearOwner(p, vector2, vector3)
	local v, v2, v3 = AssetWanderMotion.StepMoveToward(p2, cframe, pointNearOwner, p3)

	if Vector3.new(pointNearOwner.X - v.Position.X, 0, pointNearOwner.Z - v.Position.Z).Magnitude <= p4 then
		v = AssetWanderMotion.FaceOwnerCFrame(v, vector2, p2)
	end

	return v, v2, v3
end

function AssetWanderMotion.OwnerMoveVector(p: number, vector2: Vector3?, vector3: Vector3?)
	if vector2 == nil then
		return createVector(0, 0, 0), nil
	end

	if vector3 == nil or p <= 0 then
		return createVector(0, 0, 0), vector2
	end

	local v = vector2 - vector3
	return Vector3.new(v.X, 0, v.Z) / p, vector2
end

function AssetWanderMotion.OrbitGreetingCFrame(p, p2: number, cframe: CFrame, vector2: Vector3, vector3: Vector3, p3: number, p4: number, max: number)
	local DISTANCE_THRESHOLD = 0
	local position = cframe.Position
	local vector4 = Vector3.new(position.X - vector2.X, 0, position.Z - vector2.Z)
	local unit

	if vector4.Magnitude == 0 then
		local lookVector = p.CFrame.LookVector
		local vector5 = Vector3.new(lookVector.X, 0, lookVector.Z)
		assert(vector5.Magnitude > DISTANCE_THRESHOLD, "Asset area must provide a horizontal orbit greeting direction")
		unit = vector5.Unit
	else
		local unit2 = vector4.Unit
		unit = (Vector3.new(-unit2.Z, 0, unit2.X) + unit2 * math.clamp((p3 - vector4.Magnitude) / p3, -max, max)).Unit
	end

	local v = unit * p4 + vector3
	local vector5 = Vector3.new(v.X, 0, v.Z)
	local magnitude = v.Magnitude

	if vector5.Magnitude <= DISTANCE_THRESHOLD then
		return cframe, false, 0
	end

	local clampedPointToward = AssetWanderArea.ClampedPointToward(p, position + v * p2)
	local vector6 = Vector3.new(clampedPointToward.X - position.X, 0, clampedPointToward.Z - position.Z)

	if vector6.Magnitude <= DISTANCE_THRESHOLD then
		return cframe, false, 0
	end

	local yawFromFlatDirection = AssetWanderMotion.YawFromFlatDirection(vector6.Unit)
	return CFrame.new(clampedPointToward) * CFrame.Angles(0, yawFromFlatDirection, 0), true, magnitude
end

return AssetWanderMotion