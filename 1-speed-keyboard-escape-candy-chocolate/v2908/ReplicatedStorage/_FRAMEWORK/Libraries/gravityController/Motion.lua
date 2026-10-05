local createVector = vector.create
local Basis = require(script.Parent.Basis)
require(script.Parent.Types)

-- equivalent calls inferred from this helper; original call sites unknown
local function slopeSpeed(vector2: Vector3, vector3: Vector3, normal: Vector3, p)
	local dot = normal:Dot(vector3)

	if p.minGroundDot < dot then
		return -vector2:Dot(normal) / dot
	end

	return 0
end

local function surfaceGap(p, vector2: Vector3, p2: number, p3)
	local dot = p.normal:Dot(vector2)

	if p3.minGroundDot < dot then
		p2 /= dot
	end

	return (math.max(p.distance - p2, 0))
end

local Motion = {}

function Motion.blendUp(vector2: Vector3, vector3: Vector3, p: number)
	local currentCamera = workspace.CurrentCamera
	local v = not currentCamera and createVector(-0, -0, -1) or currentCamera.CFrame.LookVector
	local planarDirection = Basis.resolvePlanarDirection({ v }, vector2)
	local rotationBetween = Basis.rotationBetween(vector2, vector3, planarDirection)
	return (CFrame.new():Lerp(rotationBetween, p) * vector2).Unit
end

function Motion.resolveMoveBasis(vector2: Vector3, vector3: Vector3, vector4: Vector3)
	local currentCamera = workspace.CurrentCamera
	local cFrame

	if currentCamera then
		cFrame = currentCamera.CFrame
	else
		cFrame = CFrame.identity
	end

	local lookVector = cFrame.LookVector
	local v = { lookVector, cFrame.UpVector * -math.sign((lookVector:Dot(vector3))), vector4 }
	local v2 = { Basis.resolvePlanarDirection(v, vector3), vector4 }
	local planarDirection = Basis.resolvePlanarDirection(v2, vector2)
	return planarDirection, planarDirection:Cross(vector2).Unit
end

function Motion.turnToward(vector2: Vector3, vector3: Vector3, vector4: Vector3, p: number)
	local rotationBetween = Basis.rotationBetween(vector2, vector3, vector4)
	return (CFrame.new():Lerp(rotationBetween, p) * vector2).Unit
end

function Motion.orientation(vector2: Vector3, vector3: Vector3, vector4: Vector3)
	return CFrame.fromMatrix(vector2, vector3:Cross(vector4).Unit, vector4, -vector3)
end

function Motion.computeVelocity(vector2: Vector3, vector3: Vector3, vector4: Vector3, data, p: number, p2, flag: boolean, flag2: boolean, flag3: boolean, p3: number, data2)
	local dot = vector2:Dot(vector3)
	local v = vector2 - vector3 * dot
	local v2

	if flag then
		v2 = data2.groundResponsiveness
	else
		v2 = data2.airResponsiveness
	end

	local lerped = v:Lerp(vector4, (math.clamp(v2 * p3, 0, 1)))
	local magnitude = lerped.Magnitude

	if data2.maxHorizontalSpeed < magnitude then
		lerped *= data2.maxHorizontalSpeed / magnitude
	end

	local v3

	if flag and not flag2 then
		local v4 = slopeSpeed(lerped, vector3, data.normal, data2) -- equivalent call inferred; original call site unknown
		local v5 = math.clamp(v4 - data2.stickSpeed, -p2.maxSpeed, -data2.stickSpeed)

		if p3 > 0 then
			local dot2 = data.normal:Dot(vector3)
			local v6

			if data2.minGroundDot < dot2 then
				v6 = p / dot2
			else
				v6 = p
			end

			v4 -= math.max(data.distance - v6, 0) / p3
		end

		if not flag3 then
			v4 = math.max(dot, v4)
		end

		v3 = math.max(math.min(v5, v4), -p2.maxSpeed)
	else
		v3 = math.max(dot - p2.acceleration * p3, -p2.maxSpeed)
	end

	if not flag and data.grounded and v3 < 0 and p3 > 0 then
		v3 = math.max(v3, -math.max(data.distance - p, 0) / p3)
	end

	local v4 = lerped + vector3 * v3
	return v4 + createVector(0, 1, 0) * (workspace.Gravity * p3), v4
end

function Motion.surfaceRiseSpeed(vector2: Vector3, vector3: Vector3, p, p2)
	local normal = p.normal
	return (math.max(slopeSpeed(vector2, vector3, normal, p2), 0))
end

function Motion.isCrest(p, vector2: Vector3, vector3: Vector3, p2: number, p3: number, p4)
	local dot = p.normal:Dot(vector3)

	if not (p4.minGroundDot < dot) then
		return false
	end

	local v = math.max(p.normal:Dot(vector2) / dot, 0)
	local dot2 = p.normal:Dot(vector3)

	if p4.minGroundDot < dot2 then
		p2 /= dot2
	end

	return math.max(p.distance - p2, 0) <= v + p3
end

function Motion.jumpSpeed(data, p)
	local v

	if data.UseJumpPower then
		v = data.JumpPower
	else
		v = math.sqrt(2 * workspace.Gravity * data.JumpHeight)
	end

	return v * p.jumpMultiplier
end

function Motion.travelAcceleration(p: number, p2: number, p3: number, p4)
	local maxTravelSeconds = p4.maxTravelSeconds

	if maxTravelSeconds > 0 then
		local v = math.max(2 * (p - p2 * maxTravelSeconds) / (maxTravelSeconds * maxTravelSeconds), p3)
		return v, (math.max(p4.maxFallSpeed, p2 + v * maxTravelSeconds))
	else
		return p3, p4.maxFallSpeed
	end
end

return Motion