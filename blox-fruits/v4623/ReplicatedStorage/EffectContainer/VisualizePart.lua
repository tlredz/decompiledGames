local createVector = vector.create
game.ReplicatedStorage:WaitForChild("Util")
local v = {
	[Enum.PartType.Block] = "Brick",
	[Enum.PartType.Ball] = "Sphere",
	[Enum.PartType.Cylinder] = "Cylinder"
}

local function func(instance)
	local parent

	if instance.Reference then
		parent = instance.Reference:Clone()
		parent.Size = instance.Size
	else
		parent = Instance.new("Part")
		parent.Size = createVector(1, 1, 1)
		local specialMesh = Instance.new("SpecialMesh")
		specialMesh.MeshType = v[instance.Shape or Enum.PartType.Block]
		specialMesh.Scale = instance.Size
		specialMesh.Parent = parent
	end

	parent.CastShadow = false
	parent.CanTouch = false
	parent.CanQuery = false
	parent.Color = instance.Color or Color3.new(0, 0, 1)
	parent.Transparency = instance.Transparency or 0.9
	parent.TopSurface = 0
	parent.BottomSurface = 0
	parent.Material = "Neon"
	parent.CanCollide = false
	parent.Anchored = true
	parent.CFrame = instance.CFrame
	parent.Parent = workspace._WorldOrigin
	wait(instance.Duration)
	parent:Destroy()
end

return func