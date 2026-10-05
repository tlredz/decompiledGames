return {
	Directory = game.ServerStorage.Assets.ToolAssets.Jetpack,
	AnimatedModel = false,
	SetWeldOffset = function(instance, p)
		local humanoid = instance:FindFirstChildOfClass("Humanoid")
		local leftFoot = instance:WaitForChild("LeftFoot", 5)

		if not leftFoot then
			return
		end

		local v = p.Handle:FindFirstChild("Handle")
		local bodyHeightScale = humanoid.BodyHeightScale
		local bodyDepthScale = humanoid.BodyDepthScale
		instance:WaitForChild("UpperTorso")

		if not v then
			v = Instance.new("Weld")
			v.Name = "Handle"
			v.Part1 = leftFoot
			v.Part0 = p.Handle
			v.Parent = p.Handle
		end

		v.C0 = CFrame.new(
			-0.26,
			0.23 * bodyHeightScale.Value,
			3.14 * bodyDepthScale.Value,
			0,
			-1,
			-0,
			-1,
			0,
			-0,
			0,
			0,
			-1
		)
	end
}