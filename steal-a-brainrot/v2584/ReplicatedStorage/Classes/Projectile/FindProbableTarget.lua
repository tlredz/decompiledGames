local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SafeCast = require(ReplicatedStorage.Shared.SafeCast)
local max = math.max
local abs = math.abs
local clamp = math.clamp
local sqrt = math.sqrt

local function Dist2ToAABBLocal(vector: Vector3, vector2: Vector3)
	local v2 = max(0, abs(vector.X) - vector2.X)
	local v4 = max(0, abs(vector.Y) - vector2.Y)
	local v6 = max(0, abs(vector.Z) - vector2.Z)
	return v2 * v2 + v4 * v4 + v6 * v6
end

local function ClampToAABBLocal(vector: Vector3, vector2: Vector3)
	local v2 = clamp(vector.X, -vector2.X, vector2.X)
	local v4 = clamp(vector.Y, -vector2.Y, vector2.Y)
	local Z = vector.Z
	local v5 = -vector2.Z
	local Z2 = vector2.Z
	return (Vector3.new(v2, v4, (clamp(Z, v5, Z2))))
end

local function SegmentIntersectsAABBLocal(pointToObjectSpace: Vector3, pointToObjectSpace2: Vector3, vector: Vector3)
	local vector2 = pointToObjectSpace2 - pointToObjectSpace
	local v = 0
	local v2 = 1

	if abs(vector2.X) < 1e-6 then
		if pointToObjectSpace.X < -vector.X or pointToObjectSpace.X > vector.X then
			return false, 0
		end
	else
		local v3 = 1 / vector2.X
		local v4 = (-vector.X - pointToObjectSpace.X) * v3
		local v5 = (vector.X - pointToObjectSpace.X) * v3

		if v5 < v4 then
			v5, v4 = v4, v5
		end

		if v < v4 then
			v = v4
		end

		if v5 < v2 then
			v2 = v5
		end

		if v2 < v then
			return false, 0
		end
	end

	if abs(vector2.Y) < 1e-6 then
		if pointToObjectSpace.Y < -vector.Y or pointToObjectSpace.Y > vector.Y then
			return false, 0
		end
	else
		local v3 = 1 / vector2.Y
		local v4 = (-vector.Y - pointToObjectSpace.Y) * v3
		local v5 = (vector.Y - pointToObjectSpace.Y) * v3

		if v5 < v4 then
			v5, v4 = v4, v5
		end

		if v < v4 then
			v = v4
		end

		if v5 < v2 then
			v2 = v5
		end

		if v2 < v then
			return false, 0
		end
	end

	if abs(vector2.Z) < 1e-6 then
		if pointToObjectSpace.Z < -vector.Z or pointToObjectSpace.Z > vector.Z then
			return false, 0
		end
	else
		local v3 = 1 / vector2.Z
		local v4 = (-vector.Z - pointToObjectSpace.Z) * v3
		local v5 = (vector.Z - pointToObjectSpace.Z) * v3

		if v5 < v4 then
			v5, v4 = v4, v5
		end

		if v < v4 then
			v = v4
		end

		if v5 < v2 then
			v2 = v5
		end

		if v2 < v then
			return false, 0
		end
	end

	if v2 < 0 or v > 1 then
		return false, 0
	end

	if v < 0 then
		return true, 0
	end

	return true, v
end

local function NearestPointOnSegmentToOBB(vector: Vector3, ending: Vector3, cFrame: CFrame, vector2: Vector3)
	local vector3 = ending - vector
	local magnitude = vector3.Magnitude

	if magnitude < 1e-6 then
		local pointToObjectSpace = cFrame:PointToObjectSpace(vector)
		local v2 = clamp(pointToObjectSpace.X, -vector2.X, vector2.X)
		local v4 = clamp(pointToObjectSpace.Y, -vector2.Y, vector2.Y)
		local Z = pointToObjectSpace.Z
		local v5 = -vector2.Z
		local Z2 = vector2.Z
		return 0, vector, (pointToObjectSpace - Vector3.new(v2, v4, (clamp(Z, v5, Z2)))).Magnitude
	else
		local v = vector3 / magnitude
		local flag, v2 = SegmentIntersectsAABBLocal(
			cFrame:PointToObjectSpace(vector),
			cFrame:PointToObjectSpace(ending),
			vector2
		)

		if flag then
			local v3 = v2 * magnitude
			return v3, vector + v * v3, 0
		end

		local function f(p: number)
			local pointToObjectSpace3 = cFrame:PointToObjectSpace(vector + v * p)
			local vector4 = vector2
			local v5 = max(0, abs(pointToObjectSpace3.X) - vector4.X)
			local v7 = max(0, abs(pointToObjectSpace3.Y) - vector4.Y)
			local v9 = max(0, abs(pointToObjectSpace3.Z) - vector4.Z)
			return v5 * v5 + v7 * v7 + v9 * v9
		end

		local v3 = 0
		local v4 = magnitude - (magnitude - v3) * 0.6180339887498949
		local v5 = v3 + (magnitude - v3) * 0.6180339887498949
		local pointToObjectSpace3 = cFrame:PointToObjectSpace(vector + v * v4)
		local v7 = max(0, abs(pointToObjectSpace3.X) - vector2.X)
		local v9 = max(0, abs(pointToObjectSpace3.Y) - vector2.Y)
		local v11 = max(0, abs(pointToObjectSpace3.Z) - vector2.Z)
		local v12 = v7 * v7 + v9 * v9 + v11 * v11
		local pointToObjectSpace4 = cFrame:PointToObjectSpace(vector + v * v5)
		local v14 = max(0, abs(pointToObjectSpace4.X) - vector2.X)
		local v16 = max(0, abs(pointToObjectSpace4.Y) - vector2.Y)
		local v18 = max(0, abs(pointToObjectSpace4.Z) - vector2.Z)
		local v19 = v14 * v14 + v16 * v16 + v18 * v18

		for _ = 1, 22 do
			if v12 < v19 then
				local v20 = v5 - (v5 - v3) * 0.6180339887498949
				local pointToObjectSpace5 = cFrame:PointToObjectSpace(vector + v * v20)
				local v22 = max(0, abs(pointToObjectSpace5.X) - vector2.X)
				local v24 = max(0, abs(pointToObjectSpace5.Y) - vector2.Y)
				local v26 = max(0, abs(pointToObjectSpace5.Z) - vector2.Z)
				magnitude = v5
				v5 = v4
				v4 = v20
				v19 = v12
				v12 = v22 * v22 + v24 * v24 + v26 * v26
			else
				local v20 = v4 + (magnitude - v4) * 0.6180339887498949
				local pointToObjectSpace5 = cFrame:PointToObjectSpace(vector + v * v20)
				local v22 = max(0, abs(pointToObjectSpace5.X) - vector2.X)
				local v24 = max(0, abs(pointToObjectSpace5.Y) - vector2.Y)
				local v26 = max(0, abs(pointToObjectSpace5.Z) - vector2.Z)
				v3 = v4
				v4 = v5
				v5 = v20
				v12 = v19
				v19 = v22 * v22 + v24 * v24 + v26 * v26
			end
		end

		local v20 = 0.5 * (v3 + magnitude)
		local v21 = vector + v * v20
		local pointToObjectSpace5 = cFrame:PointToObjectSpace(vector + v * v20)
		local v23 = max(0, abs(pointToObjectSpace5.X) - vector2.X)
		local v25 = max(0, abs(pointToObjectSpace5.Y) - vector2.Y)
		local v27 = max(0, abs(pointToObjectSpace5.Z) - vector2.Z)
		return v20, v21, (sqrt(v23 * v23 + v25 * v25 + v27 * v27))
	end
