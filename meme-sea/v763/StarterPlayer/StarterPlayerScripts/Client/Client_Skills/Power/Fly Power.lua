local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Debris")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
ReplicatedStorage:WaitForChild("OtherEvent")
local skillFolder = ReplicatedStorage:WaitForChild("SkillFolder")
local skills = workspace:WaitForChild("Skills")
local PlaySound = require(moduleScript:WaitForChild("PlaySound"))
local Generate = require(moduleScript:WaitForChild("Generate"))
return {
	F = {
		Hold = function(enemy: string, sound: string, _: string, data)
			local skill_Releaser = data.Skill_Releaser
			local releaser_Id = data.Releaser_Id
			local duration = data.Duration
			local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")
			local clone = skillFolder[enemy][sound]:Clone()
			clone.Name = `{releaser_Id}_{enemy}_{sound}`
			clone.CanCollide = false
			clone.Anchored = false
			clone.Parent = skills
			local now = os.clock()
			local total = 0
			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				total += dt

				if total >= 1 then
					total = 0
					local now2 = os.clock()

					if now + duration <= now2 or not (clone and clone.Parent) then
						if clone and clone.Parent then
							clone:Destroy()
						end

						if heartbeatConnection then
							heartbeatConnection:Disconnect()
							heartbeatConnection = nil
						end
					end
				end
			end)
			PlaySound.PlaySound_Character(skill_Releaser, {
				Folder = "Power_Sound",
				Enemy = enemy,
				Sound = sound
			})

			if humanoidRootPart then
				local weld = Instance.new("Weld")
				weld.Parent = clone
				weld.Part0 = clone
				weld.Part1 = humanoidRootPart
				weld.C1 *= CFrame.new(0, 0, 2)
			end

			for _, emitter in ipairs(clone:GetChildren()) do
				if not emitter:IsA("ParticleEmitter") or emitter.Enabled then
					continue
				end

				Generate.SetParticle(emitter)
				emitter.Enabled = true
			end
		end,
		Release = function(p: string, p2: string, _: string, p3)
			local skill_Releaser = p3.Skill_Releaser
			local child = skills:FindFirstChild((`{p3.Releaser_Id}_{p}_{p2}`))

			if child and child.Parent then
				child:Destroy()
			end

			local humanoidRootPart = skill_Releaser:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				PlaySound.FadingSound_Out(humanoidRootPart, 0.5, p2)
			end
		end
	}
}