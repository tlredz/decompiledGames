local HeartCloud = {}
HeartCloud.Directory = game.ServerStorage.Assets.ToolAssets.Jetpack
HeartCloud.AnimatedModel = true

function HeartCloud.PlayAnimation(p)
	p.AnimationController:LoadAnimation(p.BoneIdle):Play(0)
end

function HeartCloud.SetWeldOffset(instance, instance2)
	instance:WaitForChild("UpperTorso")
	local _ = instance2.Handle.Size.X * -0.055 + instance.UpperTorso.Size.Z * -0.5
	local hipHeight = instance.Humanoid.HipHeight
	local size = instance.HumanoidRootPart.Size
	local weld = instance2.PrimaryPart:FindFirstChildOfClass("Weld")

	if weld then
		weld.C0 = CFrame.new(0, hipHeight + size.Y / 8, 0) * CFrame.fromOrientation(0, -1.5707963267948966, 0)
		return
	end

	local weld2 = Instance.new("Weld")
	weld2.Parent = instance2.PrimaryPart
	weld2.Part0 = instance2.PrimaryPart
	weld2.Part1 = instance.UpperTorso
	weld2.C0 = CFrame.new(0, hipHeight + size.Y / 8, 0) * CFrame.fromOrientation(0, -1.5707963267948966, 0)
end

return HeartCloud