local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
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
	local clone = script.Particles:Clone()
	clone.CFrame = rootPart.CFrame
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = rootPart
	weldConstraint.Part1 = clone
	weldConstraint.Parent = clone
	self:CreateSound("rbxassetid://110334213997451", 0.75, 0.95 + 0.1 * math.random(), nil, true, 10)
	self:CreateSound("rbxassetid://85939220046386", 1, 0.95 + 0.1 * math.random(), nil, true, 10)
	local flag = true
	self:_InternalThread(task.spawn, function()
		while flag do
			local clone2 = script.Props:GetChildren()[math.random(#script.Props:GetChildren())]:Clone()
			clone2:PivotTo(clone.CFrame * CFrame.Angles(
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2
			))
			clone2:ScaleTo(clone2:GetScale() * (1 + 2 * math.random()))

			for _, child in pairs(clone2:GetChildren()) do
				if child == clone2.Primary then
					continue
				end

				local weldConstraint2 = Instance.new("WeldConstraint")
				weldConstraint2.Part0 = child
				weldConstraint2.Part1 = clone2.Primary
				weldConstraint2.Parent = clone2.Primary
			end

			clone2.Primary.Velocity = (Random.new():NextUnitVector() + createVector(0, 2, 0)).Unit * (40 + 60 * math.random())
			clone2.Primary.RotVelocity = Random.new():NextUnitVector() * (5 + 20 * math.random())
			clone2.Parent = clone
			table.insert(self._destroy_these, clone2)
			wait(0.1 + 0.6 * math.random())
		end
	end)
	wait(7.5)
	flag = false

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end
end

function object:_Init() end

return object