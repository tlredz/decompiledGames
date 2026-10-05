local Carpet = {}
Carpet.Directory = game.ServerStorage.Assets.ToolAssets.Jetpack.Carpets
Carpet.AnimatedModel = true

function Carpet.PlayAnimation(p)
	p.AnimationController:LoadAnimation(p.BoneIdle):Play(0)
end

function Carpet.SetManualScaleOffset(instance, instance2)
	local hipHeight = instance.Humanoid.HipHeight
	local size = instance.HumanoidRootPart.Size
	local weld = instance2.PrimaryPart:FindFirstChildOfClass("Weld")
	weld.C0 = CFrame.new(0, hipHeight + size.Y / 2, 0) * CFrame.fromOrientation(0, 1.5707963267948966, 0)
end

function Carpet.SetWeldOffset(instance, instance2)
	local weld = Instance.new("Weld")
	weld.Parent = instance2.PrimaryPart
	weld.Part0 = instance2.PrimaryPart
	instance:WaitForChild("UpperTorso")
	weld.Part1 = instance.UpperTorso
	local hipHeight = instance.Humanoid.HipHeight
	local size = instance.HumanoidRootPart.Size
	weld.C0 = CFrame.new(0, hipHeight + size.Y / 2, 0) * CFrame.fromOrientation(0, 1.5707963267948966, 0)
end

return Carpet