local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(script.Parent.Config)
require(script.Parent.Types)
local Zone = require(script.Parent.Zone)
local InstanceUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.InstanceUtils)

local function getRootToFeet(instance, humanoidRootPart, humanoid)
	local leftLeg = instance:FindFirstChild("Left Leg")

	if humanoid.RigType == Enum.HumanoidRigType.R6 then
		return humanoidRootPart.Size.Y / 2 + (not (leftLeg and leftLeg:IsA("BasePart")) and 2 or leftLeg.Size.Y)
	end

	return humanoidRootPart.Size.Y / 2 + humanoid.HipHeight
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getHorizontalForward(humanoidRootPart)
	local lookVector = humanoidRootPart.CFrame.LookVector
	local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
	local upVector = humanoidRootPart.CFrame.UpVector
	local vector3 = Vector3.new(upVector.X, 0, upVector.Z)

	if vector2.Magnitude > 0.1 then
		return vector2.Unit
	end

	if vector3.Magnitude > 0.1 then
		return vector3.Unit
	end

	return createVector(0, 0, 1)
end

local function toNameSet(items)
	local result = {}

	for _, item in items do
		result[item] = true
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopAssembly(instance)
	local primaryPart = instance.PrimaryPart

	if primaryPart then
		primaryPart.AssemblyLinearVelocity = createVector(0, 0, 0)
		primaryPart.AssemblyAngularVelocity = createVector(0, 0, 0)
	end
end

local function prepareTemplate(instance)
	local clone = instance:Clone()
	clone.Name = `{Config.chaserArchetypeId}Template_{instance.Name}`

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = false
		elseif descendant:IsA("LuaSourceContainer") then
			descendant:Destroy()
		end
	end

	local humanoid = clone:FindFirstChildOfClass("Humanoid")

	if humanoid:FindFirstChildOfClass("Animator") == nil then
		local animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	clone.PrimaryPart = clone.HumanoidRootPart
	return clone
end

local Chaser = {
	isModel = function(model)
		return model:IsA("Model") and model:GetAttribute("ArchetypeId") == Config.chaserArchetypeId
	end,
	collectSourceRigs = function(p, p2: string, items)
		local models = {}
		local v

		if items then
			v = {}

			for _, item in items do
				v[item] = true
			end
		end

		local potentialInstance = InstanceUtils.getPotentialInstance(p, p2)

		if not potentialInstance then
			return models
		end

		for _, model in potentialInstance:GetChildren() do
			if not ((v == nil or v[model.Name] == true) and model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") and model:FindFirstChild("HumanoidRootPart")) then
				continue
			end

			table.insert(models, model)
		end

		return models
	end,
	getScale = function(object)
		if Config.chaserScaleRelativeToSource then
			return object:GetScale() * Config.chaserScale
		end

		return Config.chaserScale
	end
}

function Chaser.computeSpawnCFrame(instance, callback)
	local humanoidRootPart = instance.HumanoidRootPart
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local v = (Chaser.getScale(instance) / instance:GetScale() - 1) * getRootToFeet(
		instance,
		humanoidRootPart,
		humanoid
	)
	local horizontalForward = getHorizontalForward(humanoidRootPart) -- equivalent call inferred; original call site unknown
	local cross = horizontalForward:Cross(createVector(0, 1, 0))
	local position = humanoidRootPart.Position
	local v2 = position + horizontalForward * Config.chaserSpawnOffsetStuds

	for _, v4 in {
		horizontalForward,
		-horizontalForward,
		cross,
		-cross
	} do
		local v5 = position + v4 * Config.chaserSpawnOffsetStuds

		if not callback(v5) then
			continue
		end

		v2 = v5
		break
	end

	local v4 = v2 + Vector3.new(0, v, 0)
	return CFrame.lookAt(v4, v4 + horizontalForward)
end

function Chaser.createSlot(p, cframe: CFrame)
	return {
		template = prepareTemplate(p),
		spawnCFrame = cframe,
		scale = Chaser.getScale(p),
		npc = nil,
		lastSpawnClock = 0,
		lastGroundedCFrame = cframe,
		grounded = false,
		noiseSeed = math.random() * 1000,
		targetRoot = nil,
		targetExpiresClock = 0
	}
end

function Chaser.applyMoveNoise(p: number, vector2: Vector3, vector3: Vector3, p2: number)
	local vector4 = Vector3.new(vector3.X - vector2.X, 0, vector3.Z - vector2.Z)
	local magnitude = vector4.Magnitude

	if magnitude < p2 * 0.5 then
		return vector3
	end

	local v = vector4 / magnitude
	local vector5 = Vector3.new(-v.Z, 0, v.X)
	local v2 = math.clamp(math.noise(p, os.clock() * Config.moveNoiseFrequency) * 2, -1, 1)
	local v3 = math.min(1, magnitude / (Config.moveNoiseFadeDistanceStuds * p2))
	return vector3 + vector5 * (v2 * Config.moveNoiseAmplitudeStuds * p2 * v3)
end

function Chaser:confine(instance, p, p2)
	local pivot = instance:GetPivot()

	if pivot.Position.Y < self.spawnCFrame.Position.Y - Config.fallRescueStuds * self.scale then
		instance:PivotTo(self.spawnCFrame)
		stopAssembly(instance) -- equivalent call inferred; original call site unknown
		self.grounded = false
	elseif Zone.isInside(p, pivot.Position) then
		if Zone.hasFloorBelow(p2, pivot.Position, self.scale) then
			self.lastGroundedCFrame = pivot
			self.grounded = true
		elseif self.grounded then
			instance:PivotTo(self.lastGroundedCFrame)
			stopAssembly(instance) -- equivalent call inferred; original call site unknown
		end
	else
		instance:PivotTo(pivot.Rotation + Zone.clamp(p, pivot.Position, self.scale))
		stopAssembly(instance) -- equivalent call inferred; original call site unknown
	end
end

return Chaser