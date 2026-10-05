local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
local inverse = CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local fingerMesh = FX:WaitForChild("LeopardEffects").FingerMesh
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))
return function(data)
	local hrp = data.hrp
	local origin = data.origin
	local velocity = data.velocity
	local fliesFor = data.fliesFor
	local _ = data.airBulletSizeMult
	local currentCamera = Workspace.CurrentCamera

	if hrp and hrp.Parent ~= nil and math.random() < 0.8 then
		local clone = fingerMesh.Parent.ZPunch:Clone()

		if data.transformedRig then
			clone:SetAttribute("PlaybackSpeed", clone:GetAttribute("PlaybackSpeed") * 0.8)
		end

		clone.Parent = hrp
		Util.UtilSoundWrapper.Play(clone, hrp.Position)
		clone:Destroy()
	end

	if (origin - currentCamera.CFrame.Position).Magnitude > 1100 then
		return
	end

	if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude < 110 then
		Util.CameraShaker:ShakeOnce(3, 3, 0.01, 0.05)
	end

	local clone = fingerMesh:Clone()
	clone.CFrame = CFrame.lookAt(origin, origin + velocity) * inverse * CFrame.Angles(0, 3.141592653589793, 0)
	clone.Parent = _WorldOrigin
	clone.Particles.SwirlyWave:Emit(1)
	clone.Particles.ExplodingWave:Emit(1)
	destroyAfter(clone, fliesFor + 1)
	task.wait()
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = createVector(1.2980742e33, 1.2980742e33, 1.2980742e33)
	local v = velocity.Magnitude * fliesFor / ((1 - 2 ^ (-12 * fliesFor)) / 8.317766166719343)
	local velocity2 = velocity.Unit * v
	bodyVelocity.Velocity = velocity2
	bodyVelocity.Parent = clone
	clone.Anchored = false
	heartbeatLoopFor2(fliesFor + 0.5, function(p)
		bodyVelocity.Velocity = velocity2 * 2 ^ (p * -12)
	end)
	local windTrailAttach1 = clone.WindTrailAttach1
	local windTrailAttach2 = clone.WindTrailAttach2
	local v3 = (windTrailAttach1.Position + windTrailAttach2.Position) * 0.5
	heartbeatLoopFor2(fliesFor, function()
		windTrailAttach1.CFrame = CFrame.Angles(0, 0.8, 0) * (windTrailAttach1.CFrame - v3) + v3
		windTrailAttach2.CFrame = CFrame.Angles(0, 0.8, 0) * (windTrailAttach2.CFrame - v3) + v3
	end)
	task.delay(fliesFor - 0.1, function()
		clone.Particles.EndingWave:Emit(1)
	end)
	task.wait(fliesFor)

	for _, child in ipairs(clone.Particles:GetChildren()) do
		child.Enabled = false
	end

	clone.WindTrail.Enabled = false
	clone.WindTrail2.Enabled = false
	clone.WindTrail3.Enabled = false
	clone.Transparency = 1
end