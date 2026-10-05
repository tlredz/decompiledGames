local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local v = {
	[Enum.BodyPart.Head] = "Head",
	[Enum.BodyPart.Torso] = "Torso",
	[Enum.BodyPart.LeftArm] = "Left Arm",
	[Enum.BodyPart.LeftLeg] = "Left Leg",
	[Enum.BodyPart.RightArm] = "Right Arm",
	[Enum.BodyPart.RightLeg] = "Right Leg"
}
return function(instance, data)
	for _, childName in {
		"Head",
		"Torso",
		"Left Arm",
		"Left Leg",
		"Right Arm",
		"Right Leg"
	} do
		local part = instance:FindFirstChild(childName)

		if not (part and part:IsA("BasePart")) then
			continue
		end

		local clone = part:Clone()
		clone:ClearAllChildren()
		clone.CastShadow = false
		clone.Color = data.color or Color3.new(0, 0, 0)
		clone.Material = Enum.Material.Neon
		clone.Transparency = data.transparency or 0.6
		clone.CanCollide = false
		clone.CanTouch = false
		clone.CanQuery = false
		clone.Anchored = true
		clone.Parent = workspace.Runtime

		if data.cframeMap and data.cframeMap[part] then
			clone.CFrame = data.cframeMap[part]
		end

		if data.sizeScale then
			clone.Size *= data.sizeScale
		end

		local dataModelMesh = part:FindFirstChildWhichIsA("DataModelMesh")

		if dataModelMesh then
			local clone2 = dataModelMesh:Clone()
			clone2:ClearAllChildren()
			clone2.Parent = clone
		end

		local lifetime = data.lifetime or 1
		local animationDelay = data.animationDelay or 0
		local v2 = lifetime - animationDelay
		TweenService:Create(
			clone,
			TweenInfo.new(v2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, animationDelay),
			{
				Position = clone.Position + createVector(0, 1, 0) * (data.riseSpeed or 1) * v2,
				Size = clone.Size * (data.shrinkTargetScale or 0),
				Transparency = 1
			}
		):Play()
		Debris:AddItem(clone, lifetime)
	end
end