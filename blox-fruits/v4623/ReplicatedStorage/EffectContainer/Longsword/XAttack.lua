local createVector = vector.create
game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt
local currentCamera = workspace.CurrentCamera
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace._WorldOrigin, workspace.Characters, workspace.Enemies }
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local X = FX:WaitForChild("Longsword").X
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

local function mockRootPart(_, cFrame: CFrame)
	local part = Instance.new("Part")
	part.Name = "Mock" .. part.Name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cFrame
	part.Parent = _WorldOrigin
	destroyAfter(part, 7)
	return part
end

return function(p)
	local origin = p.origin
	local fireDir = p.fireDir

	if (currentCamera.CFrame.p - origin).Magnitude > 500 then
		return
	end

	Util.Sound:Play("FWoosh__9985620216", origin, 20, 1.2, 0.8)
	local clone = X.Phase2.GrabImpact:Clone()
	Util.Debris:AddItem(clone, 5)
	clone.CFrame = CFrame.lookAt(createVector(0, 0, 0), fireDir) + origin
	clone.Parent = _WorldOrigin

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end
end