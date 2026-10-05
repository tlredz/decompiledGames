local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local hybridTransformEffects = FX:WaitForChild("PhoenixEffects").HybridTransformEffects
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
local PlaySchemes = require(interpolationScheme:WaitForChild("PlaySchemes"))
return function(p)
	local char = p.char
	local noParticles = p.noParticles
	local humanoidRootPart = char.HumanoidRootPart

	if (humanoidRootPart.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 3000 then
		return
	end

	local clone = hybridTransformEffects.HybridTransformSound:Clone()
	local clone2 = hybridTransformEffects.HybridTransformEffects:Clone()
	clone.Parent = humanoidRootPart

	if noParticles then
		clone2:Destroy()
	else
		clone2.Parent = humanoidRootPart
	end

	destroyAfter(clone, PlaySchemes(clone) + 1)

	if not noParticles then
		destroyAfter(clone2, PlaySchemes(clone2:GetDescendants()) + 1)
	end
end