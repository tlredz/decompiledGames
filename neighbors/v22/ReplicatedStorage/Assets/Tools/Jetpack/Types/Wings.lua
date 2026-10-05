local _ = script.Parent.Parent
local Wings = {}
Wings.Directory = game.ServerStorage.Assets.ToolAssets.Jetpack.Wings
Wings.AnimatedModel = true

function Wings.SetWeldOffset(instance, instance2)
	instance:WaitForChild("UpperTorso")
	local v = instance2.Handle.Size.X * -0.025 + instance.UpperTorso.Size.Z * -0.3
	local weld = instance2.PrimaryPart:FindFirstChildOfClass("Weld")

	if weld then
		weld.C0 = CFrame.new(0, 0, v)
		return
	end

	local weld2 = Instance.new("Weld")
	weld2.Parent = instance2.PrimaryPart
	weld2.Part0 = instance2.PrimaryPart
	weld2.Part1 = instance.UpperTorso
	weld2.C0 = CFrame.new(0, 0, v)
end

function Wings.PlayAnimation(p)
	local track = p.AnimationController:LoadAnimation(p.BoneIdle)
	track:Play(0)
	return track
end

return Wings