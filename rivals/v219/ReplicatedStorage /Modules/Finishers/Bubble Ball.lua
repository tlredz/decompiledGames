local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Ragdoll = require(ReplicatedStorage.Modules.Finishers.Ragdoll)
local CollisionsService = CONSTANTS.IS_SERVER and require(ServerStorage.Services.CollisionsService)
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

	if not self._is_humanoid then
		return
	end

	local clone = script.Model:Clone()
	clone.Hitbox.CanCollide = false
	clone.Hitbox.Anchored = true
	clone:PivotTo(self._subject.RootPart.CFrame * CFrame.Angles(
		math.random() * 3.141592653589793 * 2,
		math.random() * 3.141592653589793 * 2,
		math.random() * 3.141592653589793 * 2
	))
	clone.Parent = self._subject
	table.insert(self._destroy_these, clone)

	for _, childName in pairs({
		"RightHand",
		"RightFoot",
		"LeftHand",
		"LeftFoot"
	}) do
		local child = self._subject.Parent and self._subject.Parent:FindFirstChild(childName)

		if not child then
			continue
		end

		local attachment = Instance.new("Attachment")
		attachment.Parent = child
		local alignPosition = Instance.new("AlignPosition")
		alignPosition.MaxForce = 100000
		alignPosition.Responsiveness = 25
		alignPosition.Attachment0 = attachment
		alignPosition.Attachment1 = clone.Hitbox[childName]
		alignPosition.Parent = attachment
		local alignOrientation = Instance.new("AlignOrientation")
		alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
		alignOrientation.Attachment0 = attachment
		alignOrientation.CFrame = child.CFrame
		alignOrientation.Parent = attachment
	end

	CollisionsService:SetDescendants(self._subject.Parent, "OnlyMap")
	clone.Hitbox.CanCollide = true
	clone.Hitbox.Anchored = false
	clone.Hitbox:SetNetworkOwner(nil)
	clone.Hitbox.AssemblyLinearVelocity = Random.new():NextUnitVector() * (24 + 8 * math.random())
end

function object:PlayClient(...)
	Ragdoll.PlayClient(self, ...)
	self:CreateSound(
		"rbxassetid://70645035845566",
		1,
		1 + 0.1 * math.random(),
		self._is_humanoid and self._subject.RootPart or self._subject,
		true,
		10
	)
end

function object:_Init() end

return object