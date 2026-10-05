local RunService = game:GetService("RunService")
return {
	Directory = game.ServerStorage.Assets.ToolAssets.Jetpack,
	AnimatedModel = false,
	SetWeldOffset = function(instance, instance2)
		instance:WaitForChild("UpperTorso")
		local v = instance2.Handle.Size.X * 0.5 + instance.UpperTorso.Size.Z * 0.3
		local v2 = instance2.PrimaryPart:FindFirstChildOfClass("Weld")

		if not v2 then
			v2 = Instance.new("Weld")
			v2.Parent = instance2.PrimaryPart
			v2.Part0 = instance2.PrimaryPart
			v2.Part1 = instance.UpperTorso
			v2.C0 = CFrame.new(0, 0.25, 1)
		end

		v2.C1 = CFrame.new(0, 0, v)
		local C0 = v2.C0
		local total = 0
		local heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
			total += dt * 1.0471975511965976
			v2.C0 = C0 * CFrame.Angles(0, 0, total)
		end)
		instance2.Destroying:Connect(function()
			heartbeatConnection:Disconnect()
		end)
	end
}