local AttachmentPair = {}
AttachmentPair.__index = AttachmentPair
AttachmentPair.VERSION = 1.1
local model = Instance.new("Model", workspace.Terrain)
model.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
local part = nil

function AttachmentPair.new(cframe: CFrame?, cframe2: CFrame?)
	local self = setmetatable({}, AttachmentPair)
	local _generateAttachments, attachment = self:_generateAttachments(cframe, cframe2)
	self.attachment0 = _generateAttachments
	self.attachment1 = attachment
	self.pseudoBasePartCFrame = CFrame.new(0, 0, 0)
	return self
end

function AttachmentPair.hookUp(p, instance)
	if instance.ClassName == "Trail" or instance.ClassName == "Beam" then
		local attachment0 = p.attachment0
		local attachment1 = p.attachment1
		instance.Attachment0 = attachment0
		instance.Attachment1 = attachment1
	end

	instance.Parent = p.attachment0
end

function AttachmentPair:setRelativeCFrame(pseudoBasePartCFrame: CFrame)
	local v = pseudoBasePartCFrame * self.pseudoBasePartCFrame:inverse()
	self.attachment0.WorldCFrame = v * self.attachment0.WorldCFrame
	self.attachment1.WorldCFrame = v * self.attachment1.WorldCFrame
	self.pseudoBasePartCFrame = pseudoBasePartCFrame
end

function AttachmentPair.destroy(p)
	if p.attachment0 ~= nil and p.attachment0.Parent ~= nil then
		p.attachment0:Destroy()
	end

	if p.attachment1 ~= nil and p.attachment1.Parent ~= nil then
		p.attachment1:Destroy()
	end
end

function AttachmentPair:_generateAttachments(cframe: CFrame?, cframe2: CFrame?)
	local cFrame = cframe or CFrame.new(0, 0, 0)
	local cFrame2 = cframe2 or CFrame.new(0, 0, 0)
	local attachment = Instance.new("Attachment")
	local attachment2 = Instance.new("Attachment")
	attachment.CFrame = cFrame
	attachment2.CFrame = cFrame2
	local _getAttachmentContainer = self:_getAttachmentContainer()
	attachment.Parent = _getAttachmentContainer
	attachment2.Parent = _getAttachmentContainer
	return attachment, attachment2
end

function AttachmentPair:_replaceNewAttachmentContainer()
	part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Locked = true
	part.Transparency = 1
	part.Name = "AttachmentPairContainer"
	part.CFrame = CFrame.new(0, 0, 0)
	part.Parent = model
	return part
end

function AttachmentPair:_getAttachmentContainer()
	if part == nil or part.Parent == nil then
		return AttachmentPair:_replaceNewAttachmentContainer()
	end

	return part
end

return AttachmentPair