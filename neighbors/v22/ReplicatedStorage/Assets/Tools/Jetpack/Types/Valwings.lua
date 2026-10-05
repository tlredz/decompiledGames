local Valwings = {}
Valwings.Directory = game.ServerStorage.Assets.ToolAssets.Jetpack
Valwings.AnimatedModel = true

function Valwings.SetWeldOffset(instance, instance2)
	instance:WaitForChild("UpperTorso")
	local v = instance2.Handle.Size.X * 0.15 + instance.UpperTorso.Size.Z * 0.15
	local weld = instance2.PrimaryPart:FindFirstChildOfClass("Weld")

	if weld then
		weld.C0 = CFrame.Angles(0, 3.141592653589793, 0)
		weld.C1 = CFrame.new(0, instance.UpperTorso.Size.Y - 0.37, v)
	else
		local weld2 = Instance.new("Weld")
		weld2.Parent = instance2.PrimaryPart
		weld2.Part0 = instance2.PrimaryPart
		weld2.Part1 = instance.UpperTorso
		weld2.C0 = CFrame.Angles(0, 3.141592653589793, 0)
		weld2.C1 = CFrame.new(0, instance.UpperTorso.Size.Y - 0.37, v)
	end
end

function Valwings.PlayAnimation(p)
	local track = p.AnimationController:LoadAnimation(p.BoneIdle)
	track:Play(0)
	return track
end

return Valwings