return {
	Directory = game.ServerStorage.Assets.ToolAssets.Jetpack,
	AnimatedModel = false,
	SetWeldOffset = function(instance, instance2)
		local midpoint = (instance2.Handle.Size.Z * 0.5 + instance.UpperTorso.Size.Z * 0.3) / 2
		local weld = instance2.PrimaryPart:FindFirstChildOfClass("Weld")

		if weld then
			weld.C1 = CFrame.new(0, 0, midpoint)
			return
		end

		local weld2 = Instance.new("Weld")
		weld2.Parent = instance2.PrimaryPart
		weld2.Part0 = instance2.PrimaryPart
		instance:WaitForChild("UpperTorso")
		weld2.Part1 = instance.UpperTorso
		weld2.C0 = CFrame.Angles(0, 1.5707963267948966, -1.5707963267948966)
		weld2.C1 = CFrame.new(0, 0, midpoint)
	end
}