local createVector = vector.create
local import = _G.import("mathUtil")
local floor = math.floor
local ceil = math.ceil
local new = Vector3.new
local new2 = Vector2.new
local round = import.round
local VectorUtil = {}

local function operateVec(callback)
	return function(data)
		return (Vector3.new(callback(data.X), callback(data.Y), callback(data.Z)))
	end
end

function VectorUtil.clampDist(p, p2, p3)
	return p2 + VectorUtil.min(VectorUtil.abs(p - p2), p3) * VectorUtil.sign(p - p2)
end

function VectorUtil.to2d(p)
	return new2(p.X, p.Z)
end

function VectorUtil.to3d(p, value)
	return (new(p.X, value or 0, p.Y))
end

function VectorUtil.round(data, p)
	return (Vector3.new(round(data.X, p), round(data.Y, p), round(data.Z, p)))
end

function VectorUtil.roundedEq(data, data2, p)
	return round(data.X, p) == round(data2.X, p) and round(data.Y, p) == round(data2.Y, p) and round(data.Z, p) == round(
		data2.Z,
		p
	)
end

local sign = math.sign

function VectorUtil.sign(data)
	return (Vector3.new(sign(data.X), sign(data.Y), sign(data.Z)))
end

local abs = math.abs

function VectorUtil.abs(data)
	return (Vector3.new(abs(data.X), abs(data.Y), abs(data.Z)))
end

function VectorUtil.floor3(data)
	return (Vector3.new(floor(data.X), floor(data.Y), floor(data.Z)))
end

function VectorUtil.ceil3(data)
	return (Vector3.new(ceil(data.X), ceil(data.Y), ceil(data.Z)))
end

local sqrt = math.sqrt

function VectorUtil.sqrt(data)
	return (Vector3.new(sqrt(data.X), sqrt(data.Y), sqrt(data.Z)))
end

function VectorUtil.floor2(p)
	return new2(floor(p.X), (floor(p.Y)))
end

function VectorUtil.ceil2(p)
	return new2(ceil(p.X), (ceil(p.Y)))
end

function VectorUtil.min(data, data2)
	return (Vector3.new(math.min(data.X, data2.X), math.min(data.Y, data2.Y), (math.min(data.Z, data2.Z))))
end

function VectorUtil.projection(vector2, p)
	return vector2:Dot(p) / p.magnitude ^ 2 * p
end

function VectorUtil.rejection(p, p2)
	return p - VectorUtil.projection(p, p2)
end

function VectorUtil.transform(p, data)
	return VectorUtil.projection(p, data.lookVector) + VectorUtil.projection(p, data.rightVector) + VectorUtil.projection(
		p,
		data.upVector
	)
end

function VectorUtil.intersection(p, p2, p3, p4)
	local v = p4 - p3
	local rejection = VectorUtil.rejection(p3 - p, p2 - p)
	local v2 = p3 - rejection
	local v3 = math.acos((v.unit:Dot(-rejection.unit)))
	return v2 + VectorUtil.rejection(v, rejection).unit * math.tan(v3) * rejection.magnitude
end

function VectorUtil.partToLine(instance)
	local X = instance.Size.X
	local to2d = VectorUtil.to2d(instance.CFrame.rightVector)
	local v = VectorUtil.to2d(instance.Position) + to2d * -X / 2
	return v, v + to2d * X
end

function VectorUtil.lookToLine(instance)
	return instance.Position, instance.Position + instance.CFrame.lookVector
end

function VectorUtil.pointInRegion2d(p, p2, p3)
	return p.X >= p2.X - p3.X / 2 and p.X <= p2.X + p3.X / 2 and p.Y >= p2.Y - p3.Y / 2 and p.Y <= p2.Y + p3.Y / 2
end

function VectorUtil.zeroUnit(p)
	if p.magnitude == 0 then
		return createVector(0, 0, 0)
	end

	return p.unit
end

function VectorUtil.capMagnitude(p, p2)
	return p.magnitude <= p2 and p or VectorUtil.zeroUnit(p) * p2
end

function VectorUtil.rotateAbout(vector2, p, p2)
	return VectorUtil.projection(vector2, p) + VectorUtil.rejection(vector2, p) * math.cos(p2) + vector2:Cross(p) * math.sin(p2)
end

return VectorUtil