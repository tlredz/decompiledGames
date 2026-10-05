local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Finisher = require(ReplicatedStorage.Modules.Finisher)
local Utility = require(ReplicatedStorage.Modules.Utility)
local object = setmetatable({}, Finisher)
object.__index = object

function object.new(...)
	local self = setmetatable(Finisher.new(...), object)
	self:_Init()
	return self
end

function object:PlayClient()
	self:_HideBody()
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject

	if not rootPart then
		return
	end

	local clone = script.Particles.Attachment:Clone()
	clone.Parent = rootPart
	table.insert(self._destroy_these, clone)
	Utility:PlayParticles(clone)
	self:CreateSound("rbxassetid://130069209812509", 1, 1 + 0.1 * math.random(), nil, true, 5)
	self:CreateSound("rbxassetid://82341777410026", 1.5, 1 + 0.1 * math.random(), nil, true, 5)
	self:CreateSound("rbxassetid://74282442822962", 1, 1 + 0.1 * math.random(), nil, true, 5)
end

function object:_Init() end

return object