local VectorUtil = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MathUtil = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("MathUtil"))

function VectorUtil.ifNanThen0(vector: Vector3)
	local X = vector.X
	local Y = vector.Y
	local Z = vector.Z
	return (Vector3.new(
		(X ~= X or X == 1e999 or X == -1e999) and 0 or X,
		(Y ~= Y or Y == 1e999 or Y == -1e999) and 0 or Y,
		(Z ~= Z or Z == 1e999 or Z == -1e999) and 0 or Z
	))
end

function VectorUtil.max(vector: Vector3, vector2: Vector3)
	return (Vector3.new(math.max(vector.X, vector2.X), math.max(vector.Y, vector2.Y), (math.max(vector.Z, vector2.Z))))
end

function VectorUtil.abs(vector: Vector3)
	return (Vector3.new(math.abs(vector.X), math.abs(vector.Y), (math.abs(vector.Z))))
end

function VectorUtil.sign(vector: Vector3)
	return (Vector3.new(math.sign(vector.X), math.sign(vector.Y), (math.sign(vector.Z))))
end

function VectorUtil.floor(vector: Vector3)
	return (Vector3.new(math.floor(vector.X), math.floor(vector.Y), (math.floor(vector.Z))))
end

function VectorUtil.round(vector: Vector3, p: number)
	return (Vector3.new(MathUtil.round(vector.X, p), MathUtil.round(vector.Y, p), MathUtil.round(vector.Z, p)))
end

function VectorUtil.getXZComponents(vector: Vector3)
	return (Vector3.new(vector.X, 0, vector.Z))
end

function VectorUtil.nextVector(p: number, p2: number)
	return (Vector3.new(MathUtil.nextNumber(p, p2), MathUtil.nextNumber(p, p2), (MathUtil.nextNumber(p, p2))))
end

function VectorUtil.getFullAngle(vector: Vector3, vector2: Vector3, vector3: Vector3)
	local dot = vector:Dot(vector2)
	local vector4 = vector:Cross(vector2)
	local v = math.acos(dot)
	return (math.deg(vector4:Dot(vector3) > 0 and v or -v))
end

function VectorUtil.getAngle(vector, p)
	return (math.deg((math.acos((math.clamp(vector:Dot(p) / (vector.Magnitude * p.Magnitude), -1, 1))))))
end

function VectorUtil.getVector2FullAngle(point: Vector2, point2: Vector2)
	local angle = VectorUtil.getAngle(point, point2)

	if (point2 - point).X >= 0 then
		angle = -angle
	end

	return (angle + 360) % 360
end

return VectorUtil