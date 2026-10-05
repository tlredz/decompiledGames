local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local object = setmetatable({}, Ragdoll)
object.__index = object

function object.new(...)
	local self = setmetatable(Ragdoll.new(...), object)
	self:_Init()
	return self
end

function object:PlayClient(...)
	Ragdoll.PlayClient(self, ...)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local clone = script.Model:Clone()
	clone.PrimaryPart = clone.Primary
	clone.Parent = rootPart
	clone:ScaleTo(clone:GetScale() * (1 + 1 * math.random()))
	table.insert(self._destroy_these, clone)
	BetterDebris:AddItem(clone, 10)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function get_position()
		return rootPart.Position - createVector(0, 1.5, 0)
	end

	local v = math.random() * 3.141592653589793 * 2
	Utility:RenderstepForLoop(0, 100, 4, function(p)
		local v2 = get_position() -- equivalent call inferred; original call site unknown
		local v3 = v2 + Vector3.new(math.cos(v), 0, (math.sin(v))) * 128 + createVector(0, 128, 0)
		local v4 = (v3 - v2).Magnitude * (1 - p / 100)
		clone:PivotTo(CFrame.new(v2, v3) * CFrame.new(0, 0, -v4 / 2))
	end)
	Utility:PlayParticles(clone)
	self:CreateSound("rbxassetid://110743147230828", 1.5, 1 + 0.1 * math.random(), nil, true, 5)
	local now = tick()

	while tick() < now + 2 do
		clone:PivotTo(CFrame.new(rootPart.Position - createVector(0, 1.5, 0)))
		RunService.RenderStepped:Wait()
	end

	clone.PrimaryPart.Anchored = false
end

function object:_Init() end

return object