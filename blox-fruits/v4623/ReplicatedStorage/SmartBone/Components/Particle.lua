local createVector = vector.create
local Particle = {}
Particle.__index = Particle

function Particle.new(bone, p, p2, settings)
	local v = {
		Bone = bone,
		RestLength = 0,
		Weight = 0.7,
		ParentIndex = 0,
		Transform = bone.WorldCFrame:ToObjectSpace(p.WorldCFrame):Inverse(),
		LocalTransform = bone.CFrame:ToObjectSpace(p.CFrame):Inverse(),
		RootTransform = p.WorldCFrame:ToObjectSpace(p2.CFrame):Inverse(),
		Radius = settings.Radius,
		IsColliding = false,
		Settings = 0,
		TransformOffset = 0,
		LastTransformOffset = 0,
		LocalTransformOffset = 0,
		RestPosition = createVector(0, 0, 0),
		BoneTransform = 0,
		CalculatedWorldCFrame = 0,
		CalculatedWorldPosition = 0,
		Position = 0,
		LastPosition = 0,
		Anchored = false,
		RecyclingBin = 0
	}

	if not settings.Create then
		settings = nil
	end

	v.Settings = settings
	v.TransformOffset = CFrame.identity
	v.LastTransformOffset = CFrame.identity
	v.LocalTransformOffset = CFrame.identity
	v.BoneTransform = CFrame.identity
	v.CalculatedWorldCFrame = bone.WorldCFrame
	v.CalculatedWorldPosition = bone.WorldPosition
	v.Position = bone.WorldPosition
	v.LastPosition = bone.WorldPosition
	v.RecyclingBin = {}
	return (setmetatable(v, Particle))
end

return Particle