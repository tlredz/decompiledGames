local createVector = vector.create
return {
	Directory = game.ServerStorage.Assets.ToolAssets.Jetpack,
	AnimatedModel = false,
	SetWeldOffset = function(instance, instance2)
		local humanoid = instance:FindFirstChildOfClass("Humanoid")
		local v = instance2.PrimaryPart:FindFirstChild("Handle")

		if not v then
			v = Instance.new("Motor6D")
			v.Name = "Handle"
			v.Part1 = instance2:WaitForChild("Handle")
			instance:WaitForChild("LowerTorso")
			v.Part0 = instance.LowerTorso
			v.Parent = instance2.PrimaryPart
		end

		local v2 = createVector(-0.08, -2.089, 0.012) * humanoid.BodyHeightScale.Value
		v.C0 = CFrame.new(v2) * CFrame.Angles(0, -1.5707963267948966, 0)
	end
}