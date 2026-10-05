return {
	Directory = game.ServerStorage.Assets.ToolAssets.Jetpack,
	AnimatedModel = false,
	SetWeldOffset = function(instance, instance2)
		local humanoid = instance:FindFirstChildOfClass("Humanoid")
		local v = instance2.PrimaryPart:FindFirstChild("Handle")
		local _ = humanoid.BodyHeightScale
		local bodyDepthScale = humanoid.BodyDepthScale

		if not v then
			v = Instance.new("Weld")
			v.Name = "Handle"
			instance:WaitForChild("UpperTorso")
			v.Part0 = instance.UpperTorso
			v.Part1 = instance2:WaitForChild("Handle")
			v.Parent = instance2.PrimaryPart
		end

		v.C0 = CFrame.new(0, 0, 0.75 * bodyDepthScale.Value) * CFrame.Angles(0, 1.5707963267948966, 0)
	end
}