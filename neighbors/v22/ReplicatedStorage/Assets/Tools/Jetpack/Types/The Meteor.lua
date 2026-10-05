local TheMeteor = {}
TheMeteor.Directory = game.ServerStorage.Assets.ToolAssets.Jetpack

function TheMeteor.PlayAnimation(p)
	p.AnimationController:LoadAnimation(p.BoneIdle):Play(0)
end

function TheMeteor.SetWeldOffset(instance, instance2)
	local hipHeight = instance.Humanoid.HipHeight
	local size = instance.HumanoidRootPart.Size
	local weld = instance2.PrimaryPart:FindFirstChildOfClass("Weld")

	if weld then
		weld.C0 = CFrame.new(-1.75 * hipHeight - size.Y / 2, 0, 0) * CFrame.fromOrientation(0, 0, 1.5707963267948966)
		return
	end

	local weld2 = Instance.new("Weld")
	weld2.Parent = instance2.PrimaryPart
	weld2.Part0 = instance2.PrimaryPart
	instance:WaitForChild("UpperTorso")
	weld2.Part1 = instance.UpperTorso
	weld2.C0 = CFrame.new(-1.75 * hipHeight - size.Y / 2, 0, 0) * CFrame.fromOrientation(0, 0, 1.5707963267948966)
end

return TheMeteor