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
return function(data)
	local _ = data.player
	local noParticles = data.noParticles
	local char = data.char
	local rigModel = data.rigModel

	if rigModel == nil then
		return
	end

	local humanoidRootPart = char.HumanoidRootPart

	if (humanoidRootPart.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 3000 then
		return
	end

	local wings = rigModel:WaitForChild("wings", 10)

	if not wings then
		return
	end

	local clone = hybridTransformEffects.HybridTransformSound:Clone()
	local clone2 = hybridTransformEffects.HybridTransformEffects:Clone()
	clone.Parent = wings

	if noParticles then
		clone2.Parent = humanoidRootPart
	else
		clone2.Parent = wings
	end

	destroyAfter(clone, PlaySchemes(clone) + 1)
	destroyAfter(clone2, PlaySchemes(clone2:GetDescendants()) + 1)
end