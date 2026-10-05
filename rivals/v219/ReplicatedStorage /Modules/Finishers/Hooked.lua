local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Finisher = require(ReplicatedStorage.Modules.Finisher)
local object = setmetatable({}, Finisher)
object.__index = object

function object.new(...)
	local self = setmetatable(Finisher.new(...), object)
	self:_Init()
	return self
end

function object:PlayServer(...)
	self:_Ragdoll()
	self:_AnchorModel(0, false)
	self:_AnchorModel(6.2)
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	local attachment = Instance.new("Attachment")
	attachment.Parent = rootPart
	table.insert(self._destroy_these, attachment)
	local clone = script.Model:Clone()
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)
	local cframe = CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0)
	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		clone:PivotTo(CFrame.new(rootPart.Position) * cframe - createVector(0, 1.5, 0))
	end)
	table.insert(self._connections, heartbeatConnection)
	local success, result = pcall(clone.AnimationController.LoadAnimation, clone.AnimationController, clone.Animation)

	if success then
		result:Play(0)
		self:CreateSound("rbxassetid://8971407111", 1, 1 + 0.1 * math.random(), nil, true, 5)
		wait(1.95)
		self:CreateSound("rbxassetid://8971407217", 1, 1 + 0.1 * math.random(), nil, true, 5)
		heartbeatConnection:Disconnect()
		attachment.WorldCFrame = clone.Hook.Attachment.WorldCFrame
		local alignPosition = Instance.new("AlignPosition")
		alignPosition.RigidityEnabled = true
		alignPosition.Attachment1 = clone.Hook.Attachment
		alignPosition.Attachment0 = attachment
		alignPosition.Parent = clone
		table.insert(self._destroy_these, alignPosition)
		wait(0.75)
		self:CreateSound("rbxassetid://8971407314", 1, 1 + 0.1 * math.random(), nil, true, 5)
		wait(0.5)
		alignPosition:Destroy()
		attachment:Destroy()
		self:_AnchorModel()
	end

	heartbeatConnection:Disconnect()
	clone:Destroy()
end

function object:_Init() end

return object