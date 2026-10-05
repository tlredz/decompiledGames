return function(parent, p: number, color: Color3, p2: number)
	local attachment = Instance.new("Attachment")
	attachment.Position = Vector3.new(0, p, 0)
	attachment.Parent = parent
	local attachment2 = Instance.new("Attachment")
	attachment2.Position = Vector3.new(0, -p, 0)
	attachment2.Parent = parent
	local trail = Instance.new("Trail")
	trail.FaceCamera = true
	trail.LightInfluence = 0
	trail.Lifetime = 0.55
	trail.Attachment0 = attachment
	trail.Attachment1 = attachment2
	trail.Brightness = 2.35
	trail.Color = ColorSequence.new(color or Color3.fromRGB(108, 168, 255))
	trail.WidthScale = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.5, 1),
		NumberSequenceKeypoint.new(1, 0)
	})
	trail.Transparency = NumberSequence.new(p2)
	trail.Parent = parent
	return trail
end