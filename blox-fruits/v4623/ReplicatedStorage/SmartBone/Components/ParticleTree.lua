local createVector = vector.create
local random = Random.new(1029410295159813)
local ParticleTree = {}
ParticleTree.__index = ParticleTree

function ParticleTree.new(bone, rootPart, vector2: Vector3)
	return (setmetatable({
		WindOffset = random:NextNumber(0, 1000000),
		Root = bone:IsA("Bone") and bone or nil,
		RootPart = rootPart,
		RootWorldToLocal = bone.WorldCFrame:ToObjectSpace(bone.CFrame),
		BoneTotalLength = 0,
		DistanceFromCamera = 100,
		Particles = {},
		LocalCFrame = bone.WorldCFrame,
		LocalGravity = bone.CFrame:PointToWorldSpace(vector2).Unit * vector2.Magnitude,
		Force = createVector(0, 0, 0),
		RestGravity = createVector(0, 0, 0),
		ObjectMove = createVector(0, 0, 0),
		ObjectPreviousPosition = rootPart.Position
	}, ParticleTree))
end

return ParticleTree