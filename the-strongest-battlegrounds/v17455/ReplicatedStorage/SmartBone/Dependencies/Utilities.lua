local Utilities = {}

function Utilities.ShallowCopy(items)
	local result = {}

	for k, item in pairs(items) do
		result[k] = item
	end

	return result
end

function Utilities.Lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function Utilities.GetRotationBetween(vector: Vector3, vector2: Vector3, vector3: Vector3)
	local dot = vector:Dot(vector2)
	local cross = vector:Cross(vector2)

	if dot < -0.99999 then
		return CFrame.fromAxisAngle(vector3, 3.141592653589793)
	end

	return CFrame.new(0, 0, 0, cross.X, cross.Y, cross.Z, 1 + dot)
end

function Utilities.GetHierarchyLength(parent, p)
	if parent == p then
		warn("Child and Root are the same Instance!")
		return
	end

	if parent == nil then
		warn("Child is nil!")
		return
	end

	local count = 0

	repeat
		count += 1
		parent = parent.Parent
	until parent == p

	return count
end

function Utilities.WaitForChildOfClass(instance, className: string, value: number)
	local lastTime = os.clock()
	local lastTime2 = tick()
	local v = value or 10

	repeat
		task.wait()
	until instance:FindFirstChildOfClass(className) or v < os.clock() - lastTime or tick() - lastTime2 > 60

	return instance:FindFirstChildOfClass(className)
end

return Utilities