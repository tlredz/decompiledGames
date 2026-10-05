local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
game:GetService("TweenService")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local rengokuSkill1 = FX:WaitForChild("Rengoku").RengokuSkill1
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
return function(p)
	local hrp = p.hrp

	if hrp == nil or hrp.Parent == nil then
		warn("Missing hrp, effect code aborted")
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	local duration = p.duration or 3
	local burn = rengokuSkill1.Burn

	for _, part in ipairs(hrp.Parent:GetChildren()) do
		if not part:IsA("MeshPart") then
			continue
		end

		for _, emitter in ipairs(burn.Attachment2:GetChildren()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local clone = emitter:Clone()
			clone.Parent = part
			clone.Enabled = true
			coroutine.wrap(function()
				task.wait(duration + 0.15)
				clone.Enabled = false
				destroyAfter(clone, 2)
			end)()
		end
	end

	local clone = burn:Clone()
	clone.Attachment2:Destroy()
	clone.Parent = Workspace._WorldOrigin
	clone.Weld.Part0 = hrp
	coroutine.wrap(function()
		task.wait(duration + 0.15)

		for _, emitter in ipairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		destroyAfter(clone, 2)
	end)()
end