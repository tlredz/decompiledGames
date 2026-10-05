local TweenService = game:GetService("TweenService")
local JointOffset = {}
JointOffset.__index = JointOffset

function JointOffset.new(instance, instance2, childName: string)
	local object = setmetatable({
		JointType = instance.ClassName,
		Destroyed = false,
		Motor = instance,
		Part0 = instance2,
		AttachmentCFrame = CFrame.identity,
		ActiveTweens = {},
		EventConnections = {}
	}, JointOffset)
	table.insert(object.EventConnections, instance2.ChildAdded:Connect(function(attachment)
		if attachment.Name ~= childName or not attachment:IsA("Attachment") then
			return
		end

		object:ConnectAttachment(attachment)
	end))
	object:ConnectAttachment((instance2:FindFirstChild(childName)))
	return object
end

function JointOffset:ConnectAttachment(startAttachment)
	if not startAttachment then
		return
	end

	self.AttachmentCFrame = startAttachment.CFrame
	self.StartAttachment = startAttachment
	table.insert(self.EventConnections, self.Part0:GetPropertyChangedSignal("Size"):Connect(function()
		if self.StartAttachment ~= startAttachment then
			return
		end

		self.AttachmentCFrame = startAttachment.CFrame
	end))
end

function JointOffset:SetProperty(p2, p3: string, p4, p5)
	if self.Destroyed then
		return
	end

	if not p5 then
		p2[p3] = p4
		return
	end

	if not self.ActiveTweens[p2] then
		self.ActiveTweens[p2] = {}
	end

	local tween = TweenService:Create(p2, p5, {
		[p3] = p4
	})
	tween:Play()
	self.ActiveTweens[p2][p3] = tween
end

function JointOffset:SetOffset(cframe: CFrame, p)
	if self.JointType == "Motor6D" then
		self:SetProperty(self.Motor, "C0", self.AttachmentCFrame * cframe, p)
	elseif self.JointType == "AnimationConstraint" and self.StartAttachment then
		self:SetProperty(self.StartAttachment, "CFrame", self.AttachmentCFrame * cframe, p)
	end
end

function JointOffset:Destroy()
	self.Destroyed = true

	for _, eventConnection in self.EventConnections do
		eventConnection:Disconnect()
	end

	for _, activeTween in self.ActiveTweens do
		for _, v in activeTween do
			v:Cancel()
		end
	end

	self.ActiveTweens = {}

	if self.Motor:IsA("Motor6D") then
		self.Motor.C0 = self.AttachmentCFrame
	elseif self.Motor:IsA("AnimationConstraint") and self.StartAttachment then
		self.StartAttachment.CFrame = self.AttachmentCFrame
	end
end

return JointOffset