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

		local v2 = createVector(0, -2.7, -1) * humanoid.BodyHeightScale.Value
		v.C0 = CFrame.new(v2) * CFrame.fromOrientation(0.4363323129985824, 0.08726646259971647, -1.1344640137963142)
	end
}