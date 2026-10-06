local CollectionService = game:GetService("CollectionService")
game:GetService("Players")
local RigTypes = require(script.RigTypes)

local function ragdoll(folder, instance)
	assert(instance:IsDescendantOf(folder))

	if CollectionService:HasTag(folder, "__Ragdoll_Active") then
		return
	end

	CollectionService:AddTag(folder, "__Ragdoll_Active")
	instance:ChangeState(Enum.HumanoidStateType.Physics)
	local attachments = RigTypes.getAttachments(folder, instance.RigType)

	for childName, attachment in pairs(attachments) do
		local child = folder:FindFirstChild(childName)

		if not child then
			continue
		end

		local ballSocketConstraint = Instance.new("BallSocketConstraint")
		ballSocketConstraint.Name = "RagdollBallSocketConstraint"
		ballSocketConstraint.Attachment0 = attachment.attachment0
		ballSocketConstraint.Attachment1 = attachment.attachment1
		ballSocketConstraint.LimitsEnabled = true
		ballSocketConstraint.UpperAngle = attachment.limits.UpperAngle
		ballSocketConstraint.TwistLimitsEnabled = true
		ballSocketConstraint.TwistLowerAngle = attachment.limits.TwistLowerAngle
		ballSocketConstraint.TwistUpperAngle = attachment.limits.TwistUpperAngle
		ballSocketConstraint.Parent = child
	end

	local noCollisions = RigTypes.getNoCollisions(folder, instance.RigType)

	for _, noCollision in pairs(noCollisions) do
		local noCollisionConstraint = Instance.new("NoCollisionConstraint")
		noCollisionConstraint.Name = "RagdollNoCollisionConstraint"
		noCollisionConstraint.Part0 = noCollision[1]
		noCollisionConstraint.Part1 = noCollision[2]
		noCollisionConstraint.Parent = noCollision[1]
	end

	for _, motor6D in pairs(folder:GetDescendants()) do
		if motor6D:IsA("Motor6D") then
			motor6D:Destroy()
		end
	end
end

return ragdoll