return {
	Directory = game.ServerStorage.Assets.ToolAssets.Jetpack,
	AnimatedModel = false,
	SetWeldOffset = function(instance, instance2)
		local v = instance.UpperTorso.Size.Y * 0.65
		instance:WaitForChild("UpperTorso")
		local weld = instance2.PrimaryPart:FindFirstChildOfClass("Weld")

		if weld then
			weld.C0 = CFrame.new(0, 0, v) * CFrame.fromOrientation(-0.5235987755982988, 0, 3.141592653589793)
			return
		end

		local weld2 = Instance.new("Weld")
		weld2.Parent = instance2.PrimaryPart
		weld2.Part0 = instance2.PrimaryPart
		weld2.Part1 = instance.UpperTorso
		weld2.C0 = CFrame.new(0, 0, v) * CFrame.fromOrientation(-0.5235987755982988, 0, 3.141592653589793)
	end
}