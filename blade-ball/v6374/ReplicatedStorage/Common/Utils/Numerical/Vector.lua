local createVector = vector.create
local Vector = {
	ClampMagnitude = function(p, p2)
		if p2 < p.Magnitude then
			p = p.Unit * p2 or p
		end

		return p
	end,
	AngleBetween = function(p, p2)
		return (math.acos((math.clamp(p.Unit:Dot(p2.Unit), -1, 1))))
	end
}

function Vector.AngleBetweenSigned(vector2, p, vector3)
	return Vector.AngleBetween(vector2, p) * math.sign((vector3:Dot(vector2:Cross(p))))
end

function Vector.FromAxisToPolar(vector2: Vector3)
	local magnitude = vector2.magnitude
	return (Vector3.new(math.atan2(vector2.z, vector2.x), math.asin(vector2.y / magnitude), magnitude))
end

function Vector.FromPolarToAxis(vector2: Vector3)
	local x = vector2.x
	local y = vector2.y
	local z = vector2.z
	return (Vector3.new(z * math.cos(x) * math.cos(y), z * math.sin(y), z * math.sin(x) * math.cos(y)))
end

function Vector.Lerp(vector2: Vector3, vector3: Vector3, p: number)
	return vector2 + p * (vector3 - vector2)
end

function Vector.Slerp(vector2: Vector3, vector3: Vector3, p: number)
	local magnitude = vector2.Magnitude
	local magnitude2 = vector3.Magnitude

	if magnitude == 0 or magnitude2 == 0 then
		return Vector.Lerp(vector2, vector3, p)
	end

	local dot = (vector2 / magnitude):Dot(vector3 / magnitude2)

	if dot < 0 then
		vector2 = -vector2
		dot = -dot
	end

	if dot > 0.99995 then
		return Vector.Lerp(vector2, vector3, p)
	end

	local v = math.acos(dot)
	local v2 = v * p
	local v3 = math.sin(v2)
	local v4 = math.sin(v)
	local v5 = math.cos(v2) - dot * v3 / v4
	local v6 = v3 / v4
	return (v5 * vector2 + v6 * vector3) * (magnitude + p * (magnitude2 - magnitude))
end

function Vector.TorqueFromForce(vector2: Vector3, vector3: Vector3, vector4: Vector3)
	return (vector2 - vector3):Cross(vector4)
end

function Vector.Reach(vector2: Vector3, vector3: Vector3, p: number)
	local v = vector3 - vector2

	if v.Magnitude < p then
		return vector3, v
	end

	local v2 = v.Unit * p
	return vector2 + v2, v2
end

function Vector.Raycast(vector2: Vector3, vector3: Vector3, _, flag: boolean, flag2: boolean, collisionGroup: string, p, flag3: boolean)
	local raycastParams = RaycastParams.new()
	local instances = { workspace:FindFirstChild("Ignore") }
	raycastParams.FilterType = p or Enum.RaycastFilterType.Blacklist
	raycastParams.FilterDescendantsInstances = instances
	raycastParams.IgnoreWater = flag or false

	if collisionGroup then
		raycastParams.CollisionGroup = collisionGroup
	end

	local raycastResult = workspace:Raycast(vector2, vector3, raycastParams)

	if not raycastResult then
		return raycastResult
	end

	local instance = raycastResult.Instance

	if instance.CanCollide ~= false and (flag3 or not (instance.Transparency > 0.45)) and not (flag2 and (instance.Parent:FindFirstChild("Humanoid") or instance.Parent.Parent:FindFirstChild("Humanoid"))) and instance.Name ~= "Collision" then
		return raycastResult
	end

	table.insert(instances, instance)
	return Vector.Raycast(
		raycastResult.Position,
		vector3.Unit * (vector3.Magnitude - (raycastResult.Position - vector2).Magnitude),
		instances,
		flag,
		flag2,
		collisionGroup,
		p,
		flag3
	)
end

local function fn(data)
	return data.CanCollide == false or data.Transparency > 0.45 or data.Name == "Collision"
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
raycastParams.FilterDescendantsInstances = { workspace:FindFirstChild("Ignore") }
raycastParams.IgnoreWater = true

function Vector.Raycast2(vector2: Vector3, vector3: Vector3, p, callback)
	local v = p or raycastParams
	local raycastResult = workspace:Raycast(vector2, vector3, v)

	if not raycastResult then
		return raycastResult
	end

	local instance = raycastResult.Instance

	if not (callback or fn)(instance, raycastResult.Position) then
		return raycastResult
	end

	local raycastParams2 = RaycastParams.new()
	raycastParams2.FilterType = v.FilterType
	local filterDescendantsInstances = v.FilterDescendantsInstances
	table.insert(filterDescendantsInstances, instance)
	raycastParams2.FilterDescendantsInstances = filterDescendantsInstances
	raycastParams2.IgnoreWater = v.IgnoreWater
	return Vector.Raycast2(vector2, vector3, raycastParams2, callback)
