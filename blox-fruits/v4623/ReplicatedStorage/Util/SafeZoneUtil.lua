local createVector = vector.create
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()

local function ensureZoneFolder()
	return (workspace._WorldOrigin:FindFirstChild("SafeZones"))
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
		part.Name = "safe"
		part.Parent = workspace._WorldOrigin:FindFirstChild("SafeZones")
		return part
	end
}