local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local function setupCharacterParticles(instance)
	pcall(function()
		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart", 3)
		local particleThing = humanoidRootPart and humanoidRootPart:WaitForChild("ParticleThing", 3)

		if particleThing then
			local config = localPlayer:FindFirstChild("Config")

			if config then
				local particleToggle = config:FindFirstChild("ParticleToggle")

				if particleToggle and not particleToggle.Value then
					return
				end
			end

			if particleThing:IsA("ParticleEmitter") then
				particleThing.Enabled = true
			end
		end
	end)
end

localPlayer.CharacterAdded:Connect(setupCharacterParticles)

if localPlayer.Character then
	local character = localPlayer.Character
	pcall(function()
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 3)
		local particleThing = humanoidRootPart and humanoidRootPart:WaitForChild("ParticleThing", 3)

		if particleThing then
			local config = localPlayer:FindFirstChild("Config")

			if config then
				local particleToggle = config:FindFirstChild("ParticleToggle")

				if particleToggle and not particleToggle.Value then
					return
				end
			end

			if particleThing:IsA("ParticleEmitter") then
				particleThing.Enabled = true
			end
		end
	end)
end