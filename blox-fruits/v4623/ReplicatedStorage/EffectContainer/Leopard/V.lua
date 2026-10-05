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
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local _ = FX:WaitForChild("LeopardEffects").M1
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local awaitHeartbeatLoopFor = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))

-- equivalent calls inferred from this helper; original call sites unknown
local function setRigTransparency(data, p)
	data["Cube.001"].Transparency = 0.9 + 0.1 * p
	data["adasds.001"].Transparency = p ^ 4
	data["adasds.005"].Transparency = 0.01 + 0.99 * p
end

return function(data)
	local _ = data.player
	local hrp = data.hrp
	local _ = data.isForTransformation

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local currentCamera = Workspace.CurrentCamera

	if (hrp.Position - currentCamera.CFrame.Position).Magnitude > 600 then
		return
	end

	local clone = FX:WaitForChild("LeopardEffects").LeopardRigGhost:Clone()
	clone.PrimaryPart = clone.RootPart
	clone:PivotTo(hrp.CFrame * CFrame.new(0, 10, 0))

	for _, part in ipairs(clone:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Transparency = 1
		end
	end

	clone.Parent = _WorldOrigin
	destroyAfter(clone, 2)
	local leopardRoarPoseGhost = Util.Anims:Get(clone, "LeopardRoarPoseGhost")
	leopardRoarPoseGhost.Priority = Enum.AnimationPriority.Action2
	leopardRoarPoseGhost.Looped = true
	leopardRoarPoseGhost:Play()

	for _ = 1, 2 do
		clone["adasds.001"].Eye1.BeamSpark:Emit(2)
		clone["adasds.001"].Eye2.BeamSpark:Emit(2)
		awaitHeartbeatLoopFor(0.15, function(_, _, p)
			setRigTransparency(clone, 1 - p) -- equivalent call inferred; original call site unknown
		end)
		clone["Cube.001"].Transparency = 0.9
		clone["adasds.001"].Transparency = 0
		clone["adasds.005"].Transparency = 0.01
		awaitHeartbeatLoopFor(0.15, function(_, _, p)
			setRigTransparency(clone, p) -- equivalent call inferred; original call site unknown
		end)
		clone["Cube.001"].Transparency = 1
		clone["adasds.001"].Transparency = 1
		clone["adasds.005"].Transparency = 1
		task.wait(0.15)
	end
end