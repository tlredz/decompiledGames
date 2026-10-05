local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
game:GetService("TweenService")
game:GetService("RunService")
return function(p)
	local cFrame = p.CFrame

	if (cFrame.p - workspace.CurrentCamera.CFrame.p).magnitude > 500 then
		return
	end

	local clones = {}

	for i = 1, 5 do
		local clone = ReplicatedStorage.Assets.Models.SmokeTrail:Clone()
		clone.CFrame = cFrame
		clone.Parent = _WorldOrigin
		clones[i] = clone
	end

	local clone = ReplicatedStorage.Assets.Models.SmokeExplosion:Clone()
	clone.CFrame = cFrame
	clone.Parent = _WorldOrigin
	local lastTime = tick()

	while tick() - lastTime < 0.6 do
		local v = (tick() - lastTime) / 0.6

		for k, v2 in pairs(clones) do
			v2.CFrame = cFrame * CFrame.Angles(0, k * 6.283185307179586 / 5 + v * 3.141592653589793, 0) * CFrame.new(
				0,
				0,
				v * 33
			)
		end

		local RunService = game:GetService("RunService")
		RunService.RenderStepped:Wait()
	end

	clone.Smoke:Emit(26)

	for _, v in pairs(clones) do
		v.Smoke.Enabled = false
	end

	wait(2)

	for _, v in pairs(clones) do
		v:Destroy()
	end

	clone.Smoke.Enabled = false
	wait(2)
	clone:Destroy()
end