end

local function GetHitbox(instance)
	local __HITBOX = instance:FindFirstChild("__HITBOX")

	if __HITBOX and __HITBOX:IsA("BasePart") then
		return __HITBOX.CFrame, __HITBOX.Size
	end

	return instance:GetBoundingBox()
end

local function GetCharacter(instance)
	local model = instance:FindFirstAncestorOfClass("Model")

	if not model then
		return nil, nil
	end

	local primaryPart = model.PrimaryPart

	if not primaryPart then
		return nil, nil
	end

	if model:FindFirstChildOfClass("Humanoid") then
		return model, primaryPart
	end

	return nil, nil
end

local function FindProbableTarget(vector: Vector3, ending: Vector3, value: number, p, p2)
	assert(typeof(vector) == "Vector3", "p0 must be Vector3")
	assert(typeof(ending) == "Vector3", "p1 must be Vector3")
	local v

	if type(value) == "number" then
		v = value >= 0
	else
		v = false
	end

	assert(v, "radius > 0")
	assert(typeof(p) == "RaycastParams")
	assert(typeof(p2) == "OverlapParams")
	local v2 = {}
	local safeCast = SafeCast(vector, ending, value, p)

	if safeCast then
		local model = safeCast.Instance:FindFirstAncestorOfClass("Model")
		local primaryPart

		if model then
			primaryPart = model.PrimaryPart

			if primaryPart then
				if not model:FindFirstChildOfClass("Humanoid") then
					model = nil
					primaryPart = nil
				end
			else
				model = nil
				primaryPart = nil
			end
		else
			model = nil
		end

		if model and primaryPart then
			local __HITBOX = model:FindFirstChild("__HITBOX")
			local cFrame

			if __HITBOX and __HITBOX:IsA("BasePart") then
				cFrame = __HITBOX.CFrame
				local _ = __HITBOX.Size
			else
				local v4
				cFrame, v4 = model:GetBoundingBox()
			end

			return cFrame.Position
		else
			ending = safeCast.Ending
		end
	end

	local vector2 = ending - vector
	local magnitude = vector2.Magnitude

	if magnitude < 1e-6 or value <= 0 then
		return nil
	end

	local v4 = vector2 / magnitude
	local v5 = 0.5 * magnitude
	local cframe = CFrame.lookAt(vector + v4 * v5, ending)
	local vector3 = Vector3.new(value * 2, value * 2, magnitude)
	local partBoundsInBox = workspace:GetPartBoundsInBox(cframe, vector3, p2)
	local _ = value * value
	local v6 = 1e999
	local position = nil

	for _, v7 in ipairs(partBoundsInBox) do
		local model = v7:FindFirstAncestorOfClass("Model")
		local primaryPart

		if model then
			primaryPart = model.PrimaryPart

			if primaryPart then
				if not model:FindFirstChildOfClass("Humanoid") then
					model = nil
					primaryPart = nil
				end
			else
				model = nil
				primaryPart = nil
			end
		else
			model = nil
		end

		if not model or not primaryPart or v2[model] then
			continue
		end

		v2[model] = true
		local __HITBOX = model:FindFirstChild("__HITBOX")
		local cFrame, size

		if __HITBOX and __HITBOX:IsA("BasePart") then
			cFrame = __HITBOX.CFrame
			size = __HITBOX.Size
		else
			cFrame, size = model:GetBoundingBox()
		end

		local _, _, v8 = NearestPointOnSegmentToOBB(vector, ending, cFrame, size * 0.5)

		if value <= v8 or not (v8 < v6) then
			continue
		end

		position = cFrame.Position
		v6 = v8
	end

	return position
end

return FindProbableTarget