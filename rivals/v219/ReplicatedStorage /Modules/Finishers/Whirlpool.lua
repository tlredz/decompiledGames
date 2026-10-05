local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Spring = require(ReplicatedStorage.Modules.Spring)
local object = setmetatable({}, Ragdoll)
object.__index = object

function object.new(...)
	local self = setmetatable(Ragdoll.new(...), object)
	self:_Init()
	return self
end

function object:PlayServer(...)
	Ragdoll.PlayServer(self, ...)
	self:_AnchorModel(0, false)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local position = rootPart.Position
	local bodyPosition = Instance.new("BodyPosition")
	bodyPosition.MaxForce = createVector(0, 100000, 0)
	bodyPosition.Position = position
	bodyPosition.Parent = rootPart
	table.insert(self._destroy_these, bodyPosition)
	local attachment = Instance.new("Attachment")
	attachment.Parent = rootPart
	table.insert(self._destroy_these, attachment)
	local vectorForce = Instance.new("VectorForce")
	vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
	vectorForce.Attachment0 = attachment
	vectorForce.Parent = rootPart
	table.insert(self._destroy_these, vectorForce)
	table.insert(self._connections, RunService.Heartbeat:Connect(function()
		local cframe = CFrame.new(rootPart.Position * createVector(1, 0, 1), position * createVector(1, 0, 1))

		if cframe ~= cframe then
			cframe = CFrame.new(createVector(0, 0, 0), (Random.new():NextUnitVector() * createVector(1, 0, 1)).Unit)
		end

		local v = (cframe.RightVector * 0.15 + cframe.LookVector) * 5000
		vectorForce.Force = v.Unit * math.min(v.Magnitude, 5000)
	end))
end

function object:PlayClient(...)
	Ragdoll.PlayClient(self, ...)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local position = rootPart.Position
	local clone = script.Model:Clone()
	clone.Parent = self._subject
	table.insert(self._destroy_these, clone)
	local _GetObjects = self:_GetObjects(true)
	local v = Spring.new(rootPart.Position, 1, 2)
	table.insert(self._connections, RunService.RenderStepped:Connect(function()
		v.Target = self:_GetGroundPosition(position, _GetObjects)
		clone:PivotTo(CFrame.new(v.Value.X, v.Target.Y, v.Value.Z))
	end))
	self:CreateSound("rbxassetid://115011821762260", 1.25, 1 + 0.1 * math.random(), nil, true, 5)
	self:CreateSound("rbxassetid://138046245903208", 0.375, 1 + 0.1 * math.random(), nil, true, 5)
	wait(2)
	Utility:RenderstepForLoop(0, 100, 0.5, function(p)
		local localTransparencyModifier = 1 - (1 - p / 100) ^ 3

		for _, part in pairs(self:_GetObjects(true)) do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = localTransparencyModifier
			end
		end
	end)
end

function object:_Init() end

return object