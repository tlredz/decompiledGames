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
local _ = FX:WaitForChild("TigerEffects").M1
local _ = FX:WaitForChild("TigerEffects").SlashPart
local transformedMoveSounds = script.TransformedMoveSounds
local untransformedMoveSounds = script.UntransformedMoveSounds
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))
return function(p)
	local hrp = p.hrp
	local transformedRig = p.transformedRig

	if hrp == nil or hrp.Parent == nil then
		return
	end

	if transformedRig then
		local running = hrp:FindFirstChild("Running")

		if running then
			running.PlaybackSpeed = transformedMoveSounds.Running.PlaybackSpeed
			running.SoundId = transformedMoveSounds.Running.SoundId
		end

		local jumping = hrp:FindFirstChild("Jumping")

		if jumping then
			local clone = transformedMoveSounds.Jumping.PitchShiftSoundEffect:Clone()
			clone.Parent = jumping
		end

		local landing = hrp:FindFirstChild("Landing")

		if landing then
			local clone_2 = transformedMoveSounds.Landing.PitchShiftSoundEffect:Clone()
			clone_2.Parent = landing
		end
	else
		local running = hrp:FindFirstChild("Running")

		if running then
			running.PlaybackSpeed = untransformedMoveSounds.Running.PlaybackSpeed
			running.SoundId = untransformedMoveSounds.Running.SoundId
		end

		local jumping = hrp:FindFirstChild("Jumping")

		if jumping then
			jumping:ClearAllChildren()
		end

		local landing = hrp:FindFirstChild("Landing")

		if landing then
			landing:ClearAllChildren()
		end
	end
end