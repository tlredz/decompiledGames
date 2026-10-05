return {
	Directory = game.ServerStorage.Assets.ToolAssets.Jetpack,
	AnimatedModel = false,
	SetWeldOffset = function(instance, instance2)
		local humanoid = instance:FindFirstChildOfClass("Humanoid")
		local v = humanoid.BodyDepthScale.Value * 0.6
		local v2 = humanoid.BodyHeightScale.Value * 0.25
		local weld = instance2.PrimaryPart:FindFirstChildOfClass("Weld")

		if weld then
			weld.C1 = CFrame.new(0, 0, v)
			return
		end

		local weld2 = Instance.new("Weld")
		weld2.Parent = instance2.PrimaryPart
		weld2.Part0 = instance2.PrimaryPart
		instance:WaitForChild("UpperTorso")
		weld2.Part1 = instance.UpperTorso
		weld2.C0 = CFrame.Angles(0, -1.5707963267948966, 0)
		weld2.C1 = CFrame.new(0, -v2, v)
	end
}