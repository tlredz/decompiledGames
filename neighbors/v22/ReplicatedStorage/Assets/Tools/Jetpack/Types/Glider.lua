require(game.ServerStorage.Modules.Utility)
local Glider = {}
Glider.Directory = game.ServerStorage.Assets.ToolAssets.Jetpack
Glider.AnimatedModel = false

function Glider.PlayAnimation(p)
	p.AnimationController:LoadAnimation(p.BoneIdle):Play(0)
end

function Glider.SetWeldOffset(instance, instance2)
	task.wait(0.2)
	local lowerTorso = instance:WaitForChild("LowerTorso")
	local motor6D = instance2.PrimaryPart:FindFirstChildOfClass("Motor6D") or Instance.new("Motor6D")
	motor6D.Parent = instance2.PrimaryPart
	motor6D.Part0 = lowerTorso
	motor6D.Part1 = instance2.PrimaryPart
	motor6D.C0 = CFrame.new(-0, 0.8, 0)
end

return Glider