local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
game:GetService("Debris")
game:GetService("RunService")
require3(ReplicatedStorage2.Packages.Trove)
local v = require3(ReplicatedStorage2.Packages.Freeze)
local v2 = require3(script.Parent.Parent.ParticleUtils)
local v3 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Finishers)
local _ = ReplicatedStorage2.Remotes
local plasmaBlasters = ReplicatedStorage2.Misc.DataFinishers["Plasma Blasters"]
return function(instance, instance2)
	local localPlayer = Players.LocalPlayer
	local v4 = instance == localPlayer.Character or not Players:GetPlayerFromCharacter(instance)

	if instance2 ~= localPlayer.Character then
		local _ = not Players:GetPlayerFromCharacter(instance2)
	end

	if not (instance.PrimaryPart and instance2.PrimaryPart) then
		return
	end

	local plasmaBlasters2 = instance:FindFirstChild("Plasma Blasters") or instance:FindFirstChild("Plasma Blaster")
	local instance3 = v3:GetInstance(script.Name)
	local pivot = instance2:GetPivot()
	local clone = instance3.AttackParticles:Clone()
	local pivot2 = instance:GetPivot()
	clone.CFrame = CFrame.lookAt(pivot2.Position, pivot.Position) * CFrame.new(0, 0, -(clone.Size.Z / 2 + 1.5))
	clone.Parent = workspace
	local v5 = { clone }

	if plasmaBlasters2 then
		table.insert(v5, plasmaBlasters2)
	end

	for _, child in instance3.RootParticles:GetChildren() do
		local clone2 = child:Clone()

		if clone2:IsA("BasePart") then
			local motor6D = clone2:FindFirstChildWhichIsA("Motor6D")

			if not motor6D then
				continue
			end

			motor6D.Part0 = instance.PrimaryPart
			motor6D.Part1 = clone2
			motor6D.Enabled = true
		end

		clone2.Parent = instance.PrimaryPart
		table.insert(v5, clone2)
	end

	local track

	if v4 then
		track = instance.Humanoid.Animator:LoadAnimation(script.Player1)
		track:Play()
	else
		track = nil
	end

	v2.emitParticles(v5)
	task.wait(1)
	v2.disableParticles(v.List.removeValue(v5, plasmaBlasters2))
	task.wait(1)

	for _, v6 in v5 do
		if v6 ~= plasmaBlasters2 then
			v6:Destroy()
		end
	end

	task.delay(plasmaBlasters:GetAttribute("Duration") - 2, function()
		if track then
			track:Stop()
			track:Destroy()
		end
	end)
end