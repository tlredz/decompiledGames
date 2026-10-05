local Cloud = {}
Cloud.Directory = game.ServerStorage.Assets.ToolAssets.Jetpack.Clouds
Cloud.AnimatedModel = true

function Cloud.PlayAnimation(p)
	p.AnimationController:LoadAnimation(p.BoneIdle):Play(0)
end

function Cloud.SetWeldOffset(instance, instance2)
	instance:WaitForChild("UpperTorso")
	local _ = instance2.Handle.Size.X * -0.025 + instance.UpperTorso.Size.Z * -0.3
	local hipHeight = instance.Humanoid.HipHeight
	local size = instance.HumanoidRootPart.Size
	local weld = instance2.PrimaryPart:FindFirstChildOfClass("Weld")

	if weld then
		weld.C0 = CFrame.new(0, hipHeight + size.Y / 2, 0) * CFrame.fromOrientation(0, 1.5707963267948966, 0)
		return
	end

	local weld2 = Instance.new("Weld")
	weld2.Parent = instance2.PrimaryPart
	weld2.Part0 = instance2.PrimaryPart
	weld2.Part1 = instance.UpperTorso
	weld2.C0 = CFrame.new(0, hipHeight + size.Y / 2, 0) * CFrame.fromOrientation(0, 1.5707963267948966, 0)
end

return Cloud