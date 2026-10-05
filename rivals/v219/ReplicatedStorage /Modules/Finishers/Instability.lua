local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Finisher = require(ReplicatedStorage.Modules.Finisher)
local Utility = require(ReplicatedStorage.Modules.Utility)
local object = setmetatable({}, Finisher)
object.__index = object

function object.new(...)
	local self = setmetatable(Finisher.new(...), object)
	self:_Init()
	return self
end

function object.PlayServer(object2)
	object2:_BreakJoints()
	object2:_AnchorModel()

	for _, part in pairs(object2:_GetObjects()) do
		if not (part:IsA("BasePart") and part.Name ~= "HumanoidRootPart") then
			continue
		end

		part.AssemblyLinearVelocity = Vector3.new(math.random() - 0.5, math.random(), math.random() - 0.5) * 128
		part.AssemblyAngularVelocity = Vector3.new(math.random() - 0.5, math.random(), math.random() - 0.5) * 32
	end
end

function object:PlayClient()
	self:CreateSound("rbxassetid://119382605046173", 1, 1 + 0.1 * math.random(), nil, true, 5)
	local clone = script.Explosion:Clone()
	clone.CFrame = (self._is_humanoid and self._subject.RootPart or self._subject).CFrame
	clone.Parent = self._subject
	table.insert(self._destroy_these, clone)
	BetterDebris:AddItem(clone, 5)
	Utility:PlayParticles(clone)
end

function object:_Init() end

return object