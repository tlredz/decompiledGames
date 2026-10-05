local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(p)
	local origin = p.Origin

	if (origin.p - workspace.CurrentCamera.CFrame.p).magnitude > 600 then
		return
	end

	local v = Util.Sound:Play("Wind", origin)
	local cFrame = origin * CFrame.Angles(0, 0, 3.141592653589793)
	local clone = game.ReplicatedStorage.Assets.Models.SandTornado:Clone()
	clone.Mesh.Offset = Vector3.new()
	clone.Mesh.Scale = Vector3.new()
	clone.Transparency = 1
	clone.CFrame = cFrame
	local sandDust = clone.SandDust
	clone.Parent = _WorldOrigin
	local lastTime = tick()

	while tick() - lastTime < 0.25 do
		local v3 = math.min(1, (tick() - lastTime) / 0.25)
		clone.CFrame = cFrame * CFrame.Angles(0, -v3 * 3.141592653589793 * 4, 0)
		clone.Transparency = 1 - v3 * 0.9
		clone.Mesh.Scale = createVector(7, 7, 7) * v3
		clone.Mesh.Offset = clone.Mesh.Scale * createVector(0, -1, 0)
		RunService.RenderStepped:Wait()
	end

	clone.Transparency = 0.1
	local lastTime2 = tick()
	local v3 = false

	while tick() - lastTime2 < 2.5 do
		local v4 = math.min(1, (tick() - lastTime2) / 2.5)
		clone.CFrame = cFrame * CFrame.Angles(0, -v4 * 3.141592653589793 * (16 - v4 * 2), 0)
		clone.Mesh.Scale = Vector3.new(math.sin(v4 * 12) * 0.05 + 1, 1, math.sin(v4 * 12) * 0.05 + 1) * (v4 ^ 0.75 * 50 + 7)
		clone.Mesh.Offset = clone.Mesh.Scale * createVector(0, -1, 0)

		if v4 > 0.85 then
			local v5 = ((v4 - 0.85) / 0.15) ^ 2.5
			sandDust.Enabled = false
			clone.Transparency = v5 + 0.1
			clone.Mesh.Scale = clone.Mesh.Scale * Vector3.new(1 - v5, 1, 1 - v5)

			if not v3 then
				Util.Sound:FadeOut(v, 0.4)
				v3 = true
			end
		end

		RunService.RenderStepped:Wait()
	end

	clone:Destroy()
end