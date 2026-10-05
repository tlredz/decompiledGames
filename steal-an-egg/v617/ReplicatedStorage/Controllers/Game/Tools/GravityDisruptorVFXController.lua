local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local VFX = require(ReplicatedStorage.Shared.Utils.VFX)
return {
	Start = function()
		local gravityDisruptorVFX = ReplicatedStorage.Assets.Particles.GravityDisruptorVFX

		local function collectEmitters(folder)
			local emitters = {}

			for _, emitter in folder:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					table.insert(emitters, emitter)
				end
			end

			return emitters
		end

		local function onBurst(position: Vector3, childName: string)
			if childName ~= "FadeIn" and childName ~= "FadeOut" then
				return
			end

			local child = gravityDisruptorVFX:FindFirstChild(childName)

			if not child then
				return
			end

			VFX.EmitAt(CFrame.new(position), (collectEmitters(child)))
		end

		Remotes.GravityDisruptor.Burst.OnClientEvent:Connect(onBurst)
	end
}