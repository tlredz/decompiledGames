local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local _ = FX:WaitForChild("SoulGuitarEffects").Wind
workspace:WaitForChild("_WorldOrigin")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local attachmentPair = Util.AttachmentPair
local random = Random.new()

local function RandomVectorOffsetBetween(p, p2, p3)
	return (CFrame.lookAt(Vector3.new(), p) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p3), (math.cos(p2))))),
		0,
		0
	)).LookVector
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function CubicBezier(p, p2, p3, p4, p5)
	return p2 * (1 - p) ^ 3 + p3 * 3 * p * (1 - p) ^ 2 + p4 * 3 * (1 - p) * p ^ 2 + p5 * p ^ 3
end

local function ballisticTrajectory(vector2: Vector3, vector3: Vector3, p, p2)
	return vector2 + vector3 * p2 + createVector(-0, -0.5, -0) * p * p2 ^ 2
end

function gaussian()
	return math.sqrt(math.log(math.random()) * -2) * math.cos(6.283185307179586 * math.random())
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRandPointInSphere(p: number)
	local v = math.random()
	local vector2 = Vector3.new(gaussian(), gaussian(), gaussian())
	return p * vector2 * v ^ 0.3333333333333333 / vector2.magnitude
end

local function WindBall(parent, data, p, vector2: Vector3, vector3: Vector3, p2)
	task.delay(p + 1, function()
		parent:Destroy()
	end)
	local v = time()
	local clone = parent:Clone()
	clone.Parent = parent
	clone:ClearAllChildren()
	local clone2 = data.LongTrail:Clone()
	clone2.Color = ColorSequence.new(Color3.fromRGB(70, 255, 67), Color3.fromRGB(120, 255, 120))
	clone2.Parent = clone
	heartbeatLoopFor2(p, function(p3)
		local v3 = vector2 + vector3 * p3 + createVector(-0, -0.5, -0) * p2 * p3 ^ 2
		local v7 = p3 + 0.01
		local v8 = vector2 + vector3 * v7 + createVector(-0, -0.5, -0) * p2 * v7 ^ 2
		parent.CFrame = CFrame.lookAt(v3, v8) * CFrame.Angles(0, 0, -44 * p3)
		clone.CFrame = CFrame.lookAt(v3, v8)
	end, function()
		clone.LongTrail.Enabled = false
	end)
	local v2 = parent.Size.Y * 0.5
	local integer = random:NextInteger(5, 10)
	local integer2 = random:NextInteger(3, 7)
	local children = data.Trails:GetChildren()
	local children2 = data.Particles:GetChildren()
	local centerAttachment = parent.CenterAttachment

	for _ = 1, integer do
		local attachment = Instance.new("Attachment")
		local attachment2 = Instance.new("Attachment")
		local randPointInSphere = getRandPointInSphere(v2) -- equivalent call inferred; original call site unknown
		attachment.CFrame = CFrame.lookAt(createVector(0, 0, 0), random:NextUnitVector()) + randPointInSphere
		attachment2.CFrame = attachment.CFrame * CFrame.new(random:NextNumber(2, 3), 0, 0)
		local clone3 = children[random:NextInteger(1, #children)]:Clone()
		clone3.Color = ColorSequence.new(Color3.fromRGB(70, 255, 67), Color3.fromRGB(120, 255, 120))
		clone3.Attachment0 = attachment
		clone3.Attachment1 = attachment2
		clone3.Parent = attachment
		attachment.Parent = parent
		attachment2.Parent = parent
	end

	for _ = 1, integer2 do
		local clone3 = children2[random:NextInteger(1, #children2)]:Clone()
		local emitCount = clone3:GetAttribute("EmitCount")
		clone3.Parent = centerAttachment
		task.spawn(function()
			task.wait(p * random:NextNumber(0, 1))

			if p < time() - v then
				return
			end

			clone3:Emit(emitCount)
		end)
	end

	task.spawn(function()
		for _ = 1, 22 do
			if p < time() - v then
				break
			end

			if math.random() < 0.5 then
				continue
			end

			task.wait(p / 22)
			local v4 = attachmentPair.new(CFrame.new(1, 0, 0), CFrame.new(-1, 0, 0))
			local clone3 = data.MainTrail:Clone()
			clone3.Color = ColorSequence.new(Color3.fromRGB(70, 255, 67), Color3.fromRGB(120, 255, 120))
			v4:hookUp(clone3)
			local lookVector = RandomVectorOffsetBetween(createVector(0, 0, 1), 0.5235987755982988, 1.0471975511965976)
			local v6 = v2 * lookVector * random:NextNumber(0.75, 1)
			local vector4 = lookVector * random:NextNumber(120, 140) * 1.25 * 0.8
			local v7 = vector4:Dot(createVector(0, 0, 1)) * createVector(0, 0, 1)
			local v8 = v6 + vector4
			local v9 = v6 + v7 * 0.7
			local v10 = v8 + (v9 - v8) * 0.7
			local cFrame = parent.CFrame
			local v17 = v4
			local v18 = v6
			local v19 = v9
			local v20 = v10
			local v21 = v8
			heartbeatLoopFor2(0.2, function(p3, p4, p5)
				cFrame *= CFrame.Angles(0, 0, -0.05)
				local cframe = CFrame.new()
				local cframe2 = cFrame
				v4:setRelativeCFrame(cframe + cframe2:PointToWorldSpace(CubicBezier(p5 * 0.5, v6, v9, v10, v8)))
			end, function()
				heartbeatLoopFor2(0.4, function(p3, p4, p5)
					cFrame *= CFrame.Angles(0, 0, -0.05)
					clone3.MaxLength = 100 * (1 - p5)
					clone3.Lifetime = 0.35 * (1 - p5)
					local cframe = CFrame.new()
					local cframe2 = cFrame
					v17:setRelativeCFrame(cframe + cframe2:PointToWorldSpace(CubicBezier(
						0.5 + p5 * 0.5,
						v18,
						v19,
						v20,
						v21
					)))
				end, function()
					v17:destroy()
				end)
			end)
		end
	end)
end

return WindBall