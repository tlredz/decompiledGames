local createVector = vector.create
local Create = {}
Create.__index = Create

function Create.new(className, items)
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	return instance
end

function Create.Part()
	return (Create.new("Part", {
		TopSurface = 0,
		BottomSurface = 0,
		Size = createVector(1, 1, 1),
		Anchored = true,
		CanCollide = false
	}))
end

function Create.Sphere()
	local part = Create.Part()
	local specialMesh = Instance.new("SpecialMesh", part)
	specialMesh.Name = "Mesh"
	specialMesh.MeshType = "Sphere"
	return part
end

function Create.Block()
	local part = Create.Part()
	local blockMesh = Instance.new("BlockMesh", part)
	blockMesh.Name = "Mesh"
	return part
end

return Create