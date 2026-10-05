local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Net = require(ReplicatedStorage.packages.Net)
local lavaExplosion = ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("general"):WaitForChild("Lava Explosion")
local VolcanicLavaController = {
	CreateExplosion = function(data)
		local clone = lavaExplosion:Clone()
		clone.CFrame = CFrame.new(data.pos)

		for _, emitter in clone.charge:GetChildren() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = true
			end
		end

		clone.CanCollide = false
		clone.CanTouch = false
		clone.CanQuery = false
		clone.Parent = workspace.active
		local v = data.time - workspace:GetServerTimeNow()

		if v > 0 then
			clone.Size = createVector(0, 0, 0)
			clone.Transparency = 0
			local v2 = data.radius * 2
			TweenService:Create(clone, TweenInfo.new(v, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
				Size = Vector3.new(v2, v2, v2)
			}):Play()
			task.wait(v)
			clone.Transparency = 1
		end

		for _, emitter in clone.charge:GetChildren() do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		clone.Smoke:Emit(25)

		for _, emitter in clone.main:GetChildren() do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(15)
			end
		end

		clone.lavaExplosion:Play()
		task.delay(10, function()
			clone:Destroy()
		end)
		local primaryPart = localPlayer.Character and localPlayer.Character.PrimaryPart

		if primaryPart and (primaryPart.Position - data.pos).Magnitude < data.radius + 2 then
			local humanoid = localPlayer.Character:FindFirstChildWhichIsA("Humanoid")
			primaryPart:ApplyImpulse(((primaryPart.Position - data.pos) * createVector(1, 0, 1)).Unit * primaryPart.AssemblyMass * 25 + Vector3.new(
				0,
				25 * primaryPart.AssemblyMass,
				0
			))

			if humanoid then
				humanoid:ChangeState(Enum.HumanoidStateType.Physics)
				task.delay(2, function()
					humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
				end)
			end
		end
	end
}

function VolcanicLavaController.Start(_)
	Net:RemoteEvent("VolcanicLava/Explode", -1).OnClientEvent:Connect(VolcanicLavaController.CreateExplosion)
end

return VolcanicLavaController