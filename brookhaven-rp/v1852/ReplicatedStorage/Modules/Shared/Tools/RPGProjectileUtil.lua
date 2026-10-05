local createVector = vector.create
local RPGProjectileUtil = {}

local function isFiniteNumber(p: number)
	return p == p and math.abs(p) ~= 1e999
end

function RPGProjectileUtil.isFiniteVector3(vector2: Vector3)
	local X = vector2.X
	local v

	if X == X then
		v = math.abs(X) ~= 1e999
	else
		v = false
	end

	if not v then
		return v
	end

	local Y = vector2.Y

	if Y == Y then
		v = math.abs(Y) ~= 1e999
	else
		v = false
	end

	if not v then
		return v
	end

	local Z = vector2.Z

	if Z == Z then
		return math.abs(Z) ~= 1e999
	else
		return false
	end

	return v
end

function RPGProjectileUtil.isFiniteCFrame(cframe: CFrame)
	return RPGProjectileUtil.isFiniteVector3(cframe.Position) and RPGProjectileUtil.isFiniteVector3(cframe.LookVector) and RPGProjectileUtil.isFiniteVector3(cframe.RightVector) and RPGProjectileUtil.isFiniteVector3(cframe.UpVector)
end

function RPGProjectileUtil.lookAlong(vector2: Vector3, vector3: Vector3)
	local v = math.abs(vector3.Unit.Y) > 0.99 and createVector(1, 0, 0) or createVector(0, 1, 0)
	return CFrame.lookAt(vector2, vector2 + vector3, v)
end

function RPGProjectileUtil.getLaunchCFrame(instance, p, vector2: Vector3)
	local v = instance.CFrame:Inverse() * p.CFrame
	return RPGProjectileUtil.lookAlong(instance.Position, vector2) * v
end

return RPGProjectileUtil