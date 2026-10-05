local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))
return function(data)
	local hrp = data.hrp
	local timeSpedUp = data.timeSpedUp
	local speedMult = data.speedMult
	local transformedRig = data.transformedRig

	if transformedRig == nil or transformedRig.Parent == nil then
		return
	end

	local cube022 = transformedRig:FindFirstChild("Cube.022")

	if cube022 == nil or cube022.Parent == nil or (cube022.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1100 then
		return
	end

	local running = hrp and hrp:FindFirstChild("Running")

	if running then
		running.PlaybackSpeed *= speedMult
		local playbackSpeed = running.PlaybackSpeed
		task.delay(timeSpedUp, function()
			if running.PlaybackSpeed ~= playbackSpeed then
				return
			end

			running.PlaybackSpeed *= 1 / speedMult
		end)
	end

	local clone = FX:WaitForChild("LeopardEffects").OnFire:Clone()
	clone.Enabled = true
	clone.Parent = cube022
	local clone2 = FX:WaitForChild("LeopardEffects").FireSound:Clone()
	local v = Util.UtilSoundWrapper.Play(clone2, cube022)
	task.wait(timeSpedUp)
	clone.Enabled = false
	task.wait(1)
	clone:Destroy()
	v:Destroy()
end