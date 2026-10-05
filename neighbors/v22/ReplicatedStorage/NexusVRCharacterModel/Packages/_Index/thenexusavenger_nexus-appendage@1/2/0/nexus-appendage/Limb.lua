local Limb = {}
Limb.__index = Limb

function Limb.new()
	return (setmetatable({}, Limb))
end

function Limb.GetAttachmentCFrame(_, instance, childName: string)
	local child = instance:FindFirstChild(childName)
	return child and child.CFrame or CFrame.identity
end

return Limb