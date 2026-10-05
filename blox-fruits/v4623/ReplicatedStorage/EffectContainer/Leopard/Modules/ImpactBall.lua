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
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
local PlaySchemes = require(interpolationScheme:WaitForChild("PlaySchemes"))

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

local function ImpactBall(parent, p, p2, vector2: Vector3, vector3: Vector3, p3)
	task.delay(p2 + 2, function()
		parent:Destroy()
	end)
	local v = time()
	heartbeatLoopFor2(p2, function(p4)
		local v3 = vector2 + vector3 * p4 + createVector(-0, -0.5, -0) * p3 * p4 ^ 2
		local v7 = p4 + 0.01
		local v8 = vector2 + vector3 * v7 + createVector(-0, -0.5, -0) * p3 * v7 ^ 2
		parent.CFrame = CFrame.lookAt(v3, v8) * CFrame.Angles(0, 0, -14 * p4)
	end)
	local v2 = parent.Size.Y * 0.5
	local integer = random:NextInteger(5, 10)
	local integer2 = random:NextInteger(3, 7)
	local children = p.Trails:GetChildren()
	local children2 = p.Particles:GetChildren()
	local centerAttachment = parent.CenterAttachment

	for _ = 1, integer do
		local attachment = Instance.new("Attachment")
		local attachment2 = Instance.new("Attachment")
		local randPointInSphere = getRandPointInSphere(v2) -- equivalent call inferred; original call site unknown
		attachment.CFrame = CFrame.lookAt(createVector(0, 0, 0), random:NextUnitVector()) + randPointInSphere
		attachment2.CFrame = attachment.CFrame * CFrame.new(random:NextNumber(14, 28), 0, 0)
		local clone = children[random:NextInteger(1, #children)]:Clone()
		clone.Attachment0 = attachment
		clone.Attachment1 = attachment2
		clone.Parent = attachment
		attachment.Parent = parent
		attachment2.Parent = parent
	end

	for _ = 1, integer2 do
		local clone = children2[random:NextInteger(1, #children2)]:Clone()
		local emitCount = clone:GetAttribute("EmitCount")
		clone.Parent = centerAttachment
		task.spawn(function()
			task.wait(p2 * random:NextNumber(0, 1))

			if p2 < time() - v then
				return
			end

			clone:Emit(emitCount)
		end)
	end

	parent.WindWave.CFrame = parent.CFrame:ToWorldSpace(CFrame.Angles(0, -1.5707963267948966, 0) * CFrame.new(
		-32.4857178,
		-4.73059368,
		-1.90472412,
		0,
		1,
		0,
		1,
		0,
		0,
		0,
		0,
		-1
	))
	local clone = parent.WindWave:Clone()
	clone.Transparency = 0
	clone.Parent = parent

	for _, child in ipairs(parent.WindWave.Attachment:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end

	local playSchemes = PlaySchemes(clone)
	task.delay(playSchemes, function()
		clone:Destroy()
	end)
end

return ImpactBall