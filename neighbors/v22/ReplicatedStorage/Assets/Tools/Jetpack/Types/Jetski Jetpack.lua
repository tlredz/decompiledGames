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

		local v2 = createVector(-0.08003044, -1.4388272, -0.96955967) * humanoid.BodyHeightScale.Value
		v.C0 = CFrame.new(v2.X, v2.Y, v2.Z, 1, 0, 0, 0, 1, 0, 0, 0, 0.9999964237213135)
	end
}