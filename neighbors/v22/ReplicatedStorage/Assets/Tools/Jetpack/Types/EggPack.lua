return {
	Directory = game.ServerStorage.Assets.ToolAssets.Jetpack,
	AnimatedModel = false,
	SetWeldOffset = function(instance, instance2)
		instance:WaitForChild("UpperTorso")
		local v = instance2.Handle.Size.X * 0.5 + instance.UpperTorso.Size.Z * 0.3
		local weld = instance2.PrimaryPart:FindFirstChildOfClass("Weld")

		if weld then
			weld.C0 = CFrame.Angles(0, -3.141592653589793, 0)
			weld.C1 = CFrame.new(0, 0, v)
		else
			local weld2 = Instance.new("Weld")
			weld2.Parent = instance2.PrimaryPart
			weld2.Part0 = instance2.PrimaryPart
			weld2.Part1 = instance.UpperTorso
			weld2.C0 = CFrame.Angles(0, -3.141592653589793, 0)
			weld2.C1 = CFrame.new(0, 0, v)
		end
	end
}