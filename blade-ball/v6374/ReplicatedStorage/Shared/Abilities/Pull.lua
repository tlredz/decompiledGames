local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3(script.Parent._Types)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
require3(ReplicatedStorage2.Shared.ThreadSafeTargetingHelper)
require3("@game/ReplicatedStorage/Types/Templates")
local Pull = {}
Pull.cooldown = 40
Pull.cooldownReductionPerUpgrade = 6.666666666666667
Pull.iconId = "rbxassetid://14787894058"

function Pull.localOwnerActivation(_)
	if RunService:IsClient() then
		TweenService:Create(
			workspace.CurrentCamera,
			TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, true),
			{
				FieldOfView = 80.5
			}
		):Play()
	end

	return nil
end

function Pull.serverActivationAsync(data)
	for _, child in workspace.Balls:GetChildren() do
		child.TargetCharacter:Invoke(data.character)

		if data.upgradeLevel < 2 then
			local clone = ReplicatedStorage2.Misc.Pull:Clone()
			clone.Parent = workspace.Runtime
			clone.CFrame = data.rootPart.CFrame * CFrame.new(-1, 0, 0)
			clone.CFrame = CFrame.new(clone.Position, child:GetPivot().Position)
			clone.part.CFrame = clone.CFrame * CFrame.new(0, 0, -40)
			clone.part.WeldConstraint.Part1 = clone.part.Parent
			clone.part.ParticleEmitter:Emit(5)
			clone.part.ParticleWhite:Emit(25)
			clone.part.Squares:Emit(7)
			clone.part.squawes:Emit(3)
			clone.Wind:Play()
			clone.dos.TimePosition = 0.4
			clone.dos:Play()
			Debris:AddItem(clone, 5)
		else
			local clone = ReplicatedStorage2.Misc.MaxPull:Clone()
			clone.Parent = workspace.Runtime
			clone.CFrame = data.rootPart.CFrame * CFrame.new(-1, 0, 0)
			clone.CFrame = CFrame.new(clone.Position, child:GetPivot().Position)
			clone.part.CFrame = clone.CFrame * CFrame.new(0, 0, -40)
			clone.part.WeldConstraint.Part1 = clone.part.Parent
			clone.part.Attachment.l1:Emit(1)
			clone.part.ParticleWhite:Emit(20)
			clone.part.Squares:Emit(10)
			clone.Wind.TimePosition = 0.1
			clone.Wind:Play()
			clone.dos.TimePosition = 0.4
			clone.dos:Play()
			Debris:AddItem(clone, 5)
		end
	end

	local animator = data.character:FindFirstChildWhichIsA("Animator", true)

	if animator then
		animator:LoadAnimation(script.PullAnimation):Play()
	end
end

return Pull