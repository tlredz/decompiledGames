return {
	Directory = game.ServerStorage.Assets.ToolAssets.Jetpack,
	AnimatedModel = false,
	SetWeldOffset = function(instance, instance2)
		instance:WaitForChild("UpperTorso")
		instance:FindFirstChildOfClass("Humanoid")

		if not instance2.PrimaryPart:FindFirstChild("Handle") then
			local weld = Instance.new("Weld")
			weld.Name = "Handle"
			weld.Part1 = instance2:WaitForChild("Handle")
			weld.Part0 = instance.UpperTorso
			weld.Parent = instance2.PrimaryPart
		end

		instance2.PrimaryPart.Size = instance.UpperTorso.Size
	end
}