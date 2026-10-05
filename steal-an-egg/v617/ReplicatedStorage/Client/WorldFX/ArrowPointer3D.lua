local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Log = require(ReplicatedStorage.Packages.Log)
local Trove = require(ReplicatedStorage.Packages.Trove)
local t = require(ReplicatedStorage.Packages.t)
local model = ReplicatedStorage.Assets.Models.Pointers.Model
local shell = model:FindFirstChild("Shell")
local v

if shell == nil then
	v = false
else
	v = shell:IsA("BasePart")
end

assert(v, "the pointer template needs a Shell BasePart")
local X = shell.Size.X
local v2 = X * 0.6666666666666666
local transient = Workspace:WaitForChild("Transient")
local color = Color3.fromRGB(255, 72, 48)
local frozen = table.freeze({
	Amplitude = 4,
	Blink = false,
	BlinkFrequency = 1.2,
	CleanupOnPartDestroyed = false,
	Color = Color3.new(1, 1, 1),
	Highlight = false,
	OriginOffset = createVector(0, 0, 0),
	OscillationSpeed = 3.2,
	ProximityThreshold = X + X / 2,
	Radius = 4,
	RotationSpeed = 0,
	TargetOffset = createVector(0, 0, 0)
})
local interface = t.interface({
	Amplitude = t.optional(t.number),
	Blink = t.optional(t.boolean),
	BlinkFrequency = t.optional(t.number),
	CleanupOnPartDestroyed = t.optional(t.boolean),
	Color = t.optional(t.Color3),
	Highlight = t.optional(t.boolean),
	OriginOffset = t.optional(t.Vector3),
	OscillationSpeed = t.optional(t.number),
	ProximityThreshold = t.optional(t.number),
	Radius = t.optional(t.number),
	RotationSpeed = t.optional(t.number),
	TargetOffset = t.optional(t.Vector3)
})
local ArrowPointer3D = {}
ArrowPointer3D.__index = ArrowPointer3D
ArrowPointer3D.__class = "ArrowPointer3D"
ArrowPointer3D.__types = {
	Config = interface,
	OptionalConfig = t.optional(interface)
}
local v3 = Log.new()
local v4 = {}
local optional = t.optional(t.union(t.instanceIsA("BasePart"), t.Vector3))

local function withDefaults(items)
	local clone = table.clone(frozen)

	if items ~= nil then
		for k, item in items do
			clone[k] = item
		end
	end

	return clone
end

local function pointOf(position, vector2: Vector3)
	if typeof(position) ~= "Vector3" then
		position = position.Position
	end

	return position + vector2
end

local function inWorld(instance)
	if instance == nil then
		return false
	end

	if typeof(instance) == "Vector3" then
		return true
	end

	return instance:IsDescendantOf(Workspace)
end

local function bothInWorld(p)
	local origin = p.origin
	local v5

	if origin == nil then
		v5 = false
	else
		v5 = typeof(origin) == "Vector3" or origin:IsDescendantOf(Workspace)
	end

	if not v5 then
		return v5
	end

	local target = p.target
	return target ~= nil and (typeof(target) == "Vector3" or target:IsDescendantOf(Workspace))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function halt(state)
	if not state.isRunning then
		return false
	end

	state.isRunning = false
	v4[state] = nil
	state.model.Parent = nil
	return true
end

local function track(instance, p: string, instance2)
	local endScope = instance.endScopes[p]
	endScope:Clean()

	if instance.Config.CleanupOnPartDestroyed then
		endScope:Connect(instance2.Destroying, function()
			instance:Destroy()
		end)
	end

	endScope:Connect(instance2.AncestryChanged, function()
		local v5 = instance
		local origin = v5.origin
		local v6

		if origin == nil then
			v6 = false
		else
			v6 = typeof(origin) == "Vector3" or origin:IsDescendantOf(Workspace)
		end

		if v6 then
			local target = v5.target

			if target == nil then
				v6 = false
			else
				v6 = typeof(target) == "Vector3" or target:IsDescendantOf(Workspace)
			end
		end

		if v6 then
			instance:Start()
			return
		end

		-- equivalent call inferred; original call site unknown
		if halt(instance) then
			instance.haltedByWorld = true
		end
	end)
end

local function bind(instances, p: string, instance)
	if typeof(instance) == "Instance" then
		if instances.boundParts[p] ~= instance then
			instances.boundParts[p] = instance
			track(instances, p, instance)
		end
	else
		instances.boundParts[p] = nil
		instances.endScopes[p]:Clean()
	end

	instances[p == "Origin" and "origin" or "target"] = instance

	if instances.haltedByWorld then
		local origin = instances.origin
		local v5

		if origin == nil then
			v5 = false
		else
			v5 = typeof(origin) == "Vector3" or origin:IsDescendantOf(Workspace)
		end

		if v5 then
			local target = instances.target

			if target == nil then
				v5 = false
			else
				v5 = typeof(target) == "Vector3" or target:IsDescendantOf(Workspace)
			end
		end

		if v5 then
			instances:Start()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tintAt(config, clock: number)
	if not config.Blink then
		return config.Color
	end

	local v5 = math.sin(clock * config.BlinkFrequency * 6.283185307179586) * 0.5 + 0.5
	return config.Color:Lerp(color, v5)
end

