local createVector = vector.create
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()

local function ensureZoneFolder()
	local v = workspace:FindFirstChild("PveZones")

	if not v then
		v = Instance.new("Folder")
		v.Name = "PveZones"
		v.Parent = workspace
	end

	return v
end

return {
	create = function(position: Vector3, value: number)
		assert(isServer, "PVEZoneUtil can only be used on the server")
		assert(typeof(position) == "Vector3", "position must be a Vector3")
		assert(typeof(value) == "number", "radius must be a number")
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Transparency = 1
		part.Size = createVector(1, 1, 1)
		part.CFrame = CFrame.new(position)
		local specialMesh = Instance.new("SpecialMesh")
		specialMesh.MeshType = Enum.MeshType.Sphere
		specialMesh.Scale = Vector3.new(value * 2, value * 2, value * 2)
		specialMesh.Parent = part
		part.Name = "PVEZone"
		local parent = workspace:FindFirstChild("PveZones")

		if not parent then
			parent = Instance.new("Folder")
			parent.Name = "PveZones"
			parent.Parent = workspace
		end

		part.Parent = parent
		return part
	end
}