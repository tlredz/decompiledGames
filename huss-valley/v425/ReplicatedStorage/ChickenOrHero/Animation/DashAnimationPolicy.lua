local createVector = vector.create
local v = {
	DashLeft = true,
	DashRight = true,
	DashBack = true
}
local DashAnimationPolicy = {
	isName = function(p)
		return v[p] == true
	end
}

local function unit(data)
	if typeof(data) ~= "Vector3" or data.X ~= data.X or data.Y ~= data.Y or data.Z ~= data.Z or math.abs(data.X) > 1000000 or math.abs(data.Y) > 1000000 or math.abs(data.Z) > 1000000 then
		return
	end

	local vector2 = Vector3.new(data.X, 0, data.Z)

	if vector2.Magnitude < 0.001 then
		return
	else
		return vector2.Unit
	end
end

function DashAnimationPolicy.select(p, p2)
	local vector2 = unit(p)
	local vector3 = unit(p2)

	if not (vector2 and vector3) then
		return
	end

	local dot = vector2:Dot(vector3)

	if dot > 0.0001 then
		return
	end

	if dot <= -0.7071067811865476 then
		return "DashBack", -vector3
	end

	if vector2:Cross(vector3).Y > 0 then
		return "DashLeft", vector3:Cross(createVector(0, 1, 0))
	end

	return "DashRight", (createVector(0, 1, 0)):Cross(vector3)
end

function DashAnimationPolicy.timing(p, p2, data)
	if p <= 0 then
		return
	end

	local v2 = math.clamp(
		p / math.max(0.05, p2.Duration + math.min(p2.RecoveryDuration or 0, data.RecoveryTail)),
		data.MinPlaybackRate,
		data.MaxPlaybackRate
	)
	return p / v2, v2
end

function DashAnimationPolicy.yaw(vector2, p)
	return (math.atan2(vector2:Cross(p).Y, (vector2:Dot(p))))
end

return DashAnimationPolicy