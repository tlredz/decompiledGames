local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
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
	local clone = script.Model:Clone()
	clone.Parent = rootPart
	table.insert(self._destroy_these, clone)
	local v = {
		clone.heavenRays.dots1,
		clone.heavenRays.Enabled.rays1,
		clone.heavenRays.Enabled.rays2,
		clone.heavenRays.Enabled.rays3
	}
	local lastTime = tick()
	table.insert(self._connections, RunService.RenderStepped:Connect(function()
		clone:PivotTo(CFrame.new(rootPart.Position))

		for _, v2 in pairs(v) do
			v2.LocalTransparencyModifier = 1 - math.clamp((tick() - lastTime) / 2, 0, 1) ^ 3
		end
	end))
	self:CreateSound("rbxassetid://122372195490308", 1.25, 0.95 + 0.1 * math.random(), rootPart, true, 10)
end

function object:_Init() end

return object