return {
	Directory = game.ServerStorage.Assets.ToolAssets.Jetpack,
	AnimatedModel = false,
	SetWeldOffset = function(instance, instance2)
		if not instance2.PrimaryPart then
			instance2.PrimaryPart = instance2:FindFirstChild("Handle")
		end

		local v = instance2.PrimaryPart:FindFirstChildOfClass("Weld")
		local headScale = instance:FindFirstChild("HeadScale", true)

		if not v then
			v = Instance.new("Weld")
			v.Parent = instance2.PrimaryPart
			v.Part0 = instance2.PrimaryPart
			instance:WaitForChild("Head")
			v.Part1 = instance.Head
		end

		v.C0 = CFrame.new(0, -(headScale.Value - 0.25), 0)
	end
}