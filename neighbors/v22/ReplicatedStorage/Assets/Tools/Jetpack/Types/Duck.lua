local Duck = {}
Duck.Directory = game.ServerStorage.Assets.ToolAssets.Jetpack
Duck.AnimatedModel = true

function Duck.PlayAnimation(p)
	p.AnimationController:LoadAnimation(p.BoneIdle):Play(0)
end

function Duck.SetWeldOffset(instance, instance2)
	instance:WaitForChild("UpperTorso")
	local _ = instance2.Handle.Size.X * -0.025 + instance.UpperTorso.Size.Z * -0.3
	local hipHeight = instance.Humanoid.HipHeight
	local _ = instance.HumanoidRootPart.Size
	local weld = instance2.PrimaryPart:FindFirstChildOfClass("Weld")

	if weld then
		weld.C0 = CFrame.new(0, hipHeight / 1.25, instance.UpperTorso.Size.X * -0.185) * CFrame.fromOrientation(
			-0.4363323129985824,
			3.141592653589793,
			0
		)
		return
	end

	local weld2 = Instance.new("Weld")
	weld2.Parent = instance2.PrimaryPart
	weld2.Part0 = instance2.PrimaryPart
	weld2.Part1 = instance.UpperTorso
	weld2.C0 = CFrame.new(0, hipHeight / 1.25, instance.UpperTorso.Size.X * -0.185) * CFrame.fromOrientation(
		-0.4363323129985824,
		3.141592653589793,
		0
	)
end

return Duck