local _ = script.Parent.Parent
local HolyWings = {}
HolyWings.Directory = game.ServerStorage.Assets.ToolAssets.Jetpack
HolyWings.AnimatedModel = true

function HolyWings.SetWeldOffset(instance, instance2)
	instance:WaitForChild("UpperTorso")
	local v = instance2.Handle.Size.X * -0.025 + instance.UpperTorso.Size.Z * -0.3
	local value = instance:FindFirstChild("BodyHeightScale", true).Value
	local weld = instance2.PrimaryPart:FindFirstChildOfClass("Weld")

	if weld then
		weld.C0 = CFrame.new(v * 2.5, -value / 2.5, 0) * CFrame.Angles(0, 1.5707963267948966, 0)
		return
	end

	local weld2 = Instance.new("Weld")
	weld2.Parent = instance2.PrimaryPart
	weld2.Part0 = instance2.PrimaryPart
	weld2.Part1 = instance.UpperTorso
	weld2.C0 = CFrame.new(v * 2.5, -value / 2.5, v * 2.5) * CFrame.Angles(0, 1.5707963267948966, 0)
end

function HolyWings.PlayAnimation(p)
	local track = p.AnimationController:LoadAnimation(p.BoneIdle)
	track:Play(0)
	return track
end

return HolyWings