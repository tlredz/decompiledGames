local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local part = Instance.new("Part")
part.Anchored = true
part.CanCollide = false
part.CastShadow = false
part.Locked = true
part.CanTouch = false
part.CanQuery = false
part.Shape = "Ball"
part.Size = createVector(2, 2, 2)
part.Transparency = 1
part.Name = "Electron"
local attachment = Instance.new("Attachment")
attachment.Parent = part
attachment.CFrame = CFrame.new(0, 1, 0)
attachment.Name = "a1"
local attachment2 = Instance.new("Attachment")
attachment2.Parent = part
attachment2.CFrame = CFrame.new(0, -1, 0)
attachment2.Name = "a2"

function RandomVectorOffset(p, p2)
	return (CFrame.new(Vector3.new(), p) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p2), 1))),
		0,
		0
	)).LookVector
end

function SamysSwirlSpline(data, data2, p)
	local v = math.exp(-0.19 * p)
	local v2 = v * (data.X * math.cos(0.8 * p) + (data2.X - -0.19 * data.X) / 0.8 * math.sin(0.8 * p))
	local v3 = ((1 - v) ^ 3 * 2 - (1 - v) ^ 2 * 3 + 1) * data.Y + ((1 - v) ^ 3 - (1 - v) ^ 2 * 2 + (1 - v)) * data2.Y
	local v4 = v * (data.Z * math.cos(0.8 * p) + (data2.Z - -0.19 * data.Z) / 0.8 * math.sin(0.8 * p))
	local v5 = v * (math.sin(0.8 * p) * (data2.X * -0.19 - data.X * 0.6761000000000001) + data2.X * 0.8 * math.cos(0.8 * p)) / 0.8
	local v6 = -v ^ 2 * -0.19 * (data2.Y * (v * 3 - 2) + 6 * data.Y * (v - 1))
	local v7 = v * (math.sin(0.8 * p) * (data2.Z * -0.19 - data.Z * 0.6761000000000001) + data2.Z * 0.8 * math.cos(0.8 * p)) / 0.8
	return Vector3.new(v2, v3, v4), (Vector3.new(v5, v6, v7))
end

local function TornadoElectron(p, value)
	local v = value or 1
	local clone = part:Clone()
	local clone2 = script["Trail" .. math.random(1, 2)]:Clone()
	clone2.Parent = clone
	clone2.Attachment0 = clone.a1
	clone2.Attachment1 = clone.a2
	local a1 = clone.a1
	local a2 = clone.a2
	local cframe = CFrame.new(0, 1 + math.random(), 0)
	local cframe2 = CFrame.new(0, -1 - math.random(), 0)
	a1.CFrame = cframe
	a2.CFrame = cframe2
	local position = CFrame.new(RandomVectorOffset(createVector(0, 1, 0), 0.6283185307179586) * random:NextNumber(
		200,
		440
	)).Position
	local v2 = RandomVectorOffset(-position.Unit:Cross(createVector(0, 1, 0)), 0.5235987755982988) * 140
	local v3 = SamysSwirlSpline(position, v2, 0)
	clone.CFrame = CFrame.new(v3)
	task.wait()
	clone.Parent = _WorldOrigin
	heartbeatLoopFor2(v, function(p2)
		local v4 = (3 - 3 * p2 / v) * 3.141592653589793
		local v5, v6 = SamysSwirlSpline(position, v2, v4)
		local _, v7 = SamysSwirlSpline(position, v2, v4 + 0.01)
		local v8 = v7 - v6
		local v9 = (v8.X * v6.Z - v6.X * v8.Z) / (v6.X ^ 2 + v6.Z ^ 2)
		clone.CFrame = CFrame.new(v5, v5 + v6) * CFrame.Angles(0, 0, -v9 * 37) + p
	end, function()
		task.wait(0.5)

		if clone then
			clone:Destroy()
		end
	end)
end

return TornadoElectron