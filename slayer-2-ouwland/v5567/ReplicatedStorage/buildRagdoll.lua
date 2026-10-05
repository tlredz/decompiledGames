local buildConstraints = require(script:WaitForChild("buildConstraints"))
local buildCollisionFilters = require(script:WaitForChild("buildCollisionFilters"))

function buildAttachmentMap(instance)
	local result = {}

	for _, part in pairs(instance:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		for _, attachment in pairs(part:GetChildren()) do
			if not attachment:IsA("Attachment") then
				continue
			end

			local match = attachment.Name:match("^(.+)RigAttachment$")
			local child

			if match then
				child = attachment.Parent:FindFirstChild(match) or nil
			end

			if child then
				result[attachment.Name] = {
					Joint = child,
					Attachment0 = child.Part0[attachment.Name],
					Attachment1 = child.Part1[attachment.Name]
				}
			end
		end
	end

	return result
end

return function(instance)
	local parent = instance.Parent
	instance.BreakJointsOnDeath = false
	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		humanoidRootPart.CanCollide = false
	end

	local attachmentMap = buildAttachmentMap(parent)
	local constraints = buildConstraints(attachmentMap)
	local collisionFilters = buildCollisionFilters(attachmentMap, parent.PrimaryPart)
	collisionFilters.Parent = constraints
	constraints.Parent = parent
	local CollectionService = game:GetService("CollectionService")
	CollectionService:AddTag(instance, "Ragdoll")
end