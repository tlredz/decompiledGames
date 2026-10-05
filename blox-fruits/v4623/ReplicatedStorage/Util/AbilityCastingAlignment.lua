return function(instance, items, duration)
	local primaryPart = instance.PrimaryPart

	if not primaryPart then
		return
	end

	local attachment = primaryPart:FindFirstChildOfClass("Attachment")
	local alignPosition = Instance.new("AlignPosition")
	alignPosition.ApplyAtCenterOfMass = true
	alignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPosition.RigidityEnabled = true
	alignPosition.Enabled = true
	alignPosition.Attachment0 = attachment
	alignPosition.Parent = primaryPart

	for k, item in pairs(items) do
		alignPosition[k] = item
	end

	if duration then
		task.delay(duration, alignPosition.Destroy, alignPosition)
	end

	return alignPosition
end