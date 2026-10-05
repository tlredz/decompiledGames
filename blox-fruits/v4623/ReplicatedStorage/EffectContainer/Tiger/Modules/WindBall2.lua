local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local _ = FX:WaitForChild("SoulGuitarEffects").Wind
workspace:WaitForChild("_WorldOrigin")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.AttachmentPair
local random = Random.new()
game:GetService("TweenService")
game:GetService("RunService")

local function RandomVectorOffsetBetween(p, p2, p3)
	return (CFrame.lookAt(Vector3.new(), p) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p3), (math.cos(p2))))),
		0,
		0
	)).LookVector
end

local function CubicBezier(p, p2, p3, p4, p5)
	return p2 * (1 - p) ^ 3 + p3 * 3 * p * (1 - p) ^ 2 + p4 * 3 * (1 - p) * p ^ 2 + p5 * p ^ 3
end

local function ballisticTrajectory(vector2: Vector3, vector3: Vector3, p, p2)
	return vector2 + vector3 * p2 + createVector(-0, -0.5, -0) * p * p2 ^ 2
end

function gaussian()
	return math.sqrt(math.log(math.random()) * -2) * math.cos(6.283185307179586 * math.random())
end

local function emitAll(folder)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitCount = emitter:GetAttribute("EmitCount")

		if emitCount then
			local emitDelay = emitter:GetAttribute("EmitDelay")

			if emitDelay then
				local v = emitter
				local v2 = emitCount
				task.delay(emitDelay, function()
					v:Emit(v2)
				end)
			else
				emitter:Emit(emitCount)
			end
		else
			emitter:Emit(1)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRandPointInSphere(p: number)
	local v = math.random()
	local vector2 = Vector3.new(gaussian(), gaussian(), gaussian())
	return p * vector2 * v ^ 0.3333333333333333 / vector2.magnitude
end

local function WindBall(p, instance, data, p2, vector2: Vector3, vector3: Vector3, p3)
	local v = vector2 + createVector(0, 45, 0)
	task.delay(p2 + 1.5, function()
		instance:Destroy()
	end)
	time()
	local clone = instance:Clone()
	Util.SetParentOverrideWithColor(clone, instance, p, "LeopardFruitVFXColor")
	clone:ClearAllChildren()
	Util.SetParentOverrideWithColor(data.LongTrail:Clone(), clone, p, "LeopardFruitVFXColor")
	local v2 = vector3 * 1.4
	local v3 = p3 * 1.1
	heartbeatLoopFor2(p2, function(p4)
		local v5 = v + v2 * p4 + createVector(-0, -0.5, -0) * v3 * p4 ^ 2
		local v9 = p4 + 0.01
		local v10 = v + v2 * v9 + createVector(-0, -0.5, -0) * v3 * v9 ^ 2
		instance.CFrame = CFrame.lookAt(v5, v10) * CFrame.Angles(0, 0, -24 * p4)
		clone.CFrame = CFrame.lookAt(v5, v10)
	end, function()
		clone.LongTrail.Enabled = false
	end)
	local v4 = instance.Size.Y * 3 * 1
	local integer = random:NextInteger(10, 20)
	random:NextInteger(3, 7)
	local children = data.Trails:GetChildren()
	data.Particles:GetChildren()
	local _ = instance.CenterAttachment

	for _ = 1, integer do
		local attachment = Instance.new("Attachment")
		local attachment2 = Instance.new("Attachment")
		local randPointInSphere = getRandPointInSphere(v4) -- equivalent call inferred; original call site unknown
		attachment.CFrame = CFrame.lookAt(createVector(0, 0, 0), random:NextUnitVector()) + randPointInSphere
		attachment2.CFrame = attachment.CFrame * CFrame.new(random:NextNumber(1, 27), 0, 0)
		local clone2 = children[random:NextInteger(1, #children)]:Clone()
		clone2.Attachment0 = attachment
		clone2.Attachment1 = attachment2
		Util.SetParentOverrideWithColor(clone2, attachment, p, "LeopardFruitVFXColor")
		Util.SetParentOverrideWithColor(attachment, instance, p, "LeopardFruitVFXColor")
		Util.SetParentOverrideWithColor(attachment2, instance, p, "LeopardFruitVFXColor")
	end
end

return WindBall