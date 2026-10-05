workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
game:GetService("TweenService")
game:GetService("RunService")
local FX = require(game.ReplicatedStorage.FX)
return function(p)
	local CF = p.CF
	local particle = p.Particle
	local currentCamera = workspace.CurrentCamera
	local magnitude = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - CF.p).Magnitude

	if currentCamera:WorldToScreenPoint(CF.p) and magnitude < 400 then
		local child = FX:WaitForChild(particle, true)

		if not child then
			return
		end

		local clone = child:Clone()
		clone.CFrame = CF
		clone.Parent = workspace._WorldOrigin
		local max = 1

		for _, emitter in pairs(clone.Attachment:GetChildren()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Enabled = true

			if max < emitter.Lifetime.Max then
				max = emitter.Lifetime.Max
			end
		end

		task.delay(max / 2, function()
			for _, emitter in pairs(clone.Attachment:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end
		end)
		Util.Debris:AddItem(clone, max)
	end
end