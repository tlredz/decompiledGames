local UFO = {}
UFO.Directory = game.ServerStorage.Assets.ToolAssets.Jetpack
UFO.AnimatedModel = false

function UFO.PlayAnimation(p)
	p.AnimationController:LoadAnimation(p.BoneIdle):Play(0)
end

function UFO.SetWeldOffset(instance, instance2)
	local _ = instance.Humanoid.HipHeight
	local size = instance.HumanoidRootPart.Size
	local weld = instance2.PrimaryPart:FindFirstChildOfClass("Weld")

	if weld then
		weld.C0 = CFrame.new(0, size.Y / 2, 0)
		return
	end

	local weld2 = Instance.new("Weld")
	weld2.Parent = instance2.PrimaryPart
	weld2.Part0 = instance2.PrimaryPart
	instance:WaitForChild("UpperTorso")
	weld2.Part1 = instance.UpperTorso
	weld2.C0 = CFrame.new(0, size.Y / 2, 0)
end

return UFO