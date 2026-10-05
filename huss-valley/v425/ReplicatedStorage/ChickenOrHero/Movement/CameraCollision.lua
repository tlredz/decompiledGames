local CameraCollision = {}
CameraCollision.__index = CameraCollision

local function avatarAncestor(instance)
	local parent = instance.Parent

	while parent and parent ~= workspace do
		if parent:IsA("Model") and parent:FindFirstChildOfClass("Humanoid") then
			return parent
		else
			parent = parent.Parent
		end
	end
end

function CameraCollision.new(p)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.RespectCanCollide = true
	raycastParams.IgnoreWater = true
	return (setmetatable({
		world = p or workspace,
		params = raycastParams,
		ignored = {}
	}, CameraCollision))
end

function CameraCollision.constrain(data, p, p2, p3)
	local v = p2 - p

	if v.Magnitude < 0.0001 then
		return p
	end

	table.clear(data.ignored)

	if p3 then
		table.insert(data.ignored, p3)
	end

	for _ = 1, 8 do
		data.params.FilterDescendantsInstances = data.ignored
		local raycastResult = data.world:Raycast(p, v, data.params)

		if not raycastResult then
			return p2
		end

		local instance = raycastResult.Instance
		local v2 = avatarAncestor(instance)

		if not v2 and instance:IsA("BasePart") and instance.Transparency >= 0.99 then
			v2 = instance
		end

		if not v2 then
			return p + v.Unit * math.max(0, raycastResult.Distance - 0.1)
		end

		table.insert(data.ignored, v2)
	end

	return p
end

return CameraCollision