end

local _ = Vector.Raycast2

function Vector:GetTrackMagnitude(flag: boolean)
	assert(self, "No track given")

	if self.__Magnitude and not flag then
		return self.__Magnitude
	end

	if #self <= 1 then
		self.__Magnitude = 0
	else
		local v = self[1]

		for i = 2, #self do
			local v2 = self[i]
			local magnitude = (v2 - v).Magnitude

			if self.__Magnitude then
				magnitude = self.__Magnitude + magnitude or magnitude
			end

			self.__Magnitude = magnitude
			v = v2
		end
	end

	return self.__Magnitude
end

function Vector.GetVectorFromTrack(p, list)
	local v = Vector.GetTrackMagnitude(list) * p
	local v2 = list[1]
	local total = 0

	for i = 2, #list do
		local v3 = list[i]
		local magnitude = (v3 - v2).Magnitude

		if v < total + magnitude then
			return v2:lerp(v3, (v - total) / magnitude)
		end

		total += magnitude
		v2 = v3
	end
end

function Vector.ShowTrack(list, p)
	assert(list, "No track given")
	local folder = Instance.new("Folder")

	if #list > 1 then
		local v = list[1]

		for k, position in pairs({
			[Color3.new(1, 0, 0)] = v,
			[Color3.new(0, 1, 0)] = list[#list]
		}) do
			local part = Instance.new("Part")
			part.Color = k
			part.Anchored = true
			part.CanCollide = false
			part.Shape = "Ball"
			part.Size = createVector(1, 1, 1)
			part.Massless = true
			part.CanTouch = false
			part.CanQuery = false
			part.Name = "VectorViewer"
			part.CFrame = CFrame.new(position)
			part.Parent = folder
		end

		for i = 2, #list do
			local v3 = list[i]
			local v4 = v3 - v
			local magnitude = (v - v3).Magnitude
			local part = Instance.new("Part")
			part.Color = p or Color3.new(0, 0, 1)
			part.Anchored = true
			part.CanCollide = false
			part.Size = Vector3.new(0.1, 0.1, magnitude)
			part.Massless = true
			part.CanTouch = false
			part.CanQuery = false
			part.Name = "VectorViewer"
			part.CFrame = CFrame.new(v + v4 / 2, v + v4)
			part.Parent = folder
			v = v3
		end
	end

	folder.Parent = workspace
end

local function lerp(p, p2, p3)
	return (p2 - p) * p3 + p
end

function Vector.SquareBezier(vector2: Vector3, vector3: Vector3, vector4: Vector3, p: number)
	local v = (vector3 - vector2) * p + vector2
	return ((vector4 - vector3) * p + vector3 - v) * p + v
end

function Vector.CubicBezier(vector2: Vector3, vector3: Vector3, vector4: Vector3, vector5: Vector3, p: number)
	local v = (vector3 - vector2) * p + vector2
	local v2 = (vector4 - vector3) * p + vector3
	local v3 = (vector5 - vector4) * p + vector4
	local v4 = (v2 - v) * p + v
	return ((v3 - v2) * p + v2 - v4) * p + v4
end

local cubicBezier = Vector.CubicBezier

function Vector.CubicBezierArcLength(vector2: Vector3, vector3: Vector3, vector4: Vector3, vector5: Vector3, p)
	local v = vector2
	local total = 0
	local result = { 0 }

	for i = 1, p - 1 do
		local v2 = cubicBezier(vector2, vector3, vector4, vector5, i / p)
		total += (v - v2).Magnitude
		table.insert(result, total)
		v = v2
	end

	local v2 = total + (v - vector5).Magnitude
	table.insert(result, v2)
	return v2, result
end

function Vector.Lightning(vector2: Vector3, vector3: Vector3, p)
	local result = table.create(p, vector2)
	local v = (vector3 - vector2) / p

	for i = 2, p - 1 do
		result[i] = vector2 + v * i + Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)
	end

	result[p] = vector3
	return result
end

function Vector.KineticDirectionMath(p, p2, p3, p4)
	local v = p2 * p2
	local v2 = v ~= v and 0 or v
	local v3 = p4 ~= p4 and 0 or p4
	local v4 = p3 * p3
	local v5 = p * p * (v2 * (v3 * v3 - 1) + v4)

	if v5 > 0 then
		local v6 = (math.sqrt(v5) + p2 * v3 * p) / (v2 - v4)

		if v6 > 0 then
			return v6
		end

		local v7 = (-math.sqrt(v5) + p2 * v3 * p) / (v2 - v4)

		if v7 > 0 then
			return v7
		end
	end

	return nil
end

function Vector.KineticDirectionAccelerationMath(_, _, _, _) end

local random = math.random

function Vector.Random()
	return (Vector3.new(random() * 2 - 1, random() * 2 - 1, random() * 2 - 1))
end

return Vector