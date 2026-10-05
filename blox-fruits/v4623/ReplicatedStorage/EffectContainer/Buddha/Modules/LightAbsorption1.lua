local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
Vector3.new()
require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = Util.LightningBolt2
local promise = Util.Promise
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local awaitHeartbeatLoopFor = heartbeatLoopFor.AwaitHeartbeatLoopFor

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function cubicHermite(p, p2, p3, position, p4)
	return (2 * p ^ 3 - 3 * p ^ 2 + 1) * p2 + (p ^ 3 - 2 * p ^ 2 + p) * p3 + (-2 * p ^ 3 + 3 * p ^ 2) * position + (p ^ 3 - p ^ 2) * p4
end

local function RandomVectorOffsetBetween(unit, p, p2)
	return (CFrame.lookAt(Vector3.new(), unit) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p2), (math.cos(p))))),
		0,
		0
	)).LookVector
end

local function buddhaAbsorb(p, p2, instance)
	local _ = Workspace.CurrentCamera
	local model = Instance.new("Model")
	model.Parent = _WorldOrigin
	local part = Instance.new("Part")
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.Size = createVector(1, 1, 1)
	part.Shape = Enum.PartType.Ball
	part.CFrame = CFrame.new(p.Position)
	local attachment = Instance.new("Attachment", part)
	local attachment2 = Instance.new("Attachment", part)
	attachment.Position = createVector(0, -1, 0)
	attachment2.Position = createVector(0, 1, 0)
	local clone = script.Trail:Clone()
	clone.Attachment0 = attachment
	clone.Attachment1 = attachment2
	clone.Parent = part
	local clone2 = part:Clone()
	clone2.Parent = model
	clone2.Name = "center"
	local clone3 = script.Rays:Clone()
	clone3.Parent = clone2
	clone3.Size = NumberSequence.new(math.min(200, p2), 0)
	clone3.Enabled = true
	local clone4 = script.Charge:Clone()
	clone4.Parent = clone2
	clone4.Size = NumberSequence.new(math.min(200, p2), 0)
	clone4.Enabled = true
	local clone5 = script.Rays_Thick:Clone()
	clone5.Parent = clone2
	clone5.Size = NumberSequence.new(math.min(100, 0.5 * p2), (math.min(200, p2)))
	clone5.Enabled = true
	local clone6 = script.Pulse:Clone()
	clone6.Parent = clone2
	clone6.Size = NumberSequence.new(math.min(200, p2), 0)
	clone6.Enabled = true

	if instance then
		for _, child in pairs(model:GetChildren()) do
			Util.SetParentOverrideWithColor(child, model, instance.Parent, instance.Name)
		end

		model.ChildAdded:Connect(function(child)
			Util.SetParentOverrideWithColor(child, model, instance.Parent, instance.Name)
		end)
	end

	awaitHeartbeatLoopFor(instance and 2 or 0.5, function(_, _)
		clone2.Position = p.Position

		for _ = 1, 2 do
			local unit = (createVector(1, 2, 1)).Unit
			local v2 = p.Position + RandomVectorOffsetBetween(unit, 0, 3.141592653589793) * p2 * 0.8
			local v3 = unit:Cross(v2 - p.Position).Unit * p2 * 2
			local _ = p.Position
			local v4 = -v3
			local clone7 = part:Clone()
			clone7.CFrame = CFrame.new(v2)
			clone7.Parent = model
			local v9 = clone7
			heartbeatLoopFor2(0.2, function(p3)
				local v10 = p3 / 0.2
				clone7.CFrame = CFrame.new(cubicHermite(v10, v2, v3, p.Position, v4))
			end, function()
				v9:Destroy()
			end)
		end
	end)
	clone3.Enabled = false
	clone4.Enabled = false
	clone5.Enabled = false
	clone6.Enabled = false
	promise.delay(0.4):await()
	part:Destroy()
	model:Destroy()
end

return buddhaAbsorb