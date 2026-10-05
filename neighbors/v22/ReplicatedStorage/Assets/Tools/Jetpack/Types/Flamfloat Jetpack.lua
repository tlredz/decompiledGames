return {
	Directory = game.ServerStorage.Assets.ToolAssets.Jetpack,
	AnimatedModel = false,
	SetWeldOffset = function(instance, instance2)
		instance:WaitForChild("LowerTorso")
		instance2.PrimaryPart:FindFirstChildOfClass("Weld")
		local weld = Instance.new("Weld")
		weld.Parent = instance2.PrimaryPart
		weld.Part0 = instance2.PrimaryPart
		weld.Part1 = instance.LowerTorso
		weld.C0 = CFrame.new(0, -0.5, 0) * CFrame.Angles(0, -3.141592653589793, 0)
	end
}