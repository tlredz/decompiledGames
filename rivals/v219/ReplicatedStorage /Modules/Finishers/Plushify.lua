local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
local object = setmetatable({}, Ragdoll)
object.__index = object

function object.new(...)
	local self = setmetatable(Ragdoll.new(...), object)
	self:_Init()
	return self
end

function object:PlayServer(...)
	Ragdoll.PlayServer(self, ...)

	if not self._is_humanoid then
		return
	end

	self._subject.Parent:ScaleTo(self._subject.Parent:GetScale() * 0.75)
	local head = self._is_humanoid and self._subject.Parent:FindFirstChild("Head")

	if not head then
		return
	end

	head.Size *= 2

	for _, accessory in pairs(head.Parent:GetChildren()) do
		if not accessory:IsA("Accessory") then
			continue
		end

		for _, part in pairs(accessory:GetChildren()) do
			if part:IsA("BasePart") then
				part.Size *= 2
			end
		end
	end
end

function object.PlayClient(object2, ...)
	Ragdoll.PlayClient(object2, ...)
	object2:CreateSound("rbxassetid://83739663458999", 1.5, 1 + 0.1 * math.random(), nil, true, 5)
end

function object:_Init() end

return object