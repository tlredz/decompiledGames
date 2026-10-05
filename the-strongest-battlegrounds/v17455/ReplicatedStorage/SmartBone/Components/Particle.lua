local createVector = vector.create
local Particle = {}
Particle.__index = Particle

function Particle.new(bone, p, p2, p3)
	return (setmetatable({
		Bone = bone,
		RestLength = 0,
		Weight = 0.7,
		ParentIndex = 0,
		Transform = bone.WorldCFrame:ToObjectSpace(p.WorldCFrame):Inverse(),
		LocalTransform = bone.CFrame:ToObjectSpace(p.CFrame):Inverse(),
		RootTransform = p.WorldCFrame:ToObjectSpace(p2.CFrame):Inverse(),
		Radius = p3.Radius,
		IsColliding = false,
		TransformOffset = CFrame.identity,
		LastTransformOffset = CFrame.identity,
		LocalTransformOffset = CFrame.identity,
		RestPosition = createVector(0, 0, 0),
		BoneTransform = CFrame.identity,
		CalculatedWorldCFrame = bone.WorldCFrame,
		CalculatedWorldPosition = bone.WorldPosition,
		Position = bone.WorldPosition,
		LastPosition = bone.WorldPosition,
		Anchored = false,
		RecyclingBin = {}
	}, Particle))
end

return Particle