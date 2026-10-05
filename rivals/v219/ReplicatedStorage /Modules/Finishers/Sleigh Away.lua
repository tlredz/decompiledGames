local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Finisher = require(ReplicatedStorage.Modules.Finisher)
local object = setmetatable({}, Finisher)
object.__index = object

function object.new(...)
	local self = setmetatable(Finisher.new(...), object)
	self:_Init()
	return self
end

function object:PlayServer()
	local rootPart = self._is_humanoid and self._subject.RootPart or self._subject
	rootPart.Anchored = true

	if self._is_humanoid then
		local animation = Instance.new("Animation")
		animation.AnimationId = "rbxassetid://4769412289"
		local success, result = pcall(self._subject.LoadAnimation, self._subject, animation)

		if success then
			result:Play(0)
			result:AdjustSpeed(0.16666666666666666)
		end
	end

	local attachment = Instance.new("Attachment")
	attachment.Parent = rootPart
	table.insert(self._destroy_these, attachment)
	local clone = script.Model:Clone()
	clone:PivotTo(CFrame.new(rootPart.Position) * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0))
	clone.Parent = workspace
	table.insert(self._destroy_these, clone)
	local success, result = pcall(clone.AnimationController.LoadAnimation, clone.AnimationController, clone.Animation)

	if success then
		result:Play(0)
		self:CreateSound("rbxassetid://70986468462566", 1.5, 1 + 0.1 * math.random(), clone.HumanoidRootPart, true, 5)
		wait(0.3)
		local collisionGroupsByPart = {}

		for _, part in pairs(self:_GetObjects(true)) do
			if not part:IsA("BasePart") then
				continue
			end

			collisionGroupsByPart[part] = part.CollisionGroup
			part.CollisionGroup = "Noclip"
		end

		rootPart.Anchored = false
		self:_Ragdoll()
		local alignPosition = Instance.new("AlignPosition")
		alignPosition.RigidityEnabled = true
		alignPosition.ApplyAtCenterOfMass = true
		alignPosition.Attachment1 = clone.Broomm.Attachment
		alignPosition.Attachment0 = attachment
		alignPosition.Parent = clone
		table.insert(self._destroy_these, alignPosition)
		wait(1.9)
		wait(0.75)
		alignPosition:Destroy()
		self:_AnchorModel()

		for k, collisionGroup in pairs(collisionGroupsByPart) do
			k.CollisionGroup = collisionGroup
		end

		if result.IsPlaying then
			result.Stopped:Wait()
		end

		clone:Destroy()
		wait(3)
	end
end

function object:_Init() end

return object