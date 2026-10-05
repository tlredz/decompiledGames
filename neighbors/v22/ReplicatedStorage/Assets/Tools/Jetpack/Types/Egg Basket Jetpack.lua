return {
	Directory = game.ServerStorage.Assets.ToolAssets.Jetpack,
	AnimatedModel = false,
	SetWeldOffset = function(instance, instance2)
		instance:WaitForChild("UpperTorso")
		local humanoid = instance:FindFirstChildOfClass("Humanoid")
		local v = instance2.PrimaryPart:FindFirstChild("Handle")
		local bodyDepthScale = humanoid.BodyDepthScale

		if not v then
			v = Instance.new("Weld")
			v.Name = "Handle"
			v.Part1 = instance2:WaitForChild("Handle")
			v.Part0 = instance.UpperTorso
			v.Parent = instance2.PrimaryPart
		end

		v.C0 = CFrame.new(0, 0, bodyDepthScale.Value) * CFrame.Angles(0, 0, 0)
		instance2.PrimaryPart.Size = instance.UpperTorso.Size
	end
}