local function settleReach(state, p: number)
	local config = state.Config
	local v5

	if math.sin(state.clock * config.OscillationSpeed) >= 0 then
		v5 = config.Amplitude
	else
		v5 = -config.Amplitude
	end

	local v6 = config.Radius + v5
	local v7 = config.OscillationSpeed * 1.6
	local v8 = -(v7 * v7) * (state.reach - v6) - 1 * v7 * state.reachVelocity
	state.reachVelocity += v8 * p
	state.reach += state.reachVelocity * p

	if state.reach < 0 then
		state.reach = 0
		state.reachVelocity = math.max(state.reachVelocity, 0)
	end

	return state.reach
end

local function poseAlong(vector2: Vector3, vector3: Vector3, p: number, p2: number)
	local unit = (vector3 - vector2).Unit
	local unit2 = unit:Cross(math.abs((unit:Dot(createVector(0, 1, 0)))) > 0.98 and createVector(0, 0, 1) or createVector(
		0,
		1,
		0
	)).Unit
	local cross = unit2:Cross(unit)

	if p2 ~= 0 then
		local cframe = CFrame.fromAxisAngle(unit, -p2)
		unit2 = cframe:VectorToWorldSpace(unit2)
		cross = cframe:VectorToWorldSpace(cross)
	end

	return CFrame.fromMatrix(vector2 + unit * p, -unit, -unit2, -cross)
end

local function advance(state, p: number)
	local v5 = math.min(p, 0.05)
	state.clock += v5
	local origin = state.origin
	local v6

	if origin == nil then
		v6 = false
	else
		v6 = typeof(origin) == "Vector3" or origin:IsDescendantOf(Workspace)
	end

	if v6 then
		local target = state.target

		if target == nil then
			v6 = false
		else
			v6 = typeof(target) == "Vector3" or target:IsDescendantOf(Workspace)
		end
	end

	if not v6 then
		return
	end

	local config = state.Config
	local origin2 = state.origin
	local originOffset = config.OriginOffset

	if typeof(origin2) ~= "Vector3" then
		origin2 = origin2.Position
	end

	local v7 = origin2 + originOffset
	local target = state.target
	local targetOffset = config.TargetOffset

	if typeof(target) ~= "Vector3" then
		target = target.Position
	end

	local v8 = target + targetOffset
	local core = state.model.Core
	local color2 = tintAt(config, state.clock) -- equivalent call inferred; original call site unknown
	core.Color = color2

	if (v8 - v7).Magnitude < config.ProximityThreshold then
		state.model.Parent = nil
		return
	end

	if state.model.Parent == nil then
		state.model.Parent = state.stage
	end

	local v9 = settleReach(state, v5) + v2
	state.model:PivotTo(poseAlong(v7, v8, v9, state.clock * config.RotationSpeed))
end

function ArrowPointer3D.new(p, p2, items)
	assert(ArrowPointer3D.__types.OptionalConfig(items))
	assert(optional(p))
	assert(optional(p2))
	local scope = Trove.new()
	local self = setmetatable({}, ArrowPointer3D)
	local clone = table.clone(frozen)

	if items ~= nil then
		for k, item in items do
			clone[k] = item
		end
	end

	self.Config = clone
	self.model = scope:Clone(model)
	self.stage = transient
	self.scope = scope
	self.endScopes = {
		Origin = scope:Extend(),
		Target = scope:Extend()
	}
	self.boundParts = {}
	self.clock = 0
	self.reach = self.Config.Radius
	self.reachVelocity = 0
	self.isRunning = false
	self.haltedByWorld = false
	self.retired = false
	self.model.Core.Color = self.Config.Color

	if p2 ~= nil then
		bind(self, "Origin", p2)
	end

	if p ~= nil then
		bind(self, "Target", p)
	end

	return self
end

function ArrowPointer3D:Start()
	if self.isRunning or self.retired then
		return false
	end

	local origin = self.origin
	local v5

	if origin == nil then
		v5 = false
	else
		v5 = typeof(origin) == "Vector3" or origin:IsDescendantOf(Workspace)
	end

	if v5 then
		local target = self.target

		if target == nil then
			v5 = false
		else
			v5 = typeof(target) == "Vector3" or target:IsDescendantOf(Workspace)
		end
	end

	assert(v5, "an arrow needs both of its anchors in the world before it starts")
	self.isRunning = true
	self.haltedByWorld = false
	self.model.Parent = self.stage
	v4[self] = true
	return true
end

function ArrowPointer3D:Stop()
	self.haltedByWorld = false

	if not self.isRunning then
		return false
	end

	self.isRunning = false
	v4[self] = nil
	self.model.Parent = nil
	return true
end

function ArrowPointer3D.PointFrom(p, p2)
	assert(optional(p2))
	bind(p, "Origin", p2)
end

function ArrowPointer3D.PointAt(p, p2)
	assert(optional(p2))
	bind(p, "Target", p2)
end

function ArrowPointer3D:Destroy()
	if self.retired then
		return
	end

	self.retired = true

	if self.isRunning then
		self.isRunning = false
		v4[self] = nil
		self.model.Parent = nil
	end

	self.scope:Destroy()
end

RunService.RenderStepped:Connect(function(dt: number)
	for k in v4 do
		local success, result = pcall(advance, k, dt)

		if success then
			continue
		end

		v3:AtError():Log((`arrow pointer step failed: {result}`))

		if not k.isRunning then
			continue
		end

		k.isRunning = false
		v4[k] = nil
		k.model.Parent = nil
	end
end)
return ArrowPointer3D