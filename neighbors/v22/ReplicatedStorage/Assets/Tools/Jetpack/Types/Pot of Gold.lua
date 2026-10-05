return {
	Directory = game.ServerStorage.Assets.ToolAssets.Jetpack,
	AnimatedModel = false,
	SetWeldOffset = function(instance, instance2)
		instance:WaitForChild("LowerTorso")
		local humanoid = instance:FindFirstChildOfClass("Humanoid")
		local v = instance2.PrimaryPart:FindFirstChild("Handle")
		local bodyHeightScale = humanoid.BodyHeightScale
		local bodyDepthScale = humanoid.BodyDepthScale

		if not v then
			v = Instance.new("Motor6D")
			v.Name = "Handle"
			v.Part1 = instance2:WaitForChild("Handle")
			v.Part0 = instance.LowerTorso
			v.Parent = instance2.PrimaryPart
		end

		v.C0 = CFrame.new(0, 0.66 * bodyHeightScale.Value, 0.127 * bodyDepthScale.Value, 0, 0, -1, 0, 1, 0, 1, 0, 0)
		local clone = script:FindFirstChild("Cauldron"):Clone()
		clone.Part0 = instance.LowerTorso
		clone.Part1 = instance2.Handle
		clone.Parent = instance.LowerTorso
		instance2.Destroying:Once(function()
			clone:Destroy()
			local clone2 = script:FindFirstChild("Cauldron"):Clone()
			clone2.Part0 = instance.LowerTorso
			clone2.Part1 = instance2.Handle
			clone2.Parent = instance.LowerTorso
		end)
	end
}