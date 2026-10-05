local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
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
	object2:_AnchorModel(0)
end

function object:PlayClient(...)
	if not self._is_humanoid then
		return
	end

	self:CreateSound("rbxassetid://140285154660882", 1.25, 1, self._subject.RootPart.Position, true, 5)
	local parent = self._subject.Parent
	local unitVector = Random.new():NextUnitVector()
	local pivot = parent:GetPivot()
	local scale = parent:GetScale()
	local now = tick()

	while tick() < now + 0.5 do
		local v = 1 - (1 - (1 - (now + 0.5 - tick()) / 0.5)) ^ 2
		local v2 = unitVector * -v * 3.141592653589793 * 2 * 3
		parent:ScaleTo(scale * (1 - v))
		parent:PivotTo(pivot * CFrame.Angles(v2.X, v2.Y, v2.Z))
		RunService.RenderStepped:Wait()
	end

	local clone = script.Particles.Attachment:Clone()
	clone.Parent = self._subject.RootPart
	table.insert(self._destroy_these, clone)
	Utility:PlayParticles(clone)
	wait(0.25)
	self:CreateSound("rbxassetid://73926817558125", 1, 1, self._subject.RootPart.Position, true, 5)
	wait(1)
end

function object:_Init() end

return object