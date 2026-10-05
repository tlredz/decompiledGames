local createVector = vector.create
local RunService = game:GetService("RunService")
local isClient = RunService:IsClient()

-- equivalent calls inferred from this helper; original call sites unknown
local function rayParams(options, value)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = options or {}
	raycastParams.FilterType = Enum.RaycastFilterType[value or "Blacklist"]
	return raycastParams
end

local TargetFolders = {
	workspace:WaitForChild("Characters"),
	workspace:WaitForChild("Enemies"),
	workspace:WaitForChild("NPCs"),
	workspace:WaitForChild("_WorldOrigin"),
	workspace:FindFirstChild("WaterStudio")
}

if isClient then
	task.spawn(function()
		table.insert(TargetFolders, workspace.Map:WaitForChild("WaterBase-Plane", 9999))
	end)
end

local cast

cast = function(p, p2, p3, options, p4)
	local v = options or {}

	for _, targetFolder in pairs(TargetFolders) do
		v[#v + 1] = targetFolder
	end

	local raycastResult = workspace:Raycast(p, p2, rayParams(v))

	if not raycastResult then
		return nil, p + p2, createVector(0, 0, 0)
	end

	local instance = raycastResult.Instance
	local position = raycastResult.Position
	local normal = raycastResult.Normal

	if instance then
		local v2 = not instance.CanCollide

		if p4 and not v2 then
			v2 = instance.Transparency > 0
		end

		if v2 then
			v[#v + 1] = instance
			return cast(p, p2, p3, v, p4)
		end
	end

	if not p3 then
		return instance, position, normal
	end

	local v2 = position - p
	local magnitude = v2.magnitude
	local part = Instance.new("Part")
	part.Size = createVector(0.4, 0.4, 1)
	part.CanCollide = false
	part.Anchored = true
	part.BrickColor = BrickColor.random()
	part.Transparency = 0.5
	part.CFrame = CFrame.new(p, p + v2)
	local blockMesh = Instance.new("BlockMesh", part)
	blockMesh.Scale = Vector3.new(1, 1, magnitude)
	blockMesh.Offset = Vector3.new(0, 0, -magnitude / 2)
	part.Parent = workspace._WorldOrigin
	game.Debris:AddItem(part, 0.05)
	return instance, position, normal
end

return cast